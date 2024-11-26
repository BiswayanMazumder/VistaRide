import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vistaride/Home%20Page/HomePage.dart';

import '../Booked Cab Details/bookedcabdetails.dart';
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late Timer _timertofetch;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isactiveride=false;
  Future<void>fetchactiveride()async{
    List bookingid=[];
    String acctivebookingid='';
    final prefs=await SharedPreferences.getInstance();
    final docsnap=await _firestore.collection('Booking IDs').doc(_auth.currentUser!.uid).get();
    if(docsnap.exists){
      bookingid=docsnap.data()?['IDs'];
    }
    for(int i=0;i<bookingid.length;i++){
      final Docsnap=await _firestore.collection('Ride Details').doc(bookingid[i]).get();
      if(Docsnap.exists){
        if(Docsnap.data()?['Ride Accepted']){
          prefs.setString('Booking ID', bookingid[i]);
          print('BID ${bookingid[i]}');
          setState(() {
            isactiveride=true;
          });
        }
      }
    }
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _timertofetch = Timer.periodic(const Duration(seconds: 15), (Timer t)async{
      await fetchactiveride();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>isactiveride?const BookedCabDetails(): const HomePage(),));
    });
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _timertofetch.cancel();
  }
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: MediaQuery.sizeOf(context).width,
        height: MediaQuery.sizeOf(context).height,
        child: const Center(
          child: Image(image: NetworkImage('https://firebasestorage.googleapis.com/v0/b/vistafeedd.appspot.com/o/Assets%2FUntitled%20design.gif?alt=media&token=f6cfb7ed-8f30-4a9e-b9f0-567389fb6eb4')),
        ),
      ),
    );
  }
}
