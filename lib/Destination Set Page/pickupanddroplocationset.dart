import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vistaride/Cab%20Selection%20Page/cabcategoryselectpage.dart';
import 'package:vistaride/Environment%20Files/.env.dart';

class Pickupandroplocation extends StatefulWidget {
  const Pickupandroplocation({super.key});

  @override
  State<Pickupandroplocation> createState() => _PickupandroplocationState();
}

class _PickupandroplocationState extends State<Pickupandroplocation> {
  String? location = '';
  late GoogleMapController mapController;
  LatLng _currentLocation = LatLng(22.7199572, -88.4663679);  // Default location
  Set<Marker> _markers = {};
  String locationName = '';
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _profilePicController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  bool isLikedLocation = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String profilePic = '';
  List<String> citySelectedList = [];
  Future<void> getservicablecities()async{
    final prefs=await SharedPreferences.getInstance();
    setState(() {
      citySelectedList=prefs.getStringList('Cities Available')??[];
    });
    if (kDebugMode) {
      print("Fetched Cities ${citySelectedList}");
    }
  }
  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    initialisesharedpref();
    getservicablecities();
  }

  // Fetch current location
  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    List<Placemark> placemarks =
    await placemarkFromCoordinates(position.latitude, position.longitude);

    if (placemarks.isNotEmpty) {
      Placemark placemark = placemarks[0];
      setState(() {
        locationName =
        '${placemark.street}, ${placemark.thoroughfare}, ${placemark.subLocality}, '
            '${placemark.locality}, ${placemark.administrativeArea}, ${placemark.postalCode}, ${placemark.country}';
        _locationController.text = locationName;
      });
    }

    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
      _markers.add(Marker(
        markerId: MarkerId('currentLocation'),
        position: _currentLocation,
        infoWindow: InfoWindow(title: 'Your Location'),
      ));
    });

    mapController.animateCamera(
      CameraUpdate.newLatLng(_currentLocation),
    );
  }

  // Initialize shared preferences
  Future<void> initialisesharedpref() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      location = prefs.getString('location');
    });
  }

  // Handle map creation
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  // Handle the item click from Google Places API
  Future<void> _onPlaceSelected(Prediction prediction) async {
    setState(() {
      _destinationController.text = prediction.description!;
    });

    // Save the dropoff location to shared preferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('dropoff', prediction.description!);

    // Get latitude and longitude for dropoff address
    List<Location> locations = await locationFromAddress(prediction.description!);

    if (locations.isNotEmpty) {
      double latitude = locations[0].latitude;
      double longitude = locations[0].longitude;

      // Save the dropoff coordinates in shared preferences
      prefs.setString('dropofflatitude', latitude.toString());
      prefs.setString('dropofflongitude', longitude.toString());

      if (kDebugMode) {
        print('Dropoff Latitude: $latitude');
        print('Dropoff Longitude: $longitude');
      }
      Navigator.push(context,MaterialPageRoute(builder: (context) => CabSelectAndPrice(
        ispromoapplied: false,
      ),));
      // Update the map and markers
      LatLng newLocation = LatLng(latitude, longitude);
      setState(() {
        _currentLocation = newLocation;  // Update the current location to dropoff
        _markers.add(Marker(
          markerId: MarkerId('dropoff'),
          position: newLocation,
          infoWindow: InfoWindow(title: prediction.description),
        ));
      });

      // Move the camera to the dropoff location
      mapController.animateCamera(
        CameraUpdate.newLatLng(newLocation),
      );

      // Optionally navigate to the next screen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CabSelectAndPrice(
          ispromoapplied: false,
        )),
      );
    } else {
      print("Could not find coordinates for the selected place.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
        ),
        title: Text(
          'Destination',
          style: GoogleFonts.poppins(
              color: Colors.black, fontWeight: FontWeight.w600, fontSize: 18),
        ),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 15),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: 150,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      offset: const Offset(4, 4),
                      blurRadius: 0.5,
                      spreadRadius: 0.5,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 5,
                          backgroundColor: Colors.green,
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 20),
                            child: Container(
                              height: 45,
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.all(Radius.circular(10)),
                                border: Border.all(width: 0.5, color: Colors.grey),
                              ),
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: Text(
                                    location!,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: GoogleFonts.poppins(
                                      color: Colors.black,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 8,
                          backgroundColor: Colors.red,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            height: 45,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.transparent),
                              borderRadius: const BorderRadius.all(Radius.circular(10)),
                            ),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 20),
                                  child: GooglePlaceAutoCompleteTextField(
                                    textEditingController: _destinationController,
                                    googleAPIKey: Environment.GoogleMapsAPI,
                                    inputDecoration: InputDecoration(
                                      hintText: '  Search Destination',
                                      hintStyle: GoogleFonts.poppins(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w300,
                                      ),
                                      border: InputBorder.none,
                                    ),
                                    itemClick: _onPlaceSelected,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
