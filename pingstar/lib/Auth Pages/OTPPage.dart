import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pingstar/Logged%20In%20Users/allchatspage.dart';
import 'package:pingstar/Navigation%20Bar/bottomnavbar.dart';
import 'package:pingstar/Onboarding%20Pages/userdetailspage.dart';
import 'package:pingstar/Utils/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OTPVerificationPage extends StatefulWidget {
  final String verificationId;
  final String phonenumber;
  const OTPVerificationPage({super.key, required this.verificationId,required this.phonenumber});

  @override
  State<OTPVerificationPage> createState() => _OTPVerificationPageState();
}

class _OTPVerificationPageState extends State<OTPVerificationPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore=FirebaseFirestore.instance;
  String? otpCode;
  String username='';
  bool isuserregistered=false;
  Future<void> _getUsername()async{
    final docsnap=await _firestore.collection('User Details(User ID Basis)').doc(_auth.currentUser!.uid).get();
    if(docsnap.exists){
      username=docsnap.data()?['Username'];
    }
    if(username!=null || username!=''){
      Navigator.push(context, MaterialPageRoute(builder: (context) => LoggedInUserTopBar(),));
    }
  }
  Future<void> _verifyOTP() async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: widget.verificationId, smsCode: otpCode!);

      await _auth.signInWithCredential(credential);
      if (kDebugMode) {
        print("User ID ${_auth.currentUser!.uid}");
      }
      final prefs=await SharedPreferences.getInstance();
      final docsnap=await _firestore.collection('User Details(User ID Basis)').doc(_auth.currentUser!.uid).get();
      if(docsnap.exists){
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoggedInUserTopBar(),));
      }
      if(!docsnap.exists){
        await _firestore.collection('User Details(User ID Basis)').doc(_auth.currentUser!.uid).set(
            {
              'Mobile Number':widget.phonenumber,
              'Country Code':'+91',
              'Date of Registration':FieldValue.serverTimestamp(),
              'Residing Country':'India',
              'UID':_auth.currentUser!.uid
            });
        await _firestore.collection('User Details(Contact Number Basis)').doc(widget.phonenumber).set(
            {
              'Mobile Number':widget.phonenumber,
              'Country Code':'+91',
              'Date of Registration':FieldValue.serverTimestamp(),
              'Residing Country':'India',
              'UID':_auth.currentUser!.uid
            });
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => UserDetails(phonenumber: widget.phonenumber,)));
      }
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invalid OTP')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: WhatsAppColors.darkGreen,
        automaticallyImplyLeading: true,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
      backgroundColor: WhatsAppColors.darkGreen,
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 40),
            const Image(
              image: NetworkImage(
                  'https://cfyxewbfkabqzrtdyfxc.supabase.co/storage/v1/object/sign/Assets/otp-one-time-password-step-authentication-data-protection-'
                      'internet-security-concept-otp-one-time-password-step-authentication-data-254434939-removebg-preview.png?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.'
                      'eyJ1cmwiOiJBc3NldHMvb3RwLW9uZS10aW1lLXBhc3N3b3JkLXN0ZXAtYXV0aGVudGljYXRpb24tZGF0YS1wcm90ZWN0aW9uLWludGVybmV0LXNlY3VyaXR5LWNvbmNlcHQtb3RwLW9uZS10aW1lL'
                      'XBhc3N3b3JkLXN0ZXAtYXV0aGVudGljYXRpb24tZGF0YS0yNTQ0MzQ5MzktcmVtb3ZlYmctcHJldmlldy5wbmciLCJpYXQiOjE3MzY3NDQxMDIsImV4cCI6MTc2ODI4MDEwMn0.eb0JVGRNasvKU_'
                      'CwaK0yT7oUNacFuoL_02tBQLfe5C0&t=2025-01-13T04%3A55%3A03.816Z'),
              height: 200,
              width: 200,
            ),
            const SizedBox(height: 20),
            Text(
              'Please enter the valid 6-digit OTP received on your phone number.',
              style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            OtpTextField(
              numberOfFields: 6,
              borderColor: WhatsAppColors.primaryGreen,
              keyboardType: TextInputType.number,
              styles: const [
                TextStyle(color: Colors.white),
                TextStyle(color: Colors.white),
                TextStyle(color: Colors.white),
                TextStyle(color: Colors.white),
                TextStyle(color: Colors.white),
                TextStyle(color: Colors.white),
              ],
              showFieldAsBox: true,
              onSubmit: (verificationCode) {
                setState(() {
                  otpCode = verificationCode;
                });
                _verifyOTP();
              },
            ),
          ],
        ),
      ),
    );
  }
}
