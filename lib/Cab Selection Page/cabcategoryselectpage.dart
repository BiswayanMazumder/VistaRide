import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
// import 'package:http/http.dart' as http;
import 'package:vistaride/Cab%20Selection%20Page/CabFindingPage.dart';
import 'package:vistaride/Environment%20Files/.env.dart';
import 'package:vistaride/Promo%20Codes/promocodes.dart';

class CabSelectAndPrice extends StatefulWidget {
  final bool ispromoapplied;  // Declare the field to hold the boolean value

  const CabSelectAndPrice({super.key, required this.ispromoapplied});

  @override
  State<CabSelectAndPrice> createState() => _CabSelectAndPriceState();
}

class _CabSelectAndPriceState extends State<CabSelectAndPrice> {
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

  List<dynamic> driversnearme = [];
  List<String> driverids = [];
  bool isdrivernearby = false;
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

  String? weathercondition;
  int discountperc=0;
  int maxamount=0;
  bool ispromoapplicable = false;
  Future<void> fetchweatherfromcache() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      weathercondition = prefs.getString('Weather Condition');
      ispromoapplicable = prefs.getBool('Promo Applicable') ?? false;
      discountperc=prefs.getInt('Discount Amount')??0;
      maxamount=prefs.getInt('Max Amount')??0;
      if (kDebugMode) {
        print('Promo Applied ${widget.ispromoapplied}');
      }
    });
    if (widget.ispromoapplied) {
      // Decrease each value by 40% (multiply by 0.60)
      cabpricesmultiplier = cabpricesmultiplier
          .asMap() // Convert the list to a map to access indices
          .map((index, price) {
        // If index is 4, don't apply the discount
        if (index == 3) {
          return MapEntry(index, price); // Keep the price unchanged at index 3
        } else {
          return MapEntry(index, (price - discountperc).roundToDouble()); // Apply discount to other prices
        }
      })
          .values // Get the updated list of values
          .toList();

      if (kDebugMode) {
        print('Updated Price $cabpricesmultiplier');
      } // To see the updated list
    }
    if (kDebugMode) {
      print('Fetched from cache $weathercondition');
    }
  }

  Future<void> fetchdrivers() async {
    await _fetchRoute();
    driverids.clear();
    try {
      final QuerySnapshot docsnap = await _firestore
          .collection('VistaRide Driver Details')
          .where('Driver Online', isEqualTo: true)
          .get();

      List<dynamic> nearbyDrivers = [];
      Set<Marker> driverMarkers = {}; // Temporary set for driver markers
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      double? pickuplongitude = prefs.getDouble('location longitude');
      double? pickuplatitude = prefs.getDouble('location latitude');

      for (var doc in docsnap.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final String driverLatitude = data['Current Latitude'] ?? "0.0";
        final String driverLongitude = data['Current Longitude'] ?? "0.0";
        final String cabcategory = data['Car Category'] ?? '';
        final bool isDriverAvaliable = data['Driver Avaliable'] ?? true;
        // Calculate the distance between user and driver
        double distance = _calculateDistance(
          pickuplatitude!,
          pickuplongitude!,
          double.parse(driverLatitude),
          double.parse(driverLongitude),
        );

        if (kDebugMode) {
          print('Distance $distance');
        }

        // Condition to add the driver marker
        if (distance <= 15.0 &&
            cabcategory == cabcategorynames[_selectedindex] &&
            isDriverAvaliable) {
          setState(() {
            isdrivernearby = true;
          });
          nearbyDrivers.add({
            'driverId': doc.id,
            'latitude': driverLatitude,
            'longitude': driverLongitude,
            'otherDetails': data,
          });
          driverids.add(doc.id);
          prefs.setStringList('Driver IDs', driverids);
          print("Driver ${cabcategorynames[_selectedindex]} $driverids");
          BitmapDescriptor carIcon;
          try {
            carIcon = await _getNetworkCarIcon(
                'https://firebasestorage.googleapis.com/v0/b/vistafeedd.appspot.com/o/Assets%2Fimages-removebg-preview%20(1).png?alt=media&token=80f80ee3-6787-4ddc-8aad-f9ce400461ea');
          } catch (e) {
            print('Failed to load custom car icon: $e');
            carIcon =
                BitmapDescriptor.defaultMarker; // Fallback to default marker
          }

          // Add the driver marker
          driverMarkers.add(
            Marker(
              markerId: MarkerId(
                  'driver_${doc.id}'), // Use a unique identifier for drivers
              icon: carIcon,
              position: LatLng(
                  double.parse(driverLatitude), double.parse(driverLongitude)),
            ),
          );
        }
      }

      setState(() {
        driversnearme = nearbyDrivers; // Update state with nearby drivers

        // Remove all existing driver markers
        _markers.removeWhere(
            (marker) => marker.markerId.value.startsWith('driver_'));

        // Add the updated driver markers
        _markers.addAll(driverMarkers);
      });

      if (nearbyDrivers.isEmpty) {
        setState(() {
          isdrivernearby = false;
        });
        if (kDebugMode) {
          print('No drivers found within the specified radius.');
        }
      } else {
        if (kDebugMode) {
          for (var driver in nearbyDrivers) {
            print('Driver ID: ${driver['driverId']}');
            print('Latitude: ${driver['latitude']}');
            print('Longitude: ${driver['longitude']}');
            print('Other Details: ${driver['otherDetails']}');
            print('--------------------------');
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        setState(() {
          isdrivernearby = false;
        });
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
    _fetchRoute();
    fetchweatherfromcache();
  }

  String Time = '';
  String? pickup;
  String? dropoffloc;
  String DistanceTravel = '';

  // Fetch route and travel time using the Google Directions API
  Future<void> _fetchRoute() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      pickup = prefs.getString('location');
      dropoffloc = prefs.getString('dropoff');
    });

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
    if (kDebugMode) {
      print('URL $url');
    }
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data['routes'].isNotEmpty) {
        final duration = data['routes'][0]['legs'][0]['duration']['text'];
        final distance = data['routes'][0]['legs'][0]['distance']['text'];

        // Get polyline for the route
        String encodedPolyline =
            data['routes'][0]['overview_polyline']['points'];
        List<LatLng> polylinePoints = _decodePolyline(encodedPolyline);

        setState(() {
          Time = duration;
          DistanceTravel = distance;
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

          // Add polyline to the map
          _polylines.add(Polyline(
            polylineId: PolylineId('route'),
            visible: true,
            geodesic: true,
            points: polylinePoints,
            color: Colors.black, // Line color (black in this case)
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

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  List cabpriceextended = [50, 200, 500, 0, 1000];
  List carcategoryimages = [
    'https://olawebcdn.com/images/v1/cabs/sl/ic_mini.png',
    'https://olawebcdn.com/images/v1/cabs/sl/ic_prime.png',
    'https://olawebcdn.com/images/v1/cabs/sl/ic_suv.png',
    'https://olawebcdn.com/images/v1/cabs/sl/ic_kp.png',
    'https://d1a3f4spazzrp4.cloudfront.net/car-types/haloProductImages/v1.1/Black_Premium_Driver_Red_Carpet.png'
  ];
  List cabcategorynames = ['Mini', 'Prime', 'SUV', 'Non AC Taxi', 'LUX'];
  List cabcategorydescription = [
    'Highly Discounted fare',
    'Spacious sedans, top drivers',
    'Spacious SUVs',
    '',
    'Our most luxurious ride'
  ];

  List cabpricesmultiplier = [36, 40, 65, 15, 100];
  int _selectedindex = 0;
  // Add this function to initialize the map controller
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  int randomFiveDigitNumber = 0;
  Future<void> generateBookingID() async {
    final random = Random();
    randomFiveDigitNumber =
        10000 + random.nextInt(90000); // Generates 5-digit number
    if (kDebugMode) {
      print('Random 5-digit number: $randomFiveDigitNumber');
    }
  }

  int randomFourDigitNumber = 0;
  Future<void> generateotp() async {
    final random = Random();
    randomFourDigitNumber =
        1000 + random.nextInt(9000); // Generates 5-digit number
    if (kDebugMode) {
      print('Random 4-digit number: $randomFourDigitNumber');
    }
  }

  bool iscashpayment = true;
  void handlePaymentErrorResponse(PaymentFailureResponse response) {}

  void handlePaymentSuccessResponse(PaymentSuccessResponse response) async {
    final prefs = await SharedPreferences.getInstance();
    await _firestore.collection('Booking IDs').doc(_auth.currentUser!.uid).set({
      'IDs': FieldValue.arrayUnion([prefs.getString('Booking ID')])
    }, SetOptions(merge: true));
    await _firestore
        .collection('Ride Details')
        .doc(prefs.getString('Booking ID'))
        .set({
      'Booking ID': prefs.getString('Booking ID'),
      'Pickup Location': pickup,
      'Drop Location': dropoffloc,
      'Fare': prefs.getDouble('Fare'),
      'Cash Payment': iscashpayment,
      'Cab Category': prefs.getString('Cab Category'),
      'Booking Time': FieldValue.serverTimestamp(),
      'Ride Accepted': false,
      'Ride Verified': false,
      'Ride Completed': false,
      'Driver ID': '',
      'Ride Owner':_auth.currentUser!.uid,
      'Pick Longitude': _pickupLocation.longitude,
      'Pickup Latitude': _pickupLocation.latitude,
      'Drop Latitude': _dropoffLocation.latitude,
      'Drop Longitude': _dropoffLocation.longitude,
      'Travel Distance': prefs.getString('Travel Distance'),
      'Travel Time': prefs.getString('Travel Time'),
      'Ride OTP': randomFourDigitNumber,
    });
    await _firestore
        .collection('Payment ID')
        .doc(prefs.getString('Booking ID'))
        .set({'Payment ID': response.paymentId});
    await capturepayment(response.paymentId!);
    if (prefs.getString('Cab Category') != null ||
        prefs.getString('Fare') != null) {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CabFinding(),
          ));
    }
  }

  void handleExternalWalletSelected(ExternalWalletResponse response) {}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
        width: MediaQuery.sizeOf(context).width,
        height: 110,
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.only(left: 30, right: 30),
          child: Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        iscashpayment = !iscashpayment;
                      });
                    },
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          iscashpayment ? 'Cash' : 'Online',
                          style: GoogleFonts.poppins(
                              color: Colors.black, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  InkWell(
                    onTap: () async {
                      final prefs = await SharedPreferences.getInstance();
                      prefs.setBool('Apply Promo', true);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PromoCodes(
                              ridepage: true,
                            ),
                          ));
                    },
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          'Promo codes',
                          style: GoogleFonts.poppins(
                              color: Colors.black, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 15,
              ),
              InkWell(
                onTap: () async {
                  await fetchdrivers();

                  final prefs = await SharedPreferences.getInstance();
                  prefs.setString(
                      'Cab Category', cabcategorynames[_selectedindex]);
                  prefs.setString('Travel Distance', DistanceTravel);
                  prefs.setString('Travel Time', Time);
                  if (kDebugMode) {
                    print('Cab ${prefs.getDouble('Fare')}');
                  }
                  await generateBookingID();
                  if (isdrivernearby) {
                    await generateotp();
                    prefs.setString(
                        'Booking ID', randomFiveDigitNumber.toString());
                    await generateBookingID();
                    if (kDebugMode) {
                      print(prefs.getString('Booking ID'));
                    }
                    if (iscashpayment) {
                      await _firestore
                          .collection('Booking IDs')
                          .doc(_auth.currentUser!.uid)
                          .set({
                        'IDs': FieldValue.arrayUnion(
                            [prefs.getString('Booking ID')])
                      }, SetOptions(merge: true));
                      await _firestore
                          .collection('Ride Details')
                          .doc(prefs.getString('Booking ID'))
                          .set({
                        'Booking ID': prefs.getString('Booking ID'),
                        'Pickup Location': pickup,
                        'Drop Location': dropoffloc,
                        'Fare': prefs.getDouble('Fare'),
                        'Cab Category': prefs.getString('Cab Category'),
                        'Booking Time': FieldValue.serverTimestamp(),
                        'Ride Accepted': false,
                        'Ride Verified': false,
                        'Ride Completed': false,
                        'Cash Payment': iscashpayment,
                        'Driver ID': '',
                        'Pick Longitude': _pickupLocation.longitude,
                        'Pickup Latitude': _pickupLocation.latitude,
                        'Drop Latitude': _dropoffLocation.latitude,
                        'Drop Longitude': _dropoffLocation.longitude,
                        'Travel Distance': prefs.getString('Travel Distance'),
                        'Travel Time': prefs.getString('Travel Time'),
                        'Ride OTP': randomFourDigitNumber,
                      });
                      if (prefs.getString('Cab Category') != null ||
                          prefs.getString('Fare') != null) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CabFinding(),
                            ));
                      }
                    }
                    if (!iscashpayment) {
                      Razorpay razorpay = Razorpay();
                      var options = {
                        'key': Environment.razorpaytestapi,
                        'amount': (prefs.getDouble('Fare'))! * 100,
                        'name': 'VistaRide',
                        'description': 'Trip to ${dropoffloc} from ${pickup}',
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
                      razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET,
                          handleExternalWalletSelected);
                      razorpay.open(options);
                    }
                  }
                },
                child: Align(
                  alignment: Alignment
                      .center, // Aligns the inner container at the top-left
                  child: Container(
                    width: MediaQuery.sizeOf(context).width,
                    height: 50,
                    decoration: BoxDecoration(
                        color: isdrivernearby ? Colors.black : Colors.grey,
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    child: Center(
                      child: Text(
                        isdrivernearby
                            ? 'Book ${cabcategorynames[_selectedindex]}'
                            : 'No drivers nearby',
                        style: GoogleFonts.poppins(
                            color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
              top: 30,
              left: 20,
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                  ),
                ),
              )),
          Positioned(
            bottom: 0,
            child: Container(
                width: MediaQuery.sizeOf(context).width,
                color: Colors.white,
                height: 400,
                child: Column(
                  children: [
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 20, right: 20, top: 20),
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: MediaQuery.sizeOf(context).width,
                          height: 40,
                          child: Row(
                            children: [
                              const Icon(
                                Icons.directions_walk,
                                color: Colors.green,
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              Expanded(
                                  child: Text(
                                pickup!,
                                style: GoogleFonts.poppins(color: Colors.black),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              )),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const Divider(
                      indent: 20,
                      endIndent: 20,
                      color: Colors.grey,
                      thickness: 0.5,
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 20, right: 20, top: 10),
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: MediaQuery.sizeOf(context).width,
                          height: 40,
                          child: Row(
                            children: [
                              const CircleAvatar(
                                radius: 5,
                                backgroundColor: Colors.red,
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              Expanded(
                                  child: Text(
                                dropoffloc!,
                                style: GoogleFonts.poppins(color: Colors.black),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              )),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const Divider(
                      indent: 0,
                      endIndent: 0,
                      color: Colors.grey,
                      thickness: 0.5,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20, top: 10),
                      child: Row(
                        children: [
                          Text(
                            'Estimated Drop off by ${formatTime(DateTime.now().add(parseDuration(Time)))}',
                            style: GoogleFonts.poppins(
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                                fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                        child: ListView.builder(
                      itemCount: carcategoryimages.length,
                      itemBuilder: (context, index) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 20, bottom: 20, right: 20),
                              child: Container(
                                decoration: _selectedindex == index
                                    ? BoxDecoration(
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(10)),
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.2),
                                            offset: const Offset(4, 4),
                                            blurRadius: 2,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      )
                                    : BoxDecoration(),
                                child: InkWell(
                                  onTap: () async {
                                    setState(() {
                                      _selectedindex = index;
                                    });
                                    fetchdrivers();
                                    try {
                                      if (kDebugMode) {
                                        print('Success to calculate');
                                      }
                                      // Access SharedPreferences
                                      final prefs =
                                          await SharedPreferences.getInstance();

                                      // Parse DistanceTravel and calculate the fare
                                      double distanceValue = double.parse(
                                          DistanceTravel.replaceAll(
                                              RegExp(r'[^0-9.]'), ''));
                                      double fare = weathercondition == 'Haze'
                                          ? ((distanceValue.floor().toDouble() *
                                                  cabpricesmultiplier[index]) +
                                              cabpriceextended[index])
                                          : (distanceValue.floor().toDouble() *
                                              cabpricesmultiplier[index]);

                                      // Store the calculated fare
                                      prefs.setDouble('Fare', fare);
                                    } catch (e) {
                                      // If parsing/calculation fails, set a default fare value
                                      if (kDebugMode) {
                                        print('Failed to calculate');
                                      }
                                      final prefs =
                                          await SharedPreferences.getInstance();
                                      prefs.setDouble(
                                          'Fare',
                                          double.parse(DistanceTravel *
                                              cabpricesmultiplier[
                                                  _selectedindex])); // Default fare value
                                    }

                                    if (kDebugMode) {
                                      print(_selectedindex);
                                      final prefs =
                                          await SharedPreferences.getInstance();
                                      print('Fare ${prefs.getDouble('Fare')}');
                                    }
                                  },
                                  child: Row(
                                    children: [
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Image(
                                        image: NetworkImage(
                                            carcategoryimages[index]),
                                        height: 70,
                                        width: 70,
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
                                            cabcategorynames[index],
                                            style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w600),
                                          ),
                                          Text(
                                            cabcategorydescription[index],
                                            style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w300,
                                                color: Colors.grey,
                                                fontSize: 11),
                                          ),
                                        ],
                                      ),
                                      const Spacer(),
                                      weathercondition == 'Haze'
                                          ? Text(
                                              '₹${(double.parse(DistanceTravel.replaceAll(RegExp(r'[^0-9.]'), '')).floor() * cabpricesmultiplier[index]) + cabpriceextended[index]}',
                                              style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.w600),
                                            )
                                          : Text(
                                              '₹${(double.parse(DistanceTravel.replaceAll(RegExp(r'[^0-9.]'), '')).floor() * cabpricesmultiplier[index])}',
                                              style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.w600),
                                            ),
                                      const SizedBox(
                                        width: 20,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            )
                          ],
                        );
                      },
                    ))
                  ],
                )),
          )
        ],
      ),
    );
  }
}
