import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'dart:async';

import 'package:google_fonts/google_fonts.dart';
import 'package:pingstar/Chat%20Page/UserChats.dart';
import 'package:pingstar/Utils/colors.dart';

class UpdateViewing extends StatefulWidget {
  final String imageUrl; // The image URL passed from the previous page
  final String Name;
  final bool isowner;
  final String storyowneruid;
  final List<String> contactname; // List to store contact names
  final List<String> contactnumber;

  const UpdateViewing(
      {super.key,
      required this.imageUrl,
      required this.Name,
      required this.storyowneruid,
      required this.isowner,
      required this.contactnumber,
      required this.contactname});

  @override
  State<UpdateViewing> createState() => _UpdateViewingState();
}

class _UpdateViewingState extends State<UpdateViewing> {
  PageController _pageController = PageController();
  int _currentPage = 0;
  late Timer _timer;
  double _progress = 0.0;

  // List of story images (we initialize this in initState)
  late List<String> _stories;
  Future<void> updatestoryviewers() async {
    if (kDebugMode) {
      print('Owner ${widget.storyowneruid}');
    }
    try {
      await _firestore
          .collection('Users Status')
          .doc(widget.storyowneruid)
          .update({
        'Story Seen By': FieldValue.arrayUnion([_auth.currentUser!.uid]),
      });
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _listentostoryviewers();
    if (widget.isowner == false) {
      updatestoryviewers();
    }
    _stories = [
      widget.imageUrl
    ]; // Initialize the list with the passed image URL
    _startTimer();
  }

  // Start the timer for progressing the story
  void _startTimer() {
    _progress = 0.0;
    _timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      if (_progress >= 1.0) {
        _nextStory();
      } else {
        setState(() {
          _progress += 0.01;
        });
      }
    });
  }

  // Move to the next story
  void _nextStory() {
    if (_currentPage < _stories.length - 1) {
      // There's another story, so navigate to the next
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // No more stories left, end and pop the view
      _timer.cancel(); // Cancel the timer to stop further updates
      Navigator.pop(context); // Go back to the previous page
    }
  }

  // Move to the previous story
  void _previousStory() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  List<dynamic> StorySeenUIDS = [];
  List<dynamic> ContactNumbers = [];
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Listen for story viewers and fetch contact details
  Future<void> _listentostoryviewers() async {
    _firestore
        .collection('Users Status')
        .doc(_auth.currentUser!.uid)
        .snapshots()
        .listen((docsnap) {
      if (docsnap.exists) {
        setState(() {
          // Update StorySeenUIDS whenever the document changes
          StorySeenUIDS =
              List<String>.from(docsnap.data()?['Story Seen By'] ?? []);
        });
        // Fetch contact details after StorySeenUIDS is updated
        _fetchContactDetails();
      }
    });
  }

  List<String> StoryViewerUsername = [];
  List<String> StoryViewerUserID = [];
  // Fetch the contact details for all users who viewed the story
  Future<void> _fetchContactDetails() async {
    // Ensure that StorySeenUIDS is populated
    if (StorySeenUIDS.isEmpty) return;

    // Clear existing contact numbers when updating
    ContactNumbers.clear();
    List<String> tempContactNumbers = [];
    List<String> tempUserIDs = [];
    // Iterate over StorySeenUIDS and fetch contact details
    for (String userUID in StorySeenUIDS) {
      try {
        var docsnap = await _firestore
            .collection('User Details(User ID Basis)')
            .doc(userUID)
            .get();

        if (docsnap.exists) {
          var mobileNumber = docsnap.data()?['Mobile Number'];
          var UserIDS = docsnap.data()?['UID'];

          if (mobileNumber != null) {
            tempUserIDs.add(UserIDS);
            tempContactNumbers.add(mobileNumber);
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print("Error fetching user details for UID $userUID: $e");
        }
      }
    }

    // Update the ContactNumbers list with fetched numbers
    setState(() {
      StoryViewerUserID.addAll(tempUserIDs);
      ContactNumbers.addAll(tempContactNumbers);
    });

    // Log the contact numbers for debugging
    if (kDebugMode) {
      print('Updated Contact Numbers: $tempUserIDs');
    }
    for (int i = 0; i < tempContactNumbers.length; i++) {
      if (kDebugMode) {
        print(
            'Found at ${widget.contactnumber.indexOf(tempContactNumbers[i])}');
      }
      StoryViewerUsername.add(widget
          .contactname[widget.contactnumber.indexOf(tempContactNumbers[i])]);
      if (kDebugMode) {
        print('Story Username $StoryViewerUsername');
      }
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _stories.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                  _progress = 0.0; // Reset the progress for the next story
                });
                _startTimer(); // Restart the timer for the next story
              },
              itemBuilder: (context, index) {
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    // Displaying story image from network
                    Image.network(
                      _stories[index],
                      fit: BoxFit.contain,
                    ),
                    Positioned(
                      top: 80,
                      left: 20,
                      child: Row(
                        children: [
                          // Profile image
                          const CircleAvatar(
                            radius: 20,
                            backgroundImage: NetworkImage(
                                'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png'), // Display the passed network image
                          ),
                          const SizedBox(width: 20),
                          InkWell(
                            onTap: () {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChattingPage(
                                        UserID: widget.storyowneruid,
                                        Name: widget.Name),
                                  ));
                            },
                            child: Text(
                              widget
                                  .Name, // You can replace this with dynamic data
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 50,
                      left: 20,
                      right: 20,
                      child: LinearProgressIndicator(
                        value: _progress,
                        backgroundColor: Colors.white.withOpacity(0.5),
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          widget.isowner
              ? InkWell(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      showDragHandle: false,
                      builder: (context) {
                        return Container(
                          height: MediaQuery.sizeOf(context).height / 1.5,
                          width: MediaQuery.sizeOf(context).width / 1.1,
                          decoration: const BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          child: Column(
                            children: [
                              Container(
                                width: MediaQuery.sizeOf(context).width,
                                color: WhatsAppColors.darkGreen,
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Center(
                                    child: Text(
                                      ' Viewed by ${StorySeenUIDS.length}',
                                      style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              for (int i = 0;
                                  i < StoryViewerUsername.length;
                                  i++)
                                SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ChattingPage(
                                                        UserID:
                                                            StoryViewerUserID[
                                                                i],
                                                        Name:
                                                            StoryViewerUsername[
                                                                i]),
                                              ));
                                        },
                                        child: Row(
                                          children: [
                                            const SizedBox(
                                              width: 20,
                                            ),
                                            const CircleAvatar(
                                              backgroundImage: NetworkImage(
                                                  'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png'),
                                            ),
                                            const SizedBox(
                                              width: 20,
                                            ),
                                            Text(
                                              StoryViewerUsername[i],
                                              style: GoogleFonts.poppins(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w500),
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                )
                            ],
                          ),
                        );
                      },
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(
                        CupertinoIcons.eye_solid,
                        color: Colors.white,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        StorySeenUIDS.length.toString(),
                        style: GoogleFonts.poppins(color: Colors.white),
                      )
                    ],
                  ))
              : Container(),
          const SizedBox(
            height: 20,
          )
        ],
      ),
    );
  }

  // Build indicators for the stories (like dots below each story)
  Widget _buildStoryIndicators() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          _stories.length,
          (index) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: CircleAvatar(
              radius: 5,
              backgroundColor: _currentPage == index
                  ? Colors.green
                  : Colors.white.withOpacity(0.5),
            ),
          ),
        ),
      ),
    );
  }
}
