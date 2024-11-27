import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/style.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image/image.dart' as img;
import 'package:http/http.dart' as http;

import '../Environment Files/.env.dart';
class RideDetails extends StatefulWidget {
  const RideDetails({super.key});

  @override
  State<RideDetails> createState() => _RideDetailsState();
}

class _RideDetailsState extends State<RideDetails> {
  final FirebaseAuth _auth=FirebaseAuth.instance;
  final FirebaseFirestore _firestore=FirebaseFirestore.instance;
  late GoogleMapController mapController;
  LatLng _currentLocation = LatLng(22.7199572, -88.4663679);
  Set<Marker> _markers = {};
  String locationName = ''; // Store the name of the location
  final TextEditingController _locationcontroller = TextEditingController();
  Future<BitmapDescriptor> _getNetworkCarIcon(String imageUrl) async {
    final response = await http.get(Uri.parse(imageUrl));
    if (response.statusCode == 200) {
      final Uint8List bytes = response.bodyBytes;

      // Decode the image and resize it
      img.Image? originalImage = img.decodeImage(bytes);
      if (originalImage == null) {
        throw Exception('Failed to decode image');
      }

      img.Image resizedImage = img.copyResize(originalImage, width: 80, height: 80);

      // Convert the resized image back to bytes
      final Uint8List resizedBytes = Uint8List.fromList(img.encodePng(resizedImage));

      // Create a BitmapDescriptor from the resized bytes
      return BitmapDescriptor.fromBytes(resizedBytes);
    } else {
      throw Exception('Failed to load image from network');
    }
  }
  Set<Polyline> _polylines = {}; // Set to hold polyline
  LatLng _pickupLocation =
  LatLng(22.7199572, 88.4663679); // Default pickup location (Kolkata)
  LatLng _dropoffLocation = LatLng(
      22.582077, 88.368420);
  String Time = '';
  String DistanceTravel = '';
  bool isdrivernearby=false;
  Future<void> _getCurrentLocation() async {
    await fetchridedetails();
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
    await _firestore.collection('VistaRide Driver Details').doc(_auth.currentUser!.uid).update(
        {
          'Current Latitude':position.latitude.toString(),
          'Current Longitude':position.longitude.toString()
        });
    mapController.animateCamera(
      CameraUpdate.newLatLng(_currentLocation),
    );
    LatLng driverCurrentLocation = LatLng(
      position.latitude,
      position.longitude,
    );
    LatLng droplocation = LatLng(
      double.parse(droplat.toString()),
      double.parse(droplong.toString()),
    );
    setState(() {
      _pickupLocation = LatLng(pickuplat, pickuplong);
      _dropoffLocation=LatLng(droplat, droplong);
    });
    const String apiKey = Environment.GoogleMapsAPI;
    final String url1 = //use it when ride is verified
        'https://maps.googleapis.com/maps/api/directions/json?origin=${driverCurrentLocation.latitude},${driverCurrentLocation.longitude}&destination=${_dropoffLocation.latitude},${_dropoffLocation.longitude}&key=$apiKey';
    final String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${driverCurrentLocation.latitude},${driverCurrentLocation.longitude}&destination=${_pickupLocation.latitude},${_pickupLocation.longitude}&key=$apiKey';

    if (kDebugMode) {
      print('URL $url1');
    }
    final response = await http.get(Uri.parse(rideverified?url1:url));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data['routes'].isNotEmpty) {
        final duration = data['routes'][0]['legs'][0]['duration']['text'];
        final distance = data['routes'][0]['legs'][0]['distance']['text'];

        // Decode the polyline
        String encodedPolyline = data['routes'][0]['overview_polyline']['points'];
        List<LatLng> polylinePoints = _decodePolyline(encodedPolyline);

        // Convert distance to kilometers and check if driver is nearby
        double distanceInKm = _convertDistanceToKm(distance);

        // Fetch the custom car icon from the network
        BitmapDescriptor carIcon;
        try {
          carIcon = await _getNetworkCarIcon(
              'https://firebasestorage.googleapis.com/v0/b/vistafeedd.appspot.com/o/Assets%2Fimages-removebg-preview%20(1).png?alt=media&token=80f80ee3-6787-4ddc-8aad-f9ce400461ea');
        } catch (e) {
          print('Failed to load custom car icon: $e');
          carIcon = BitmapDescriptor.defaultMarker; // Fallback to default marker
        }
        BitmapDescriptor pinIcon;
        try {
          pinIcon = await _getNetworkCarIcon(
              'https://firebasestorage.googleapis.com/v0/b/vistafeedd.appspot.com/o/Assets%2Fpngimg.com%20-%20pin_PNG27.png?alt=media&token=a7926167-44dd-4938-b74f-030f0487e5b4');
        } catch (e) {
          print('Failed to load custom car icon: $e');
          pinIcon = BitmapDescriptor.defaultMarker; // Fallback to default marker
        }
        setState(() {
          isdrivernearby = distanceInKm < 1;

          Time = duration;
          DistanceTravel = distance;

          // Add markers for driver's current location and pickup location
          _markers.add(Marker(
              markerId: MarkerId('driver'),
              position: driverCurrentLocation,
              icon: carIcon,
              // Use the custom network car icon
              infoWindow:  InfoWindow(
                  title:rideverified?'Your current location':'Driver\'s Current Location',
                  snippet:rideverified?'You are $DistanceTravel away from your drop location':'$drivername is $DistanceTravel away from you'
              )));
          _markers.add(Marker(
            markerId: MarkerId('pickup'),
            icon: pinIcon,
            position:rideverified?_dropoffLocation: _pickupLocation,
            infoWindow: InfoWindow(
                title:rideverified?'Drop Location':'Pickup Location',
                snippet:
                'Drop Location arriving in $Time'),
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
  double _convertDistanceToKm(String distance) {
    if (distance.contains('km')) {
      return double.parse(distance.replaceAll(' km', '').trim());
    } else if (distance.contains('m')) {
      return double.parse(distance.replaceAll(' m', '').trim()) / 1000;
    }
    return 0.0;
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
  String rideid='';
  Future<void>fetchactiverides()async{
    final docsnap=await _firestore.collection('VistaRide Driver Details').doc(_auth.currentUser!.uid).get();
    if(docsnap.exists){
      setState(() {
        rideid=docsnap.data()?['Ride Doing'];
      });
    }
    if (kDebugMode) {
      print('Ride Doing $rideid');
    }
  }
  late Timer _timetofetch;
  bool ridestarted = false;
  bool rideverified=false;
  String driverid = '';
  String drivername = '';
  String driverprofilephoto = '';
  String carnumber = '';
  String carphoto = '';
  String carname = '';
  double rating = 0;
  String cabcategory='';
  int rideotp = 0;
  String phonenumber = '';
  double pickuplong = 0;
  double pickuplat = 0;
  double droplong = 0;
  String pickuploc = '';
  String droploc = '';
  double droplat = 0;
  bool isamountpaid=false;
  double price=0;
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
        price=docsnap.data()?['Fare'];
        droplong = docsnap.data()?['Drop Longitude'];
        pickuploc = docsnap.data()?['Pickup Location'];
        droploc = docsnap.data()?['Drop Location'];
        cabcategory=docsnap.data()?['Cab Category'];
        rideverified=docsnap.data()?['Ride Verified'];
      });
      print('Ride Verified $rideverified');
    }
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
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _timetofetch.cancel();
  }
  final TextEditingController _OTPController=TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchactiverides();
    fetchridedetails();
    _getCurrentLocation();
    // _timetofetch = Timer.periodic(const Duration(seconds: 5), (Timer t) {
    //   fetchridedetails();
    //   // _getCurrentLocation();
    // });
  }
  bool isotpverification=false;
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
            polylines: _polylines,
            markers: _markers,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: false,
            buildingsEnabled: true,
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
          ),
          Positioned(
              bottom: 0,
              child: Container(
            height: 350,
            width: MediaQuery.sizeOf(context).width,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.only(left: 20,right: 20),
              child: SingleChildScrollView(
                child:!isotpverification?Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    isdrivernearby? const SizedBox(
                      height: 20,
                    ):Container(),
                   isdrivernearby? Center(
                      child: Text('Rider has been notified',style: GoogleFonts.poppins(
                          color: Colors.black,fontWeight: FontWeight.w600,fontSize: 18
                      ),),
                    ):Container(),
                    const SizedBox(
                      height: 20,
                    ),
                    Text('You are $DistanceTravel ($Time) away from your trip',style: GoogleFonts.poppins(
                      color: Colors.black,fontWeight: FontWeight.w500
                    ),),
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
                            pickuploc,
                            maxLines: 5, // Ensures the text doesn't exceed 5 lines
                            overflow: TextOverflow.ellipsis, // Adds ellipsis if text is too long
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
                          Icons.pin_drop_rounded,
                          color: Colors.red,
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        Flexible(
                          child: Text(
                            droploc,
                            maxLines: 5, // Ensures the text doesn't exceed 5 lines
                            overflow: TextOverflow.ellipsis, // Adds ellipsis if text is too long
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
                    rideverified?InkWell(
                      onTap: (){
                        // setState(() {
                        //   isotpverification=true;
                        // });
                      },
                      child: Container(
                        height: 60,
                        width: MediaQuery.sizeOf(context).width,
                        decoration:  const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(50)),
                            color: Colors.red
                        ),
                        child: Center(
                          child: Text('END TRIP',style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w500
                          ),),
                        ),
                      ),
                    ): InkWell(
                      onTap: (){
                        setState(() {
                          isotpverification=true;
                        });
                      },
                      child: Container(
                        height: 60,
                        width: MediaQuery.sizeOf(context).width,
                        decoration:  const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(50)),
                            color: Colors.green
                        ),
                        child: Center(
                          child: Text('Verify OTP',style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontWeight: FontWeight.w500
                          ),),
                        ),
                      ),
                    ),
                  ],
                ):Column(
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    Text('Enter the OTP to start the trip.',style: GoogleFonts.poppins(
                        color: Colors.black,fontWeight: FontWeight.w600,fontSize: 18
                    ),),
                    const SizedBox(
                      height: 40,
                    ),
                    Container(
                      width: MediaQuery.sizeOf(context).width,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.black,
                        ),
                        borderRadius: const BorderRadius.all(Radius.circular(50))
                      ),
                      child: TextField(
                        controller: _OTPController,
                        keyboardType: TextInputType.name,
                        decoration: const InputDecoration(
                          border: InputBorder.none, // Removes the outline border
                          hintText: 'Enter OTP to start trip.',
                          contentPadding: EdgeInsets.all(10), // Optional: adjust padding
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    InkWell(
                      onTap: ()async{
                        final prefs=await SharedPreferences.getInstance();
                        if (kDebugMode) {
                          print('OTP ${_OTPController.text}');
                        }
                        int? enteredOtp = int.tryParse(_OTPController.text);
                        if (enteredOtp != null && rideotp == enteredOtp) {
                          if (kDebugMode) {
                            print("Verified");
                          }
                          await _firestore
                              .collection('Ride Details')
                              .doc(prefs.getString('Booking ID')).update({
                            'Ride Verified':true
                          });
                          await _getCurrentLocation();
                          setState(() {
                            isotpverification=false;
                            rideverified=true;
                          });
                        } else {
                          if (kDebugMode) {
                            print("Invalid OTP");
                          }
                        }

                      },
                      child: Container(
                        height: 60,
                        width: MediaQuery.sizeOf(context).width,
                        decoration:  const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(50)),
                            color: Colors.green
                        ),
                        child: Center(
                          child: Text('Verify OTP',style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontWeight: FontWeight.w500
                          ),),
                        ),
                      ),
                    ),
                  ],
                )
              ),
            ),
          ))
        ],
      ),
    );
  }
}