// video call page
// import 'package:flutter/material.dart';
// import 'package:camera/camera.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:pingstar/Utils/colors.dart';
//
// class VideoCallPage extends StatefulWidget {
//   final String UserID;
//   final String Name;
//
//   const VideoCallPage({super.key, required this.UserID, required this.Name});
//
//   @override
//   State<VideoCallPage> createState() => _VideoCallPageState();
// }
//
// class _VideoCallPageState extends State<VideoCallPage> {
//   late CameraController _cameraController;
//   late Future<void> _initializeControllerFuture;
//
//   bool iscameraon = true;
//   bool ismicon = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeCamera(true); // Default to front camera
//   }
//
//   // Initializes the camera
//   Future<void> _initializeCamera(bool isFront) async {
//     final cameras = await availableCameras();
//     final camera = cameras.firstWhere(
//           (camera) => isFront
//           ? camera.lensDirection == CameraLensDirection.front
//           : camera.lensDirection == CameraLensDirection.back,
//     );
//     _cameraController = CameraController(camera, ResolutionPreset.high);
//     _initializeControllerFuture = _cameraController.initialize();
//     setState(() {});
//   }
//
//   // Dispose the camera controller when done
//   @override
//   void dispose() {
//     _cameraController.dispose();
//     super.dispose();
//   }
//
//   // Toggle the camera state
//   void _toggleCamera() async {
//     if (iscameraon) {
//       // Turn off camera
//       await _cameraController.dispose(); // Dispose the controller
//     } else {
//       // Reinitialize camera if turned back on
//       _initializeCamera(true);
//     }
//     setState(() {
//       iscameraon = !iscameraon; // Toggle the camera state
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: FutureBuilder<void>(
//         future: _initializeControllerFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           }
//
//           if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           }
//
//           return Stack(
//             children: [
//               // Camera feed
//               Positioned.fill(
//                 child: iscameraon
//                     ? CameraPreview(_cameraController)
//                     : Container(color: Colors.black), // Display black screen when camera off
//               ),
//               Positioned(
//                 top: 80,
//                 left: 0,
//                 right: 0,
//                 child: Align(
//                   alignment: Alignment.topCenter,
//                   child: Column(
//                     children: [
//                       Text(
//                         widget.Name,
//                         style: GoogleFonts.poppins(
//                           color: Colors.white,
//                           fontWeight: FontWeight.w500,
//                           fontSize: 18,
//                         ),
//                       ),
//                       const SizedBox(height: 15),
//                       Text(
//                         'Calling',
//                         style: GoogleFonts.poppins(
//                           color: Colors.white,
//                           fontWeight: FontWeight.w300,
//                           fontSize: 14,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               Positioned(
//                 bottom: 50,
//                 left: 20,
//                 right: 20,
//                 child: Container(
//                   width: MediaQuery.sizeOf(context).width,
//                   height: 100,
//                   decoration: const BoxDecoration(
//                     color: WhatsAppColors.darkGreen,
//                     borderRadius: BorderRadius.all(Radius.circular(20)),
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     children: [
//                       InkWell(
//                         onTap: () {
//                           _initializeCamera(false); // Flip camera
//                         },
//                         child: const CircleAvatar(
//                           backgroundColor: Colors.white,
//                           child: Icon(Icons.flip_camera_ios_rounded, color: Colors.black),
//                         ),
//                       ),
//                       InkWell(
//                         onTap: _toggleCamera, // Toggle camera on/off
//                         child: CircleAvatar(
//                           backgroundColor: iscameraon ? Colors.white : Colors.black,
//                           child: Icon(
//                             Icons.camera_alt,
//                             color: !iscameraon ? Colors.white : Colors.black,
//                           ),
//                         ),
//                       ),
//                       InkWell(
//                         onTap: () {
//                           setState(() {
//                             ismicon = !ismicon;
//                           });
//                         },
//                         child: CircleAvatar(
//                           backgroundColor: Colors.white,
//                           child: Icon(
//                             !ismicon ? Icons.mic_off : Icons.mic,
//                             color: Colors.black,
//                           ),
//                         ),
//                       ),
//                       InkWell(
//                         onTap: () {
//                           Navigator.pop(context); // End call
//                         },
//                         child: const CircleAvatar(
//                           backgroundColor: Colors.red,
//                           child: Icon(Icons.call_end, color: Colors.white),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }