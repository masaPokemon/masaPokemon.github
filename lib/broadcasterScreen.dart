import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BroadcasterScreen extends StatefulWidget {
  @override
  _BroadcasterScreenState createState() => _BroadcasterScreenState();
}

class _BroadcasterScreenState extends State<BroadcasterScreen> {
  late RTCPeerConnection _peerConnection;
  final _localRenderer = RTCVideoRenderer();

  @override
  void initState() {
    super.initState();
    _initializeRenderer();
    _createPeerConnection();
  }

  Future<void> _initializeRenderer() async {
    await _localRenderer.initialize();
  }

  Future<void> _createPeerConnection() async {
    // WebRTCの設定
    Map<String, dynamic> configuration = {
      "iceServers": [
        {"urls": "stun:stun.l.google.com:19302"},
      ]
    };
    _peerConnection = await createPeerConnection(configuration);

    // ローカルストリームを取得
    MediaStream stream = await navigator.mediaDevices.getDisplayMedia({
      'video': true,
      'audio': true,
    });
    _localRenderer.srcObject = stream;
    stream.getTracks().forEach((track) {
      _peerConnection.addTrack(track, stream);
    });

    // Firebaseにシグナリングデータを送信
    _peerConnection.onIceCandidate = (RTCIceCandidate candidate) {
      FirebaseFirestore.instance
          .collection('signals')
          .add({'candidate': candidate.toMap()});
    };

    // 受信したICE候補をFirebaseから取得
    FirebaseFirestore.instance.collection('signals').snapshots().listen((snapshot) {
      snapshot.docChanges.forEach((change) {
        if (change.type == DocumentChangeType.added) {
          // ICE候補を追加
          RTCIceCandidate candidate = RTCIceCandidate(
            change.doc['candidate']['candidate'],
            change.doc['candidate']['sdpMid'],
            change.doc['candidate']['sdpMLineIndex'],
          );
          _peerConnection.addIceCandidate(candidate);
        }
      });
    });
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _peerConnection.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Broadcasting")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Broadcasting Screen"),
            Container(
              width: 300,
              height: 400,
              child: RTCVideoView(_localRenderer),
            ),
          ],
        ),
      ),
    );
  }
}
