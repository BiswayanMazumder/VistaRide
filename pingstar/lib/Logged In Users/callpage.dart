import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pingstar/Utils/colors.dart';
class CallPage extends StatefulWidget {
  const CallPage({super.key});

  @override
  State<CallPage> createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WhatsAppColors.darkGreen,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: WhatsAppColors.darkGreen,
        actions: [
          Row(
            children: [
              InkWell(
                onTap: () {},
                child: const Icon(
                  Icons.camera_alt_outlined,
                  color: Colors.white,
                ),
              ),
              const SizedBox(
                width: 20,
              ),
              InkWell(
                onTap: () {},
                child: const Icon(
                  CupertinoIcons.search,
                  color: Colors.white,
                ),
              ),
              const SizedBox(
                width: 20,
              ),
              InkWell(
                onTap: () {},
                child: const Icon(
                  CupertinoIcons.ellipsis_vertical,
                  color: Colors.white,
                ),
              ),
              const SizedBox(
                width: 10,
              ),
            ],
          )
        ],
        title: Text(
          'Calls',
          style: GoogleFonts.actor(
              color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
