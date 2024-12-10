import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
class PromoCodes extends StatefulWidget {
  const PromoCodes({super.key});

  @override
  State<PromoCodes> createState() => _PromoCodesState();
}

class _PromoCodesState extends State<PromoCodes> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 20,right: 20,top: 20),
          child: Column(
            children: [
              Text('Promotions',style: GoogleFonts.poppins(
                color: Colors.black,fontWeight: FontWeight.bold,fontSize: 25
              ),)
            ],
          ),
        ),
      ),
    );
  }
}
