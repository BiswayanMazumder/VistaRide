import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vistaride/Environment%20Files/.env.dart';

class Pickupandroplocation extends StatefulWidget {
  const Pickupandroplocation({super.key});

  @override
  State<Pickupandroplocation> createState() => _PickupandroplocationState();
}

class _PickupandroplocationState extends State<Pickupandroplocation> {
  String? location = '';
  late GoogleMapController mapController;
  LatLng _currentLocation = LatLng(22.7199572, -88.4663679);
  Set<Marker> _markers = {};
  String locationName = '';
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _profilePicController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  bool isLikedLocation = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String profilePic = '';

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    initialisesharedpref();
  }

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

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> initialisesharedpref() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      location = prefs.getString('location');
    });
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
                width: MediaQuery.sizeOf(context).width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2), // Shadow color with opacity
                      offset: Offset(4, 4), // Position of the shadow
                      blurRadius: 0.5, // How blurry the shadow is
                      spreadRadius: 0.5, // How much the shadow spreads
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 5,
                          backgroundColor: Colors.green,
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        Expanded(
                          child: Container(
                            height: 50,
                            width: MediaQuery.sizeOf(context).width,
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
                                  maxLines: 1, // Ensure the text does not exceed one line
                                  style: GoogleFonts.poppins(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 8,
                          backgroundColor: Colors.red,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.transparent),
                              borderRadius: const BorderRadius.all(Radius.circular(10)),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                GooglePlaceAutoCompleteTextField(
                                  textEditingController: _destinationController,
                                  googleAPIKey: Environment.GoogleMapsAPI, // Use your actual Google API Key
                                  inputDecoration: InputDecoration(
                                    hintText: '  Search Destination',
                                    hintStyle: GoogleFonts.poppins(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w300,
                                    ),
                                    // Ensure no border is applied to the text field
                                    border: InputBorder.none, // No border
                                    focusedBorder: InputBorder.none, // No border when focused
                                    enabledBorder: InputBorder.none, // No border when enabled
                                    disabledBorder: InputBorder.none, // No border when disabled
                                    filled: false, // Ensure no background color
                                  ),
                                  itemClick: (prediction) async {
                                    // Set the selected place's description in the TextField
                                    setState(() {
                                      _destinationController.text = prediction.description!;
                                    });
                                    final SharedPreferences prefs = await SharedPreferences.getInstance();
                                    prefs.setString('dropoff', _destinationController.text);
                                    if (kDebugMode) {
                                      print(prefs.getString('dropoff'));
                                    }
                                    // Fetch location coordinates when a suggestion is selected
                                    List<Location> locations = await locationFromAddress(
                                      prediction.description!,
                                    );
                                    if (locations.isNotEmpty) {
                                      LatLng newLocation = LatLng(
                                        locations[0].latitude,
                                        locations[0].longitude,
                                      );

                                      setState(() {
                                        _currentLocation = newLocation;
                                        _markers.add(Marker(
                                          markerId: MarkerId(prediction.description!),
                                          position: newLocation,
                                          infoWindow: InfoWindow(title: prediction.description),
                                        ));
                                      });

                                      mapController.animateCamera(
                                        CameraUpdate.newLatLng(newLocation),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        )
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
