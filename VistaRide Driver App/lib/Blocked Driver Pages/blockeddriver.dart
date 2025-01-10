import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vistaridedriver/Home%20Page/homepage.dart';
import 'package:vistaridedriver/Login%20Pages/login_page.dart';

class BlockedDriver extends StatefulWidget {
  const BlockedDriver({super.key});

  @override
  State<BlockedDriver> createState() => _BlockedDriverState();
}

class _BlockedDriverState extends State<BlockedDriver> {
  late StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>
      _driverBlockedListener;
  bool isDriverBlocked = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void listenToDriverBlockedStatus() {
    _driverBlockedListener = _firestore
        .collection('VistaRide Driver Details')
        .doc(_auth.currentUser!.uid)
        .snapshots()
        .listen((DocumentSnapshot<Map<String, dynamic>> docsnap) {
      if (docsnap.exists) {
        final data = docsnap.data();
        if (data != null && data.containsKey('Blocked')) {
          setState(() {
            isDriverBlocked = data['Blocked'];
          });
          if (!isDriverBlocked) {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const HomePage(),
                ));
          }
          if (kDebugMode) {
            print('Block Status updated: $isDriverBlocked');
          }
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    listenToDriverBlockedStatus();
  }

  @override
  void dispose() {
    _driverBlockedListener.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 20,right: 20),
        child: Container(
          height: 70,
          width: MediaQuery.sizeOf(context).width,
          child: Column(
            children: [
              InkWell(
                onTap: ()async{
                  await _auth.signOut();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
                child: Container(
                  width: MediaQuery.sizeOf(context).width,
                  height: 50,
                  decoration: const BoxDecoration(
                      color:  Colors.black,
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: Center(
                    child: Text(
                      'Sign Out',
                      style: GoogleFonts.poppins(
                          color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            ],
          )
        ),
      ),
      appBar: AppBar(
        title: Text(
          'VistaRide',
          style: GoogleFonts.poppins(
              color: Colors.white, fontWeight: FontWeight.w600),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate font size based on screen width
          double fontSize =
              constraints.maxWidth / 14; // Adjust divisor as needed

          return Padding(
            padding: const EdgeInsets.only(left: 20,right: 20),
            child: Center(
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    'This account is blocked',
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: fontSize,
                    ),
                    textAlign: TextAlign.start,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    'If you think this is a mistake then please contact our customer support for help.',
                    style: GoogleFonts.poppins(
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.start,
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  const Image(
                    image: NetworkImage(
                        'https://cdn.pixabay.com/photo/2014/04/02/10/26/attention-303861_640.png'),
                    height: 200,
                    width: 200,
                  ),

                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
