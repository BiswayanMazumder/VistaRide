import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pingstar/Auth%20Pages/OTPPage.dart';
import 'package:pingstar/Utils/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _PhoneNumberController = TextEditingController();
  String error = '';
  String? verificationId;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Function to send OTP to the user's phone number
  void _sendOTP() async {
    final prefs=await SharedPreferences.getInstance();
    final phoneNumber = _PhoneNumberController.text;
    if (phoneNumber.isNotEmpty && phoneNumber.length == 10) {
      setState(() {
        error = '';
      });

      try {
        await _auth.verifyPhoneNumber(
          phoneNumber: '+91$phoneNumber',
          verificationCompleted: (PhoneAuthCredential credential) async {
            // This is when auto-verification happens (e.g., on Android)
            await _auth.signInWithCredential(credential);
            prefs.setString('Phone Number', _PhoneNumberController.text);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => OTPVerificationPage(verificationId: verificationId!,phonenumber: _PhoneNumberController.text,)),
            );
          },
          verificationFailed: (FirebaseAuthException e) {
            setState(() {
              error = 'Verification failed: ${e.message}';
            });
          },
          codeSent: (String verificationId, int? resendToken) {
            this.verificationId = verificationId;
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => OTPVerificationPage(verificationId: verificationId,phonenumber: _PhoneNumberController.text,)),
            );
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            this.verificationId = verificationId;
          },
        );
      } catch (e) {
        setState(() {
          error = 'An error occurred: ${e.toString()}';
        });
      }
    } else {
      setState(() {
        error = 'Please enter a valid phone number';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: WhatsAppColors.darkGreen,
        automaticallyImplyLeading: false,
      ),
      backgroundColor: WhatsAppColors.darkGreen,
      body: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: Column(
          children: [
            const SizedBox(height: 30),
            Center(
              child: Text(
                'Enter your phone number',
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 25),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Synergy will need to verify your phone number. Carrier charges may apply.',
              style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w400),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 60),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 28,
                  width: 60,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: error == '' ? Colors.green : Colors.red,
                        width: 2,
                      ),
                    ),
                  ),
                  child: TextField(
                    style: GoogleFonts.poppins(color: Colors.white),
                    keyboardType: TextInputType.number,
                    enabled: false,
                    readOnly: true,
                    decoration: InputDecoration(
                        hintText: '+91', hintStyle: GoogleFonts.poppins(color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 30),
                Container(
                  height: 28,
                  width: MediaQuery.sizeOf(context).width / 3,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: error == '' ? Colors.green : Colors.red,
                        width: 2,
                      ),
                    ),
                  ),
                  child: TextField(
                    controller: _PhoneNumberController,
                    style: GoogleFonts.poppins(color: Colors.white),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(hintText: 'Phone Number', hintStyle: GoogleFonts.poppins(color: Colors.grey)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            Center(
              child: Text(
                error,
                style: GoogleFonts.poppins(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 40),
            InkWell(
              onTap: _sendOTP,
              child: Container(
                width: 100,
                height: 45,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: WhatsAppColors.primaryGreen,
                ),
                child: Center(
                  child: Text(
                    'NEXT',
                    style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}