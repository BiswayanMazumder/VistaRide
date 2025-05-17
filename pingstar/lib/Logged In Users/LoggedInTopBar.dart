import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pingstar/Logged%20In%20Users/allchatspage.dart';
import 'package:pingstar/Logged%20In%20Users/callpage.dart';
import 'package:pingstar/Logged%20In%20Users/updatespage.dart';
import 'package:pingstar/Utils/colors.dart';

class Loggedinusertopbar extends StatefulWidget {
  const Loggedinusertopbar({super.key});

  @override
  State<Loggedinusertopbar> createState() => _LoggedinusertopbarState();
}

class _LoggedinusertopbarState extends State<Loggedinusertopbar> {
  int currentPageIndex = 0;

  final List<Widget> pages = [
    const AllChats(),
    const UpdatesPage(),
    const CallPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WhatsAppColors.darkGreen,
      body: Column(
        children: [
          Container(
            width: MediaQuery.sizeOf(context).width,
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      currentPageIndex = 0;
                    });
                  },
                  child: Text(
                    'Chats',
                    style: GoogleFonts.poppins(
                      color: currentPageIndex == 0
                          ? Colors.green
                          : Colors.white,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      currentPageIndex = 1;
                    });
                  },
                  child: Text(
                    'Updates',
                    style: GoogleFonts.poppins(
                      color: currentPageIndex == 1
                          ? Colors.green
                          : Colors.white,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      currentPageIndex = 2;
                    });
                  },
                  child: Text(
                    'Calls',
                    style: GoogleFonts.poppins(
                      color: currentPageIndex == 2
                          ? Colors.green
                          : Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: pages[currentPageIndex],
          ),
        ],
      ),
    );
  }
}
