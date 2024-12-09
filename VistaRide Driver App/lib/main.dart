import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vistaridedriver/Home%20Page/homepage.dart';
import 'package:vistaridedriver/Login%20Pages/login_page.dart';
import 'package:vistaridedriver/OnBoarding%20Pages/documentupload.dart';
import 'package:vistaridedriver/OnBoarding%20Pages/registeruser.dart';

import 'firebase_options.dart';
@pragma('vm:entry-point')
Future<void>_FirebaseBackgroundHandler(RemoteMessage message)async{
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}
void main()async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_FirebaseBackgroundHandler);
  runApp(
      kDebugMode?  DevicePreview(
        enabled:true,
        builder: (context) => const MyApp(),):const MyApp()
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Map<String, dynamic>> fetchDriverDetails() async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    if (_auth.currentUser != null) {
      final docsnap = await _firestore
          .collection('VistaRide Driver Details')
          .doc(_auth.currentUser!.uid)
          .get();

      if (docsnap.exists) {
        return {
          'isSubmitted': docsnap.data()?['Submitted'] ?? false,
          'isApproved': docsnap.data()?['Approved'] ?? false,
        };
      }
    }
    return {'isSubmitted': false, 'isApproved': false};
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VistaRide Partner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        useMaterial3: true,
      ),
      home: FutureBuilder<Map<String, dynamic>>(
        future: fetchDriverDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('An error occurred!'));
          }

          final FirebaseAuth _auth = FirebaseAuth.instance;
          final isSubmitted = snapshot.data?['isSubmitted'] ?? false;
          final isApproved = snapshot.data?['isApproved'] ?? false;

          if (_auth.currentUser == null) {
            return const LoginPage();
          } else {
            return isSubmitted
                ? (isApproved ? const HomePage() : const DocumentUpload())
                : const RegisterUser();
          }
        },
      ),
    );
  }
}
