import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart'; // Import the image_picker package
import 'dart:io'; // For File handling
import 'package:vistaridedriver/OnBoarding%20Pages/documentupload.dart';

class UploadDL extends StatefulWidget {
  final bool needdlnumber;
  const UploadDL({super.key, required this.needdlnumber});
  @override
  State<UploadDL> createState() => _UploadRCState();
}

class _UploadRCState extends State<UploadDL> {
  File? _frontImage; // Variable to store the front image
  File? _backImage; // Variable to store the back image
  final ImagePicker _picker = ImagePicker(); // Image picker instance
  bool isUploading = false;
  String _imageURLfront = '';
  String _imageURLback = '';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Function to pick image from the gallery
  Future<void> _pickImage(bool isFront) async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        if (isFront) {
          _frontImage = File(pickedFile.path);
        } else {
          _backImage = File(pickedFile.path);
        }
      });
    }
  }

  final TextEditingController _DLNumber = TextEditingController();
  // Function to upload images to Firebase Storage
  Future<String> _uploadImage(File image, String fileName) async {
    try {
      // Create a reference to the Firebase Storage location
      final storageRef =
          FirebaseStorage.instance.ref().child('dl_images/$fileName');

      // Upload the image to Firebase Storage
      await storageRef.putFile(image);

      // Get the download URL of the uploaded image
      String downloadURL = await storageRef.getDownloadURL();

      return downloadURL;
    } catch (e) {
      print('Error uploading image: $e');
      throw e;
    }
  }

  Future<void> fetchrc() async {
    final docsnap = await _firestore
        .collection('VistaRide Driver Details')
        .doc(_auth.currentUser!.uid)
        .get();
    if (docsnap.exists) {
      setState(() {
        _imageURLfront = docsnap.data()?['Front Side DL'];
        _imageURLback = docsnap.data()?['Back Side DL'];
      });
    }
  }

  // Function to update Firestore with the image URLs
  Future<void> uploadRC() async {
    if (_frontImage != null && _backImage != null) {
      setState(() {
        isUploading = true;
      });

      try {
        // Upload the front image and get the download URL
        String frontImageURL = await _uploadImage(
            _frontImage!, 'front_dl_${_auth.currentUser!.uid}.jpg');

        // Upload the back image and get the download URL
        String backImageURL = await _uploadImage(
            _backImage!, 'back_dl_${_auth.currentUser!.uid}.jpg');

        // Update Firestore with the image URLs
        await _firestore
            .collection('VistaRide Driver Details')
            .doc(_auth.currentUser!.uid)
            .update({
          'Front Side DL': frontImageURL,
          'Back Side DL': backImageURL,
        });

        // Update local variables with URLs
        setState(() {
          _imageURLfront = frontImageURL;
          _imageURLback = backImageURL;
          isUploading = false;
        });

        // Optionally, show a success message
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('RC images uploaded successfully!')));
      } catch (e) {
        setState(() {
          isUploading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error uploading images.')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please upload both front and back images')));
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchrc();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      bottomNavigationBar: Container(
        height: 80,
        width: MediaQuery.sizeOf(context).width,
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              InkWell(
                onTap: () async {
                  if (widget.needdlnumber) {
                    if (_DLNumber.text.isNotEmpty) {
                      if (kDebugMode) {
                        print("DL NUMBER ${_DLNumber.text}");
                      }
                      await _firestore.collection('VistaRide Driver Details').doc(_auth.currentUser!.uid).update(
                          {
                            'Driving Licence Number':_DLNumber.text
                          });
                      Navigator.push(context, MaterialPageRoute(builder: (context) => DocumentUpload(),));
                    }
                  }
                  if (widget.needdlnumber == false) {
                    if (_frontImage != null && _backImage != null) {
                      await uploadRC();
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DocumentUpload(),
                          ));
                    }
                  }
                },
                child: Container(
                  width: MediaQuery.sizeOf(context).width,
                  height: 60,
                  decoration: BoxDecoration(
                      color: widget.needdlnumber
                          ? _DLNumber.text.isNotEmpty
                              ? Colors.black
                              : Colors.grey
                          : _frontImage != null && _backImage != null
                              ? Colors.black
                              : Colors.grey,
                      borderRadius:
                          const BorderRadius.all(Radius.circular(10))),
                  child: Center(
                    child: isUploading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : Text(
                            'Continue',
                            style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.w600),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 30,
              ),
              Text(
                'Make sure all the data on your document are fully visible, glare free and not blurred',
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                ),
              ),
              const SizedBox(
                height: 40,
              ),
              const Padding(
                padding: EdgeInsets.only(left: 40, right: 40),
                child: Image(
                  image: NetworkImage(
                      'https://cdni.iconscout.com/illustration/premium/thumb/driving-license-illustration-download-in-svg-png-gif-file-formats--getting-driver-get-permission-identification-proof-miscellaneous-pack-illustrations-4397188.png'),
                ),
              ),
              const SizedBox(
                height: 40,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  InkWell(
                    onTap: () {
                      if (!widget.needdlnumber) {
                        _pickImage(true);
                      }
                    }, // Call the function to pick front image
                    child: Container(
                      height: 120,
                      width: 150,
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.2),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.file_upload_outlined,
                              color: Colors.blue,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              'Upload front side',
                              style: GoogleFonts.poppins(
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                            // Display the selected image if exists
                            if (_frontImage == null && _imageURLfront != '')
                              Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Image(
                                    image: NetworkImage(_imageURLfront),
                                    height: 50,
                                    width: 50,
                                    fit: BoxFit.cover,
                                  )),
                            if (_frontImage != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Image.file(
                                  _frontImage!,
                                  height: 50,
                                  width: 50,
                                  fit: BoxFit.cover,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      if (!widget.needdlnumber) {
                        _pickImage(false);
                      }
                    }, // Call the function to pick back image
                    child: Container(
                      height: 120,
                      width: 150,
                      decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.2),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10))),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.file_upload_outlined,
                              color: Colors.blue,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              'Upload back side',
                              style: GoogleFonts.poppins(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12),
                            ),
                            // Display the selected image if exists
                            if (_backImage == null && _imageURLback != '')
                              Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Image(
                                    image: NetworkImage(_imageURLback),
                                    height: 50,
                                    width: 50,
                                    fit: BoxFit.cover,
                                  )),
                            if (_backImage != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Image.file(
                                  _backImage!,
                                  height: 50,
                                  width: 50,
                                  fit: BoxFit.cover,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (widget.needdlnumber)
                Column(
                  children: [
                    const SizedBox(
                      height: 40,
                    ),
                    Row(
                      children: [
                        Text(
                          'Driving Licence Number',
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: MediaQuery.sizeOf(context).width,
                      height: 50,
                      color: Colors.grey.shade100,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: TextField(
                          controller: _DLNumber,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                              hintText: 'Driving Licence Number',
                              hintStyle: GoogleFonts.poppins(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14),
                              border: InputBorder.none),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                )
            ],
          ),
        ),
      ),
    );
  }
}
