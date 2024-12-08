import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TripDetails extends StatefulWidget {
  final String drivername;
  final String driverpic;
  final String pickuplocation;
  final String droplocation;
  final String carname;
  final String carcategory;
  final String tripdate;
  final bool cancelled;
  final double fare;
  final String bookingid;
  // final String drivername;
  const TripDetails(
      {super.key,
      required this.driverpic,
      required this.bookingid,
      required this.tripdate,
      required this.drivername,
      required this.carcategory,
      required this.pickuplocation,
      required this.droplocation,
      required this.cancelled,
      required this.carname,
      required this.fare});

  @override
  State<TripDetails> createState() => _TripDetailsState();
}

class _TripDetailsState extends State<TripDetails> {
  List cabcategorynames = ['Mini', 'Prime', 'SUV', 'Non AC Taxi', 'LUX'];
  List carcategoryimages = [
    'https://olawebcdn.com/images/v1/cabs/sl/ic_mini.png',
    'https://olawebcdn.com/images/v1/cabs/sl/ic_prime.png',
    'https://olawebcdn.com/images/v1/cabs/sl/ic_suv.png',
    'https://olawebcdn.com/images/v1/cabs/sl/ic_kp.png',
    'https://d1a3f4spazzrp4.cloudfront.net/car-types/haloProductImages/v1.1/Black_Premium_Driver_Red_Carpet.png'
  ];
  @override
  Widget build(BuildContext context) {
    int photoindex = cabcategorynames.indexOf(widget.carcategory);
    print('Index $photoindex');
    // You can now access the tideId through widget.tideId
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Row(
              children: [
                Text(
                  widget.tripdate,
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  'CRN ${widget.bookingid}',
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                      fontSize: 13),
                ),
              ],
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Column(
            children: [
              const SizedBox(
                height: 40,
              ),
              widget.cancelled? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image(
                    image: NetworkImage(carcategoryimages[photoindex]),
                    height: 70,
                    width: 70,
                  ),
                  Container(
                    height: 30,
                    width: 100,
                    decoration:  BoxDecoration(
                      color: Colors.green.withOpacity(0.5),
                      borderRadius: const BorderRadius.all(Radius.circular(10))
                    ),
                    child: Center(child: Text('Cancelled',style: GoogleFonts.poppins(color: Colors.green.shade500),)),
                  )
                ],
              ):Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundImage: NetworkImage(widget.driverpic),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.drivername,style: GoogleFonts.poppins(
                            color: Colors.black,fontWeight: FontWeight.w600
                          ),),
                          Text(widget.carname,style: GoogleFonts.poppins(
                              color: Colors.grey,fontWeight: FontWeight.w500,fontSize: 12
                          ),)
                        ],
                      )
                    ],
                  ),
                  Container(
                    height: 30,
                    width: 100,
                    decoration:  BoxDecoration(
                        color: Colors.green.withOpacity(0.5),
                        borderRadius: const BorderRadius.all(Radius.circular(10))
                    ),
                    child: Center(child: Text('Completed',style: GoogleFonts.poppins(color: Colors.green.shade500),)),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
