import 'firebase_options.dart'; // Firebaseの設定ファイルをインポート
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class ScreenSharingApp extends StatefulWidget {
  @override
  _ScreenSharingAppState createState() => _ScreenSharingAppState();
}

class _ScreenSharingAppState extends State<ScreenSharingApp> {
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  final _firestore = FirebaseFirestore.instance;
  final _configuration = {
    "iceServers": [
      {"urls": "stun:stun.l.google.com:19302"},
    ]
  };

  @override
  void initState() {
    super.initState();
    initWebRTC();
  }

  // WebRTCの初期化
  Future<void> initWebRTC() async {
    // ストリームの取得（画面共有用）
    _localStream = await navigator.mediaDevices.getDisplayMedia({
      'video': {'mandatory': {}, 'optional': []},
      'audio': false
    });

    // PeerConnectionの作成
    _peerConnection = await createPeerConnection(_configuration);

    // ローカルストリームを追加
    _localStream?.getTracks().forEach((track) {
      _peerConnection?.addTrack(track, _localStream!);
    });

    // ICE候補のリスナー
    _peerConnection?.onIceCandidate = (candidate) {
      if (candidate != null) {
        // FirestoreにICE候補を保存（シグナリング用）
        _firestore.collection('candidates').add(candidate.toMap());
      }
    };

    // シグナリングをFirebaseで処理
    _handleSignaling();
  }

  // シグナリング処理
  Future<void> _handleSignaling() async {
    var offer = await _peerConnection?.createOffer();
    await _peerConnection?.setLocalDescription(offer!);

    // オファーをFirestoreに保存
    await _firestore.collection('offers').add(offer!.toMap());

    // リモートのオファーに対する応答処理
    _firestore.collection('answers').snapshots().listen((snapshot) {
      for (var doc in snapshot.docs) {
        var data = doc.data();
        if (data.containsKey('sdp')) {
          var answer = RTCSessionDescription(data['sdp'], data['type']);
          _peerConnection?.setRemoteDescription(answer);
        }
      }
    });

    // ICE候補を取得して追加
    _firestore.collection('candidates').snapshots().listen((snapshot) {
      for (var doc in snapshot.docs) {
        var data = doc.data();
        _peerConnection?.addCandidate(RTCIceCandidate(data['candidate'], data['sdpMid'], data['sdpMLineIndex']));
      }
    });
  }

  @override
  void dispose() {
    _localStream?.dispose();
    _peerConnection?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Screen Sharing')),
      body: Center(
        child: _localStream != null
            ? RTCVideoView(_localStream!.getVideoTracks()[0].renderer)
            : Text('Waiting for screen sharing...'),
      ),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(ScreenSharingApp());
}
