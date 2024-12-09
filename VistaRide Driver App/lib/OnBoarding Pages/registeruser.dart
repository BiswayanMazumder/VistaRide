import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vistaridedriver/OnBoarding%20Pages/documentupload.dart';
class RegisterUser extends StatefulWidget {
  const RegisterUser({super.key});

  @override
  State<RegisterUser> createState() => _RegisterUserState();
}

class _RegisterUserState extends State<RegisterUser> {
  TextEditingController _vehiclenumber = TextEditingController();
  TextEditingController _contactNumber = TextEditingController();
  List<String> cabcategorynames = [
    'Mini',
    'Prime',
    'SUV',
    'Non AC Taxi',
    'LUX'
  ];
  List<String> LUX = [
    'MercedesBenz',
    'BMW',
    'Audi',
    'Jaguar',
    'LandRover',
    'Volvo',
    'Porsche',
    'Lexus',
    'MiniCooper',
    'Skoda',
    'Honda',
    'Toyota',
  ];
  List<String> Mini = [
    'MarutiSuzuki',
    'Hyundai',
    'TataMotors',
    'Ford',
    'Renault',
    'Mahindra',
    'Kia',
    'Nissan',
  ];
  List<String> Prime = [
    'Skoda',
    'Toyota',
    'Volkswagen',
    'Hyundai',
    'Kia',
    'TataMotors',
  ];
  List<String> SUV = [
    'Hyundai',
    'TataMotors',
    'Mahindra',
    'Kia',
    'Toyota',
    'Skoda',
    'Nissan',
    'Renault',
    'Ford',
    'MarutiSuzuki',
  ];
  List<String> MercedesBenz = ['A-Class', 'B-Class', 'C-Class', 'E-Class', 'S-Class', 'GLA', 'GLB', 'GLE'];
  List<String> BMW = ['2 Series', '3 Series', '5 Series', '7 Series', 'X1', 'X3', 'X5', 'X7'];
  List<String> Audi = ['A3', 'A4', 'A6', 'A8', 'Q3', 'Q5', 'Q7', 'Q8'];
  List<String> Jaguar = ['XE', 'XF', 'F-Pace'];
  List<String> LandRover = ['Discovery Sport', 'Range Rover Evoque'];
  List<String> Volvo = ['XC40', 'XC60', 'XC90'];
  List<String> Porsche = ['Macan', 'Cayenne'];
  List<String> Lexus = ['NX', 'RX', 'ES'];
  List<String> MiniCooper = ['Mini Cooper 3-Door', 'Mini Cooper S Convertible'];
  List<String> Skoda = ['Superb', 'Kodiaq'];
  List<String> Toyota = ['Camry', 'Innova Crysta', 'Fortuner'];
  List<String> MarutiSuzuki = ['Swift', 'Dzire', 'Baleno', 'Vitara Brezza', 'Eeco'];
  List<String> Hyundai = ['i10', 'i20', 'Verna', 'Creta', 'Venue'];
  List<String> TataMotors = ['Tiago', 'Tigor', 'Nexon', 'Altroz'];
  List<String> Honda = ['Amaze', 'Jazz','Civic'];
  List<String> Ford = ['Figo', 'EcoSport'];
  List<String> Renault = ['Kwid', 'Triber', 'Duster'];
  List<String> Mahindra = ['KUV100', 'XUV300', 'TUV300'];
  List<String> Kia = ['Seltos', 'Sonet'];
  List<String> Nissan = ['Magnite', 'Kicks'];
  List<String> Volkswagen = ['Vento', 'Jetta', 'Tiguan'];

  String selectedcarcategory = '';
  List carcategoryimages = [
    'https://d1a3f4spazzrp4.cloudfront.net/car-types/haloProductImages/Hatchback.png',
    'https://d1a3f4spazzrp4.cloudfront.net/car-types/haloProductImages/v1.1/UberX_v1.png',
    'https://d1a3f4spazzrp4.cloudfront.net/car-types/haloProductImages/package_UberXL_new_2022.png',
    'https://olawebcdn.com/images/v1/cabs/sl/ic_kp.png',
    'https://d1a3f4spazzrp4.cloudfront.net/car-types/haloProductImages/v1.1/Black_Premium_Driver_Red_Carpet.png'
  ];

  // This will hold the selected category's index.
  int selectedCategoryIndex = -1;
  int selectedtedCarbrandindex = -1;

