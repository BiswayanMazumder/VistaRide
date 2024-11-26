import 'package:device_preview/device_preview.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:vistaride/Home%20Page/HomePage.dart';
import 'package:vistaride/Login%20Pages/loginpage.dart';
import 'package:vistaride/Splash%20Screen/splash_screen.dart';

import 'firebase_options.dart';

void main()async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
      kDebugMode?  DevicePreview(
        enabled:true,
        builder: (context) => const MyApp(),):const MyApp()
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final FirebaseAuth _auth=FirebaseAuth.instance;
    return MaterialApp(
      title: 'VistaRide',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home:const SplashScreen()
    );
  }
}

