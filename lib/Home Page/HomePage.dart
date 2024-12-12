import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:image/image.dart' as img;
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vistaride/Booked%20Cab%20Details/bookedcabdetails.dart';
import 'package:vistaride/Destination%20Set%20Page/pickupanddroplocationset.dart';
import 'package:vistaride/Login%20Pages/loginpage.dart'; // Import geocoding package
import 'package:vistaride/Environment%20Files/.env.dart';
import 'package:vistaride/Profile%20Pages/TripHistory.dart';
import 'package:vistaride/Promo%20Codes/promocodes.dart';

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
  List<dynamic> driversnearme = [];
  List<dynamic> driverlocation = [];
  Future<BitmapDescriptor> _getNetworkCarIcon(String imageUrl) async {
    final response = await http.get(Uri.parse(imageUrl));
    if (response.statusCode == 200) {
      final Uint8List bytes = response.bodyBytes;

      // Decode the image and resize it
      img.Image? originalImage = img.decodeImage(bytes);
      if (originalImage == null) {
        throw Exception('Failed to decode image');
      }

      img.Image resizedImage =
          img.copyResize(originalImage, width: 80, height: 80);

      // Convert the resized image back to bytes
      final Uint8List resizedBytes =
          Uint8List.fromList(img.encodePng(resizedImage));

      // Create a BitmapDescriptor from the resized bytes
      return BitmapDescriptor.fromBytes(resizedBytes);
    } else {
      throw Exception('Failed to load image from network');
    }
  }

  Future<void> fetchdrivers() async {
    await _getCurrentLocation();
    try {
      final QuerySnapshot docsnap = await _firestore
          .collection('VistaRide Driver Details')
          .get(); // Fetch all drivers regardless of their "Driver Online" status

      List<dynamic> nearbyDrivers = [];
      Set<Marker> driverMarkers = {}; // Temporary set for driver markers

      for (var doc in docsnap.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final String driverLatitude = data['Current Latitude'] ?? "0.0";
        final String driverLongitude = data['Current Longitude'] ?? "0.0";
        final String cabcategory = data['Car Category'] ?? '';
        final bool isDriverOnline = data['Driver Online'] ?? false;
        final bool isDriverAvaliable = data['Driver Avaliable'] ?? true;
        // Skip offline drivers and remove their markers if they are already on the map
        if (!isDriverOnline) {
          setState(() {
            _markers.removeWhere(
              (marker) =>
                  marker.markerId.value.startsWith('driver_') &&
                  marker.markerId.value == 'driver_${doc.id}',
            );
          });
          continue;
        }

        // Calculate the distance between user and driver
        double distance = _calculateDistance(
          _currentLocation.latitude,
          _currentLocation.longitude,
          double.parse(driverLatitude),
          double.parse(driverLongitude),
        );

        if (kDebugMode) {
          print('Distance $distance');
        }

        if (distance <= 15.0 && isDriverAvaliable) {
          // Within 15 km
          nearbyDrivers.add({
            'driverId': doc.id,
            'latitude': driverLatitude,
            'longitude': driverLongitude,
            'otherDetails': data,
          });

          BitmapDescriptor carIcon;
          try {
            carIcon = await _getNetworkCarIcon(
                'https://firebasestorage.googleapis.com/v0/b/vistafeedd.appspot.com/o/Assets%2Fimages-removebg-preview%20(1).png?alt=media&token=80f80ee3-6787-4ddc-8aad-f9ce400461ea');
          } catch (e) {
            print('Failed to load custom car icon: $e');
            carIcon =
                BitmapDescriptor.defaultMarker; // Fallback to default marker
          }

          // Add a marker for this driver
          driverMarkers.add(
            Marker(
              markerId:
                  MarkerId('driver_${doc.id}'), // Unique ID for driver markers
              icon: carIcon,
              position: LatLng(
                  double.parse(driverLatitude), double.parse(driverLongitude)),
            ),
          );
        }
      }

      setState(() {
        driversnearme = nearbyDrivers; // Update the state with nearby drivers
        // Remove all driver markers first
        _markers.removeWhere(
            (marker) => marker.markerId.value.startsWith('driver_'));
        // Add the updated driver markers
        _markers.addAll(driverMarkers);
      });

      if (nearbyDrivers.isNotEmpty) {
        for (var driver in nearbyDrivers) {
          if (kDebugMode) {
            print('Driver ID: ${driver['driverId']}');
            print('Latitude: ${driver['latitude']}');
            print('Longitude: ${driver['longitude']}');
            print('Other Details: ${driver['otherDetails']}');
            print('--------------------------');
          }
        }
      } else {
        if (kDebugMode) {
          print('No drivers found within 15 km radius.');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching drivers: $e');
      }
    }
  }

  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double R = 6371; // Radius of the Earth in km
    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);
    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c; // Distance in km
  }

  double _toRadians(double degree) {
    return degree * pi / 180;
  }

  Future<void> fetchactiveride() async {
    List bookingid = [];
    String acctivebookingid = '';
    final prefs = await SharedPreferences.getInstance();
    final docsnap = await _firestore
        .collection('Booking IDs')
        .doc(_auth.currentUser!.uid)
        .get();
    if (docsnap.exists) {
      bookingid = docsnap.data()?['IDs'];
    }
    for (int i = 0; i < bookingid.length; i++) {
      final Docsnap =
          await _firestore.collection('Ride Details').doc(bookingid[i]).get();
      if (Docsnap.exists) {
        if (Docsnap.data()?['Ride Accepted']) {
          prefs.setString('Booking ID', bookingid[i]);
          print('BID ${bookingid[i]}');
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => BookedCabDetails(),
              ));
        }
      }
    }
  }

  late Timer _timertofetch;
  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    fetchuserdetails();
    fetchactiveride();
    fetchdrivers();
    _timertofetch = Timer.periodic(const Duration(seconds: 900), (Timer t) {
      fetchdrivers();
    });
  }
  bool _addressliked=false;
  String city='';
  // Function to get the current location using Geolocator
  Future<void> _getCurrentLocation() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
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
      Placemark placemark =
          placemarks[0]; // Take the first placemark from the list

      setState(() {
        locationName =
            '${placemark.street}, ${placemark.thoroughfare}, ${placemark.subLocality}, '
            '${placemark.locality},${placemark.administrativeArea}, ${placemark.postalCode} , ${placemark.country}'; // Format the address as needed
        _locationcontroller.text = locationName;
        prefs.setString('Locality', placemark.locality!);
      });
    }

    print('Latitude ${position.latitude} Long ${position.latitude}');
    // Update the state with the new location
    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
      // Add a marker at the current location
      _markers.add(Marker(
        markerId: MarkerId('currentLocation'),
        position: _currentLocation,
        infoWindow: InfoWindow(title: locationName),
      ));
    });
    prefs.setDouble('location longitude', position.longitude);
    prefs.setDouble('location latitude', position.latitude);
    await _fetchWeather(position.latitude, position.longitude);
    // Move the camera to the user's current location
    mapController.animateCamera(
      CameraUpdate.newLatLng(_currentLocation),
    );
  }
  Future<void> _fetchWeather(double latitude, double longitude) async {
    final apiKey = Environment.WeatherAPI; // Replace with your OpenWeatherMap API key
    final url =
        'https://api.openweathermap.org/data/2.5/weather?lat=${latitude}&lon=${longitude}&appid=${apiKey}&units=metric';

    try {
      final response = await http.get(Uri.parse(url));

      // Check if the API call was successful
      if (response.statusCode == 200) {
        // Parse the JSON data
        Map<String, dynamic> weatherData = json.decode(response.body);
        if (kDebugMode) {
          print('Weather $weatherData');
        }
        // Extract weather information
        String description = weatherData['weather'][0]['main'];
        double temperature = weatherData['main']['temp'];
        final prefs=await SharedPreferences.getInstance();
        prefs.setDouble('Weather Temperature', temperature);
        prefs.setString('Weather Condition', description);
        if (kDebugMode) {
          print('Weather ${prefs.getString('Weather Condition')}');
        }
        // Print the weather information to the terminal
        if (kDebugMode) {
          print('Weather in $locationName:');
          print('Temperature: $temperature°C');
          print('Condition: $description');
        }
      } else {
        // If the response code is not 200, print the error
        if (kDebugMode) {
          print('Error: Failed to load weather data. Status Code: ${response.statusCode}');
        }
      }
    } catch (e) {
      // Catch any errors that occur during the HTTP request
      if (e is http.ClientException) {
        if (kDebugMode) {
          print('Network Error: Failed to reach the server.');
        }
      } else {
        if (kDebugMode) {
          print('Error: $e');
        }
      }
    }
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _timertofetch.cancel();
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
    final SharedPreferences prefs = await SharedPreferences.getInstance();
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
  bool isposteropen=true;
  List carcategoryimages = [
    'https://olawebcdn.com/images/v1/cabs/sl/ic_mini.png',
    'https://olawebcdn.com/images/v1/cabs/sl/ic_prime.png',
    'https://olawebcdn.com/images/v1/cabs/sl/ic_suv.png',
    'https://olawebcdn.com/images/v1/cabs/sl/ic_kp.png'
  ];
  List cabcategorynames = ['Mini', 'Prime', 'SUV', 'Non AC Taxi'];
  int _selectedindex = 0;
  bool issidebaropened = false;
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
         isposteropen? Positioned(
            top: MediaQuery.sizeOf(context).height / 4, // Adjust top position for centering vertically
            left: MediaQuery.sizeOf(context).width / 2 - (MediaQuery.sizeOf(context).width - 40) / 2, // Center horizontally
            child: Container(
              height: (MediaQuery.sizeOf(context).height / 2)-20,
              width: MediaQuery.sizeOf(context).width - 40,
              color: Colors.transparent,
              child:  Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                       SizedBox(
                        width: MediaQuery.sizeOf(context).width-70,
                      ),
                      InkWell(
                          onTap: (){
                            setState(() {
                              isposteropen=false;
                            });
                          },
                          child: const Icon(Icons.close,color: Colors.black,))
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Image(image: NetworkImage('https://firebasestorage.googleapis.com/v0/b/vistafeedd.appspot.com/o/Assets%2FVistaRide%20Prem'
                      'ium%20Membership%20poster%20with%20the%20provided%20details%20(1).png?alt=media&token=49d06886-4c91-4c79-8911-f4e02e2f4327'),
                  fit: BoxFit.fill,
                  )
                ],
              ),
            ),
          ):Container(),
          Positioned(
            top: 40,
            left: 75,
            child: Container(
              height: 50,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              width: MediaQuery.sizeOf(context).width - 140,
              child: TextField(
                controller: _locationcontroller,
                decoration: InputDecoration(
                  // hintText: 'Search for a location',
                  suffixIcon: InkWell(
                    onTap: ()async{
                      setState(() {
                        islikedlocation = !islikedlocation;
                      });
                      if(islikedlocation){
                        await _firestore.collection('Liked Addresses').doc(_auth.currentUser!.uid).set(
                            {
                              'Addresses':FieldValue.arrayUnion([_locationcontroller.text])
                            },SetOptions(merge: true));
                      }
                      if(!islikedlocation){
                        await _firestore.collection('Liked Addresses').doc(_auth.currentUser!.uid).update(
                            {
                              'Addresses':FieldValue.arrayRemove([_locationcontroller.text])
                            });
                      }
                    },
                    child: Icon(
                      islikedlocation ? Icons.favorite : Icons.favorite_border,
                      color: islikedlocation ? Colors.red : Colors.black,
                    ),
                  ),
                  border: InputBorder.none, // Removes the bottom underline
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                ),
                onSubmitted: (value) {
                  // Trigger location search when user submits text
                  _searchLocation(value);
                },
              ),
            ),
          ),
          Positioned(
              top: 100,
              left: 75,
              child: InkWell(
                onTap: () async {
                  if (kDebugMode) {
                    print('Clicked');
                  }
                  final SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  prefs.setString('location', locationName);

                  if (kDebugMode) {
                    print(prefs.getDouble('location longitude'));
                  }
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Pickupandroplocation(),
                      ));
                },
                child: Container(
                    height: 50,
                    width: MediaQuery.sizeOf(context).width - 140,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.white),
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 10,
                        ),
                        const Icon(
                          Icons.search,
                          color: Colors.green,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          'Search for a destination',
                          style: GoogleFonts.poppins(
                              color: Colors.grey,
                              fontSize: 15,
                              fontWeight: FontWeight.w400),
                        )
                      ],
                    )),
              )),
          issidebaropened? Positioned(
              top: 0,
              left: 0,
              child: GestureDetector(
                onHorizontalDragEnd: (details) {
                  if (details.primaryVelocity! < 0) {
                    // If velocity is negative, it means a swipe left
                    setState(() {
                      issidebaropened=false;
                    });
                    if (kDebugMode) {
                      print('Closed');
                    }
                  }
                },
                child: Container(
                  height: MediaQuery.sizeOf(context).height,
                  width: MediaQuery.sizeOf(context).width / 1.5,
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 40,
                        ),
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 25,
                              backgroundImage: NetworkImage(profilepic),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        InkWell(
                          onTap: (){},
                          child: Text('My Profile',style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                          ),),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        InkWell(
                          onTap: (){},
                          child: Row(
                            children: [
                              const Icon(Icons.person,color: Colors.green,),
                              const SizedBox(
                                width: 8,
                              ),
                              Text('My Profile',style: GoogleFonts.poppins(
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                              ),),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        InkWell(
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context) => MyTrips(),));
                            setState(() {
                              issidebaropened=false;
                            });
                          },
                          child: Row(
                            children: [
                              const Icon(Icons.history,color: Colors.green,),
                              const SizedBox(
                                width: 8,
                              ),
                              Text('History',style: GoogleFonts.poppins(
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                              ),),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        InkWell(
                          onTap: ()async{
                            final prefs=await SharedPreferences.getInstance();
                            prefs.setBool('Apply Promo', false);
                            Navigator.push(context, MaterialPageRoute(builder: (context) => PromoCodes(
                              ridepage: false,
                            ),));
                          },
                          child: Row(
                            children: [
                              const Icon(Icons.discount,color: Colors.green,),
                              const SizedBox(
                                width: 8,
                              ),
                              Text('Promos',style: GoogleFonts.poppins(
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                              ),),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        InkWell(
                          onTap: ()async{
                            await _auth.signOut();
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage(),));
                          },
                          child: Row(
                            children: [
                              const Icon(Icons.logout,color: Colors.red,),
                              const SizedBox(
                                width: 8,
                              ),
                              Text('Logout',style: GoogleFonts.poppins(
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                              ),),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              )
          ):Container(),
          !issidebaropened? Positioned(
            top: 48,
            left: 20,
            child: Row(
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      issidebaropened = !issidebaropened;
                    });
                    if (kDebugMode) {
                      print('Sidebar $issidebaropened');
                    }
                  },
                  child: Container(
                    height: 40,
                    width: 40,
                    decoration: const BoxDecoration(
                      color: Colors.yellow,
                      borderRadius: BorderRadius.all(Radius.circular(50)),
                    ),
                    child: const Icon(Icons.menu, color: Colors.black),
                  ),
                ),
              ],
            ),
          ):Container(),
          Positioned(
            top: 45,
            left: MediaQuery.sizeOf(context).width - 50,
            child: Row(
              children: [
                InkWell(
                  onTap: () async {
                    await _auth.signOut();
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoginPage(),
                        ));
                  },
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(profilepic),
                  ),
                ),
              ],
            ),
          ),
          // Positioned(
          //     bottom: 0,
          //     child: Container(
          //   width: MediaQuery.sizeOf(context).width,
          //   color: Colors.white,
          //   height: 300,
          //   child: SingleChildScrollView(
          //     child: Padding(
          //       padding: const EdgeInsets.only(left: 20,right: 20),
          //       child: Column(
          //         crossAxisAlignment: CrossAxisAlignment.start,
          //         children: [
          //           SizedBox(
          //             height: 100,
          //             child: Expanded(
          //               child: ListView.builder(
          //                 scrollDirection: Axis.horizontal,
          //                 itemCount: carcategoryimages.length,
          //                 itemBuilder: (context, index) {
          //                   return Row(
          //                     children: [
          //                       Padding(
          //                         padding: const EdgeInsets.only(right: 30,bottom: 0),
          //                         child: InkWell(
          //                           onTap: (){
          //                             setState(() {
          //                               _selectedindex=index;
          //                             });
          //                           },
          //                           child: Column(
          //                             children: [
          //                               Image(image: NetworkImage(carcategoryimages[index]),height: 60,width: 60,),
          //                               Text(cabcategorynames[index],style: GoogleFonts.poppins(
          //                                 fontWeight: _selectedindex==index?FontWeight.bold:FontWeight.w400,
          //                               ),)
          //                             ],
          //                           ),
          //                         ),
          //                       )
          //                     ],
          //                   );
          //                 },
          //               ),
          //             ),
          //           ),
          //
          //         ],
          //       ),
          //     ),
          //   )
          //     ),
          // ),
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              shape: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: BorderSide.none),
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