  // Method to get the correct car brands list based on the selected category
  List<String> getCarBrandsForCategory() {
    switch (selectedcarcategory) {
      case 'Mini':
        return Mini;
      case 'Prime':
        return Prime;
      case 'SUV':
        return SUV;
      case 'LUX':
        return LUX;
      default:
        return [];
    }
  }
  List<String> getCarModelsForBrand(String selectedCarBrand) {
    switch (selectedCarBrand) {
      case 'MercedesBenz':
        return MercedesBenz;
      case 'BMW':
        return BMW;
      case 'Audi':
        return Audi;
      case 'Jaguar':
        return Jaguar;
      case 'LandRover':
        return LandRover;
      case 'Volvo':
        return Volvo;
      case 'Porsche':
        return Porsche;
      case 'Lexus':
        return Lexus;
      case 'MiniCooper':
        return MiniCooper;
      case 'Skoda':
        return Skoda;
      case 'Toyota':
        return Toyota;
      case 'MarutiSuzuki':
        return MarutiSuzuki;
      case 'Hyundai':
        return Hyundai;
      case 'TataMotors':
        return TataMotors;
      case 'Honda':
        return Honda;
      case 'Ford':
        return Ford;
      case 'Renault':
        return Renault;
      case 'Mahindra':
        return Mahindra;
      case 'Kia':
        return Kia;
      case 'Nissan':
        return Nissan;
      case 'Volkswagen':
        return Volkswagen;
      default:
        return [];
    }
  }
  int carmodelindex=-1;
  String carmodel='';
  bool issubmitted=false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Future<void> fetchrc() async {
    final docsnap = await _firestore
        .collection('VistaRide Driver Details')
        .doc(_auth.currentUser!.uid)
        .get();
    if (docsnap.exists) {
      setState(() {
        issubmitted=docsnap.data()?['Submitted']??false;
      });
    }
    issubmitted?Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => DocumentUpload(),)):null;
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
      bottomNavigationBar: Container(
        height: 100,
        width: MediaQuery.sizeOf(context).width,
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Center(
            child: InkWell(
              onTap: ()async{
                final prefs=await SharedPreferences.getInstance();
                  if (selectedCategoryIndex != -1 &&
                      _vehiclenumber.text.isNotEmpty && selectedtedCarbrandindex!=-1  && carmodelindex!=-1&&
                      _contactNumber.text.isNotEmpty) {
                    await prefs.setString('Car Category', cabcategorynames[selectedCategoryIndex]);
                    await prefs.setString('Car Brand', getCarBrandsForCategory()[selectedtedCarbrandindex]);
                    await prefs.setString('Car Model', carmodel);
                    await prefs.setString('Contact Number', _contactNumber.text);
                    await prefs.setString('Car Name', '${getCarBrandsForCategory()[selectedtedCarbrandindex]} $carmodel');
                    await prefs.setString('Car Number Plate', _vehiclenumber.text);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => DocumentUpload(),));
                    if (kDebugMode) {
                      print(prefs.get('Car Name'));
                    }
                    // Move to the next page
                    if (kDebugMode) {
                      print('Vehicle ${_vehiclenumber.text.isEmpty}');
                    }
                  }

              },
              child: Container(
                height: 50,
                width: MediaQuery.sizeOf(context).width,
                decoration: BoxDecoration(
                  color: (selectedCategoryIndex == -1 &&
                      _vehiclenumber.text.isEmpty == true &&
                      _contactNumber.text.isEmpty == true)
                      ? Colors.grey
                      : Colors.black,
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
                child: Center(
                  child: Text(
                    'Continue',
                    style: GoogleFonts.poppins(
                        color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: MediaQuery.sizeOf(context).width,
                height: MediaQuery.sizeOf(context).height / 3.5,
                color: Colors.grey.shade100,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: MediaQuery.sizeOf(context).height / 6,
                    ),
                    Text(
                      'Add your vehicle to continue',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      'Please enter the required details',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500, fontSize: 15),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                'Select category',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(
                height: 10,
              ),
              InkWell(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.grey.shade100,
                    enableDrag: true,
                    builder: (context) {
                      return Container(
                        width: MediaQuery.sizeOf(context).width,
                        height: MediaQuery.sizeOf(context).height / 2.2,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20, right: 20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 40,
                              ),
                              for (int i = 0; i < cabcategorynames.length; i++)
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Image(
                                          image: NetworkImage(
                                              carcategoryimages[i]),
                                          height: 60,
                                          width: 60,
                                        ),
                                        const SizedBox(
                                          width: 20,
                                        ),
                                        Text(
                                          cabcategorynames[i],
                                          style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15),
                                        ),
                                      ],
                                    ),
                                    Radio<int>(
                                      value: i,
                                      groupValue: selectedCategoryIndex,
                                      onChanged: (value) {
                                        setState(() {
                                          selectedCategoryIndex = value!;
                                          selectedcarcategory = cabcategorynames[selectedCategoryIndex];
                                          // Close the modal and return the selected value
                                          Navigator.pop(
                                              context,
                                              cabcategorynames[selectedCategoryIndex]);
                                        });
                                      },
                                      activeColor: Colors.blue,
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ).then((selectedCategory) {
                    if (selectedCategory != null) {
                      if (kDebugMode) {
                        print('Selected Category: $selectedCategory');
                      }
                    }
                  });
                },
                child: Container(
                  width: MediaQuery.sizeOf(context).width,
                  height: 50,
                  color: Colors.grey.shade100,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          selectedCategoryIndex != -1
                              ? cabcategorynames[selectedCategoryIndex]
                              : 'Select Category',
                          style: GoogleFonts.poppins(
                              color: Colors.grey, fontWeight: FontWeight.w600),
                        ),
                        const Icon(
                          Icons.arrow_drop_down_rounded,
                          color: Colors.black,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Only show the car brand selection if the category is not "Non AC Taxi"
              if (selectedCategoryIndex != 3 && selectedCategoryIndex!=-1)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 30,
                    ),
                    Text(
                      'Select car brand',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    InkWell(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.grey.shade100,
                          enableDrag: true,
                          builder: (context) {
                            return SingleChildScrollView(
                              child: Container(
                                width: MediaQuery.sizeOf(context).width,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 20, right: 20),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(
                                        height: 40,
                                      ),
                                      for (int i = 0; i < getCarBrandsForCategory().length; i++)
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  getCarBrandsForCategory()[i],
                                                  style: GoogleFonts.poppins(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 15),
                                                ),
                                              ],
                                            ),
                                            Radio<int>(
                                              value: i,
                                              groupValue: selectedtedCarbrandindex,
                                              onChanged: (value) {
                                                setState(() {
                                                  selectedtedCarbrandindex = value!;
                                                  // Close the modal and return the selected value
                                                  Navigator.pop(context,
                                                      getCarBrandsForCategory()[selectedtedCarbrandindex]);
                                                });
                                              },
                                              activeColor: Colors.blue,
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                      child: Container(
                        width: MediaQuery.sizeOf(context).width,
                        height: 50,
                        color: Colors.grey.shade100,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                selectedtedCarbrandindex != -1
                                    ? getCarBrandsForCategory()[selectedtedCarbrandindex]
                                    : 'Select car brand',
                                style: GoogleFonts.poppins(
                                    color: Colors.grey, fontWeight: FontWeight.w600),
                              ),
                              const Icon(
                                Icons.arrow_drop_down_rounded,
                                color: Colors.black,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              if (selectedCategoryIndex != 3 && selectedCategoryIndex!=-1)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 30,
                    ),
                    Text(
                      'Select car model',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    InkWell(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.grey.shade100,
                          enableDrag: true,
                          builder: (context) {
                            return SingleChildScrollView(
                              child: Container(
                                width: MediaQuery.sizeOf(context).width,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 20, right: 20),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(
                                        height: 40,
                                      ),
                                      for (int i = 0; i < getCarModelsForBrand(getCarBrandsForCategory()[selectedtedCarbrandindex]).length; i++)
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  getCarModelsForBrand(getCarBrandsForCategory()[selectedtedCarbrandindex])[i],
                                                  style: GoogleFonts.poppins(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 15),
                                                ),
                                              ],
                                            ),
                                            Radio<int>(
                                              value: i,
                                              groupValue: carmodelindex,
                                              onChanged: (value) {
                                                setState(() {
                                                  carmodelindex = value!;
                                                  carmodel= getCarModelsForBrand(getCarBrandsForCategory()[selectedtedCarbrandindex])[carmodelindex];
                                                  // Close the modal and return the selected value
                                                  Navigator.pop(context,
                                                      getCarModelsForBrand(getCarBrandsForCategory()[selectedtedCarbrandindex]));
                                                });
                                              },
                                              activeColor: Colors.blue,
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                      child: Container(
                        width: MediaQuery.sizeOf(context).width,
                        height: 50,
                        color: Colors.grey.shade100,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                selectedtedCarbrandindex != -1
                                    ? carmodel
                                    : 'Select car brand',
                                style: GoogleFonts.poppins(
                                    color: Colors.grey, fontWeight: FontWeight.w600),
                              ),
                              const Icon(
                                Icons.arrow_drop_down_rounded,
                                color: Colors.black,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              const SizedBox(
                height: 30,
              ),
              Text(
                'Vehicle Number',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold, fontSize: 15),
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
                    controller: _vehiclenumber,
                    decoration: InputDecoration(
                        hintText: 'Vehicle Number',
                        hintStyle: GoogleFonts.poppins(
                            color: Colors.grey,
                            fontWeight: FontWeight.w600,
                            fontSize: 14),
                        border: InputBorder.none),
                  ),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Text(
                'Mobile Number',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold, fontSize: 15),
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
                    controller: _contactNumber,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        hintText: 'Contact Number',
                        hintStyle: GoogleFonts.poppins(
                            color: Colors.grey,
                            fontWeight: FontWeight.w600,
                            fontSize: 14),
                        border: InputBorder.none),
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
