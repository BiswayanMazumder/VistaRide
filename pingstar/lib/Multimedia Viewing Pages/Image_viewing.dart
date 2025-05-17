import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pingstar/Utils/colors.dart';

class Image_viewing extends StatefulWidget {
  final String UserID;
  final String Name;
  final String Image_Link;

  const Image_viewing(
      {super.key,
      required this.UserID,
      required this.Name,
      required this.Image_Link});

  @override
  State<Image_viewing> createState() => _Image_viewingState();
}

class _Image_viewingState extends State<Image_viewing> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WhatsAppColors.darkGreen,
      appBar: AppBar(
        backgroundColor: WhatsAppColors.darkGreen,
        title: Text(
          widget.Name,
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 18),
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
      body: GestureDetector(
        onHorizontalDragUpdate: (details) {
          Navigator.pop(context);
        },
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height,
          width: MediaQuery.sizeOf(context).width,
          child: Image(
            image: NetworkImage(widget.Image_Link),
            fit:BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
