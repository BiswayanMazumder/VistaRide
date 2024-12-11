import 'dart:async';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vistaride/Promo%20Codes/promo_details.dart';

class PromoCodes extends StatefulWidget {
  const PromoCodes({super.key});

  @override
  State<PromoCodes> createState() => _PromoCodesState();
}

class _PromoCodesState extends State<PromoCodes> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<String> documentIds = [];
  List<String> codes = [];
  List<int> usageLimits = [];
  List<int> minimumValues = [];
  List<int> discountPercentages = [];
  List<int> maxAmounts = [];
  List<bool> premiumUsers = [];
  List<Timestamp> validUntilDates = [];
  List<String> validUntilFormatted = [];
  StreamSubscription? _listener;

  @override
  void initState() {
    super.initState();
    _startListening();
  }

  void _startListening() {
    _listener =
        _firestore.collection('Promo Codes').snapshots().listen((snapshot) {
      setState(() {
        // Clear previous data
        documentIds.clear();
        codes.clear();
        usageLimits.clear();
        minimumValues.clear();
        discountPercentages.clear();
        maxAmounts.clear();
        premiumUsers.clear();
        validUntilFormatted.clear();

        // Update data with new snapshot
        for (var doc in snapshot.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

          documentIds.add(doc.id);
          codes.add(data['code'] ?? '');
          usageLimits.add(data['usage_limit'] ?? 0);
          minimumValues.add(data['Minimum_Value'] ?? 0);
          discountPercentages.add(data['discount_percentage'] ?? 0);
          maxAmounts.add(data['Max Amount'] ?? 0);
          premiumUsers.add(data['Premium User'] ?? false);

          // Format the valid_until Timestamp
          Timestamp validUntilTimestamp =
              data['valid_until'] ?? Timestamp.now();
          DateTime validUntilDate = validUntilTimestamp.toDate();
          String formattedDate =
              DateFormat('MMM dd yyyy').format(validUntilDate);
          validUntilFormatted.add(formattedDate);
        }
      });
    });
  }

  @override
  void dispose() {
    // Cancel the listener to avoid memory leaks
    _listener?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Promotions',
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
              ),
              const SizedBox(height: 20),
              if (discountPercentages.isEmpty)
                Center(
                  child: Text(
                    'No Promo Codes Available',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              for (int i = 0; i < discountPercentages.length; i++)
                InkWell(
                  onTap: ()async{
                    final prefs=await SharedPreferences.getInstance();
                    prefs.setString('Valid Upto', validUntilFormatted[i]);
                    prefs.setInt('Discount Percentage', discountPercentages[i]);
                    prefs.setInt('Max Amount', maxAmounts[i]);
                    prefs.setInt('Usage Limit', usageLimits[i]);
                    prefs.setString('Promo ID', documentIds[i]);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => PromoDetails(),));
                  },
                  child: Card(
                    elevation: 0,
                    margin: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.discount,
                            color: Colors.green,
                            size: 30,
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Congrats! You have ${discountPercentages[i]}% off up to INR ${maxAmounts[i]} on your rides.',
                                  style: GoogleFonts.poppins(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  validUntilFormatted[i],
                                  style: GoogleFonts.poppins(
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  '${usageLimits[i]} trips left • India',
                                  style: GoogleFonts.poppins(
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                const SizedBox(
                                  height: 30,
                                ),
                                Divider(
                                  color: Colors.grey.shade700,
                                  indent: 0,
                                  endIndent: 0,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
