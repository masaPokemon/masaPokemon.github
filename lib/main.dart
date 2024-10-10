import 'firebase_options.dart'; // Firebaseの設定ファイルをインポート
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(Broadcaster());
}

class StreamingScreen extends StatefulWidget {
  @override
  _StreamingScreenState createState() => _StreamingScreenState();
}

class _StreamingScreenState extends State<StreamingScreen> {
  final _localRenderer = RTCVideoRenderer();
  final _remoteRenderer = RTCVideoRenderer();
  late RTCPeerConnection _peerConnection;
  final _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _initRenderers();
    _createPeerConnection();
  }

  Future<void> _initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  Future<void> _createPeerConnection() async {
    final config = {
      'iceServers': [
        {'url': 'stun:stun.l.google.com:19302'},
      ]
    };

    _peerConnection = await createPeerConnection(config);
    _peerConnection.onIceCandidate = (candidate) {
      _firestore.collection('calls').doc('your-call-id').update({
        'candidate': candidate.toMap(),
      });
    };

    _peerConnection.onAddStream = (stream) {
      _remoteRenderer.srcObject = stream;
    };

    // スクリーンをキャプチャ
    MediaStream stream = await navigator.mediaDevices.getDisplayMedia({
      'video': true,
      'audio': true,
    });
    _localRenderer.srcObject = stream;
    _peerConnection.addStream(stream);
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    _peerConnection.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Screen Sharing - Streamer"),
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(child: RTCVideoView(_localRenderer)),
            Expanded(child: RTCVideoView(_remoteRenderer)),
          ],
        ),
      ),
    );
  }
}
