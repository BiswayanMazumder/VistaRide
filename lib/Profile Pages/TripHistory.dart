import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
class MyTrips extends StatefulWidget {
  const MyTrips({super.key});

  @override
  State<MyTrips> createState() => _MyTripsState();
}

class _MyTripsState extends State<MyTrips> {
  final FirebaseAuth _auth=FirebaseAuth.instance;
  final FirebaseFirestore _firestore=FirebaseFirestore.instance;
  List<dynamic> bookingids=[];
  List<dynamic>cabcategory=[];
  List<dynamic>tripdate=[];
  List<dynamic>destination=[];
  List<dynamic>price=[];
  List<dynamic> bookingdate=[];
  List<dynamic>driverpic=[];
  List<dynamic>cancelledtrip=[];
  bool isloading=true;
  Future<void> fetchrideids() async {
    setState(() {
      isloading=true;
    });
    final docsnap = await _firestore.collection('Booking IDs').doc(_auth.currentUser!.uid).get();
    if (docsnap.exists) {
      setState(() {
        bookingids = docsnap.data()?['IDs'];
      });
    }
    if (kDebugMode) {
      print('Booking ID $bookingids');
    }

    for (int i = 0; i < bookingids.length; i++) {
      final Docsnap = await _firestore.collection('Ride Details').doc(bookingids[i]).get();
      if (Docsnap.exists) {
        // Handle the Firestore Timestamp and format it
        var bookingTime = Docsnap.data()?['Booking Time'];
        String formattedDate = '';

        if (bookingTime != null && bookingTime is Timestamp) {
          try {
            DateTime parsedDate = bookingTime.toDate(); // Convert Timestamp to DateTime
            formattedDate = DateFormat('EEE, MMM d, y, h:mm a').format(parsedDate);
          } catch (e) {
            if (kDebugMode) {
              print('Error parsing date: $e');
            }
          }
        }

        setState(() {
          bookingdate.add(formattedDate);
          cabcategory.add(Docsnap.data()?['Cab Category']);
          destination.add(Docsnap.data()?['Drop Location']);
          price.add(Docsnap.data()?['Fare']);
          cancelledtrip.add(Docsnap.data()?['Ride Cancelled'] ?? false);
          // driverpic.add(Docsnap.data()?[''])
        });
      }
    }
    if (kDebugMode) {
      print('Data $bookingdate $cabcategory $destination $price $cancelledtrip');
    }
    setState(() {
      isloading=false;
    });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchrideids();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('History',style: GoogleFonts.poppins(color: Colors.black,fontWeight: FontWeight.w600),),
      ),
      body:isloading?const Center(
        child: CircularProgressIndicator(
          color: Colors.black,
        ),
      ) :ListView.builder(
        itemCount: bookingids.length,
        itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(left: 20,right: 20,top: 40),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bookingdate[index],
                          style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '${cabcategory[index]} to',
                          style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontWeight: FontWeight.w400,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          destination[index],
                          maxLines: 3, // Allows wrapping up to 3 lines
                          overflow: TextOverflow.visible, // Avoids truncation
                          style: GoogleFonts.poppins(
                            color: Colors.grey,
                            fontWeight: FontWeight.w300,
                            fontSize: 15,
                          ),
                          softWrap: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              cancelledtrip[index]?Row(
                children: [
                  Container(
                    height: 40,
                    width: 100,
                    decoration: const BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.all(Radius.circular(10))
                    ),
                    child: Center(
                      child: Text('Cancelled',style: GoogleFonts.poppins(
                        color: Colors.black,fontSize: 15
                      ),),
                    ),
                  ),
                ],
              ):Container()
            ],
          ),
        );
      },),
    );
  }
}
