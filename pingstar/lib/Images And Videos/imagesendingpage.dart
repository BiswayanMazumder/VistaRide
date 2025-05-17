import 'package:flutter/material.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pingstar/Utils/environment_files.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ImageSending extends StatefulWidget {
  final File? image; // Image file to upload
  final String otherUID; // Receiver's UID

  const ImageSending({Key? key, required this.image, required this.otherUID}) : super(key: key);

  @override
  State<ImageSending> createState() => _ImageSendingState();
}

class _ImageSendingState extends State<ImageSending> {
  SupabaseClient? _supabaseClient;
  String imageURL = '';

  @override
  void initState() {
    super.initState();
    initializeSupabase();
  }

  Future<void> initializeSupabase() async {
    try {
      await Supabase.initialize(
        url: EnvironmentFiles.supabaseURL, // Replace with your Supabase URL
        anonKey: EnvironmentFiles.supabaseannonkey, // Replace with your Supabase anon key
      );
      setState(() {
        _supabaseClient = Supabase.instance.client; // Assign the initialized client
      });
    } catch (e) {
      print('Error initializing Supabase: $e');
    }
  }

  Future<void> uploadImageToSupabase(File image) async {
    try {
      // Initialize Supabase client
      final supabase = Supabase.instance.client;

      // Default credentials for authentication
      const defaultEmail = 'biswayanmazumder77@gmail.com'; // Replace with your default email
      String defaultPassword = EnvironmentFiles.supabasepassword; // Replace with your default password

      // Authenticate using the default email and password
      final sessionResponse = await supabase.auth.signInWithPassword(
        email: defaultEmail,
        password: defaultPassword,
      );

      // Get the authenticated user's ID
      final userId = sessionResponse.session?.user?.id;

      // Define the bucket and file name
      const bucketName = 'Chat Images'; // Replace with your bucket name
      final fileName = '${userId ?? 'anonymous'}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Upload the file to Supabase Storage
      final storage = supabase.storage.from(bucketName);
      final response = await storage.upload(fileName, image);

      // Check if there was an error during the upload

      // Retrieve the public URL of the uploaded image
      final imageUrl = storage.getPublicUrl(fileName);
      print('Image successfully uploaded! URL: $imageUrl');
      setState(() {
        imageURL = imageUrl;
      });

      // Now, upload the same image URL to Firestore
      await sendImageMessage(imageUrl);

    } catch (e) {
      // Handle errors and print them to the console
      print('Error uploading image: $e');
    }
  }

  Future<void> sendImageMessage(String imageUrl) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser!;
      final timestamp = FieldValue.serverTimestamp();

      // Add image message to Firestore
      final docRef = await FirebaseFirestore.instance.collection('chats').add({
        'senderID': currentUser.uid,
        'receiverID': widget.otherUID,
        'message': imageUrl, // Image URL
        'timestamp': timestamp,
        'status': 'pending', // Message status
        'messageType': 'image', // Message type
      });

      // Update status to 'sent' after adding
      await docRef.update({'status': 'sent'});
      print('Image message sent to Firestore!');
      Navigator.pop(context);
    } catch (e) {
      print('Error sending image message: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
      bottomNavigationBar: Container(
        height: 80,
        color: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            IconButton(
              icon: const Icon(Icons.send, color: Colors.green),
              onPressed: () {
                if (widget.image != null) {
                  uploadImageToSupabase(widget.image!);
                } else {
                  print('No image selected.');
                }
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: widget.image != null
            ? Image.file(widget.image!) // Display the image
            : const Text(
          'No image selected.',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
