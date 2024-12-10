import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:vistaridedriver/OnBoarding%20Pages/UploadDL.dart';
import 'package:vistaridedriver/OnBoarding%20Pages/uploadrc.dart';

class DocumentUpload extends StatefulWidget {
  const DocumentUpload({super.key});

  @override
  State<DocumentUpload> createState() => _DocumentUploadState();
}

class _DocumentUploadState extends State<DocumentUpload> {
  late VideoPlayerController _controller;
  bool issubmitted=false;
  @override
  void initState() {
    super.initState();
    fetchrc();
    _controller = VideoPlayerController.networkUrl(Uri.parse(
        'https://g1uudlawy6t63z36.public.blob.vercel-storage.com/%2523EkNayaOla.mp4'))
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {
          _controller.pause();
          _controller.setVolume(0);
          _controller.setLooping(false);
        });
      });
  }

  String _imageURLfront = '';
  String _imageURLback = '';
  String _imageURLfrontDL = '';
  String _imageURLbackDL = '';
  String DLNumber = '';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Future<void> fetchrc() async {
    final docsnap = await _firestore
        .collection('VistaRide Driver Details')
        .doc(_auth.currentUser!.uid)
        .get();
    if (docsnap.exists) {
      setState(() {
        _imageURLfront = docsnap.data()?['Front Side RC'];
        _imageURLback = docsnap.data()?['Back Side RC'];
        _imageURLfrontDL = docsnap.data()?['Front Side DL'];
        _imageURLbackDL = docsnap.data()?['Back Side DL'];
        DLNumber = docsnap.data()?['Driving Licence Number'];
        issubmitted=docsnap.data()?['Submitted']??false;
      });
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
      ),
      backgroundColor: Colors.green,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            child: Container(
              height: MediaQuery.sizeOf(context).height / 2.8,
              width: MediaQuery.sizeOf(context).width,
              child: Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: Center(
                  child: _controller.value.isInitialized
                      ? AspectRatio(
                          aspectRatio: _controller.value.aspectRatio,
                          child: VideoPlayer(_controller),
                        )
                      : Container(),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            child: Container(
              height: MediaQuery.sizeOf(context).height / 2,
              width: MediaQuery.sizeOf(context).width,
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(40))),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 50,
                      ),
                      Row(
                        children: [
                          Text(
                            issubmitted?'Approval Pending': 'Upload Documents',
                            style: GoogleFonts.poppins(
                                color: issubmitted?Colors.orange:Colors.black,
                                fontWeight: FontWeight.w700,
                                fontSize: 18),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Text(
                           issubmitted?'Please wait for document approval':'Please keep all the documents handy.',
                            style: GoogleFonts.poppins(
                              color: Colors.black, fontWeight: FontWeight.w400,
                              // fontSize: 18
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      InkWell(
                        onTap: () {
                          !issubmitted? Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UploadRC(),
                              )):null;
                        },
                        child: Container(
                          height: 100,
                          width: MediaQuery.sizeOf(context).width,
                          decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10))),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 10, right: 10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          CupertinoIcons.car,
                                          color: Colors.black,
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Vehicle RC',
                                              style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.w700),
                                            ),
                                            Text(
                                              issubmitted?'Approval Pending':'Upload vehicle RC',
                                              style: GoogleFonts.poppins(
                                                color: issubmitted?Colors.orange:Colors.black,
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 12),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                    const Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.black,
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      InkWell(
                        onTap: () {
                          !issubmitted? Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const UploadDL(
                                  needdlnumber: false,
                                ),
                              )):null;
                        },
                        child: Container(
                          height: 100,
                          width: MediaQuery.sizeOf(context).width,
                          decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10))),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 10, right: 10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          CupertinoIcons.creditcard,
                                          color: Colors.black,
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Driving Licence',
                                              style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.w700),
                                            ),
                                            Text(
                                              issubmitted?'Approval Pending':'Upload driving licence',
                                              style: GoogleFonts.poppins(
                                                  color: issubmitted?Colors.orange:Colors.black,
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 12),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                    const Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.black,
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      InkWell(
                        onTap: () {
                          !issubmitted?Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const UploadDL(
                                  needdlnumber: true,
                                ),
                              )):null;
                        },
                        child: Container(
                          height: 100,
                          width: MediaQuery.sizeOf(context).width,
                          decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10))),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 10, right: 10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          CupertinoIcons.creditcard,
                                          color: Colors.black,
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Licence Number',
                                              style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.w700),
                                            ),
                                            Text(
                                              issubmitted?'Approval Pending': 'Enter licence number',
                                              style: GoogleFonts.poppins(
                                                  color: issubmitted?Colors.orange:Colors.black,
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 12),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                    const Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.black,
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      issubmitted?Container():InkWell(
                        onTap: ()async{
                          final prefs=await SharedPreferences.getInstance();
                          if (DLNumber != '' &&
                              _imageURLfront != '' &&
                              _imageURLback != '' &&
                              _imageURLbackDL != '' &&
                              _imageURLfrontDL != '') {
                            await _firestore.collection('VistaRide Driver Details').doc(_auth.currentUser!.uid).update({
                              'Submitted':true,
                              'Approved':false,
                              'Submission Date':FieldValue.serverTimestamp(),
                              'Car Category':prefs.getString('Car Category'),
                              'Car Name':prefs.get('Car Name'),
                              'Car Number Plate':prefs.getString('Car Number Plate'),
                              'Contact Number':prefs.getString('Contact Number'),
                            });
                            setState(() {
                              issubmitted=true;
                            });
                            prefs.setBool('Submitted', true);
                          }
                        },
                        child: Container(
                          height: 60,
                          width: MediaQuery.sizeOf(context).width,
                          decoration: BoxDecoration(
                              color: DLNumber != '' &&
                                      _imageURLfront != '' &&
                                      _imageURLback != '' &&
                                      _imageURLbackDL != '' &&
                                      _imageURLfrontDL != ''
                                  ? Colors.black
                                  : Colors.grey,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20))),
                          child: Center(
                            child: Text(
                              'Submit Details',
                              style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
