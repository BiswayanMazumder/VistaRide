import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:pingstar/Logged%20In%20Users/allchatspage.dart';
import 'package:pingstar/Navigation%20Bar/bottomnavbar.dart';
import 'package:pingstar/Welcome%20Page/welcome_page.dart';

import 'firebase_options.dart';

void main()async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final FirebaseAuth _auth=FirebaseAuth.instance;
    return  MaterialApp(
      title: 'Connect',
      debugShowCheckedModeBanner: false,
      home: _auth.currentUser!=null?const LoggedInUserTopBar():const WelcomePage(),
    );
  }
}
