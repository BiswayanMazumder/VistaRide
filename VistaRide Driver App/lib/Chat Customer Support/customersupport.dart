import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatSupport extends StatefulWidget {
  final String RideID; // Add a field to accept the name

  const ChatSupport({super.key, required this.RideID});

  @override
  State<ChatSupport> createState() => _ChatSupportState();
}

class _ChatSupportState extends State<ChatSupport> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isloaded = false;
  String profilepic = ''; // User's profile picture URL

  Future<void> fetchuserdetails() async {
    setState(() {
      isloaded = true;
    });
    final docsnap = await _firestore
        .collection('VistaRide Driver Details')
        .doc(_auth.currentUser!.uid)
        .get();
    if (docsnap.exists) {
      setState(() {
        profilepic = docsnap.data()?['Profile Picture'] ?? '';
      });
    }
    setState(() {
      isloaded = false;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchuserdetails();
  }

  List<String> messages = [
    'Hi',
    'How can I help you',
  ]; // List of messages
  List<bool> issender = [true, false]; // List to track whether message is from the user or not

  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      setState(() {
        messages.add(_messageController.text); // Add message to list
        issender.add(true); // Mark the message as sent by user
      });
      _messageController.clear(); // Clear the text field
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(
          'Chat Support',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: isloaded
          ? const Center(
        child: CircularProgressIndicator(
          color: Colors.black,
        ),
      )
          : Stack(
        children: [
          // ListView for displaying messages
          Positioned.fill(
            bottom: 100, // Leave space for the message input field
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: ListView.builder(
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  return Align(
                    alignment: issender[index]
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Row(
                      mainAxisAlignment: issender[index]
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      children: [
                        if (!issender[index]) ...[
                          const CircleAvatar(
                            backgroundColor: Colors.grey,
                            child: Icon(Icons.person, color: Colors.white),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Padding(
                          padding: const EdgeInsets.only(bottom: 30,top: 25),
                          child: Container(
                            margin:
                            const EdgeInsets.symmetric(vertical: 5),
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 15),
                            decoration: BoxDecoration(
                              color: issender[index]
                                  ? Colors.blue[100]
                                  : Colors.grey[300],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              messages[index],
                              style: GoogleFonts.poppins(fontSize: 16),
                            ),
                          ),
                        ),
                        if (issender[index]) ...[
                          const SizedBox(width: 8),
                          CircleAvatar(
                            backgroundImage: profilepic.isNotEmpty
                                ? NetworkImage(profilepic)
                                : null,
                            backgroundColor: profilepic.isEmpty
                                ? Colors.grey
                                : Colors.transparent,
                            child: profilepic.isEmpty
                                ? const Icon(Icons.person,
                                color: Colors.white)
                                : null,
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
          ),

          // Bottom message input container
          Positioned(
            bottom: 0,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 100,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius:
                      const BorderRadius.all(Radius.circular(50)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          suffixIcon: InkWell(
                            onTap: _sendMessage, // Send message on tap
                            child: const Icon(
                              Icons.send,
                              color: Colors.black,
                            ),
                          ),
                          border: InputBorder.none,
                          hintText: 'Enter your message...',
                          hintStyle: GoogleFonts.poppins(
                              color: Colors.black,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
