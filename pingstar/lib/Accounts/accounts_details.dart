import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pingstar/Utils/colors.dart';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../Utils/environment_files.dart';

class Accounts_Page extends StatefulWidget {
  const Accounts_Page({super.key});

  @override
  State<Accounts_Page> createState() => _Accounts_PageState();
}

class _Accounts_PageState extends State<Accounts_Page> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String contactnumber = '';
  String status = '';
  String profilepicture = '';
  String username = '';
  File? _image;
  Future<void> getprofiledetails() async {
    final docsnap = await _firestore
        .collection('User Details(User ID Basis)')
        .doc(_auth.currentUser!.uid)
        .get();
    if (docsnap.exists) {
      setState(() {
        contactnumber = docsnap.data()?['Mobile Number'];
        status = docsnap.data()?['Status'];
        profilepicture = docsnap.data()?['Profile Picture'] ??
            'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png';
        username = docsnap.data()?['Username'];
      });
    }
  }
  Future<void>updateprofilepicture(String imageurl)async{
    await _firestore.collection('User Details(User ID Basis)').doc(_auth.currentUser!.uid).update(
        {
          'Profile Picture':imageurl
        });
    await _firestore.collection('User Details(Contact Number Basis)').doc(contactnumber).update(
        {
          'Profile Picture':imageurl
        });
  }
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      uploadImageToSupabase(_image!);
    }
  }
  SupabaseClient? _supabaseClient;
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
  String imageURL = '';
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
      const bucketName = 'Status Images'; // Replace with your bucket name
      final fileName = '${userId ?? 'anonymous'}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Upload the file to Supabase Storage
      final storage = supabase.storage.from(bucketName);
      final response = await storage.upload(fileName, image);

      // Check if there was an error during the upload

      // Retrieve the public URL of the uploaded image
      final imageUrl = storage.getPublicUrl(fileName);
      if (kDebugMode) {
        print('Image successfully uploaded! URL: $imageUrl');
      }
      await updateprofilepicture(imageUrl);
      await getprofiledetails();
    } catch (e) {

      // Handle errors and print them to the console
      print('Error uploading image: $e');
    }
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getprofiledetails();
    initializeSupabase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WhatsAppColors.darkGreen,
      appBar: AppBar(
        backgroundColor: WhatsAppColors.darkGreen,
        title: Text(
          'Profile',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 20,right: 20),
          child: Column(
            children: [
              const SizedBox(
                height: 40,
              ),
              Stack(
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(profilepicture),
                    ),
                  ),
                   Positioned(
                      bottom: 0,
                      left: 300,
                      child: InkWell(
                        onTap: _pickImage,
                        child: const CircleAvatar(
                          backgroundColor: WhatsAppColors.primaryGreen,
                          radius: 12,
                          child: Icon(
                            Icons.camera_alt_outlined,
                            color: Colors.black,
                            size: 15,
                          ),
                        ),
                      ))
                ],
              ),
              const SizedBox(
                height: 40,
              ),
              Container(
                width: MediaQuery.sizeOf(context).width,
                child: Row(
                  children: [
                    const SizedBox(
                      width: 20,
                    ),
                    const Icon(CupertinoIcons.person,color: Colors.white,),
                    const SizedBox(
                      width: 20,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Name',style: GoogleFonts.poppins(
                          color: Colors.grey
                        ),),
                        Text(username,style: GoogleFonts.poppins(
                            color: Colors.white,fontSize: 15
                        ),),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 40,
              ),
              Container(
                width: MediaQuery.sizeOf(context).width,
                child: Row(
                  children: [
                    const SizedBox(
                      width: 20,
                    ),
                    const Icon(CupertinoIcons.info,color: Colors.white,),
                    const SizedBox(
                      width: 20,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('About',style: GoogleFonts.poppins(
                            color: Colors.grey
                        ),),
                        Text(status,style: GoogleFonts.poppins(
                            color: Colors.white,fontSize: 15
                        ),),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 40,
              ),
              Container(
                width: MediaQuery.sizeOf(context).width,
                child: Row(
                  children: [
                    const SizedBox(
                      width: 20,
                    ),
                    const Icon(CupertinoIcons.phone,color: Colors.white,),
                    const SizedBox(
                      width: 20,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Contact',style: GoogleFonts.poppins(
                            color: Colors.grey
                        ),),
                        Text('+91 ${contactnumber}',style: GoogleFonts.poppins(
                            color: Colors.white,fontSize: 15
                        ),),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
