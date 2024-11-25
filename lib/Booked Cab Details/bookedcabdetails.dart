import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
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
    // Ensure ride details are fetched before attempting to fetch the route
    await fetchridedetails();

    if (pickuplong == 0 || pickuplat == 0 || droplong == 0 || droplat == 0) {
      print('Invalid coordinates from Firestore.');
      return;
    }

    // Update pickup and dropoff locations
    setState(() {
      _pickupLocation = LatLng(pickuplat, pickuplong);
      _dropoffLocation = LatLng(droplat, droplong);
    });

    final String apiKey =
        Environment.GoogleMapsAPI; // Replace with your API key
    final String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${_pickupLocation.latitude},${_pickupLocation.longitude}&destination=${_dropoffLocation.latitude},${_dropoffLocation.longitude}&key=$apiKey';

    if (kDebugMode) {
      print('URL $url');
    }

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data['routes'].isNotEmpty) {
        final duration = data['routes'][0]['legs'][0]['duration']['text'];
        final distance = data['routes'][0]['legs'][0]['distance']['text'];

        // Decode the polyline
        String encodedPolyline =
            data['routes'][0]['overview_polyline']['points'];
        List<LatLng> polylinePoints = _decodePolyline(encodedPolyline);

        setState(() {
          Time = duration;
          DistanceTravel = distance;

          // Add markers for pickup and dropoff
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

          // Add polyline for the route
          _polylines.add(Polyline(
            polylineId: PolylineId('route'),
            visible: true,
            geodesic: true,
            points: polylinePoints,
            color: Colors.black, // Line color
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
  String driverid = '';
  String drivername = '';
  String driverprofilephoto = '';
  String carnumber = '';
  String carphoto = '';
  String carname = '';
  double rating = 0;
  int rideotp = 0;
  String phonenumber = '';
  double pickuplong = 0;
  double pickuplat = 0;
  double droplong = 0;
  String pickuploc = '';
  String droploc = '';
  double droplat = 0;
  Future<void> fetchridedetails() async {
    final prefs = await SharedPreferences.getInstance();
    final docsnap = await _firestore
        .collection('Ride Details')
        .doc(prefs.getString('Booking ID'))
        .get();
    if (docsnap.exists) {
      setState(() {
        ridestarted = docsnap.data()?['Ride Accepted'];
        driverid = docsnap.data()?['Driver ID'];
        rideotp = docsnap.data()?['Ride OTP'];
        pickuplong = docsnap.data()?['Pick Longitude'];
        pickuplat = docsnap.data()?['Pickup Latitude'];
        droplat = docsnap.data()?['Drop Latitude'];
        droplong = docsnap.data()?['Drop Longitude'];
        pickuploc = docsnap.data()?['Pickup Location'];
        droploc = docsnap.data()?['Drop Location'];
      });
    }
    print('OTP $rideotp');
    final Docsnap = await _firestore
        .collection('VistaRide Driver Details')
        .doc(driverid)
        .get();
    if (Docsnap.exists) {
      setState(() {
        drivername = Docsnap.data()?['Name'];
        driverprofilephoto = Docsnap.data()?['Profile Picture'];
        carname = Docsnap.data()?['Car Name'];
        carphoto = Docsnap.data()?['Car Photo'];
        carnumber = Docsnap.data()?['Car Number Plate'];
        rating = Docsnap.data()?['Rating'];
        phonenumber = Docsnap.data()?['Contact Number'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _pickupLocation,
              zoom: 11.0,
            ),
            buildingsEnabled: true,
            zoomGesturesEnabled: true,
            trafficEnabled: true,
            onMapCreated: _onMapCreated,
            markers: _markers,
            polylines: _polylines, // Display the polyline here
          ),
          Positioned(
            bottom: 320,
            left: 20,
            child: Container(
              height: 70,
              width: 85,
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              child: Center(
                child: Column(
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      '$rideotp',
                      style: GoogleFonts.poppins(
                          color: Colors.purple,
                          fontWeight: FontWeight.w600,
                          fontSize: 18),
                    ),
                    Text(
                      'Start OTP',
                      style: GoogleFonts.poppins(
                          color: Colors.grey, fontWeight: FontWeight.w300),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
              bottom: 0,
              child: Container(
                height: 300,
                width: MediaQuery.sizeOf(context).width,
                color: Colors.white,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        'Your ride is confirmed.',
                        style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Divider(
                        color: Colors.grey,
                        thickness: 0.5,
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Row(
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  carnumber,
                                  style: GoogleFonts.poppins(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                Text(
                                  carname,
                                  style: GoogleFonts.poppins(
                                      color: Colors.grey,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                Text(
                                  drivername,
                                  style: GoogleFonts.poppins(
                                      color: Colors.grey,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            const Spacer(),
                            CircleAvatar(
                              radius: 28,
                              backgroundColor: Colors.white,
                              backgroundImage:NetworkImage(driverprofilephoto) ,
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ))
        ],
      ),
    );
  }
}
