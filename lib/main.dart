import 'firebase_options.dart'; // Firebaseの設定ファイルをインポート

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Broadcaster extends StatefulWidget {
  @override
  _BroadcasterState createState() => _BroadcasterState();
}

class _BroadcasterState extends State<Broadcaster> {
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _createPeerConnection().then((pc) {
      _peerConnection = pc;
      _startLocalStream();
    });
  }

  Future<void> _startLocalStream() async {
    _localStream = await navigator.mediaDevices.getDisplayMedia({
      'video': true,
      'audio': false,
    });
    _peerConnection?.addStream(_localStream!);
  }

  Future<RTCPeerConnection> _createPeerConnection() async {
    final config = {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'}
      ]
    };
    final pc = await createPeerConnection(config);
    pc.onIceCandidate = (candidate) {
      _firestore.collection('candidates').add(candidate.toMap());
    };

    final offer = await pc.createOffer();
    await pc.setLocalDescription(offer);
    _firestore.collection('offers').doc('broadcaster').set(offer.toMap());

    return pc;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Broadcaster'),
      ),
      body: Center(
        child: _localStream != null
            ? RTCVideoView(_localStream!.getVideoTracks()[0].renderers[0])
            : CircularProgressIndicator(),
      ),
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
  runApp(Broadcaster());
}
