import 'dart:async';
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
import 'package:url_launcher/url_launcher.dart';
import 'package:vistaride/Home%20Page/HomePage.dart';
import '../Environment Files/.env.dart';
import 'package:image/image.dart' as img;
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
  late Timer _timertofetch;
  @override
  void initState() {
    super.initState();
    _fetchRoute();
    fetchridedetails();
    _timertofetch = Timer.periodic(const Duration(seconds: 5), (Timer t) {
      fetchridedetails();
      _fetchRoute();
    });
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _timertofetch.cancel();
  }
  String drivercurrentlongitude='';
  String drivercurrentlatitude='';
  String Time = '';
  String? pickup;
  String? dropoffloc;
  String DistanceTravel = '';
  bool isdrivernearby=false;
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

  Future<void> _fetchRoute() async {
    await fetchridedetails();
    if (drivercurrentlatitude.isEmpty || drivercurrentlongitude.isEmpty || pickuplat == 0 || pickuplong == 0) {
      print('Invalid coordinates: Unable to fetch route.');
      return;
    }

    // Driver's current location as origin
    LatLng driverCurrentLocation = LatLng(
      double.parse(drivercurrentlatitude),
      double.parse(drivercurrentlongitude),
    );
    LatLng droplocation = LatLng(
      double.parse(droplat.toString()),
      double.parse(droplong.toString()),
    );
    // Update the pickup location
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
      print('URL $url');
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
          print('Is driver nearby: $isdrivernearby');
        }
      }
    } else {
      print('Failed to load route');
    }
  }


// Helper function to convert distance to kilometers
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
        cabcategory=docsnap.data()?['Cab Category'];
        rideverified=docsnap.data()?['Ride Verified'];
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
        drivercurrentlatitude=Docsnap.data()?['Current Latitude'];
        drivercurrentlongitude=Docsnap.data()?['Current Longitude'];

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
            bottom: 320,
            left: 20,
            child: Container(
              height: 70,
              width: 85,
              decoration:  BoxDecoration(
                  color:isdrivernearby || rideverified?Colors.purple: Colors.white,
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
                          color:isdrivernearby || rideverified?Colors.white: Colors.purple,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    ),
                    Text(
                      'Start OTP',
                      style: GoogleFonts.poppins(
                          color: isdrivernearby || rideverified?Colors.white: Colors.grey, fontWeight: FontWeight.w500),
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
                      rideverified?Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(Icons.check,color: Colors.green,),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            "Ride verified successfully.",
                            style: GoogleFonts.poppins(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ): Text(
                        "Share the 'OTP' before starting trip.",
                        style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontSize: 16,
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
                                Row(
                                  children: [
                                    Text(
                                      drivername,
                                      style: GoogleFonts.poppins(
                                          color: Colors.grey,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    const Icon(Icons.star,color: Colors.yellow,),
                                    Text(
                                      rating.toString(),
                                      style: GoogleFonts.poppins(
                                          color: Colors.grey,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
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
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20,right: 20),
                        child: Row(
                          children: [
                            InkWell(
                              onTap: ()async{
                                final Uri phoneUri = Uri(scheme: 'tel', path: phonenumber);
                                if (await canLaunchUrl(phoneUri)) {
                                  await launchUrl(phoneUri);
                                } else {
                                  throw 'Could not launch $phoneUri';
                                }
                              },
                              child: Container(
                                height: 50,
                                width: 120,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                                  border: Border.all(
                                    color: Colors.grey,
                                    width: 0.5
                                  ),
                                ),
                                child:  Padding(padding: const EdgeInsets.only(left: 10,right: 10),
                                child: Row(
                                  children: [
                                    const Icon(Icons.call,color: Colors.black,),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Text('Contact',style: GoogleFonts.poppins(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600
                                    ),)
                                  ],
                                ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding:
                        const EdgeInsets.only(left: 20, right: 20, top: 20),
                        child: InkWell(
                          child: Container(
                            width: MediaQuery.sizeOf(context).width,
                            height: 40,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.grey,
                                width: 0.5
                              )
                            ),
                            child: Row(
                              children: [
                                const SizedBox(
                                  width: 10,
                                ),
                                const Icon(
                                  Icons.directions_walk,
                                  color: Colors.green,
                                ),
                                const SizedBox(
                                  width: 20,
                                ),
                                Expanded(
                                    child: Text(
                                      pickuploc,
                                      style: GoogleFonts.poppins(color: Colors.black),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    )),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                        const EdgeInsets.only(left: 20, right: 20, top: 30,bottom: 20),
                        child: InkWell(
                          child: Container(
                            width: MediaQuery.sizeOf(context).width,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.grey,width: 0.5
                              )
                            ),
                            height: 40,
                            child: Row(
                              children: [
                                const SizedBox(
                                  width: 10,
                                ),
                                const CircleAvatar(
                                  radius: 5,
                                  backgroundColor: Colors.red,
                                ),
                                const SizedBox(
                                  width: 20,
                                ),
                                Expanded(
                                    child: Text(
                                      droploc,
                                      style: GoogleFonts.poppins(color: Colors.black),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    )),
                              ],
                            ),
                          ),
                        ),
                      ),
                    !rideverified?  Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: InkWell(
                          onTap: ()async{
                            // Navigator.pop(context);
                            final prefs=await SharedPreferences.getInstance();
                            if (kDebugMode) {
                              print(prefs.getString('Booking ID'));
                            }
                            await _firestore.collection('Ride Details').doc(prefs.getString('Booking ID')).update(
                                {
                                  'Ride Accepted':false,
                                  'Ride Cancelled':true,
                                  'Cancellation Time':FieldValue.serverTimestamp(),
                                });
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage(),));
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
                                    color: Colors.red,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ),
                      ):Container(),
                      const SizedBox(
                        height: 20,
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
