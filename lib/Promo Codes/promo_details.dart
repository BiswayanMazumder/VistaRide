import 'dart:ffi';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vistaride/Cab%20Selection%20Page/CabFindingPage.dart';
import 'package:vistaride/Cab%20Selection%20Page/cabcategoryselectpage.dart';
import 'package:vistaride/Home%20Page/HomePage.dart';

class PromoDetails extends StatefulWidget {
  const PromoDetails({super.key});

  @override
  State<PromoDetails> createState() => _PromoDetailsState();
}

class _PromoDetailsState extends State<PromoDetails> {
  String validity = '';
  int discount = 0;
  int maxamount = 0;
  bool applypromo = false;
  int usagelimit = 0;
  String promoid = '';
  int minvalue=0;
  String locality = '';
  List cabcategorynames = ['Mini', 'Prime', 'SUV', 'Non AC Taxi', 'LUX'];
  Future<void> fetchsharedpref() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      minvalue=prefs.getInt('Minimum_Value')??0;
      validity = prefs.getString('Valid Upto') ??
          ''; // Default to empty string if null
      discount =
          prefs.getInt('Discount Percentage') ?? 0; // Default to 0 if null
      maxamount = prefs.getInt('Max Amount') ?? 0; // Default to 0 if null
      usagelimit = prefs.getInt('Usage Limit') ?? 0; // Default to 0 if null
      promoid =
          prefs.getString('Promo ID') ?? ''; // Default to empty string if null
      locality = prefs.getString('Locality') ?? '';
      applypromo = prefs.getBool('Apply Promo') ?? false;
    });
  }
  bool ispromoapplicable=false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchsharedpref();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
        width: MediaQuery.sizeOf(context).width,
        height: 80,
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.only(left: 30, right: 30),
          child: Column(
            children: [
              const SizedBox(
                height: 15,
              ),
              InkWell(
                onTap: ()async{
                  if(applypromo){
                    final prefs=await SharedPreferences.getInstance();
                    double fare=prefs.getDouble('Fare')??0;
                    if (kDebugMode) {
                      print('Fare $fare');
                    }
                    if(fare>minvalue){
                      setState(() {
                        prefs.setBool('Promo Applicable', true);
                        Random random = Random();
                        int randomNumber = random.nextInt(maxamount);
                        if (kDebugMode) {
                          print('Random Number $randomNumber');
                        }
                        prefs.setInt('Discount Amount', randomNumber);
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const CabSelectAndPrice(
                          ispromoapplied: true,
                        ),));
                      });
                    }else{
                      prefs.setBool('Promo Applicable', false);
                    }
                    // print('Discount value $fare');
                  }
                },
                child: Align(
                  alignment: Alignment
                      .center, // Aligns the inner container at the top-left
                  child: Container(
                    width: MediaQuery.sizeOf(context).width,
                    height: 50,
                    decoration:  const BoxDecoration(
                        color:Colors.black,
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    child: Center(
                      child: Text(
                        applypromo ? 'Apply Promo' : 'Book Now',
                        style: GoogleFonts.poppins(
                            color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
          child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 70,
            ),
            InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: const Icon(
                  Icons.close,
                  color: Colors.black,
                )),
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
              height: 30,
            ),
            Text(
              '$discount% off your next $usagelimit trips. Up to ₹$maxamount per trip.',
              style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                  fontSize: 22),
            ),
            const SizedBox(
              height: 30,
            ),
            Text(
              'Expires $validity.',
              style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontWeight: FontWeight.w400,
                  fontSize: 15),
            ),
            const SizedBox(
              height: 50,
            ),
            Text(
              '• Offer avaliable in select areas in $locality.',
              style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontWeight: FontWeight.w400,
                  fontSize: 17),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              '• Up to ₹$maxamount per trip.',
              style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontWeight: FontWeight.w400,
                  fontSize: 17),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              '• Ride value should be above ₹$minvalue.',
              style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontWeight: FontWeight.w400,
                  fontSize: 17),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              '• Only valid on: Mini, Prime, SUV, LUX',
              style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontWeight: FontWeight.w400,
                  fontSize: 17),
            ),
            const SizedBox(
              height: 50,
            ),
            Text(
              'Promo codes are available to registered users of VistaRide who meet the specified eligibility criteria, '
              'such as first-time users or users from specific regions. Promo codes are non-transferable, non-refundable, '
              'and cannot be exchanged for cash. Promo codes have a limited time period, and expiry dates are clearly mentioned '
              'in the offer details. Promo codes are subject to a maximum discount limit. Any charges above the discount must be '
              'paid by the user. Promo codes cannot be combined with other offers or discounts unless explicitly stated. '
              'Promo codes can generally be used only once per user unless otherwise specified. VistaRide reserves the right to '
              'cancel or block accounts involved in fraudulent activity. Changes to promo codes, including modification or suspension, '
              'may occur without prior notice. Canceled rides will not reissue discounts, and refunds will be based on the full fare.',
              style: GoogleFonts.poppins(
                color: Colors.black,
                fontWeight: FontWeight.w400,
                fontSize: 17,
              ),
            ),
            const SizedBox(
              height: 50,
            ),
          ],
        ),
      )),
    );
  }
}
