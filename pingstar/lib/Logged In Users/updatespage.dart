import 'package:blur/blur.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pingstar/Multimedia%20Viewing%20Pages/updateviewingpage.dart';
import 'package:pingstar/Status%20Pages/upload_status.dart';
import 'package:pingstar/Utils/colors.dart';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

class UpdatesPage extends StatefulWidget {
  const UpdatesPage({super.key});

  @override
  State<UpdatesPage> createState() => _UpdatesPageState();
}

class _UpdatesPageState extends State<UpdatesPage> {
  bool statusseen = false;
  File? _image;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => StatusUploading(
                  image: _image, otherUID: _auth.currentUser!.uid)));
    }
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String ImageUrl = '';
  void _listenToStatus() {
    _firestore
        .collection('Users Status')
        .doc(_auth.currentUser!.uid)
        .snapshots()
        .listen((docsnap) {
      if (docsnap.exists) {
        setState(() {
          ImageUrl = docsnap.data()?['Image URL'];
        });
      }
    });
  }

  List<String> contactname = []; // List to store contact names
  List<String> contactnumber = []; // List to store contact numbers
  List<String> ContactNumber = [];

  String normalizePhoneNumber(String number) {
    String normalized = number.replaceAll(RegExp(r'\s+|-|\(|\)|\+'), '');
    if (normalized.startsWith('91') && normalized.length > 10) {
      normalized = normalized.substring(2);
    }
    return normalized;
  }

  Future<void> getContacts() async {
    try {
      if (await FlutterContacts.requestPermission()) {
        List<Contact> contacts =
            await FlutterContacts.getContacts(withProperties: true);

        List<String> names = [];
        List<String> numbers = [];

        for (var contact in contacts) {
          String name = contact.displayName ?? 'Unnamed Contact';
          String phoneNumber = contact.phones.isNotEmpty
              ? contact.phones.first.number ?? 'No phone number'
              : 'No phone number';

          names.add(name);
          numbers.add(normalizePhoneNumber(phoneNumber));
        }

        setState(() {
          contactname = names;
          contactnumber = numbers;
        });
      }
      if (kDebugMode) {
        print(contactnumber);
      }
      if (kDebugMode) {
        print(contactname);
      }
    } catch (e) {
      if (kDebugMode) print('Failed to fetch contacts: $e');
    }
  }

  List<dynamic> statusimageURL = [];
  bool _isloading=true;
  List<String> ContactsUIDS = [];
  Future<void> fetchcontactstatus() async {
    setState(() {
      _isloading=true;
    });
    await getContacts();
    for (int i = 0; i < contactnumber.length; i++) {
      final docsnap = await _firestore
          .collection('User Details(Contact Number Basis)')
          .doc(contactnumber[i])
          .get();
      if (docsnap.exists) {
        ContactsUIDS.add(docsnap.data()?['UID']);
      }
      else{
        setState(() {
          _isloading=false;
        });
      }
    }
    if (kDebugMode) {
      print("UIDS $ContactsUIDS");
    }
    for (int k = 0; k < ContactsUIDS.length; k++) {
      final StatusSnap = await _firestore
          .collection('Users Status')
          .doc(ContactsUIDS[k])
          .get();
      if (StatusSnap.exists) {
        statusimageURL.add(StatusSnap.data()?['Image URL']);
      }
    }
    if (kDebugMode) {
      print('Status $statusimageURL');
    }
    setState(() {
      _isloading=false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _listenToStatus();
    fetchcontactstatus();
    // getContacts();
  }

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
                onTap: () {
                  if(ImageUrl==''){
                    _pickImage();
                  }
                },
                child: const Icon(
                  Icons.camera_alt_outlined,
                  color: Colors.white,
                ),
              ),
              const SizedBox(
                width: 10,
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
          'Updates',
          style: GoogleFonts.actor(
              color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        child:_isloading?const Column(
          children: [
             Center(child: CircularProgressIndicator(color: WhatsAppColors.primaryGreen,)),
          ],
        ): Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Text(
                    'Status',
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600),
                  )
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              SingleChildScrollView(
                // scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Stack(
                      children: [
                        InkWell(
                          onTap: () {
                            if (ImageUrl == '') {
                              _pickImage();
                            }
                            if (ImageUrl != '') {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => UpdateViewing(
                                      imageUrl: ImageUrl,
                                      Name: 'My Status',
                                      isowner: true,
                                      storyowneruid: _auth.currentUser!.uid,
                                      contactname: contactname,
                                      contactnumber: contactnumber,
                                    ),
                                  ));
                            }
                          },
                          child: Container(
                            height: 250,
                            width: 180,
                            decoration: BoxDecoration(
                                color: Colors.grey.shade500.withOpacity(0.5),
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(10))),
                            child: ImageUrl == ''
                                ? Container()
                                : Container(
                                    height: 250,
                                    width: 180,
                                    decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10))),
                                    child: Image(
                                      image: NetworkImage(ImageUrl),
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                          ),
                        ),
                        Positioned(
                            top: 10,
                            left: 10,
                            child: Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                color: statusseen ? Colors.grey : Colors.green,
                                shape: BoxShape.circle,
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(4.0),
                                child: CircleAvatar(
                                  backgroundImage: NetworkImage(
                                      'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png'),
                                  radius: 10,
                                  backgroundColor: Colors.white,
                                ),
                              ),
                            )),
                        const Positioned(
                            left: 40,
                            top: 40,
                            child: CircleAvatar(
                              backgroundColor: WhatsAppColors.primaryGreen,
                              radius: 10,
                              child: Icon(
                                Icons.add,
                                color: Colors.black,
                                size: 15,
                              ),
                            )),
                        Positioned(
                            bottom: 10,
                            left: 10,
                            child: Text(
                              'My Status',
                              style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600),
                            )),
                      ],
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    for (int i = 0; i < statusimageURL.length; i++)
                      Row(
                        children: [
                          Stack(
                            children: [
                              InkWell(
                                onTap: () async{
                                  // final prefs=await SharedPreferences.getInstance();
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => UpdateViewing(
                                          imageUrl: statusimageURL[i],
                                          storyowneruid: ContactsUIDS[i],
                                          isowner: false,
                                          Name: contactname[i],
                                          contactname: contactname,
                                          contactnumber: contactnumber,
                                        ),
                                      ));
                                },
                                child: Container(
                                  height: 250,
                                  width: 180,
                                  decoration: BoxDecoration(
                                      color:
                                          Colors.grey.shade500.withOpacity(0.5),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(10))),
                                  child: Container(
                                    height: 250,
                                    width: 180,
                                    decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10))),
                                    child: Image(
                                      image: NetworkImage(statusimageURL[i]),
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                  top: 10,
                                  left: 10,
                                  child: Container(
                                    height: 50,
                                    width: 50,
                                    decoration: BoxDecoration(
                                      color: statusseen
                                          ? Colors.grey
                                          : Colors.green,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Padding(
                                      padding: EdgeInsets.all(4.0),
                                      child: CircleAvatar(
                                        backgroundImage: NetworkImage(
                                            'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png'),
                                        radius: 10,
                                        backgroundColor: Colors.white,
                                      ),
                                    ),
                                  )),
                              Positioned(
                                  bottom: 10,
                                  left: 10,
                                  child: Text(
                                    contactname[i],
                                    style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600),
                                  )),
                            ],
                          ),
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
