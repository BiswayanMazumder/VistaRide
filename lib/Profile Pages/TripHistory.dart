import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
  List<dynamic>driverpic=[];
  List<dynamic>cancelledtrip=[];
  Future<void>fetchrideids()async{
    final docsnap=await _firestore.collection('Booking IDs').doc(_auth.currentUser!.uid).get();
    if(docsnap.exists){
      setState(() {
        bookingids=docsnap.data()?['IDs'];
      });
    }
    if (kDebugMode) {
      print('Booking ID $bookingids');
    }
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
      
    );
  }
}
