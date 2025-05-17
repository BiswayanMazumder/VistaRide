import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pingstar/Logged%20In%20Users/allchatspage.dart';
import 'package:pingstar/Logged%20In%20Users/callpage.dart';
import 'package:pingstar/Logged%20In%20Users/updatespage.dart';
import 'package:pingstar/Utils/colors.dart';

class LoggedInUserTopBar extends StatefulWidget {
  const LoggedInUserTopBar({super.key});

  @override
  State<LoggedInUserTopBar> createState() => _LoggedInUserTopBarState();
}

class _LoggedInUserTopBarState extends State<LoggedInUserTopBar> {
  int currentIndex = 0;

  final List<Widget> pages = [
    const AllChats(),
    const UpdatesPage(),
    const CallPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WhatsAppColors.darkGreen,
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        backgroundColor: WhatsAppColors.darkGreen,
        selectedItemColor: WhatsAppColors.primaryGreen,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.update),
            label: 'Updates',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.call),
            label: 'Calls',
          ),
        ],
      ),
    );
  }
}
