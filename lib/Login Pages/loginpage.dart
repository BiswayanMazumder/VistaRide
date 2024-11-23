import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:vistaride/HomePage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Function to handle Google Sign-In
  Future<void> _handleGoogleSignIn() async {
    try {
      // Initiate the Google Sign-In process
      GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account != null) {
        // Retrieve authentication details from Google
        GoogleSignInAuthentication googleAuth = await account.authentication;

        // Create a new credential for Firebase
        OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // Sign in to Firebase using the credential
        UserCredential userCredential = await _auth.signInWithCredential(credential);

        User? user = userCredential.user;
        if (user == null) {
          // Handle the error if user is null
          if (kDebugMode) {
            print('Error: User not authenticated.');
          }
          return;
        }

        // Check if the user document exists in Firestore
        final docsnap = await _firestore.collection('VistaRide User Details')
            .doc(user.uid)
            .get();

        // If the document doesn't exist, create it
        if (!docsnap.exists) {
          await _firestore.collection('VistaRide User Details').doc(user.uid).set(
              {
                'User Name': account.displayName,
                'Profile Picture': account.photoUrl,
                'Date Of Joining': FieldValue.serverTimestamp(),
                'Email Address': account.email,
              });
        }

        // Navigate to the next screen (HomePage)
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));
      }
    } catch (error) {
      // Handle sign-in errors
      if (kDebugMode) {
        print('Error signing in with Google: $error');
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow,
        automaticallyImplyLeading: false,
      ),
      backgroundColor: Colors.yellow,
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 50),
            Text(
              'VistaRide',
              style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 35),
            ),
            const SizedBox(height: 20),
            const Image(
              image: NetworkImage(
                  'https://firebasestorage.googleapis.com/v0/b/vistafeedd.appspot.com/o/Assets%2FSc'
                      'reenshot_2024-11-22_204328-removebg-preview.png?alt=media&token=53712449-daaa-4f70-bb92-0ca64793111e'),
              height: 150,
              width: 150,
            ),
            const SizedBox(height: 15),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              width: MediaQuery.sizeOf(context).width,
              child: Text(
                'On Time, Every Time!',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 35,
                ),
              ),
            ),
            Spacer(),
            const SizedBox(height: 20),
            InkWell(
              onTap: _handleGoogleSignIn,
              child: Container(
                height: 50,
                width: MediaQuery.sizeOf(context).width - 50,
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(50))),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      const Image(image: NetworkImage('https://www.google.com/images/hpp/ic_wahlberg_product_core_48.png8.png')),
                      const SizedBox(width: 50),
                      Text('Continue using Google', style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      )),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Container(
              height: 50,
              width: MediaQuery.sizeOf(context).width - 50,
              decoration: const BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.all(Radius.circular(50))),
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    const Image(image: NetworkImage('https://www.apple.com/favicon.ico')),
                    const SizedBox(width: 50),
                    Text('Continue using Apple', style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600
                    )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
