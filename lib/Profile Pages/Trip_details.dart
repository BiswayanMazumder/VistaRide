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
              ),
              const SizedBox(
                height: 30,
              ),
              const Divider(
                color: Colors.grey,
              ),
              const SizedBox(
                height: 30,
              ),
              Row(
                children: [
                  Image(image: NetworkImage('https://tb-static.uber.com/prod/wallet/icons/cash_3x.png'),height: 50,width: 50,),
                  const SizedBox(
                    width: 20,
                  ),
                  Text(
                   '₹${widget.cancelled?'0':widget.fare.toString()}',style: GoogleFonts.poppins(
                    color: Colors.black,fontWeight:FontWeight.w600
                  ),)
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              const Divider(
                color: Colors.grey,
              ),
              const SizedBox(
                height: 30,
              ),
              Row(
                children: [
                  const Icon(
                    Icons.directions_walk,
                    color: Colors.green,
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Expanded(
                      child: Text(
                        widget.pickuplocation,
                        style: GoogleFonts.poppins(color: Colors.black),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      )),
                ],
              ),
              const SizedBox(
                height: 50,
              ),
              Row(
                children: [
                  const CircleAvatar(
                    radius: 5,
                    backgroundColor: Colors.red,
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Expanded(
                      child: Text(
                        widget.droplocation,
                        style: GoogleFonts.poppins(color: Colors.black),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      )),
                ],
              ),
              widget.cancelled?Container(): const SizedBox(
                height: 30,
              ),
              widget.cancelled?Container():  const Divider(
                color: Colors.grey,
              ),
              widget.cancelled?Container(): const SizedBox(
                height: 30,
              ),
             widget.cancelled?Container(): Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Your Trip',style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),),
                  Text('₹${widget.fare}',style: GoogleFonts.poppins(
                      color: Colors.black,
                  ),)
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
