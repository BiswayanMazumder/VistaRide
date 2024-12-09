import 'package:device_preview/device_preview.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:vistaridedriver/Home%20Page/homepage.dart';
import 'package:vistaridedriver/Login%20Pages/login_page.dart';
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
  @override
  Widget build(BuildContext context) {
    final FirebaseAuth _auth=FirebaseAuth.instance;
    return MaterialApp(
      title: 'VistaRide Partner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        useMaterial3: true,
      ),
      home:_auth.currentUser!=null?const RegisterUser(): const LoginPage(),
    );
  }
}
