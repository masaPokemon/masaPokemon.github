import 'firebase_options.dart'; // Firebaseの設定ファイルをインポート
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MaterialApp(home: ScreenShareBroadcaster()));
}

class ScreenShareBroadcaster extends StatefulWidget {
  @override
  _ScreenShareBroadcasterState createState() => _ScreenShareBroadcasterState();
}

class _ScreenShareBroadcasterState extends State<ScreenShareBroadcaster> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;

  @override
  void initState() {
    super.initState();
    _initWebRTC();
  }

  Future<void> _initWebRTC() async {
    // WebRTCの設定
    _peerConnection = await createPeerConnection({});
    _localStream = await navigator.mediaDevices.getDisplayMedia({'video': true});
    _localStream?.getTracks().forEach((track) {
      _peerConnection?.addTrack(track, _localStream!);
    });

    // Offerの作成
    RTCSessionDescription description = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(description);

    // FirebaseにOfferを送信
    await firestore.collection('screenshare').doc('room').set({
      'offer': description.toMap(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Screen Share Broadcaster')),
      body: Center(child: Text('Sharing Screen...')),
    );
  }

  @override
  void dispose() {
    _localStream?.dispose();
    _peerConnection?.close();
    super.dispose();
  }
}
