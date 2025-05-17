import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pingstar/Utils/colors.dart';
import 'package:http/http.dart' as http;
import 'package:pingstar/Utils/environment_files.dart';

class AIChatPage extends StatefulWidget {
  const AIChatPage({super.key});

  @override
  State<AIChatPage> createState() => _AIChatPageState();
}

class _AIChatPageState extends State<AIChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<String> chats = [];
  List<String> ChatUid = [];
  Future<void> getAIResponse() async {
    if (kDebugMode) {
      print('Clicked');
    }
    setState(() {
      // Add user's message
      chats.add(_messageController.text);
      ChatUid.add(_auth.currentUser!.uid);
    });

    final response = await http.post(
      Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${EnvironmentFiles.geminiapikey}'),
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": _messageController.text}
            ]
          }
        ]
      }), // Make sure to encode the body as JSON
      headers: {"Content-Type": "application/json"}, // Set content-type to JSON
    );

    if (response.statusCode == 200) {
      // Decode the response body
      var decodedResponse = jsonDecode(response.body);

      // Extract relevant data from the response
      var candidates = decodedResponse['candidates'];
      if (candidates != null && candidates.isNotEmpty) {
        var content = candidates[0]['content']['parts'][0]['text'];
        if (kDebugMode) {
          print(content);
        } // Print the text from the response
        setState(() {
          // Add AI's response
          chats.add(content);
          ChatUid.add('MjxL78Fy2NWmAXYqVVI9e36hyb62');
        });
        _messageController.clear();
      }
    } else {
      print('Request failed with status: ${response.statusCode}');
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WhatsAppColors.darkGreen,
      appBar: AppBar(
        title: Row(
          children: [
            const Image(
              image: NetworkImage(
                  'https://cfyxewbfkabqzrtdyfxc.supabase.co/storage/v1/object/sign/Assets/800px-Meta_AI_logo-remo'
                      'vebg-preview.png?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1cmwiOiJBc3NldHMvODAwcHgtTWV0YV9BSV9sb2dvLXJlbW92ZWJnLXByZXZpZXcucG5'
                      'nIiwiaWF0IjoxNzM3MjIxNjk2LCJleHAiOjE3Njg3NTc2OTZ9.SbXqTuyHtZkHazqLooZGB-09GsXQIpSxnGlDWfviX1s&t=2025-01-18T17%3A34%3A57.203Z'),
              height: 40, width: 40,
            ),
            const SizedBox(
              width: 5,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Connect AI',
                      style: GoogleFonts.poppins(color: Colors.white, fontSize: 18),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    const Icon(Icons.verified,color: Colors.blue,size: 18,),
                  ],
                ),
                const SizedBox(
                  height: 3,
                ),
                Text(
                  'with Llama 3.0',
                  style: GoogleFonts.poppins(color: Colors.grey, fontSize: 10),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: WhatsAppColors.darkGreen,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          // Chat messages
          Expanded(
            child: ListView.builder(
              itemCount: chats.length,
              reverse: true,
              itemBuilder: (context, index) {
                bool isUserMessage = ChatUid[index] == _auth.currentUser!.uid;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: Align(
                    alignment: isUserMessage
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      decoration: BoxDecoration(
                        color: isUserMessage ? Colors.green : Colors.blue,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Text(
                          chats[index],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Message input field
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            color: Colors.grey[900],
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.green),
                  onPressed: _messageController.text!=null || _messageController.text!=''
                      ? getAIResponse
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
