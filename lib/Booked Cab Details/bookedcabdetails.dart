import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Environment Files/.env.dart';

class BookedCabDetails extends StatefulWidget {
  const BookedCabDetails({super.key});

  @override
  State<BookedCabDetails> createState() => _BookedCabDetailsState();
}

class _BookedCabDetailsState extends State<BookedCabDetails> {
  late GoogleMapController mapController;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {}; // Set to hold polyline
  LatLng _pickupLocation =
      LatLng(22.7199572, 88.4663679); // Default pickup location (Kolkata)
  LatLng _dropoffLocation = LatLng(
      22.582077, 88.368420); // Default drop-off location (Sealdah Station)
  String? _pickupAddress;
  String? _dropoffAddress;

  @override
  void initState() {
    super.initState();
    _fetchRoute();
    fetchridedetails();
  }

  String Time = '';
  String? pickup;
  String? dropoffloc;
  String DistanceTravel = '';

  // Fetch route and travel time using the Google Directions API
  Future<void> _fetchRoute() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      pickup = prefs.getString('location');
      dropoffloc = prefs.getString('dropoff');
    });

    // Retrieve coordinates as double for pickup and dropoff
    double? pickuplongitude = prefs.getDouble('location longitude');
    double? pickuplatitude = prefs.getDouble('location latitude');

    String? dropofflatitudeStr = prefs.getString('dropofflatitude');
    String? dropofflongitudeStr = prefs.getString('dropofflongitude');

    // Check if drop-off coordinates are retrieved as String and parse them into double
    double dropofflatitude =
        dropofflatitudeStr != null ? double.parse(dropofflatitudeStr) : 0.0;
    double dropofflongitude =
        dropofflongitudeStr != null ? double.parse(dropofflongitudeStr) : 0.0;

    // Check if valid data is present, if not use default
    if (pickuplongitude == null ||
        pickuplatitude == null ||
        dropofflatitude == 0.0 ||
        dropofflongitude == 0.0) {
      print('Invalid coordinates, using default.');
      return;
    }

    // Update pickup and dropoff locations
    setState(() {
      _pickupLocation = LatLng(pickuplatitude, pickuplongitude);
      _dropoffLocation = LatLng(dropofflatitude, dropofflongitude);
    });

    final String apiKey =
        Environment.GoogleMapsAPI; // Replace with your API key
    final String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=$pickuplatitude,$pickuplongitude&destination=$dropofflatitude,$dropofflongitude&key=$apiKey';
    if (kDebugMode) {
      print('URL $url');
    }
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data['routes'].isNotEmpty) {
        final duration = data['routes'][0]['legs'][0]['duration']['text'];
        final distance = data['routes'][0]['legs'][0]['distance']['text'];

        // Get polyline for the route
        String encodedPolyline =
            data['routes'][0]['overview_polyline']['points'];
        List<LatLng> polylinePoints = _decodePolyline(encodedPolyline);

        setState(() {
          Time = duration;
          DistanceTravel = distance;
          _markers.add(Marker(
            markerId: MarkerId('pickup'),
            position: _pickupLocation,
            infoWindow: InfoWindow(
                title: 'Pickup Location',
                snippet:
                    'Latitude: ${_pickupLocation.latitude}, Longitude: ${_pickupLocation.longitude}'),
          ));
          _markers.add(Marker(
            markerId: MarkerId('dropoff'),
            position: _dropoffLocation,
            infoWindow: InfoWindow(
                title: 'Drop-off Location',
                snippet:
                    'Latitude: ${_dropoffLocation.latitude}, Longitude: ${_dropoffLocation.longitude}'),
          ));

          // Add polyline to the map
          _polylines.add(Polyline(
            polylineId: PolylineId('route'),
            visible: true,
            geodesic: true,
            points: polylinePoints,
            color: Colors.black, // Line color (black in this case)
            width: 4,
          ));
        });

        if (kDebugMode) {
          print('Estimated travel time: $Time');
          print('Estimated distance: $DistanceTravel');
        }
      }
    } else {
      print('Failed to load route');
    }
  }

  // Method to decode polyline from the Directions API response
  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> polyline = [];
    int index = 0;
    int len = encoded.length;
    int lat = 0;
    int lng = 0;

    while (index < len) {
      int shift = 0;
      int result = 0;
      int byte;
      do {
        byte = encoded.codeUnitAt(index) - 63;
        result |= (byte & 0x1f) << shift;
        shift += 5;
        index++;
      } while (byte >= 0x20);

      int dLat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dLat;

      shift = 0;
      result = 0;
      do {
        byte = encoded.codeUnitAt(index) - 63;
        result |= (byte & 0x1f) << shift;
        shift += 5;
        index++;
      } while (byte >= 0x20);

      int dLng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dLng;

      polyline.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return polyline;
  }

  Duration parseDuration(String durationString) {
    int hours = 0;
    int minutes = 0;

    // Regular expressions to extract hours and minutes from the string
    RegExp hourRegExp = RegExp(r'(\d+)\s*hour');
    RegExp minuteRegExp = RegExp(r'(\d+)\s*min');

    // Match the hours
    var hourMatch = hourRegExp.firstMatch(durationString);
    if (hourMatch != null) {
      hours = int.parse(hourMatch.group(1)!);
    }

    // Match the minutes
    var minuteMatch = minuteRegExp.firstMatch(durationString);
    if (minuteMatch != null) {
      minutes = int.parse(minuteMatch.group(1)!);
    }

    return Duration(hours: hours, minutes: minutes);
  }

  // Function to format a DateTime object into h:mm format
  String formatTime(DateTime time) {
    // Use DateFormat to display time as h:mm
    return DateFormat('H:mm a').format(time);
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  bool ridestarted = false;
  String drivername = '';
  String driverprofilephoto = '';
  Future<void> fetchridedetails() async {
    final prefs = await SharedPreferences.getInstance();
    final docsnap = await _firestore
        .collection('Ride Details')
        .doc(prefs.getString('Booking ID'))
        .get();
    if (docsnap.exists) {
      setState(() {
        ridestarted = docsnap.data()?['Ride Accepted'];
        drivername = docsnap.data()?['Driver Name'];
        driverprofilephoto = docsnap.data()?['Driver Photo'];
      });
    }
    print('Ride Started $drivername $driverprofilephoto');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _pickupLocation,
              zoom: 12.0,
            ),
            buildingsEnabled: true,
            zoomGesturesEnabled: true,
            trafficEnabled: true,
            onMapCreated: _onMapCreated,
            markers: _markers,
            polylines: _polylines, // Display the polyline here
          ),
          Positioned(
              bottom: 0,
              child: Container(
                height: 300,
                width: MediaQuery.sizeOf(context).width,
                color: Colors.white,
              ))
        ],
      ),
    );
  }
}
