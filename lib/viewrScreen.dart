import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewerScreen extends StatefulWidget {
  @override
  _ViewerScreenState createState() => _ViewerScreenState();
}

class _ViewerScreenState extends State<ViewerScreen> {
  late RTCPeerConnection _peerConnection;
  final _remoteRenderer = RTCVideoRenderer();

  @override
  void initState() {
    super.initState();
    _initializeRenderer();
    _createPeerConnection();
  }

  Future<void> _initializeRenderer() async {
    await _remoteRenderer.initialize();
  }

  Future<void> _createPeerConnection() async {
    Map<String, dynamic> configuration = {
      "iceServers": [
        {"urls": "stun:stun.l.google.com:19302"},
      ]
    };
    _peerConnection = await createPeerConnection(configuration);

    // Firebaseからシグナリングデータを受信
    FirebaseFirestore.instance.collection('signals').snapshots().listen((snapshot) {
      snapshot.docChanges.forEach((change) {
        if (change.type == DocumentChangeType.added) {
          // SDPを受信
          if (change.doc['sdp'] != null) {
            _peerConnection.setRemoteDescription(RTCSessionDescription(
              change.doc['sdp']['sdp'],
              change.doc['sdp']['type'],
            ));
          }

          // ICE候補を追加
          if (change.doc['candidate'] != null) {
            RTCIceCandidate candidate = RTCIceCandidate(
              change.doc['candidate']['candidate'],
              change.doc['candidate']['sdpMid'],
              change.doc['candidate']['sdpMLineIndex'],
            );
            _peerConnection.addIceCandidate(candidate);
          }
        }
      });
    });

    _peerConnection.onAddStream = (MediaStream stream) {
      _remoteRenderer.srcObject = stream;
    };
  }

  @override
  void dispose() {
    _remoteRenderer.dispose();
    _peerConnection.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Viewer")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Watching Broadcast"),
            Container(
              width: 300,
              height: 400,
              child: RTCVideoView(_remoteRenderer),
            ),
          ],
        ),
      ),
    );
  }
}
