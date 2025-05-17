import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pingstar/Chat%20Page/UserChats.dart';
import 'package:pingstar/Utils/colors.dart';

class AllContacts extends StatefulWidget {
  final List contactname;
  final List contactnumber;

  const AllContacts({super.key, required this.contactname, required this.contactnumber});

  @override
  State<AllContacts> createState() => _AllContactsState();
}

class _AllContactsState extends State<AllContacts> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List contactname = [];
  List ContactNumber = [];
  Set<String> addedContactNumbers = {}; // Set to track added numbers and avoid duplicates

  List<String> UserIDS = [];
  List<String> Statuses = [];

  // Track selected items using their indices
  Set<int> selectedItems = Set<int>();
  int selectedCount = 0; // To track the number of selected items

  // Normalize phone numbers by removing spaces, dashes, parentheses, and plus signs
  String normalizePhoneNumber(String number) {
    return number.replaceAll(RegExp(r'\s+|-|\(|\)|\+'), '');
  }

  Future<void> getAllContacts() async {
    // print('Contact Names from widget: ${widget.contactname}');
    // print('Contact Numbers from widget: ${widget.contactnumber}');

    final docsnap = await _firestore.collection('User Details(User ID Basis)').get();
    if (docsnap.docs.isNotEmpty) {
      List<String> contactNumbers = [];

      for (var doc in docsnap.docs) {
        var contactNumber = '${doc['Mobile Number']}';
        contactNumber = normalizePhoneNumber(contactNumber);

        // print('Firestore contact number: $contactNumber');

        if (contactNumber != null) {
          contactNumbers.add(contactNumber);
          if (doc['UID'] == _auth.currentUser!.uid) {
            contactNumbers.remove(contactNumber); // Remove own contact number
          }
        }
      }

      for (int i = 0; i < widget.contactnumber.length; i++) {
        String phoneContact = normalizePhoneNumber(widget.contactnumber[i]);

        // print('Phone contact from contacts service: $phoneContact');

        if (contactNumbers.contains(phoneContact) && !addedContactNumbers.contains(phoneContact)) {
          ContactNumber.add(widget.contactnumber[i]);
          contactname.add(widget.contactname[i]);

          addedContactNumbers.add(phoneContact);
        }
      }

      for (int i = 0; i < ContactNumber.length; i++) {
        final docSnap = await _firestore.collection('User Details(Contact Number Basis)').doc(ContactNumber[i]).get();
        if (docSnap.exists) {
          UserIDS.add(docSnap.data()?['UID']);
          Statuses.add(docSnap.data()?['Status']);
        }
      }
    }

    // Debugging output
    // print('Final Contact Names: $contactname');
    // print('Final Contact Numbers: $ContactNumber');
    // print('Final User IDS: $UserIDS');
    // print('Final Statuses: $Statuses');

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getAllContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WhatsAppColors.darkGreen,
      appBar: AppBar(
        actions: [
          Row(
            children: [
              InkWell(
                onTap: () {},
                child: const Icon(Icons.search, color: Colors.white),
              ),
              const SizedBox(width: 20),
              const InkWell(
                child: Icon(CupertinoIcons.ellipsis_vertical, color: Colors.white),
              ),
              const SizedBox(width: 10),
            ],
          )
        ],
        backgroundColor: WhatsAppColors.darkGreen,
        title: (selectedCount > 0)
            ? Text(selectedCount.toString(), style: GoogleFonts.poppins(color: Colors.white))
            : Text('Select Contacts', style: GoogleFonts.poppins(color: Colors.white)),
        leading: InkWell(
          onTap: () {
            if (selectedCount > 0) {
              setState(() {
                selectedCount = 0;
              });
            }
            if (selectedCount == 0) {
              Navigator.pop(context);
            }
          },
          child: const Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
      body: contactname.isEmpty || ContactNumber.isEmpty || UserIDS.isEmpty || Statuses.isEmpty
          ? Padding(
        padding: const EdgeInsets.only(top: 20.0),
        child: Center(
          child: Text(
            "No Contacts Found",
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 18),
          ),
        ),
      )
          : Padding(
        padding: const EdgeInsets.only(left: 10, right: 10, top: 20),
        child: GestureDetector(
          onTap: () {
            setState(() {
              // Reset selected items on tapping outside
              selectedItems.clear();
              selectedCount = 0;
            });
          },
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: contactname.length,
                  itemBuilder: (context, index) {
                    if (index >= UserIDS.length || index >= Statuses.length) {
                      return const SizedBox.shrink();
                    }
                    return ListTile(
                      title: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChattingPage(
                                UserID: UserIDS[index],
                                Name: contactname[index],
                              ),
                            ),
                          );
                        },
                        onLongPress: () {
                          setState(() {
                            if (selectedItems.contains(index)) {
                              selectedItems.remove(index);
                              selectedCount--;
                            } else {
                              selectedItems.add(index);
                              selectedCount++;
                            }
                          });
                        },
                        child: Container(
                          color: selectedItems.contains(index)
                              ? Colors.green.shade400.withOpacity(0.25)
                              : Colors.transparent,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 15, bottom: 15, left: 10),
                            child: Row(
                              children: [
                                const CircleAvatar(
                                  backgroundImage: NetworkImage(
                                      'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png'),
                                ),
                                const SizedBox(width: 20),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(contactname[index],
                                        style: GoogleFonts.poppins(color: Colors.white)),
                                    const SizedBox(height: 5),
                                    Text(Statuses[index],
                                        style: GoogleFonts.poppins(
                                            color: Colors.grey, fontSize: 13)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
