import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'dart:io';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:path/path.dart' as p;
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:record/record.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vistaride/Driver%20Chat/chatpage.dart';
import 'package:vistaride/Home%20Page/HomePage.dart';
import '../Environment Files/.env.dart';
import 'package:image/image.dart' as img;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_core/firebase_core.dart';

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
  String paymentid = '';
  Future<void> fetchpaymentid() async {
    await fetchridedetails();
    final prefs = await SharedPreferences.getInstance();
    final docsnap = await _firestore
        .collection('Payment ID')
        .doc(prefs.getString('Booking ID'))
        .get();
    if (docsnap.exists) {
      setState(() {
        paymentid = docsnap.data()?['Payment ID'];
      });
    }
    if (kDebugMode) {
      print('Payment ID $paymentid');
    }
  }

  Future<void> processRefund() async {
    await fetchridedetails();
    await fetchpaymentid();
    // Razorpay credentials
    const String keyId = Environment.razorpaytestapi;
    const String keySecret = Environment.razorpaytestkeysecret;

    // Base64 encode the credentials
    String basicAuth =
        'Basic ${base64Encode(utf8.encode('$keyId:$keySecret'))}';

    // API Endpoint
    String url = 'https://api.razorpay.com/v1/payments/$paymentid/refund';

    // Request body
    final Map<String, dynamic> requestBody = {
      "amount": price * 100,
      "speed": "optimum",
    };

    try {
      // Make the HTTP POST request
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': basicAuth,
        },
        body: jsonEncode(requestBody),
      );

      // Check the response
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (kDebugMode) {
          print("Refund processed successfully:");
        }
        if (kDebugMode) {
          print(response.body);
        }
      } else {
        if (kDebugMode) {
          print("Failed to process refund:");
        }
        if (kDebugMode) {
          print(response.body);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error occurred: $e");
      }
    }
  }

  FlutterSoundRecorder _audioRecorder = FlutterSoundRecorder();
  String _recordingPath = '';
  Future<void> uploadToFirebaseStorage(String filePath) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? bookingId = prefs.getString('Booking ID');

      if (bookingId == null) {
        print('Booking ID not found!');
        return;
      }

      // Create a reference to Firebase Storage with the booking ID
      FirebaseStorage storage = FirebaseStorage.instance;
      Reference storageRef = storage.ref().child(
          'recordings/$bookingId/${DateTime.now().millisecondsSinceEpoch}.wav');

      // Upload the file to Firebase Storage
      File file = File(filePath);
      await storageRef.putFile(file);

      // Get the download URL
      String downloadUrl = await storageRef.getDownloadURL();

      // Save the download URL in Firestore
      await saveRecordingUrlToFirestore(downloadUrl);
    } catch (e) {
      print('Error uploading file: $e');
    }
  }

  Future<void> saveRecordingUrlToFirestore(String downloadUrl) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? bookingId = prefs.getString('Booking ID');

      if (bookingId == null) {
        print('Booking ID not found!');
        return;
      }

      // Save the URL to Firestore in the Ride Details collection
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      await firestore.collection('Ride Details').doc(bookingId).update({
        'Emergency Audio Recording': FieldValue.arrayUnion([downloadUrl]),
      });

      if (kDebugMode) {
        print('Recording URL saved to Firestore: $downloadUrl');
      }
    } catch (e) {
      print('Error saving URL to Firestore: $e');
    }
  }

  late Stream<Position> _positionStream;
  stt.SpeechToText _speechToText = stt.SpeechToText();
  bool _isListening = false;
  String _text = "Say something...";
  bool _micWorking = true;
  Future<void> _requestPermissions() async {
    PermissionStatus status = await Permission.microphone.request();
    if (status.isGranted) {
        _startListening();

    } else {
      setState(() {
        _micWorking = false;  // If permission is denied
      });
    }
    print('Mic Working $_micWorking');
  }
  bool isvoicemergency=false;
  void _startListening() async {
    print('Listening');
    bool available = await _speechToText.initialize();
    if (available) {
      setState(() {
        _isListening = true;
        _micWorking = true;
      });
      _speechToText.listen(
        onResult: (result) {
          setState(() {
            _text = result.recognizedWords;
          });

          // Print the recognized speech in real-time
          if (kDebugMode) {
            print("Recognized speech: ${result.recognizedWords}");
          }
          if(result.recognizedWords.contains('emergency')){
            setState(() {
              // isrecording=true;
              // _micWorking=false;
              isvoicemergency=true;
            });
            if (kDebugMode) {
              print('Emergency');
            }
          }
        },
        listenFor: const Duration(seconds: 10), // Listen for 30 seconds or however long you need
        pauseFor: const Duration(seconds: 3), // If there's a pause for 3 seconds, it will still keep recognizing
      );
    } else {
      setState(() {
        _micWorking = false;  // If initialization fails
      });
      print("Microphone is not working. Please check your device.");
    }
  }

  // Stop listening
  void _stopListening() {
    setState(() {
      _isListening = false;
    });
    print('Listening Stopped');
    _speechToText.stop();
  }
  @override
  void initState() {
    super.initState();
    _fetchRoute();
    fetchridedetails();
    // _requestPermissions();
    fetchpaymentid();
    _positionStream = Geolocator.getPositionStream(
      desiredAccuracy: LocationAccuracy.high,
      distanceFilter:
          10, // Update location when the user moves at least 10 meters
    );
    _positionStream.listen((Position position) {
      _updateUserLocation(position);
    });
    _timertofetch = Timer.periodic(const Duration(seconds: 5), (Timer t) {
      fetchridedetails();
    });
  }
  LatLng _userCurrentLocation = const LatLng(0.0, 0.0);
  Future<void> _updateUserLocation(Position position) async {
    setState(() {
      _userCurrentLocation = LatLng(position.latitude, position.longitude);
    });

    // Now fetch the route every time the location updates
    await _fetchRoute();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _speechToText.stop();
    super.dispose();
    _timertofetch.cancel();
  }

  String drivercurrentlongitude = '';
  String drivercurrentlatitude = '';
  String Time = '';
  String? pickup;
  bool showaudiorecord=true;
  String? dropoffloc;
  String DistanceTravel = '';
  bool isdrivernearby = false;
  bool istripdone = false;
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

  bool isEmergency = false;
  Future<void> _fetchRoute() async {
    await fetchridedetails();

    // Check if pickup and dropoff locations are valid
    if (pickuplat == 0 || pickuplong == 0 || droplat == 0 || droplong == 0) {
      print('Invalid coordinates: Unable to fetch route.');
      return;
    }

    // User's current location as origin
    LatLng userCurrentLocation = _userCurrentLocation;

    // Update the pickup and dropoff locations
    setState(() {
      _pickupLocation = LatLng(pickuplat, pickuplong);
      _dropoffLocation = LatLng(droplat, droplong);
    });

    const String apiKey = Environment.GoogleMapsAPI;
    final String url1 =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${userCurrentLocation.latitude},${userCurrentLocation.longitude}&destination=${_dropoffLocation.latitude},${_dropoffLocation.longitude}&key=$apiKey';
    final String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${userCurrentLocation.latitude},${userCurrentLocation.longitude}&destination=${_pickupLocation.latitude},${_pickupLocation.longitude}&key=$apiKey';

    if (kDebugMode) {
      print('URL $url');
    }

    final response = await http.get(Uri.parse(rideverified ? url1 : url));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data['routes'].isNotEmpty) {
        final duration = data['routes'][0]['legs'][0]['duration']['text'];
        final distance = data['routes'][0]['legs'][0]['distance']['text'];

        // Decode the polyline
        String encodedPolyline =
            data['routes'][0]['overview_polyline']['points'];
        List<LatLng> polylinePoints = _decodePolyline(encodedPolyline);

        // Convert distance to kilometers and check if user is nearby
        double distanceInKm = _convertDistanceToKm(distance);

        // Check if the user is deviating from the expected route
        if (_isDeviatingFromRoute(userCurrentLocation, polylinePoints)) {
          setState(() {
            isEmergency = true; // Set emergency flag if deviating
          });
        } else {
          setState(() {
            isEmergency = false; // No emergency
          });
        }

        // Fetch the custom car icon from the network
        BitmapDescriptor carIcon;
        try {
          carIcon = await _getNetworkCarIcon(
              'https://firebasestorage.googleapis.com/v0/b/vistafeedd.appspot.com/o/Assets%2Fimages-removebg-preview%20(1).png?alt=media&token=80f80ee3-6787-4ddc-8aad-f9ce400461ea');
        } catch (e) {
          print('Failed to load custom car icon: $e');
          carIcon =
              BitmapDescriptor.defaultMarker; // Fallback to default marker
        }

        BitmapDescriptor pinIcon;
        try {
          pinIcon = await _getNetworkCarIcon(
              'https://firebasestorage.googleapis.com/v0/b/vistafeedd.appspot.com/o/Assets%2Fpngimg.com%20-%20pin_PNG27.png?alt=media&token=a7926167-44dd-4938-b74f-030f0487e5b4');
        } catch (e) {
          print('Failed to load custom car icon: $e');
          pinIcon =
              BitmapDescriptor.defaultMarker; // Fallback to default marker
        }

        setState(() {
          isdrivernearby = distanceInKm < 1;

          Time = duration;
          DistanceTravel = distance;

          // Add markers for user's current location and pickup location
          _markers.add(Marker(
              markerId: MarkerId('user'),
              position: userCurrentLocation,
              icon: carIcon,
              infoWindow: InfoWindow(
                  title: rideverified
                      ? 'Your current location'
                      : 'User\'s Current Location',
                  snippet: rideverified
                      ? 'You are $DistanceTravel away from your drop location'
                      : '$drivername is $DistanceTravel away from you')));

          _markers.add(Marker(
            markerId: MarkerId('pickup'),
            icon: pinIcon,
            position: rideverified ? _dropoffLocation : _pickupLocation,
            infoWindow: InfoWindow(
                title: rideverified ? 'Drop Location' : 'Pickup Location',
                snippet: 'Drop Location arriving in $Time'),
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
          print('Is user nearby: $isdrivernearby');
          print('Is Emergency: $isEmergency');
        }
      }
    } else {
      print('Failed to load route');
    }
  }

// Method to check if the user is deviating from the route
  bool _isDeviatingFromRoute(LatLng userLocation, List<LatLng> polylinePoints) {
    const double threshold = 100.0; // 100 meters threshold for deviation

    // Find the closest point on the polyline to the user's current location
    double minDistance = double.infinity;

    for (LatLng point in polylinePoints) {
      double distance = _calculateDistance(userLocation.latitude,
          userLocation.longitude, point.latitude, point.longitude);
      if (distance < minDistance) {
        minDistance = distance;
      }
    }

    return minDistance > threshold;
  }

// Helper method to calculate distance between two lat/lng points
  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371000; // meters
    double dLat = _degToRad(lat2 - lat1);
    double dLon = _degToRad(lon2 - lon1);

    double a = (sin(dLat / 2) * sin(dLat / 2)) +
        (cos(_degToRad(lat1)) *
            cos(_degToRad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2));
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c; // Returns the distance in meters
  }

