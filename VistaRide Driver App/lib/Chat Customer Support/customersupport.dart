import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatSupport extends StatefulWidget {
  final String RideID; // Pass RideID to this widget

  const ChatSupport({super.key, required this.RideID});

  @override
  State<ChatSupport> createState() => _ChatSupportState();
}

class _ChatSupportState extends State<ChatSupport> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isLoaded = false;
  String profilePic = ''; // User's profile picture URL

  // Fetch user details (like profile picture)
  Future<void> fetchUserDetails() async {
    setState(() {
      isLoaded = true;
    });
    final docSnap = await _firestore
        .collection('VistaRide Driver Details')
        .doc(_auth.currentUser!.uid)
        .get();

    if (docSnap.exists) {
      setState(() {
        profilePic = docSnap.data()?['Profile Picture'] ?? '';
      });
    }
    setState(() {
      isLoaded = false;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
  }

  // Function to send messages to Firestore
  void _sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      String messageText = _messageController.text;
      String senderId = _auth.currentUser!.uid;

      try {
        await _firestore
            .collection('Driver Chat Support') // Main collection for chats
            .doc(widget.RideID) // Document with RideID as the identifier
            .collection('Messages') // Sub-collection for messages
            .add({
          'message': messageText, // Message content
          'senderId': senderId, // Sender's UID
          'timestamp': FieldValue.serverTimestamp(), // Timestamp
        });

        _messageController.clear(); // Clear text field after sending
      } catch (e) {
        print('Error saving message: $e');
      }
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
      body: isLoaded
          ? const Center(
        child: CircularProgressIndicator(
          color: Colors.black,
        ),
      )
          : StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('Driver Chat Support')
            .doc(widget.RideID) // Using RideID to find the chat
            .collection('Messages') // Sub-collection for messages
            .orderBy('timestamp', descending: false) // Order by timestamp
            .snapshots(), // Stream updates when new messages arrive
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          var chatDocs = snapshot.data!.docs;

          return Stack(
            children: [
              // ListView to display messages
              Positioned.fill(
                bottom: 100, // Leave space for the input field at the bottom
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: ListView.builder(
                    itemCount: chatDocs.length,
                    itemBuilder: (context, index) {
                      var messageData = chatDocs[index];
                      bool isSender =
                          messageData['senderId'] == _auth.currentUser!.uid;

                      return Align(
                        alignment: isSender
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Row(
                          mainAxisAlignment: isSender
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.start,
                          children: [
                            if (!isSender) ...[
                              const CircleAvatar(
                                backgroundColor: Colors.grey,
                                child: Icon(Icons.person, color: Colors.white),
                              ),
                              const SizedBox(width: 8),
                            ],
                            Padding(
                              padding: const EdgeInsets.only(bottom: 30, top: 25),
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 5),
                                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                                decoration: BoxDecoration(
                                  color: isSender ? Colors.blue[100] : Colors.grey[300],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  messageData['message'],
                                  style: GoogleFonts.poppins(fontSize: 16),
                                ),
                              ),
                            ),
                            if (isSender) ...[
                              const SizedBox(width: 8),
                              CircleAvatar(
                                backgroundImage: profilePic.isNotEmpty
                                    ? NetworkImage(profilePic)
                                    : null,
                                backgroundColor: profilePic.isEmpty
                                    ? Colors.grey
                                    : Colors.transparent,
                                child: profilePic.isEmpty
                                    ? const Icon(Icons.person, color: Colors.white)
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
                          borderRadius: const BorderRadius.all(Radius.circular(50)),
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
          );
        },
      ),
    );
  }
}
