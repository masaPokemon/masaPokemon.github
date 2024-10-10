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

class Broadcaster extends StatefulWidget {
  @override
  _BroadcasterState createState() => _BroadcasterState();
}

class _BroadcasterState extends State<Broadcaster> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late RTCPeerConnection _peerConnection;
  late MediaStream _localStream;

  @override
  void initState() {
    super.initState();
    _createPeerConnection();
  }

  Future<void> _createPeerConnection() async {
    // WebRTCの設定を行う
    final Map<String, dynamic> configuration = {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
      ],
    };
    _peerConnection = await createPeerConnection(configuration);

    // ローカルメディアストリームを作成
    _localStream = await _getUserMedia();
    _peerConnection.addStream(_localStream);

    // Firebaseにシグナリング情報を保存
    await _firestore.collection('broadcasters').add({
      'offer': await _peerConnection.createOffer(),
    });
  }

  Future<MediaStream> _getUserMedia() async {
    final stream = await navigator.mediaDevices.getDisplayMedia({'video': true});
    return stream;
  }

  @override
  void dispose() {
    _localStream.dispose();
    _peerConnection.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Broadcaster'),
      ),
      body: Center(
        child: Text('Screen Sharing in Progress'),
      ),
    );
  }
}
