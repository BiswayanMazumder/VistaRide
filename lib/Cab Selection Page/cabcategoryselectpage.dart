import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:vistaride/Environment%20Files/.env.dart';

class CabSelectAndPrice extends StatefulWidget {
  const CabSelectAndPrice({super.key});

  @override
  State<CabSelectAndPrice> createState() => _CabSelectAndPriceState();
}

class _CabSelectAndPriceState extends State<CabSelectAndPrice> {
  late GoogleMapController mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {}; // Set to hold polyline
  LatLng _pickupLocation =
      LatLng(22.7199572, 88.4663679); // Default pickup location (Kolkata)
  LatLng _dropoffLocation = LatLng(
      22.582077, 88.368420); // Default drop-off location (Sealdah Station)
  String? _pickupAddress;
  String? _dropoffAddress;

  @override
  void initState() {
    super.initState();
    _fetchRoute();
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

  List carcategoryimages = [
    'https://olawebcdn.com/images/v1/cabs/sl/ic_mini.png',
    'https://olawebcdn.com/images/v1/cabs/sl/ic_prime.png',
    'https://olawebcdn.com/images/v1/cabs/sl/ic_suv.png',
    'https://olawebcdn.com/images/v1/cabs/sl/ic_kp.png'
  ];
  List cabcategorynames = ['Mini', 'Prime', 'SUV', 'Non AC Taxi'];
  List cabcategorydescription = [
    'Highly Discounted fare',
    'Spacious sedans, top drivers',
    'Spacious SUVs',
    ''
  ];

  List cabpricesmultiplier = [36, 40, 65, 15];
  int _selectedindex = 0;

  // Add this function to initialize the map controller
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
        width: MediaQuery.sizeOf(context).width,
        height: 80,
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.only(left: 30, right: 30),
          child: InkWell(
            onTap: () async {
              final prefs =
              await SharedPreferences.getInstance();
              prefs.setString('Cab Category', cabcategorynames[_selectedindex]);
              prefs.setString('Travel Distance', DistanceTravel);
              prefs.setString('Travel Time', Time);
              print(prefs.getString('Cab Category'));
            },
            child: Align(
              alignment: Alignment
                  .center, // Aligns the inner container at the top-left
              child: Container(
                width: MediaQuery.sizeOf(context).width,
                height: 50,
                decoration: const BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                child: Center(
                  child: Text(
                    'Book ${cabcategorynames[_selectedindex]}',

                    style: GoogleFonts.poppins(
                        color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
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
                height: 300,
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

                                    try {
                                      // Access SharedPreferences
                                      final prefs =
                                          await SharedPreferences.getInstance();

                                      // Parse DistanceTravel and calculate the fare
                                      double distanceValue = double.parse(
                                          DistanceTravel.replaceAll(
                                              RegExp(r'[^0-9.]'), ''));
                                      double fare =
                                          distanceValue.floor().toDouble() *
                                              cabpricesmultiplier[index];

                                      // Store the calculated fare
                                      prefs.setDouble('Fare', fare);
                                    } catch (e) {
                                      // If parsing/calculation fails, set a default fare value
                                      final prefs =
                                          await SharedPreferences.getInstance();
                                      prefs.setDouble(
                                          'Fare', double.parse(DistanceTravel*cabpricesmultiplier[_selectedindex])); // Default fare value
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
                                        width: 20,
                                      ),
                                      Image(
                                          image: NetworkImage(
                                              carcategoryimages[index])),
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
                                      Text(
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
