import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
class UploadRC extends StatefulWidget {
  const UploadRC({super.key});

  @override
  State<UploadRC> createState() => _UploadRCState();
}

class _UploadRCState extends State<UploadRC> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.only(left: 20,right: 20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 30,
              ),
              Text('Make sure all the data on your document are fully visible, glare free and not blurred',style: GoogleFonts.poppins(
                color: Colors.black,
                fontWeight: FontWeight.w500,
                fontSize: 18
              ),),
              const SizedBox(
                height: 40,
              ),
              const Padding(
                padding: EdgeInsets.only(left: 40,right: 40),
                child: Image(image: NetworkImage('https://static.toiimg.com/thumb/resizemode-4,msid-92497668,imgsize-68152,width-800/92497668.jpg'),),
              ),
              const SizedBox(
                height: 40,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  InkWell(
                    onTap: (){},
                    child: Container(
                      height: 120,
                      width: 150,
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.2),
                        borderRadius: const BorderRadius.all(Radius.circular(10))
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(Icons.file_upload_outlined,color: Colors.blue,),
                            const SizedBox(
                              height: 10,
                            ),
                            Text('Upload front side',style: GoogleFonts.poppins(
                              color: Colors.black,fontWeight: FontWeight.w600,fontSize: 12
                            ),)
                          ],
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: (){},
                    child: Container(
                      height: 120,
                      width: 150,
                      decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.2),
                          borderRadius: const BorderRadius.all(Radius.circular(10))
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(Icons.file_upload_outlined,color: Colors.blue,),
                            const SizedBox(
                              height: 10,
                            ),
                            Text('Upload back side',style: GoogleFonts.poppins(
                                color: Colors.black,fontWeight: FontWeight.w600,fontSize: 12
                            ),)
                          ],
                        ),
                      ),
                    ),
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
