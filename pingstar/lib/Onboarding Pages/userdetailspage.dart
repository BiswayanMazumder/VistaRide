import 'dart:io'; // For File type
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart'; // Import the image_picker package
import 'package:pingstar/Logged%20In%20Users/allchatspage.dart';
import 'package:pingstar/Navigation%20Bar/bottomnavbar.dart';
import 'package:pingstar/Utils/colors.dart';

class UserDetails extends StatefulWidget {
  final String phonenumber;
  const UserDetails({super.key,required this.phonenumber});

  @override
  State<UserDetails> createState() => _UserDetailsState();
}

class _UserDetailsState extends State<UserDetails> {
  final TextEditingController _NameController = TextEditingController();
  List<Contact> _contacts = [];
  File? _imageFile; // Store the selected image file
  final FirebaseFirestore _firestore=FirebaseFirestore.instance;
  final FirebaseAuth _auth=FirebaseAuth.instance;
  Future<void>updateusername()async{
    await _firestore.collection('User Details(User ID Basis)').doc(_auth.currentUser!.uid).update(
        {
          'Username':_NameController.text,
          'Status':'Hey there! Am using Connect'
        });
    await _firestore.collection('User Details(Contact Number Basis)').doc(widget.phonenumber).update({
          'Username':_NameController.text,
          'Status':'Hey there! Am using Connect'
    });
  }
  // Function to request permission to access contacts and get contacts
  Future<void> getcontacts() async {
    PermissionStatus permissionStatus = await Permission.contacts.request();

    if (permissionStatus.isGranted) {
      try {
        List<Contact> contacts = await ContactsService.getContacts();
        setState(() {
          _contacts = contacts;
        });
        if (kDebugMode) {
          for (var contact in contacts) {
            String contactName = contact.displayName ?? 'Unnamed Contact';

            // Check if the phones list is not null and not empty
            String contactPhoneNumber = (contact.phones != null && contact.phones!.isNotEmpty)
                ? contact.phones!.first.value ?? 'No phone number'
                : 'No phone number';

            print('Name: $contactName, Phone: $contactPhoneNumber');
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('Failed to load contacts: $e');
        }
      }
    } else {
      if (kDebugMode) {
        print('Contact permission denied');
      }
    }
  }

  // Function to pick an image from gallery
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path); // Set the picked image to the _imageFile variable
      });
    } else {
      if (kDebugMode) {
        print('No image selected.');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // Request contact permissions as soon as the page loads
    getcontacts();
  }

  String error = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WhatsAppColors.darkGreen,
      appBar: AppBar(
        backgroundColor: WhatsAppColors.darkGreen,
        automaticallyImplyLeading: true,
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            height: 30,
          ),
          Center(
            child: Text(
              'Profile Info',
              style: GoogleFonts.poppins(color: WhatsAppColors.primaryGreen, fontSize: 28),
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          Text(
            'Please provide your name and an optional profile photo',
            style: GoogleFonts.poppins(color: Colors.grey, fontSize: 15, fontWeight: FontWeight.w400),
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 50,
          ),
          InkWell(
            onTap: _pickImage, // Trigger image selection when the avatar is tapped
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey,
              backgroundImage: _imageFile != null
                  ? FileImage(_imageFile!) // Show the selected image
                  : null, // If no image is selected, display no image
              child: _imageFile == null
                  ? Icon(
                Icons.add_a_photo,
                color: Colors.grey.shade700,
                size: 35,
              )
                  : null, // Show the icon only if no image is selected
            ),
          ),
          const SizedBox(
            height: 50,
          ),
          SizedBox(
            width: MediaQuery.sizeOf(context).width / 1.5,
            child: TextField(
              controller: _NameController,
              style: GoogleFonts.poppins(color: Colors.green),
              decoration: InputDecoration(
                hintText: 'Type your name here',
                hintStyle: GoogleFonts.poppins(color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          Text(
            error,
            style: GoogleFonts.poppins(
              color: Colors.red,
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          InkWell(
            onTap: ()async{
              if(_NameController.text.isNotEmpty){
                await updateusername();
                Navigator.push(context, MaterialPageRoute(builder: (context) => LoggedInUserTopBar(),));
              }
              if (_NameController.text.isEmpty) {
                setState(() {
                  error = 'Please enter a name to continue.';
                });
                Future.delayed(const Duration(seconds: 5), () {
                  setState(() {
                    error = '';
                  });
                });
              }
            },
            child: Container(
              width: 100,
              height: 45,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: WhatsAppColors.primaryGreen,
              ),
              child: Center(
                child: Text(
                  'NEXT',
                  style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
