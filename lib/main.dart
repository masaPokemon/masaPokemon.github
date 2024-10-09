import 'firebase_options.dart'; // Firebaseの設定ファイルをインポート
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BroadcasterScreen(),
    );
  }
}

class BroadcasterScreen extends StatefulWidget {
  @override
  _BroadcasterScreenState createState() => _BroadcasterScreenState();
}

class _BroadcasterScreenState extends State<BroadcasterScreen> {
  RTCPeerConnection? _peerConnection;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.reference().child('signaling');
  final _localRenderer = RTCVideoRenderer();
  MediaStream? _localStream;

  @override
  void initState() {
    super.initState();
    _initializeRenderer();
    _startBroadcast();
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    super.dispose();
  }

  Future<void> _initializeRenderer() async {
    await _localRenderer.initialize();
  }

  Future<void> _startBroadcast() async {
    // カメラや画面のストリームを取得
    _localStream = await navigator.mediaDevices.getDisplayMedia({'video': true});

    // WebRTCの接続設定
    Map<String, dynamic> config = {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
      ]
    };

    _peerConnection = await createPeerConnection(config);

    _localStream!.getTracks().forEach((track) {
      _peerConnection!.addTrack(track, _localStream!);
    });

    // Firebaseにオファーを保存
    var offer = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(offer);
    _dbRef.child('offer').set(offer.toMap());

    _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
      if (candidate != null) {
        _dbRef.child('ice_candidates').push().set(candidate.toMap());
      }
    };

    setState(() {
      _localRenderer.srcObject = _localStream;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Broadcaster'),
      ),
      body: Center(
        child: RTCVideoView(_localRenderer),
      ),
    );
  }
}