// Helper method to convert degrees to radians
  double _degToRad(double deg) {
    return deg * (pi / 180);
  }

  Future<Position?> _getUserLocation() async {
    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('Location services are disabled.');
      return null;
    }

    // Check location permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Location permission denied.');
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('Location permission permanently denied.');
      return null;
    }

    // Get the user's current position
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    return position;
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
  Future<void> capturepayment(String paymentid) async {
    final prefs = await SharedPreferences.getInstance();
    // Razorpay credentials
    const String keyId = Environment.razorpaytestapi;
    const String keySecret = Environment.razorpaytestkeysecret;

    // Base64 encode the credentials
    String basicAuth =
        'Basic ${base64Encode(utf8.encode('$keyId:$keySecret'))}';

    // API Endpoint
    String url = 'https://api.razorpay.com/v1/payments/$paymentid/capture';

    // Request body
    final Map<String, dynamic> requestBody = {
      "amount": (prefs.getDouble('Fare'))! * 100,
      "currency": "INR"
    };

    try {
      // Make the HTTP POST request
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': basicAuth,
        },
        body: jsonEncode(requestBody),
      );

      // Check the response
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (kDebugMode) {
          print("Refund processed successfully:");
        }
        if (kDebugMode) {
          print(response.body);
        }
      } else {
        if (kDebugMode) {
          print("Failed to process refund:");
        }
        if (kDebugMode) {
          print(response.body);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error occurred: $e");
      }
    }
  }
  void handlePaymentErrorResponse(PaymentFailureResponse response) {}

  void handlePaymentSuccessResponse(PaymentSuccessResponse response) async {
    final prefs = await SharedPreferences.getInstance();
    await _firestore
        .collection('Payment ID')
        .doc(prefs.getString('Booking ID'))
        .set({'Payment ID': response.paymentId});
    await _firestore.collection('Ride Details').doc(prefs.getString('Booking ID')).update(
        {
          'Cash Payment':false
        });
    await capturepayment(response.paymentId!);
    setState(() {
      iscashpayment=false;
    });
  }
  bool ridestarted = false;
  bool rideverified = false;
  String driverid = '';
  String drivername = '';
  String driverprofilephoto = '';
  String carnumber = '';
  String carphoto = '';
  String carname = '';
  double rating = 0;
  String cabcategory = '';
  int rideotp = 0;
  String phonenumber = '';
  double pickuplong = 0;
  double pickuplat = 0;
  double droplong = 0;
  String pickuploc = '';
  String droploc = '';
  double droplat = 0;
  bool isamountpaid = false;
  bool iscashpayment = false;
  double price = 0;
  bool isridecancelled=false;
  Future<void> fetchridedetails() async {
    try {
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
          price = docsnap.data()?['Fare'] is int
              ? (docsnap.data()?['Fare']).toDouble()
              : docsnap.data()?['Fare'] is double
                  ? (docsnap.data()?['Fare']) as double
                  : 0.0;
          isridecancelled=docsnap.data()?['Ride Cancelled']??false;
          droplong = docsnap.data()?['Drop Longitude'];
          pickuploc = docsnap.data()?['Pickup Location'];
          droploc = docsnap.data()?['Drop Location'];
          cabcategory = docsnap.data()?['Cab Category'];
          rideverified = docsnap.data()?['Ride Verified'];
          istripdone = docsnap.data()?['Ride Completed'];
          isamountpaid = docsnap.data()?['Amount Paid'] ?? false;
          iscashpayment = docsnap.data()?['Cash Payment'] ?? false;
        });
      }
      print('Trip Done $isamountpaid');
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
          drivercurrentlatitude = Docsnap.data()?['Current Latitude'];
          drivercurrentlongitude = Docsnap.data()?['Current Longitude'];
        });
      }
      if(isridecancelled){
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(),
            ));
      }
      if (isamountpaid) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(),
            ));
      }
    } catch (e) {
      print('Error in fetching ride $e');
    }
  }

  String? recordingpath;
  final record = AudioRecorder();
  bool isrecording = false;
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
            top: 40,
            right: 20,
            child: InkWell(
            onTap: ()async{
              final prefs=await SharedPreferences.getInstance();
              Navigator.push(context, MaterialPageRoute(builder: (context) => DriverChat(RideID: prefs.getString('Booking ID')!),));
            },
            child: const CircleAvatar(
              backgroundColor: Colors.white,
              radius: 25,
              child: Icon(
                Icons.chat,
                color: Colors.blue,
              ),
            ),
          ),),
          showaudiorecord?Positioned(
            top: 60,
            child: Padding(
              padding: const EdgeInsets.only(left: 30, right: 30),
              child: GestureDetector(
                onHorizontalDragUpdate: (value) {
                  setState(() {
                    showaudiorecord=false;
                  });
                },
                child: Container(
                  // height: 100,
                  decoration: const BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.all(Radius.circular(20))
                  ),
                  width: MediaQuery.of(context).size.width -
                      60, // Subtract 30px from each side
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20,right: 20,top: 20,bottom: 20),
                      child: Text(
                        "For your safety and security, please be aware that audio recording will take place throughout the trip. "
                            "This helps monitor the environment and ensure a secure experience for everyone. Thank you."
                        ,style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 13,
                          // letterSpacing: 5,
                          fontWeight: FontWeight.w400
                      ),),
                    ),
                  ),
                ),
              ),
            ),
          ):Container(),
          isEmergency? Positioned(
            top: 60,
            child: Padding(
              padding: const EdgeInsets.only(left: 30, right: 30),
              child: Container(
                // height: 100,
                decoration: const BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.all(Radius.circular(20))
                ),
                width: MediaQuery.of(context).size.width -
                    60, // Subtract 30px from each side
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20,right: 20,top: 20,bottom: 20),
                    child: Text(
                        "Hi ${_auth.currentUser!.displayName}, it seems the driver is on the wrong route. We're on it and working to get you "
                            "back on track quickly and safely. Please don't worry—your safety is our priority. Thanks for your understanding!"
                      ,style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 13,
                      // letterSpacing: 5,
                      fontWeight: FontWeight.w400
                    ),),
                  ),
                ),
              ),
            ),
          ):Container(),
          istripdone
              ? Center(
                  child: Container(
                    height: 250,
                    width: 300,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color: Colors.white,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(
                          height: 20,
                        ),
                        Text(
                          'Trip Completed',
                          style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                              fontSize: 17),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Divider(
                          color: Colors.grey,
                          thickness: 0.5,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Text(
                          '₹$price',
                          style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                              fontSize: 30),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: Text(
                            'Please pay the fare amount (₹$price) to the driver.',
                            textAlign: TextAlign
                                .center, // Ensures text wraps and stays centered
                            style: GoogleFonts.poppins(
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  ),
                )
              : Container(),
          istripdone
              ? Container()
              : Positioned(
                  bottom: 320,
                  left: 20,
                  child: Container(
                    height: 70,
                    width: 85,
                    decoration: BoxDecoration(
                        color: isdrivernearby || rideverified
                            ? Colors.purple
                            : Colors.white,
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
                                color: isdrivernearby || rideverified
                                    ? Colors.white
                                    : Colors.purple,
                                fontWeight: FontWeight.bold,
                                fontSize: 18),
                          ),
                          Text(
                            'Start OTP',
                            style: GoogleFonts.poppins(
                                color: isdrivernearby || rideverified
                                    ? Colors.white
                                    : Colors.grey,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
           rideverified?Positioned(
            bottom: 350,
            right: 80,
            child: InkWell(
              onTap: ()async{
                final prefs=await SharedPreferences.getInstance();
                Share.share("I've booked an VistaRide. Track this ride: https://vistaride.vercel.app/ride/${prefs.getString('Booking ID')}\n"
                    "Vehicle number: $carnumber\n"
                    "Start OTP: $rideotp (needed to start the ride)\n"
                    "Driver contact number: $phonenumber");
              },
              child: const CircleAvatar(
              backgroundColor: Colors.white,
              radius: 25,
              child: Icon(
                Icons.telegram,
                color: Colors.blue,
              ),
                        ),
            ),):Container(),
          rideverified
              ? Positioned(
                  bottom: 350,
                  right: 20,
                  child: InkWell(
                    onTap: () {
                      if (kDebugMode) {
                        print('Support Started');
                      }
                      showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return Container(
                            height: 400,
                            width: MediaQuery.sizeOf(context).width,
                            color: Colors.white,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  height: 30,
                                ),
                                Center(
                                  child: Text(
                                    'Safety Toolkit',
                                    style: GoogleFonts.poppins(
                                        color: Colors.black,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                                const SizedBox(
                                  height: 40,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    const Icon(
                                      Icons.mic,
                                      color: Colors.black,
                                      size: 30,
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Record Audio',
                                          style: GoogleFonts.poppins(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 20),
                                        ),
                                        Text(
                                          'Record Audio to send to VistaRide',
                                          style: GoogleFonts.poppins(
                                              color: Colors.grey,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 12),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      width: 20,
                                    ),
                                    InkWell(
                                      onTap: () async {
                                        final prefs = await SharedPreferences
                                            .getInstance();

                                        if (isrecording) {
                                          String? filePath =
                                              await record.stop();
                                          if (filePath != null) {
                                            setState(() {
                                              isrecording = false;
                                              recordingpath = filePath;
                                            });
                                            if (kDebugMode) {
                                              print(
                                                  'Saved recording to $recordingpath');
                                            }
                                            await uploadToFirebaseStorage(
                                                filePath);
                                          }
                                        } else {
                                          if (await record.hasPermission()) {
                                            final Directory appdocumentsdir =
                                                await getApplicationDocumentsDirectory();
                                            final String filepath = p.join(
                                                appdocumentsdir.path,
                                                '${prefs.getString('Booking ID')}recording.wav');
                                            await record.start(
                                                const RecordConfig(),
                                                path: filepath);
                                            setState(() {
                                              isrecording = true;
                                              recordingpath = null;
                                            });
                                          }
                                        }
                                      },
                                      child: Container(
                                        width: 80,
                                        height: 40,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(50)),
                                            color: Colors.grey.shade200),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Icon(
                                              isrecording
                                                  ? Icons.square
                                                  : Icons.stop_circle,
                                              color: Colors.red,
                                            ),
                                            Text(
                                              isrecording ? 'STOP' : 'START',
                                              style: GoogleFonts.poppins(
                                                  color: isrecording
                                                      ? Colors.red
                                                      : Colors.black),
                                            )
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                const SizedBox(
                                  height: 50,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    const Icon(
                                      Icons.add_road_rounded,
                                      color: Colors.black,
                                      size: 30,
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Trip Detection',
                                          style: GoogleFonts.poppins(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 20),
                                        ),
                                        Text(
                                          'Send alert if unwanted route is taken',
                                          style: GoogleFonts.poppins(
                                              color: Colors.grey,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 12),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    InkWell(
                                      onTap: () {},
                                      child: Container(
                                          width: 80,
                                          height: 40,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(50)),
                                              color: Colors.grey.shade200),
                                          child: Center(
                                              child: Text(
                                            'Active',
                                            style: GoogleFonts.poppins(
                                                color: Colors.blue,
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600),
                                          ))),
                                    )
                                  ],
                                ),
                                const SizedBox(
                                  height: 50,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    const Icon(
                                      Icons.add_road_rounded,
                                      color: Colors.black,
                                      size: 30,
                                    ),
                                    const SizedBox(
                                      width: 20,
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '100 Assistance',
                                          style: GoogleFonts.poppins(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 20),
                                        ),
                                        Text(
                                          'Inform police in case of any emergency',
                                          style: GoogleFonts.poppins(
                                              color: Colors.grey,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 12),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      width: 20,
                                    ),
                                    InkWell(
                                      onTap: () async {
                                        final Uri phoneUri =
                                            Uri(scheme: 'tel', path: '1111');
                                        if (await canLaunchUrl(phoneUri)) {
                                          await launchUrl(phoneUri);
                                        } else {
                                          throw 'Could not launch $phoneUri';
                                        }
                                      },
                                      child: Container(
                                          width: 80,
                                          height: 40,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(50)),
                                              color: Colors.grey.shade200),
                                          child: Center(
                                              child: Text(
                                            'Call',
                                            style: GoogleFonts.poppins(
                                                color: Colors.red,
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600),
                                          ))),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    child: const CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 25,
                      child: Icon(
                        Icons.security,
                        color: Colors.blue,
                      ),
                    ),
                  ))
              : Container(),
          istripdone
              ? Container()
              : Positioned(
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
                          rideverified
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.check,
                                      color: Colors.green,
                                    ),
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
                                )
                              : Text(
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
                            height: 10,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: Row(
                              children: [
                                rideverified
                                    ? Text(
                                        'Reaching destination in $Time ($DistanceTravel)',
                                        style: GoogleFonts.poppins(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w600),
                                      )
                                    : Text(
                                        'Driver arriving in $Time',
                                        style: GoogleFonts.poppins(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w600),
                                      ),
                              ],
                            ),
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
                                        const Icon(
                                          Icons.star,
                                          color: Colors.yellow,
                                        ),
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
                                  backgroundImage:
                                      NetworkImage(driverprofilephoto),
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
                            padding: const EdgeInsets.only(left: 20, right: 20),
                            child: Row(
                              children: [
                                InkWell(
                                  onTap: () async {
                                    final Uri phoneUri =
                                        Uri(scheme: 'tel', path: phonenumber);
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
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(10)),
                                      border: Border.all(
                                          color: Colors.grey, width: 0.5),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 10, right: 10),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.call,
                                            color: Colors.black,
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            'Contact',
                                            style: GoogleFonts.poppins(
                                                color: Colors.black,
                                                fontWeight: FontWeight.w600),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 20,
                                ),
                               iscashpayment? InkWell(
                                  onTap: () async {
                                    Razorpay razorpay = Razorpay();
                                    var options = {
                                      'key': Environment.razorpaytestapi,
                                      'amount': price * 100,
                                      'name': 'VistaRide',
                                      'description': 'Trip to $dropoffloc from $pickup',
                                      'retry': {'enabled': true, 'max_count': 1},
                                      'send_sms_hash': true,
                                      'external': {
                                        'wallets': ['paytm']
                                      }
                                    };
                                    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR,
                                        handlePaymentErrorResponse);
                                    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS,
                                        handlePaymentSuccessResponse);
                                    razorpay.open(options);
                                  },
                                  child: Container(
                                    height: 50,
                                    width: 120,
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(10)),
                                      border: Border.all(
                                          color: Colors.grey, width: 0.5),
                                    ),
                                    child: const Padding(
                                      padding: EdgeInsets.only(
                                          left: 10, right: 10),
                                      child: Image(image: NetworkImage('https://cdn.iconscout.com/icon/free/png-256/free-upi-logo-icon-download-in-svg-png-gif-file-'
                                          'formats--unified-payments-interface-payment-money-transfer-logos-icons-1747946.png?f=webp'))
                                    ),
                                  ),
                                ):Container(),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 20, right: 20, top: 20),
                            child: InkWell(
                              child: Container(
                                width: MediaQuery.sizeOf(context).width,
                                height: 40,
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.grey, width: 0.5)),
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
                                      style: GoogleFonts.poppins(
                                          color: Colors.black),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    )),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 20, right: 20, top: 30, bottom: 20),
                            child: InkWell(
                              child: Container(
                                width: MediaQuery.sizeOf(context).width,
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.grey, width: 0.5)),
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
                                      style: GoogleFonts.poppins(
                                          color: Colors.black),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    )),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.only(
                                left: 20, right: 20, top: 10, bottom: 20),
                            child: InkWell(
                              child: Container(
                                width: MediaQuery.sizeOf(context).width,
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.grey, width: 0.5)),
                                height: 40,
                                child: Row(
                                  children: [
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    !iscashpayment
                                        ? const Icon(
                                            Icons.credit_card,
                                            color: Colors.black,
                                          )
                                        : const Icon(
                                            Icons.currency_rupee_sharp,
                                            color: Colors.black,
                                          ),
                                    const SizedBox(
                                      width: 20,
                                    ),
                                    Expanded(
                                        child: Text(
                                      '₹$price (${iscashpayment ? 'Cash' : 'Online'})',
                                      style: GoogleFonts.poppins(
                                          color: Colors.black),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    )),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          !rideverified
                              ? Padding(
                            padding: const EdgeInsets.only(
                                left: 20, right: 20,bottom: 20),
                            child: InkWell(
                              onTap: () async {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    String? selectedReason; // Variable to store selected cancellation reason

                                    return AlertDialog(
                                      backgroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      title: Center(
                                        child: Text(
                                          'Cancel Ride',
                                          style: GoogleFonts.poppins(
                                            color: Colors.black,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      content: StatefulBuilder(
                                        builder: (BuildContext context, StateSetter setState) {
                                          return Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              ListTile(
                                                title: Text(
                                                  'Driver is taking too long',
                                                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.black),
                                                ),
                                                leading: Radio<String>(
                                                  value: 'Driver is taking too long',
                                                  groupValue: selectedReason,
                                                  onChanged: (String? value) {
                                                    setState(() {
                                                      selectedReason = value;
                                                    });
                                                  },
                                                ),
                                              ),
                                              ListTile(
                                                title: Text(
                                                  'Change of plans',
                                                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.black),
                                                ),
                                                leading: Radio<String>(
                                                  value: 'Change of plans',
                                                  groupValue: selectedReason,
                                                  onChanged: (String? value) {
                                                    setState(() {
                                                      selectedReason = value;
                                                    });
                                                  },
                                                ),
                                              ),
                                              ListTile(
                                                title: Text(
                                                  'Booked another cab',
                                                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.black),
                                                ),
                                                leading: Radio<String>(
                                                  value: 'Booked another cab',
                                                  groupValue: selectedReason,
                                                  onChanged: (String? value) {
                                                    setState(() {
                                                      selectedReason = value;
                                                    });
                                                  },
                                                ),
                                              ),
                                              ListTile(
                                                title: Text(
                                                  'Fare is too high',
                                                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.black),
                                                ),
                                                leading: Radio<String>(
                                                  value: 'Fare is too high',
                                                  groupValue: selectedReason,
                                                  onChanged: (String? value) {
                                                    setState(() {
                                                      selectedReason = value;
                                                    });
                                                  },
                                                ),
                                              ),
                                              ListTile(
                                                title: Text(
                                                  'Other',
                                                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.black),
                                                ),
                                                leading: Radio<String>(
                                                  value: 'Other',
                                                  groupValue: selectedReason,
                                                  onChanged: (String? value) {
                                                    setState(() {
                                                      selectedReason = value;
                                                    });
                                                  },
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop(); // Close dialog
                                          },
                                          child: Text(
                                            'Cancel',
                                            style: GoogleFonts.poppins(
                                              color: Colors.grey,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                        ElevatedButton(
                                          onPressed: ()async{
                                            if (selectedReason != null) {
                                              // Handle the selected cancellation reason
                                              if (kDebugMode) {
                                                print("Selected Reason: $selectedReason");
                                              }
                                              try {
                                                final prefs = await SharedPreferences
                                                    .getInstance();
                                                if (kDebugMode) {
                                                  print(prefs.getString('Booking ID'));
                                                }

                                                // Attempt to fetch payment ID and process refund
                                                await fetchpaymentid();

                                                try {
                                                  await processRefund(); // If this fails, no further code will execute
                                                } catch (e) {
                                                  if (kDebugMode) {
                                                    print('Refund Error: $e');
                                                  }
                                                  return; // Stop execution if refund fails
                                                }

                                                // Proceed to update Firestore and Navigator only if refund was successful
                                                await _firestore
                                                    .collection('Ride Details')
                                                    .doc(prefs.getString('Booking ID'))
                                                    .update({
                                                  'Ride Accepted': false,
                                                  'Ride Cancelled': true,
                                                  'Cancellation Time':
                                                  FieldValue.serverTimestamp(),
                                                });

                                                await _firestore
                                                    .collection(
                                                    'VistaRide Driver Details')
                                                    .doc(driverid)
                                                    .update({
                                                  'Ride Doing': FieldValue.delete(),
                                                  'Driver Avaliable': true,
                                                });

                                                Navigator.pushReplacement(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => HomePage(),
                                                    ));
                                              } catch (e) {
                                                if (kDebugMode) {
                                                  print('General Error: $e');
                                                }
                                              }
                                              Navigator.of(context).pop();
                                            } else {
                                              // Show a message if no reason is selected
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text('Please select a reason to cancel the ride'),
                                                ),
                                              );
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red, // Change to your desired color
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: Text(
                                            'Submit',
                                            style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10)),
                                    border:
                                    Border.all(color: Colors.grey)),
                                width:
                                MediaQuery.sizeOf(context).width - 40,
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
                          )
                              : Padding(
                            padding: const EdgeInsets.only(
                                left: 20, right: 20,bottom: 20),
                            child: InkWell(
                              onTap: () async {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    String? selectedReason; // Variable to store selected cancellation reason

                                    return AlertDialog(
                                      backgroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      title: Center(
                                        child: Text(
                                          'Cancel Ride',
                                          style: GoogleFonts.poppins(
                                            color: Colors.black,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      content: StatefulBuilder(
                                        builder: (BuildContext context, StateSetter setState) {
                                          return Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              ListTile(
                                                title: Text(
                                                  'Driver is taking too long',
                                                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.black),
                                                ),
                                                leading: Radio<String>(
                                                  value: 'Driver is taking too long',
                                                  groupValue: selectedReason,
                                                  onChanged: (String? value) {
                                                    setState(() {
                                                      selectedReason = value;
                                                    });
                                                  },
                                                ),
                                              ),
                                              ListTile(
                                                title: Text(
                                                  'Change of plans',
                                                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.black),
                                                ),
                                                leading: Radio<String>(
                                                  value: 'Change of plans',
                                                  groupValue: selectedReason,
                                                  onChanged: (String? value) {
                                                    setState(() {
                                                      selectedReason = value;
                                                    });
                                                  },
                                                ),
                                              ),
                                              ListTile(
                                                title: Text(
                                                  'Booked another cab',
                                                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.black),
                                                ),
                                                leading: Radio<String>(
                                                  value: 'Booked another cab',
                                                  groupValue: selectedReason,
                                                  onChanged: (String? value) {
                                                    setState(() {
                                                      selectedReason = value;
                                                    });
                                                  },
                                                ),
                                              ),
                                              ListTile(
                                                title: Text(
                                                  'Fare is too high',
                                                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.black),
                                                ),
                                                leading: Radio<String>(
                                                  value: 'Fare is too high',
                                                  groupValue: selectedReason,
                                                  onChanged: (String? value) {
                                                    setState(() {
                                                      selectedReason = value;
                                                    });
                                                  },
                                                ),
                                              ),
                                              ListTile(
                                                title: Text(
                                                  'Other',
                                                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.black),
                                                ),
                                                leading: Radio<String>(
                                                  value: 'Other',
                                                  groupValue: selectedReason,
                                                  onChanged: (String? value) {
                                                    setState(() {
                                                      selectedReason = value;
                                                    });
                                                  },
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop(); // Close dialog
                                          },
                                          child: Text(
                                            'Cancel',
                                            style: GoogleFonts.poppins(
                                              color: Colors.grey,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                        ElevatedButton(
                                          onPressed: ()async{
                                            if (selectedReason != null) {
                                              // Handle the selected cancellation reason
                                              if (kDebugMode) {
                                                print("Selected Reason: $selectedReason");
                                              }
                                              try {
                                                final prefs = await SharedPreferences
                                                    .getInstance();
                                                if (kDebugMode) {
                                                  print(prefs.getString('Booking ID'));
                                                }
                                                // Proceed to update Firestore and Navigator only if refund was successful
                                                await _firestore
                                                    .collection('Ride Details')
                                                    .doc(prefs.getString('Booking ID'))
                                                    .update({
                                                  'Ride Accepted': false,
                                                  'Ride Cancelled': true,
                                                  'Ride Cancelled After Starting':true,
                                                  'Cancellation Reason':selectedReason,
                                                  'Cancellation Time':
                                                  FieldValue.serverTimestamp(),
                                                });
                                                await _firestore
                                                    .collection(
                                                    'VistaRide Driver Details')
                                                    .doc(driverid)
                                                    .update({
                                                  'Ride Doing': FieldValue.delete(),
                                                  'Driver Avaliable': true,
                                                });
                                                Navigator.pushReplacement(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => HomePage(),
                                                    ));
                                              } catch (e) {
                                                if (kDebugMode) {
                                                  print('General Error: $e');
                                                }
                                              }
                                              Navigator.of(context).pop();
                                            } else {
                                              // Show a message if no reason is selected
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('Please select a reason to cancel the ride'),
                                                ),
                                              );
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red, // Change to your desired color
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: Text(
                                            'Submit',
                                            style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );

                              },
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10)),
                                    border:
                                    Border.all(color: Colors.grey)),
                                width:
                                MediaQuery.sizeOf(context).width - 40,
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
                          ),
                        ],
                      ),
                    ),
                  ))
        ],
      ),
    );
  }
}
