import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pingstar/Auth%20Pages/loginpage.dart';
import 'package:pingstar/Utils/colors.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: WhatsAppColors.darkGreen,
        actions: const [
          InkWell(
            child: Icon(
              CupertinoIcons.ellipsis_vertical,
              color: Colors.white,
            ),
          )
        ],
      ),
      backgroundColor: WhatsAppColors.darkGreen,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Image(
              image: NetworkImage(
                  'https://cfyxewbfkabqzrtdyfxc.supabase.co/storage/v1/object/sign/Assets/synergylogin-removebg-preview.png?'
                  'token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1cmwiOiJBc3NldHMvc3luZXJneWxvZ2luLXJlbW92ZWJnLXByZXZpZXcucG5nIiwiaWF0IjoxNzM2NjcyMTYzLCJleHAiOjE3'
                  'NjgyMDgxNjN9._m9IFf7qayC-_hMlixNaJs7HbWAH71oaYFDFaYUjQ8A&t=2025-01-12T08%3A56%3A03.193Z')),
          const SizedBox(
            height: 20,
          ),
          Text(
            'Welcome to Synergy',
            style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 28,
                letterSpacing: 0,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            'Read our Privacy Policy. Tap "Agree and continue" to accept the Terms of Service',
            style: GoogleFonts.poppins(
                color: Colors.grey,
                fontSize: 15,
                letterSpacing: 0,
                fontWeight: FontWeight.w400),
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 60,
          ),
          InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage(),));
            },
            child: Container(
              width: MediaQuery.sizeOf(context).width/1.1,
              height: 45,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: WhatsAppColors.primaryGreen,
              ),
              child: Center(
                child: Text('Agree and continue',style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontWeight: FontWeight.w500
                ),),
              ),
            ),
          ),
          const SizedBox(
            height: 60,
          ),
        ],
      ),
    );
  }
}
