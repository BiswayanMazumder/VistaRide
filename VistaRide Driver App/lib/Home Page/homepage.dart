import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image/image.dart' as img;
import 'package:http/http.dart' as http;
import 'package:vistaridedriver/Environment%20Files/.env.dart';
import 'package:vistaridedriver/Login%20Pages/login_page.dart';
import 'package:vistaridedriver/Ride%20Details/ridedetails.dart';
import 'package:vistaridedriver/Sidebar%20Pages/mytrips.dart';

import '../Services/NotificationServices.dart';
import '../Services/fcm_services.dart';
import '../Services/get_serverkey.dart';

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
  bool isonline = false;

  // Variables for ride details
  String riderequestid = '';
  String pickuplocation = '';
  String droplocation = '';
  double fare = 0;
  double picklong = 0;
  double picklat = 0;
  double droplong = 0;
  double droplat = 0;
  String traveltime = '';
  String distance = '';
  String cabcategory = '';

  // Firestore Listener
  StreamSubscription<DocumentSnapshot>? _rideRequestListener;

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

  Future<void> _getCurrentLocation() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
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
            '${placemark.locality},${placemark.administrativeArea}, ${placemark.postalCode} , ${placemark.country}';
        _locationcontroller.text = locationName;
      });
    }

    BitmapDescriptor carIcon;
    try {
      carIcon = await _getNetworkCarIcon(
          'https://firebasestorage.googleapis.com/v0/b/vistafeedd.appspot.com/o/Assets%2Fimages-removebg-preview%20(1).png?alt=media&token=80f80ee3-6787-4ddc-8aad-f9ce400461ea');
    } catch (e) {
      print('Failed to load custom car icon: $e');
      carIcon = BitmapDescriptor.defaultMarker;
    }

    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
      _markers.add(Marker(
        markerId: MarkerId('currentLocation'),
        position: _currentLocation,
        icon: carIcon,
        infoWindow: InfoWindow(title: locationName),
      ));
    });

    prefs.setDouble('location longitude', position.longitude);
    prefs.setDouble('location latitude', position.latitude);
    if (kDebugMode) {
      print('Longitude ${prefs.getDouble('location latitude')}');
    }
    await _firestore
        .collection('VistaRide Driver Details')
        .doc(_auth.currentUser!.uid)
        .update({
      'Current Latitude': position.latitude.toString(),
      'Current Longitude': position.longitude.toString()
    });
    mapController.animateCamera(
      CameraUpdate.newLatLng(_currentLocation),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }
  String name='';
  Future<void> fetchuserdetails() async {
    final docsnap = await _firestore
        .collection('VistaRide Driver Details')
        .doc(_auth.currentUser!.uid)
        .get();
    if (docsnap.exists) {
      setState(() {
        profilepic = docsnap.data()?['Profile Picture'];
        isonline = docsnap.data()?['Driver Online'];
        name=docsnap.data()?['Name']??'';
      });
    }
  }

  bool isamountpaid = false;
  bool istripcompleted = false;
  Future<void> fetchRideDetails(String rideId) async {
    player = AudioPlayer();

    // Set the release mode to keep the source after playback has completed.

    final docSnap =
        await _firestore.collection('Ride Details').doc(rideId).get();
    if (docSnap.exists) {
      setState(() {
        pickuplocation = docSnap.data()?['Pickup Location'] ?? '';
        droplocation = docSnap.data()?['Drop Location'] ?? '';
        fare = docSnap.data()?['Fare'] ?? 0;
        traveltime = docSnap.data()?['Travel Time'] ?? '';
        distance = docSnap.data()?['Travel Distance'] ?? '';
        cabcategory = docSnap.data()?['Cab Category'] ?? '';
        isamountpaid = docSnap.data()?['Amount Paid'] ?? false;
        istripcompleted = docSnap.data()?['Ride Completed'];
      });
    }
  }

  late AudioPlayer player = AudioPlayer();
  void listenForRideRequest() {
    _rideRequestListener = _firestore
        .collection('VistaRide Driver Details')
        .doc(_auth.currentUser!.uid)
        .snapshots()
        .listen((snapshot) async {
      if (snapshot.exists) {
        String? rideId = snapshot.data()?['Ride Requested'];

        if (rideId != null && rideId.isNotEmpty) {
          setState(() {
            riderequestid = rideId;
          });
          await fetchRideDetails(rideId);

          // Play the audio when a ride is assigned
          player.setReleaseMode(ReleaseMode.stop);
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            try {
              await player.setSourceUrl(
                'https://firebasestorage.googleapis.com/v0/b/vistafeedd.appspot.com/o/Assets%2Fuber_driver_sound.mp3?alt=media&token=f2ea7775-ce3d-4049-b565-01fa3c15093f',
              );
              await player.resume();
            } catch (e) {
              if (kDebugMode) {
                print("Error playing sound: $e");
              }
            }
          });
        } else {
          setState(() {
            riderequestid = '';
            pickuplocation = '';
            droplocation = '';
            fare = 0;
            traveltime = '';
            distance = '';
            cabcategory = '';
          });

          // Stop the audio when the ride is no longer assigned
          await player.stop();
        }
      }
    });
  }

  String rideid = '';
  Future<void> fetchactiverides() async {
    final docsnap = await _firestore
        .collection('VistaRide Driver Details')
        .doc(_auth.currentUser!.uid)
        .get();

    if (docsnap.exists) {
      setState(() {
        rideid = docsnap.data()?['Ride Doing'];
      });
    }
    if (kDebugMode) {
      print('Ride Doing $rideid');
    }
    if (rideid != '') {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('Booking ID', rideid);
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => RideDetails(),
          ));
    }
  }

  NotificationService notificationService = NotificationService();
  Future<void> sendnotification() async {
    await getDeviceToken(); // Assuming this sets a valid `token`

    // Replace this with your actual server token.
    const String serverToken = Environment.ServerToken;

    final response = await http.post(
      Uri.parse(
          'https://fcm.googleapis.com/v1/projects/vistafeedd/messages:send'),
      headers: {
        'Content-Type': 'application/json', // Correct Content-Type header
        'Authorization': 'Bearer $serverToken', // Correct Authorization header
      },
      body: jsonEncode({
        "message": {
          "token": '$token',
          "notification": {
            "body":
                "Unfortunately, your rider has cancelled the trip. Please wait for some time till we assign you a new ride.",
            "title": "Ride Cancelled"
          }
        }
      }), // Convert the body Map to JSON string
    );

    if (response.statusCode == 200) {
      if (kDebugMode) {
        print('Notification sent');
      }
    } else {
      if (kDebugMode) {
        print(
            'Failed to send notification. Status code: ${response.statusCode}');
        print('Response: ${response.body}');
      }
    }
  }

  Future<void> sendrideacceptnotification() async {
    await fetchRideDetails(riderequestid);
    await getDeviceToken();

    // Replace this with your actual server token.
    const String serverToken = Environment.ServerToken;

    final response = await http.post(
      Uri.parse(
          'https://fcm.googleapis.com/v1/projects/vistafeedd/messages:send'),
      headers: {
        'Content-Type': 'application/json', // Correct Content-Type header
        'Authorization': 'Bearer $serverToken', // Correct Authorization header
      },
      body: jsonEncode({
        "message": {
          "token": '$token',
          "notification": {
            "body": "Your trip to $droplocation has successfully been accepted",
            "title": "Ride Accepted"
          }
        }
      }), // Convert the body Map to JSON string
    );

    if (response.statusCode == 200) {
      if (kDebugMode) {
        print('Notification sent');
      }
    } else {
      if (kDebugMode) {
        print(
            'Failed to send notification. Status code: ${response.statusCode}');
        print('Response: ${response.body}');
      }
    }
  }
  List<dynamic> driversnearme = [];
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

        if (distance <= 30.0 && isDriverAvaliable) {
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
                'https://firebasestorage.googleapis.com/v0/b/vistafeedd.appspot.com/o/Assets%2Fpngtree-red-car-top-view-icon-png-image_3745904-removebg-preview.png?alt=media&token=ec094a1a-9864-4a06-9b44-529d04ed2a29');
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
  @override
  void initState() {
    super.initState();
    notificationService.requestnotificationpermission();
    notificationService.getDeviceToken();
    notificationService.firebaseInit(context);
    notificationService.setupInteractMessage(context);
    FCMService.firebaseInit();
    fetchuserdetails();
    _getCurrentLocation();
    listenForRideRequest();
    fetchactiverides();
    getDeviceToken();
    fetchdrivers();
    // sendnotification();
  }

  String? token;
  Future<void> getDeviceToken() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    try {
      token = await messaging.getToken();
      if (token != null) {
        if (kDebugMode) {
          print("Device Token: $token");
        }
        // Save the token to your backend or use it directly for testing
      } else {
        if (kDebugMode) {
          print("Failed to retrieve token.");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching device token: $e");
      }
    }
  }

  @override
  void dispose() {
    _rideRequestListener?.cancel();
    super.dispose();
  }

  bool ismenuopened = false;
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
            markers:isonline? _markers:{},
            zoomGesturesEnabled: true,
            zoomControlsEnabled: false,
            buildingsEnabled: true,
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
          ),
          Positioned(
            top: 20,
            right: 20,
            child: Row(
              children: [
                InkWell(
                  onTap: () async {
                  },
                  child: CircleAvatar(
                    radius: 25,
                    backgroundImage: NetworkImage(profilepic),
                  ),
                ),
              ],
            ),
          ),
          riderequestid == ''
              ? Positioned(
                  bottom: 30,
                  left: (MediaQuery.sizeOf(context).width / 2) - 40,
                  child: InkWell(
                    onTap: () async {
                      // await sendnotification();
                      setState(() {
                        isonline = !isonline;
                      });
                      await _firestore
                          .collection('VistaRide Driver Details')
                          .doc(_auth.currentUser!.uid)
                          .update({'Driver Online': isonline});
                      if (!isonline) {
                        player.setReleaseMode(ReleaseMode.stop);
                        WidgetsBinding.instance.addPostFrameCallback((_) async {
                          try {
                            await player.setSourceUrl(
                              'https://firebasestorage.googleapis.com/v0/b/vistafeedd.appspot.com/o/Assets%2Fuber_offline.mp3?alt=media&token=f36e57e3-5a20-48f0-ab12-fd7bdc867a08',
                            );
                            await player.resume();
                          } catch (e) {
                            if (kDebugMode) {
                              print("Error playing sound: $e");
                            }
                          }
                        });
                      }
                      if (isonline) {
                        player.setReleaseMode(ReleaseMode.stop);
                        WidgetsBinding.instance.addPostFrameCallback((_) async {
                          try {
                            await player.setSourceUrl(
                              'https://firebasestorage.googleapis.com/v0/b/vistafeedd.appspot.com/o/Assets%2Fuber_online.mp3?alt=media&token=16b87e0b-fad4-4e78-81b8-459a4aff6ed3',
                            );
                            await player.resume();
                          } catch (e) {
                            if (kDebugMode) {
                              print("Error playing sound: $e");
                            }
                          }
                        });
                      }
                    },
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: isonline ? Colors.red : Colors.blue,
                      child: Center(
                        child: Text(
                          isonline ? 'Stop' : 'Go',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              : Container(),
          ismenuopened
              ? Positioned(
                  child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    setState(() {
                      ismenuopened = false;
                    });
                  },
                  child: Container(
                    height: MediaQuery.sizeOf(context).height,
                    width: MediaQuery.sizeOf(context).width / 1.5,
                    color: Colors.white,
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 50,
                        ),
                        CircleAvatar(
                          radius: 40,
                          backgroundImage: NetworkImage(profilepic),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Text(name,style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),),
                        const SizedBox(
                          height: 20,
                        ),
                         Row(
                           mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const SizedBox(
                              width: 40,
                            ),
                            const Icon(Icons.person,color: Colors.green,),
                            const SizedBox(
                              width: 20,
                            ),
                            Text('Profile',style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                            ),),
                          ],
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        InkWell(
                          onTap: (){
                            setState(() {
                              ismenuopened=false;
                            });
                            Navigator.push(context,MaterialPageRoute(builder: (context) => const TripsPage(),));
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const SizedBox(
                                width: 40,
                              ),
                              const Icon(Icons.pin_drop_rounded,color: Colors.green,),
                              const SizedBox(
                                width: 20,
                              ),
                              Text('Trips Done',style: GoogleFonts.poppins(
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                              ),),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        InkWell(
                          onTap: () async {
                            await _auth.signOut();
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => LoginPage()),
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const SizedBox(
                                width: 40,
                              ),
                              const Icon(Icons.logout,color: Colors.red,),
                              const SizedBox(
                                width: 20,
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
                ))
              : Container(),
          ismenuopened
              ? Container()
              : Positioned(
                  top: 20,
                  left: 20,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        ismenuopened = !ismenuopened;
                      });
                    },
                    child: const CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.yellow,
                      child: Icon(
                        Icons.menu,
                        color: Colors.black,
                      ),
                    ),
                  )),
          riderequestid != ''
              ? Positioned(
                  bottom: 0,
                  child: Container(
                    height: MediaQuery.sizeOf(context).height / 2.2,
                    width: (MediaQuery.sizeOf(context).width),
                    color: Colors.white,
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 20,
                            ),
                            Container(
                              height: 60,
                              width: 100,
                              decoration: const BoxDecoration(
                                  color: Colors.black,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(50))),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  const Icon(
                                    Icons.person,
                                    color: Colors.white,
                                  ),
                                  Text(
                                    cabcategory,
                                    style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600),
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Text(
                              '₹$fare Trip Fare',
                              style: GoogleFonts.poppins(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 20),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Text(
                              'Includes 5% Tax',
                              style: GoogleFonts.poppins(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w200,
                                  fontSize: 15),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Text(
                              '${traveltime} (${distance}) trip',
                              style: GoogleFonts.poppins(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 18),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                const Icon(
                                  Icons.directions_walk,
                                  color: Colors.green,
                                ),
                                const SizedBox(
                                  width: 20,
                                ),
                                Flexible(
                                  child: Text(
                                    pickuplocation,
                                    maxLines:
                                        5, // Ensures the text doesn't exceed 5 lines
                                    overflow: TextOverflow
                                        .ellipsis, // Adds ellipsis if text is too long
                                    style: GoogleFonts.poppins(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                const Icon(
                                  Icons.pin_drop,
                                  color: Colors.red,
                                ),
                                const SizedBox(
                                  width: 20,
                                ),
                                Flexible(
                                  child: Text(
                                    droplocation,
                                    maxLines:
                                        5, // Ensures the text doesn't exceed 5 lines
                                    overflow: TextOverflow
                                        .ellipsis, // Adds ellipsis if text is too long
                                    style: GoogleFonts.poppins(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                InkWell(
                                  onTap: () async {
                                    await _firestore
                                        .collection('VistaRide Driver Details')
                                        .doc(_auth.currentUser!.uid)
                                        .update({
                                      'Ride Requested': FieldValue.delete()
                                    });
                                  },
                                  child: Container(
                                    height: 60,
                                    width: 100,
                                    decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(50)),
                                        border: Border.all(
                                          color: Colors.black,
                                        )),
                                    child: Center(
                                      child: Text(
                                        'Pass',
                                        style: GoogleFonts.poppins(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () async {
                                    String riderassigned = '';
                                    final docsnap = await _firestore
                                        .collection('Ride Details')
                                        .doc(riderequestid)
                                        .get();
                                    if (docsnap.exists) {
                                      setState(() {
                                        riderassigned =
                                            docsnap.data()?['Driver ID'] ?? '';
                                      });
                                    }
                                    //Ride Details update Driver ID to current user then Ride Accepted to true
                                    if (riderassigned == '') {
                                      await _firestore
                                          .collection('Ride Details')
                                          .doc(riderequestid)
                                          .update({
                                        'Driver ID': _auth.currentUser!.uid,
                                        'Ride Accepted': true
                                      });
                                      //In VistaRide Driver Details update Driver Avaliable to false Ride Doing to bookingid
                                      await _firestore
                                          .collection(
                                              'VistaRide Driver Details')
                                          .doc(_auth.currentUser!.uid)
                                          .update({
                                        'Driver Avaliable': false,
                                        'Ride Doing': riderequestid,
                                        'Ride Accepted': FieldValue.delete()
                                      });
                                      final prefs =
                                          await SharedPreferences.getInstance();
                                      await prefs.setString(
                                          'Booking ID', riderequestid);
                                      await sendrideacceptnotification();
                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => RideDetails(),
                                          ));
                                    }
                                  },
                                  child: Container(
                                    height: 60,
                                    width: 100,
                                    decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(50)),
                                        color: Colors.green),
                                    child: Center(
                                      child: Text(
                                        'Accept',
                                        style: GoogleFonts.poppins(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ))
              : Container(),
        ],
      ),
    );
  }
}
