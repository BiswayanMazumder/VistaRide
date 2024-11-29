import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pinput/pinput.dart';
class TripsPage extends StatefulWidget {
  const TripsPage({super.key});

  @override
  State<TripsPage> createState() => _TripsPageState();
}

class _TripsPageState extends State<TripsPage> {
  final FirebaseAuth _auth=FirebaseAuth.instance;
  final FirebaseFirestore _firestore=FirebaseFirestore.instance;
  List<dynamic>tripid=[];
  List<dynamic>pickup=[];
  List<dynamic>drop=[];
  List<dynamic>fare=[];
  List<dynamic>tripdate=[];
  double totalFare=0;
  bool isloading=true;
  Future<void> fetchTrips() async {
    setState(() {
      isloading=true;
    });
    final docsnap = await _firestore
        .collection('VistaRide Driver Details')
        .doc(_auth.currentUser!.uid)
        .get();

    if (docsnap.exists) {
      setState(() {
        tripid = docsnap.data()?['Rides Completed'];
      });
    }

    if (kDebugMode) {
      print('Trips done $tripid');
    }

    // Reset lists for each fetch
    pickup.clear();
    drop.clear();
    fare.clear();
    tripdate.clear();

    for (int i = 0; i < tripid.length; i++) {
      final TripSnap = await _firestore
          .collection('Ride Details')
          .doc(tripid[i])
          .get();

      if (TripSnap.exists) {
        pickup.add(TripSnap.data()?['Pickup Location'] ?? '');
        drop.add(TripSnap.data()?['Drop Location'] ?? '');

        var fareValue = TripSnap.data()?['Fare'] ?? 0;
        // Ensure fareValue is a valid double
        if (fareValue is double) {
          fare.add(fareValue);
        } else if (fareValue is String) {
          fare.add(double.tryParse(fareValue) ?? 0.0); // Convert string to double
        } else {
          fare.add(0.0); // Default value if parsing fails
        }

        // Handle Timestamp or invalid Booking Time values
        var bookingTime = TripSnap.data()?['Booking Time'];
        if (bookingTime != null) {
          try {
            DateTime parsedDate;
            if (bookingTime is Timestamp) {
              parsedDate = bookingTime.toDate(); // Convert Timestamp to DateTime
            } else if (bookingTime is String) {
              parsedDate = DateTime.parse(bookingTime); // Parse String to DateTime
            } else {
              throw 'Unsupported date format';
            }

            String formattedDate = DateFormat('E, MMM dd, yyyy, hh:mm a').format(parsedDate);
            tripdate.add(formattedDate);
          } catch (e) {
            tripdate.add('Invalid date');
            if (kDebugMode) print('Error parsing date: $e');
          }
        } else {
          tripdate.add('Date not available');
        }
      }
    }

    // Calculate totalFare after collecting all the data
    double calculatedFare = fare.fold(0, (sum, item) => sum + item);

    setState(() {
      totalFare = calculatedFare; // Update totalFare in the UI
    });
    setState(() {
      isloading=false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchTrips();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Trips Completed',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.w500,
            fontSize: 18,
          ),
        ),
      ),
      body:isloading?const Center(
        child: CircularProgressIndicator(
          color: Colors.black,
        ),
      ) :Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              // height: 100,
              width: MediaQuery.sizeOf(context).width,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                color: Colors.grey.shade100
              ),
              child: Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  Text('Total Trips Done: ${tripid.length}',style: GoogleFonts.poppins(
                    color: Colors.black,fontWeight: FontWeight.w600
                  ),),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    'Total Revenue Generated: \₹${totalFare.toStringAsFixed(2)}',
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: tripid.isNotEmpty
                ? ListView.builder(
              itemCount: tripid.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tripdate[index],
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        pickup[index],
                        style: GoogleFonts.poppins(
                          color: Colors.grey,
                          fontWeight: FontWeight.w400,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        'To',
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        drop[index],
                        style: GoogleFonts.poppins(
                          color: Colors.grey,
                          fontWeight: FontWeight.w400,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                );
              },
            )
                : Center(
              child: Text(
                "No trips completed yet.",
                style: GoogleFonts.poppins(
                  color: Colors.grey,
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
