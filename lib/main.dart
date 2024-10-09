import 'firebase_options.dart'; // Firebaseの設定ファイルをインポート
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BroadcasterApp extends StatefulWidget {
  @override
  _BroadcasterAppState createState() => _BroadcasterAppState();
}

class _BroadcasterAppState extends State<BroadcasterApp> {
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  final _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _createPeerConnection();
  }

  Future<void> _createPeerConnection() async {
    _localStream = await navigator.mediaDevices.getDisplayMedia({
      'video': true,
      'audio': false,
    });

    _peerConnection = await createPeerConnection({
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
      ]
    });

    _peerConnection!.addStream(_localStream!);

    _peerConnection!.onIceCandidate = (candidate) {
      if (candidate != null) {
        _firestore.collection('calls').doc('callId').update({
          'offerCandidates': FieldValue.arrayUnion([candidate.toMap()])
        });
      }
    };

    RTCSessionDescription offer = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(offer);

    _firestore.collection('calls').doc('callId').set({
      'offer': offer.toMap(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Screen Sharing (Broadcaster)")),
      body: Center(child: Text("Sharing Screen...")),
    );
  }

  @override
  void dispose() {
    _localStream?.dispose();
    _peerConnection?.close();
    super.dispose();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(BroadcasterApp());
}
