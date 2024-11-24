import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_animation_progress_bar/simple_animation_progress_bar.dart';

class CabFinding extends StatefulWidget {
  const CabFinding({super.key});

  @override
  State<CabFinding> createState() => _CabFindingState();
}

class _CabFindingState extends State<CabFinding> with TickerProviderStateMixin {
  late GoogleMapController mapController;
  LatLng _currentLocation = const LatLng(22.7199572, 88.4663679);
  Set<Marker> _markers = {};
  String locationName = ''; // Store the name of the location
  final TextEditingController _locationcontroller = TextEditingController();
  bool islikedlocation = false;
  String? pickup;
  String? dropoff;
  Future<void> inititalisesharedpref() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      dropoff = prefs.getString('dropoff');
      pickup = prefs.getString('location');
    });
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String profilepic = '';

  // Animation controller for the ripple effect
  late AnimationController _rippleController;
  late Animation<double> _rippleAnimation;
  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    inititalisesharedpref();
    _timer = Timer.periodic(Duration(minutes: 1), _updateText);

    // Initialize the ripple animation
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(
        reverse:
            true); // Repeat and reverse the animation to simulate a ripple effect

    _rippleAnimation = Tween<double>(begin: 0, end: 50).animate(
      CurvedAnimation(
        parent: _rippleController,
        curve: Curves.easeInOut,
      ),
    );
  }

  // Function to update the current index and refresh the UI
  void _updateText(Timer timer) {
    if (currentIndex < bookingtexts.length - 1) {
      setState(() {
        currentIndex++;
      });
    }
  }

  // Function to get the current location using Geolocator
  Future<void> _getCurrentLocation() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    LocationPermission permission = await Geolocator.requestPermission();
    double? pickuplongitude = prefs.getDouble('location longitude');
    double? pickuplatitude = prefs.getDouble('location latitude');

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
            '${placemark.locality},${placemark.administrativeArea}, ${placemark.postalCode} , ${placemark.country}';
        _locationcontroller.text = locationName;
      });
    }

    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
      _markers.add(Marker(
        markerId: const MarkerId('currentLocation'),
        position: _currentLocation,
        infoWindow: const InfoWindow(title: 'Your Location'),
      ));
    });

    mapController.animateCamera(
      CameraUpdate.newLatLng(_currentLocation),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> _searchLocation(String location) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      List<Location> locations = await locationFromAddress(location);

      if (locations.isNotEmpty) {
        Location loc = locations[0];
        LatLng newLocation = LatLng(loc.latitude, loc.longitude);

        setState(() {
          _currentLocation = newLocation;
          _markers.clear();
          _markers.add(Marker(
            markerId: MarkerId('searchedLocation'),
            position: _currentLocation,
            infoWindow: InfoWindow(title: location),
          ));
        });

        mapController.animateCamera(
          CameraUpdate.newLatLng(_currentLocation),
        );
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Location not found")),
      );
    }
  }

  int currentIndex = 0;
  late Timer _timer;
  List bookingtexts = [
    'Contacting Drivers Nearby...',
    'Getting you the quickest ride to your destination',
    'Waiting for driver to accept',
    'Sent requests to more drivers...',
    'Still Waiting for driver...'
  ];
  List bookingimages = [
    'https://www.gm.com/content/dam/company/img/us/en/vehicle-safety/safety_periscope2_research3.gif',
    'https://i.pinimg.com/originals/af/ab/46/afab4635c7491943d71528a650e95673.gif',
    'https://i.giphy.com/D8EFNfzm0c1KZyoYgh.webp',
    'https://www.gm.com/content/dam/company/img/us/en/vehicle-safety/safety_periscope2_research3.gif',
    'https://www.gm.com/content/dam/company/img/us/en/vehicle-safety/safety_periscope2_research3.gif',
  ];
  @override
  void dispose() {
    _timer.cancel();
    _rippleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentLocation,
              zoom: 15,
            ),
            onMapCreated: _onMapCreated,
            zoomGesturesEnabled: false,
            zoomControlsEnabled: false,
            buildingsEnabled: true,
            trafficEnabled: true,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
          ),
          // Ripple effect circle around current location
          AnimatedBuilder(
            animation: _rippleAnimation,
            builder: (context, child) {
              return Positioned(
                top: MediaQuery.of(context).size.height / 2 -
                    _rippleAnimation.value,
                left: MediaQuery.of(context).size.width / 2 -
                    _rippleAnimation.value,
                child: Container(
                  width: _rippleAnimation.value * 2,
                  height: _rippleAnimation.value * 2,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue.withOpacity(0.3), // Light blue color
                  ),
                ),
              );
            },
          ),
          Positioned(
            bottom: 0,
            child: Container(
              height: 350,
              width: MediaQuery.sizeOf(context).width,
              color: Colors.white,
              child: Stack(
                children: [
                  Positioned(
                      top: 80,
                      child: SimpleAnimationProgressBar(
                        height: 10,
                        width: MediaQuery.sizeOf(context).width,
                        backgroundColor: Colors.grey,
                        foregrondColor: Colors.green,
                        ratio: 0.5,
                        direction: Axis.horizontal,
                        curve: Curves.fastLinearToSlowEaseIn,
                        duration: const Duration(minutes: 5),
                      )),
                  Positioned(
                    top: 120,
                    left: 20,
                    right: 20,
                    child: Container(
                      width: MediaQuery.sizeOf(context).width,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey,width: 0.5)),
                      height: 50,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: Row(
                          children: [
                            const Icon(Icons.directions_walk,color: Colors.green,),
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: Text(pickup!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                      color: Colors.black,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 200,
                    left: 20,
                    right: 20,
                    child: Container(
                      width: MediaQuery.sizeOf(context).width,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey,width: 0.5)),
                      height: 50,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: Row(
                          children: [
                            const CircleAvatar(
                              radius: 7,
                              backgroundColor: Colors.red,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: Text(dropoff!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                      color: Colors.black,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 35,
                    child: Container(
                      width: MediaQuery.sizeOf(context).width,
                      height: 20,
                      child: Center(
                        child: Text(bookingtexts[currentIndex],
                            style: GoogleFonts.poppins(
                                color: Colors.black,
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                  Positioned(
                      bottom: 20,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(10)),
                                border: Border.all(color: Colors.grey)),
                            width: MediaQuery.sizeOf(context).width - 40,
                            child: Center(
                              child: Text(
                                'Cancel Ride',
                                style: GoogleFonts.poppins(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ),
                      ))
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
