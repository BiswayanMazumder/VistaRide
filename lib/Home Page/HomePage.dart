import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:vistaride/Login%20Pages/loginpage.dart'; // Import geocoding package

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late GoogleMapController mapController;
  LatLng _currentLocation = LatLng(22.7199572, -88.4663679);
  Set<Marker> _markers = {};
  String locationName = ''; // Store the name of the location
  final TextEditingController _locationcontroller = TextEditingController();
  bool islikedlocation = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String profilepic = '';
  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    fetchuserdetails();
  }

  // Function to get the current location using Geolocator
  Future<void> _getCurrentLocation() async {
    // Check if the user has granted location permission
    LocationPermission permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      // You can show a message to the user requesting them to grant permission
      return;
    }

    // Get the current location
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // Reverse geocode the latitude and longitude to get the name of the location
    List<Placemark> placemarks =
    await placemarkFromCoordinates(position.latitude, position.longitude);

    // Check if placemarks are returned and update the location name
    if (placemarks.isNotEmpty) {
      Placemark placemark = placemarks[0]; // Take the first placemark from the list
      setState(() {
        locationName =
        '${placemark.street}, ${placemark.thoroughfare}, ${placemark.subLocality}, '
            '${placemark.locality},${placemark.administrativeArea}, ${placemark.postalCode} , ${placemark.country}'; // Format the address as needed
        _locationcontroller.text = locationName;
      });
    }

    // Update the state with the new location
    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
      // Add a marker at the current location
      _markers.add(Marker(
        markerId: MarkerId('currentLocation'),
        position: _currentLocation,
        infoWindow: InfoWindow(title: 'Your Location'),
      ));
    });

    // Move the camera to the user's current location
    mapController.animateCamera(
      CameraUpdate.newLatLng(_currentLocation),
    );
  }

  // Called when the map is created
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  // Fetch user details (e.g., profile picture)
  Future<void> fetchuserdetails() async {
    final docsnap = await _firestore
        .collection('VistaRide User Details')
        .doc(_auth.currentUser!.uid)
        .get();
    if (docsnap.exists) {
      setState(() {
        profilepic = docsnap.data()?['Profile Picture'];
      });
    }
  }

  // Function to search for a location
  Future<void> _searchLocation(String location) async {
    // Use geocoding to convert the location name to latitude and longitude
    try {
      List<Location> locations = await locationFromAddress(location);

      if (locations.isNotEmpty) {
        Location loc = locations[0]; // Get the first location result
        LatLng newLocation = LatLng(loc.latitude, loc.longitude);

        // Update the map with the new location
        setState(() {
          _currentLocation = newLocation;
          _markers.clear(); // Clear previous markers
          _markers.add(Marker(
            markerId: MarkerId('searchedLocation'),
            position: _currentLocation,
            infoWindow: InfoWindow(title: location),
          ));
        });

        // Move the camera to the new location
        mapController.animateCamera(
          CameraUpdate.newLatLng(_currentLocation),
        );
      }
    } catch (e) {
      // Handle the error (e.g., invalid address or no results)
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Location not found")),
      );
    }
  }
  List carcategoryimages=[
    'https://olawebcdn.com/images/v1/cabs/sl/ic_mini.png',
    'https://olawebcdn.com/images/v1/cabs/sl/ic_prime.png',
    'https://olawebcdn.com/images/v1/cabs/sl/ic_suv.png',
    'https://olawebcdn.com/images/v1/cabs/sl/ic_kp.png'
  ];
  List cabcategorynames=[
    'Mini',
    'Prime',
    'SUV',
    'Non AC Taxi'
  ];
  int _selectedindex=0;
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
            markers: _markers,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: false,
            buildingsEnabled: true,
            myLocationEnabled: true, // Show the user's location as a blue dot
            myLocationButtonEnabled: false, // Disable the default button
          ),
          Positioned(
            top: 40,
            left: 75,
            child: Container(
              height: 50,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              width: MediaQuery.sizeOf(context).width - 140,
              child: TextField(
                controller: _locationcontroller,
                decoration: InputDecoration(
                  // hintText: 'Search for a location',
                  suffixIcon: InkWell(
                    onTap: () {
                      setState(() {
                        islikedlocation = !islikedlocation;
                      });
                    },
                    child: Icon(
                      islikedlocation ? Icons.favorite : Icons.favorite_border,
                      color: islikedlocation ? Colors.red : Colors.black,
                    ),
                  ),
                  border: InputBorder.none, // Removes the bottom underline
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 15, horizontal: 10),
                ),
                onSubmitted: (value) {
                  // Trigger location search when user submits text
                  _searchLocation(value);
                },
              ),
            ),
          ),
          Positioned(
            top: 48,
            left: 20,
            child: Row(
              children: [
                Container(
                  height: 40,
                  width: 40,
                  decoration: const BoxDecoration(
                    color: Colors.yellow,
                    borderRadius: BorderRadius.all(Radius.circular(50)),
                  ),
                  child: const Icon(Icons.menu, color: Colors.black),
                ),
              ],
            ),
          ),
          Positioned(
            top: 45,
            left: MediaQuery.sizeOf(context).width - 50,
            child: Row(
              children: [
                InkWell(
                  onTap: ()async{
                   await _auth.signOut();
                    Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => LoginPage(),));
                  },
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(profilepic),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
              bottom: 0,
              child: Container(
            width: MediaQuery.sizeOf(context).width,
            color: Colors.white,
            height: 300,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(left: 20,right: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 100,
                      child: Expanded(
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: carcategoryimages.length,
                          itemBuilder: (context, index) {
                            return Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 30,bottom: 0),
                                  child: InkWell(
                                    onTap: (){
                                      setState(() {
                                        _selectedindex=index;
                                      });
                                    },
                                    child: Column(
                                      children: [
                                        Image(image: NetworkImage(carcategoryimages[index]),height: 60,width: 60,),
                                        Text(cabcategorynames[index],style: GoogleFonts.poppins(
                                          fontWeight: _selectedindex==index?FontWeight.bold:FontWeight.w400,
                                        ),)
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                    Container(
                      height: 50,
                      decoration:  BoxDecoration(
                        color: Colors.grey.shade300,
                        border: Border.all(
                          color: Colors.grey
                        ),
                        borderRadius: const BorderRadius.all(Radius.circular(10)),
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.search,color: Colors.green,),
                          hintText: 'Search Destination',
                          hintStyle: GoogleFonts.poppins(
                            color: Colors.black,
                            fontWeight: FontWeight.w600
                          ),
                          // hintText: 'Search for a location',
                          border: InputBorder.none, // Removes the bottom underline
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 15, horizontal: 10),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            )
              ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              shape: OutlineInputBorder(borderRadius: BorderRadius.circular(50),borderSide: BorderSide.none),
              onPressed: _getCurrentLocation,
              backgroundColor: Colors.white,
              child: const Icon(Icons.my_location, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
