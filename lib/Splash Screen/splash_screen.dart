import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vistaride/Home%20Page/HomePage.dart';
import 'package:vistaride/Login%20Pages/loginpage.dart';
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
  bool isactiveride = false;
  int vistamiles=0;
  Future<void> fetchactiveride() async {
    List bookingid = [];
    final prefs = await SharedPreferences.getInstance();
    final vistamilesnap=await _firestore.collection('VistaRide User Details').doc(_auth.currentUser!.uid).get();
    if(vistamilesnap.exists){
      prefs.setInt('Vistamiles', vistamilesnap.data()?['Vistamiles']??0);
      if (kDebugMode) {
        print('VistaMiles: ${vistamilesnap.data()?['Vistamiles']??0}');
      }
    }
    final docsnap = await _firestore
        .collection('Booking IDs')
        .doc(_auth.currentUser!.uid)
        .get();
    if (docsnap.exists) {
      bookingid = docsnap.data()?['IDs'];
    }
    for (int i = 0; i < bookingid.length; i++) {
      final Docsnap =
      await _firestore.collection('Ride Details').doc(bookingid[i]).get();
      if (Docsnap.exists) {
        if (Docsnap.data()?['Ride Accepted']) {
          prefs.setString('Booking ID', bookingid[i]);
          if (kDebugMode) {
            print('BID ${bookingid[i]}');
          }
          setState(() {
            isactiveride = true;
          });
        }
      }
    }
  }
  List<String> citySelectedList = [];
  Future<void> fetchservicablecities() async {
    final prefs=await SharedPreferences.getInstance();
    try {
      // Get the Firestore instance
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Fetch all documents from the Servicable Locations collection
      QuerySnapshot querySnapshot =
      await firestore.collection('Servicable Locations').get();

      // Extract the citySelected fields from each document
      List<String> cities = querySnapshot.docs
          .map((doc) => doc['citySelected'] as String)
          .toList();

      // Update the state with the fetched cities
      setState(() {
        citySelectedList = cities;
      });
      prefs.setStringList('Cities Available', cities);
      if (kDebugMode) {
        print('Cities Available: ${prefs.getStringList('Cities Available')}');
      }
    } catch (e) {
      print("Error fetching cities: $e");
    }
  }
  @override
  void initState() {
    super.initState();
    fetchservicablecities();
    // Check if user is logged in
    if (_auth.currentUser != null) {
      // If the user is logged in, fetch the ride details
      fetchactiveride().then((_) {
        // Delay navigation after fetching ride details
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => isactiveride
                  ? const BookedCabDetails()
                  : const HomePage(),
            ),
          );
        });
      });
    } else {
      // If not logged in, navigate to the login page
      Future.delayed(const Duration(seconds: 8), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginPage(),
          ),
        );
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.network(
          'https://firebasestorage.googleapis.com/v0/b/vistafeedd.appspot.com/o/Assets%2FUntitled%20design.gif?alt=media&token=f6cfb7ed-8f30-4a9e-b9f0-567389fb6eb4',
        ),
      ),
    );
  }
}
