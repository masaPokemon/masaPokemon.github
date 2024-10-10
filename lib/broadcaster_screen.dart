import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BroadcasterScreen extends StatefulWidget {
  @override
  _BroadcasterScreenState createState() => _BroadcasterScreenState();
}

class _BroadcasterScreenState extends State<BroadcasterScreen> {
  late RTCPeerConnection _peerConnection;
  late MediaStream _localStream;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _initWebRTC();
  }

  Future<void> _initWebRTC() async {
    _localStream = await _createStream();
    _peerConnection = await createPeerConnection({}, {});

    _localStream.getTracks().forEach((track) {
      _peerConnection.addTrack(track, _localStream);
    });

    _peerConnection.onIceCandidate = (RTCIceCandidate candidate) {
      _firestore.collection('candidates').add({
        'candidate': candidate.toMap(),
        'uid': _auth.currentUser?.uid,
      });
    };

    _peerConnection.onTrack = (RTCTrackEvent event) {
      // Track event handling (if needed)
    };

    // Signaling logic here
    _listenForCandidates();
  }

  Future<MediaStream> _createStream() async {
    final stream = await navigator.mediaDevices.getDisplayMedia({
      'video': true,
      'audio': true,
    });
    return stream;
  }

  void _listenForCandidates() {
    _firestore.collection('candidates').snapshots().listen((snapshot) {
      for (var doc in snapshot.docChanges) {
        if (doc.type == DocumentChangeType.added) {
          _peerConnection.addIceCandidate(
              RTCIceCandidate.fromMap(doc.doc.data()!));
        }
      }
    });
  }

  @override
  void dispose() {
    _peerConnection.close();
    _localStream.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Broadcaster'),
      ),
      body: Center(
        child: Text('Broadcasting...'),
      ),
    );
  }
}
