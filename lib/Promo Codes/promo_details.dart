import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
class PromoDetails extends StatefulWidget {
  const PromoDetails({super.key});

  @override
  State<PromoDetails> createState() => _PromoDetailsState();
}

class _PromoDetailsState extends State<PromoDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 20,right: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 70,
              ),
            const Icon(Icons.close,color: Colors.black,),
              const SizedBox(
                height: 15,
              ),
              Text(
                'Promotions',
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
              ),
              const SizedBox(
                height: 20,
              ),

            ],
          ),
        )
      ),
    );
  }
}
