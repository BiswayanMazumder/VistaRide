import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pingstar/Utils/colors.dart';

class VideoCallPage extends StatefulWidget {
  final String name;
  final String userId;
  final bool isInitiator;

  const VideoCallPage({
    Key? key,
    required this.name,
    required this.userId,
    required this.isInitiator,
  }) : super(key: key);

  @override
  State<VideoCallPage> createState() => _VideoCallPageState();
}

class _VideoCallPageState extends State<VideoCallPage> {
  late RTCPeerConnection _peerConnection;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool iscameraon = true;
  bool ismicon = true;
  bool isCallPicked = false;

  bool isbusy = false;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _initializeRenderers();
    // fetchActiveCalls();
    _initializePeerConnection().then((_) {
      if (widget.isInitiator) {
        _createRoom();
      } else {
        _joinRoom();
      }
    }).catchError((error) {
      print("Error initializing peer connection: $error");
    });
  }

  Future<void> _initializeRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
    await _startLocalStream();
  }

  Future<void> _startLocalStream() async {
    final mediaStream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': {'facingMode': 'user'},
    });
    _localRenderer.srcObject = mediaStream;

    mediaStream.getTracks().forEach((track) {
      _peerConnection.addTrack(track, mediaStream);
    });
  }

  Future<void> _initializePeerConnection() async {
    _peerConnection = await createPeerConnection({
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
      ],
    });

    _peerConnection.onIceCandidate = (candidate) {
      if (candidate != null) {
        _firestore
            .collection('rooms')
            .doc(_auth.currentUser!.uid)
            .collection('candidates')
            .add(candidate.toMap());
      }
    };

    _peerConnection.onTrack = (event) {
      if (event.track.kind == 'video') {
        setState(() {
          isCallPicked = true;
          _stopAudio();
          _remoteRenderer.srcObject = event.streams[0];
        });
      }
    };
  }

  Future<void> _createRoom() async {
    await fetchActiveCalls();
    if (!isbusy) {
      final roomDoc =
      _firestore.collection('rooms').doc(_auth.currentUser!.uid);

      final offer = await _peerConnection.createOffer();
      await _peerConnection.setLocalDescription(offer);

      await roomDoc.set({
        'offer': offer.toMap(),
        'createdBy': _auth.currentUser!.uid,
      });

      roomDoc.snapshots().listen((snapshot) async {
        if (!snapshot.exists) return;

        final data = snapshot.data()!;
        if (data['answer'] != null) {
          final answer = RTCSessionDescription(
              data['answer']['sdp'], data['answer']['type']);
          await _peerConnection.setRemoteDescription(answer);
        }
      });

      roomDoc.collection('candidates').snapshots().listen((snapshot) {
        for (var doc in snapshot.docs) {
          final candidate = RTCIceCandidate(
            doc.data()['candidate'],
            doc.data()['sdpMid'],
            doc.data()['sdpMLineIndex'],
          );
          _peerConnection.addCandidate(candidate);
        }
      });
    }
  }

  Future<void> _joinRoom() async {
    final roomDoc = _firestore.collection('rooms').doc(widget.userId);
    final snapshot = await roomDoc.get();

    if (!snapshot.exists) {
      print('Room does not exist.');
      return;
    }

    final data = snapshot.data()!;
    final offer =
    RTCSessionDescription(data['offer']['sdp'], data['offer']['type']);
    await _peerConnection.setRemoteDescription(offer);

    final answer = await _peerConnection.createAnswer();
    await _peerConnection.setLocalDescription(answer);

    await roomDoc.update({'answer': answer.toMap()});

    roomDoc.collection('candidates').snapshots().listen((snapshot) {
      for (var doc in snapshot.docs) {
        final candidate = RTCIceCandidate(
          doc.data()['candidate'],
          doc.data()['sdpMid'],
          doc.data()['sdpMLineIndex'],
        );
        _peerConnection.addCandidate(candidate);
      }
    });
  }

  void _toggleMic() {
    final audioTrack = _localRenderer.srcObject?.getAudioTracks().first;
    if (audioTrack != null) {
      setState(() {
        ismicon = !ismicon;
        audioTrack.enabled = ismicon;
      });
    }
  }

  void _toggleCamera() {
    final videoTrack = _localRenderer.srcObject?.getVideoTracks().first;
    if (videoTrack != null) {
      setState(() {
        iscameraon = !iscameraon;
        videoTrack.enabled = iscameraon;
      });
    }
  }

  Future<void> fetchActiveCalls() async {
    final docSnap =
    await _firestore.collection('Active Calls').doc(widget.userId).get();
    if (docSnap.exists) {
      setState(() {
        isbusy = docSnap.data()?['User Busy'];
      });
    }
    if (!isbusy && !isCallPicked) {
      _playAudioLoop();
    }
  }

  void _playAudioLoop() async {
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    await _audioPlayer.play(
      UrlSource(
        'https://cfyxewbfkabqzrtdyfxc.supabase.co/storage/v1/object/sign/Audio%20Files/videoplayback%20(2).wav?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1cmwiOiJBdWRpbyBGaWxlcy92aWRlb3BsYXliYWNrICgyKS53YXYiLCJpYXQiOjE3Mzc2NTEzMzQsImV4cCI6MTc2OTE4NzMzNH0.reH9rJ7ygYo78erwtmjfuhXFnEsx2g4RgWiQSwOHBwE&t=2025-01-23T16%3A55%3A34.702Z',
      ),
    );
  }

  void _stopAudio() async {
    await _audioPlayer.stop();
  }

  Future<void> _endCall() async {
    _stopAudio();

    // Stop the local video track (camera)
    final mediaStream = _localRenderer.srcObject;
    mediaStream?.getTracks().forEach((track) {
      if (track.kind == 'video') {
        track.stop(); // Stop the video track
      }
    });

    // Close the peer connection
    await _firestore
        .collection('Active Calls')
        .doc(_auth.currentUser!.uid)
        .set({'User Busy': false});
    await _firestore.collection('rooms').doc(_auth.currentUser!.uid).delete();

    final candidatesRef = _firestore
        .collection('rooms')
        .doc(_auth.currentUser!.uid)
        .collection('candidates');
    final candidatesSnapshot = await candidatesRef.get();
    for (final doc in candidatesSnapshot.docs) {
      await doc.reference.delete();
    }

    // Release the resources and dispose of the renderer
    await _localRenderer.dispose();
    await _remoteRenderer.dispose();
    await _peerConnection.close();

    Navigator.pop(context);
  }


  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    _peerConnection.close();
    _audioPlayer.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fullscreen remote video feed when call is picked
          Positioned.fill(
            child: SizedBox(
              width: MediaQuery.sizeOf(context).width,
              height: MediaQuery.sizeOf(context).height,
              child: RTCVideoView(
                isCallPicked ? _remoteRenderer : _localRenderer,
                objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
              ),
            ),
          ),

          // Local video feed in a small box at the bottom right when call is picked
          if (isCallPicked)
            Positioned(
              bottom: 200,
              right: 20,
              width: 120,
              height: 160,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: RTCVideoView(
                  _localRenderer,
                  mirror: true,
                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                ),
              ),
            ),

          // Caller name and status
          Positioned(
            top: 80,
            left: 0,
            right: 0,
            child: Align(
              alignment: Alignment.topCenter,
              child: Column(
                children: [
                  Text(
                    widget.name,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    isbusy ? 'User Busy' : 'Calling',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w300,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Call control buttons
          Positioned(
            bottom: 50,
            left: 20,
            right: 20,
            child: Container(
              width: MediaQuery.sizeOf(context).width,
              height: 100,
              decoration: const BoxDecoration(
                color: WhatsAppColors.darkGreen,
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  InkWell(
                    onTap: _toggleCamera,
                    child: const CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(Icons.flip_camera_ios_rounded, color: Colors.black),
                    ),
                  ),
                  InkWell(
                    onTap: _toggleCamera,
                    child: CircleAvatar(
                      backgroundColor: iscameraon ? Colors.white : Colors.black,
                      child: Icon(
                        Icons.camera_alt,
                        color: !iscameraon ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: _toggleMic,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(
                        !ismicon ? Icons.mic_off : Icons.mic,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      _stopAudio();
                      await _endCall();
                      // Delete the main document
                      await _firestore
                          .collection('rooms')
                          .doc(_auth.currentUser!.uid)
                          .delete();

                      // Delete all documents in the 'candidates' subcollection
                      final candidatesRef = _firestore
                          .collection('rooms')
                          .doc(_auth.currentUser!.uid)
                          .collection('candidates');

                      final candidatesSnapshot = await candidatesRef.get();

                      for (final doc in candidatesSnapshot.docs) {
                        await doc.reference.delete();
                      }
                      Navigator.pop(context);
                    },
                    child: const CircleAvatar(
                      backgroundColor: Colors.red,
                      child: Icon(Icons.call_end, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

}
