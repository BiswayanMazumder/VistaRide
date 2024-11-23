import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:vistaride/Environment%20Files/.env.dart';

class CabSelectAndPrice extends StatefulWidget {
  const CabSelectAndPrice({super.key});

  @override
  State<CabSelectAndPrice> createState() => _CabSelectAndPriceState();
}

class _CabSelectAndPriceState extends State<CabSelectAndPrice> {
  late GoogleMapController mapController;
  Set<Marker> _markers = {};
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
  }

  String Time = '';
  String DistanceTravel = '';
  // Fetch route and travel time using the Google Directions API
  Future<void> _fetchRoute() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

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

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data['routes'].isNotEmpty) {
        final duration = data['routes'][0]['legs'][0]['duration']['text'];
        final distance = data['routes'][0]['legs'][0]['distance']['text'];
        setState(() {
          Time = duration;
          DistanceTravel = distance;
        });
        if (kDebugMode) {
          print('Estimated travel time: $Time');
        }
        if (kDebugMode) {
          print('Estimated distance: $DistanceTravel');
        }
      }
    } else {
      print('Failed to load route');
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    setState(() {
      // Add updated markers to the map
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
    });
  }

  List carcategoryimages = [
    'https://olawebcdn.com/images/v1/cabs/sl/ic_mini.png',
    'https://olawebcdn.com/images/v1/cabs/sl/ic_prime.png',
    'https://olawebcdn.com/images/v1/cabs/sl/ic_suv.png',
    'https://olawebcdn.com/images/v1/cabs/sl/ic_kp.png'
  ];
  List cabcategorynames = ['Mini', 'Prime', 'SUV', 'Non AC Taxi'];
  List cabcategorydescription = ['Highly Discounted fare', 'Spacious sedans, top drivers', 'Spacious SUVs', ''];
  List cabpricesmultiplier=[36,40,65,15];
  int _selectedindex = 0;
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
            onMapCreated: _onMapCreated,
            markers: _markers,
            polylines: {
              Polyline(
                visible: true,
                geodesic: true,
                polylineId: PolylineId('route'),
                points: [
                  _pickupLocation,
                  _dropoffLocation,
                ],
                color: Colors.black,
                width: 4,
              ),
            },
          ),
          Positioned(
              bottom: 0,
              child: Container(
                width: MediaQuery.sizeOf(context).width,
                color: Colors.white,
                height: 300,
                child:ListView.builder(
                  itemCount: carcategoryimages.length,
                  itemBuilder: (context, index) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 20,bottom: 50),
                          child: Row(
                            children: [
                              Image(image: NetworkImage(carcategoryimages[index])),
                              const SizedBox(
                                width: 20,
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(cabcategorynames[index],style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600
                                  ),),
                                  Text(cabcategorydescription[index],style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w300,
                                    color: Colors.grey,
                                    fontSize: 11
                                  ),),
                                ],
                              ),
                              const Spacer(),
                              Text(
                                '₹${(double.parse(DistanceTravel.replaceAll(RegExp(r'[^0-9.]'), '')).floor() * cabpricesmultiplier[index])}',
                                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(
                                width: 20,
                              )
                            ],
                          ),
                        )
                      ],
                    );
                  },)
              ),
            
          )
        ],
      ),
    );
  }
}
