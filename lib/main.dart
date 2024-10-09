import 'firebase_options.dart'; // Firebaseの設定ファイルをインポート
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class BroadcasterScreen extends StatefulWidget {
  @override
  _BroadcasterScreenState createState() => _BroadcasterScreenState();
}

class _BroadcasterScreenState extends State<BroadcasterScreen> {
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _sdpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _createPeerConnection().then((pc) {
      _peerConnection = pc;
      _startLocalStream();
    });
  }

  Future<void> _startLocalStream() async {
    _localStream = await navigator.mediaDevices.getDisplayMedia({'video': true});
    _peerConnection?.addStream(_localStream!);
  }

  Future<RTCPeerConnection> _createPeerConnection() async {
    final configuration = {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
      ],
    };

    final pc = await createPeerConnection(configuration);

    pc.onIceCandidate = (candidate) {
      if (candidate != null) {
        _firestore.collection('candidates').add({
          'candidate': candidate.toMap(),
        });
      }
    };

    pc.onAddStream = (stream) {
      print('Stream added: ${stream.id}');
    };

    final offer = await pc.createOffer();
    await pc.setLocalDescription(offer);

    // FirebaseにSDP情報を保存
    _firestore.collection('offers').doc('broadcast').set({
      'sdp': offer.sdp,
      'type': offer.type,
    });

    return pc;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Broadcaster')),
      body: Column(
        children: [
          Expanded(
            child: _localStream != null
                ? RTCVideoView(_localStream!.getVideoTracks())
                : Center(child: Text('Starting stream...')),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _localStream?.dispose();
    _peerConnection?.dispose();
    super.dispose();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(BroadcasterScreen());
}
