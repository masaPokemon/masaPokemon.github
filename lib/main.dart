import 'firebase_options.dart'; // Firebaseの設定ファイルをインポート
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class Signaling {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createOffer(String roomId, String offer) async {
    await _firestore.collection('rooms').doc(roomId).set({'offer': offer});
  }

  Future<void> createAnswer(String roomId, String answer) async {
    await _firestore.collection('rooms').doc(roomId).update({'answer': answer});
  }

  Stream<DocumentSnapshot> getRoom(String roomId) {
    return _firestore.collection('rooms').doc(roomId).snapshots();
  }
}

class StreamScreen extends StatefulWidget {
  final String roomId;

  StreamScreen({required this.roomId});

  @override
  _StreamScreenState createState() => _StreamScreenState();
}

class _StreamScreenState extends State<StreamScreen> {
  late RTCPeerConnection _peerConnection;
  late MediaStream _localStream;
  final Signaling _signaling = Signaling();

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    // MediaStreamの作成
    _localStream = await navigator.mediaDevices.getUserMedia({'video': true, 'audio': true});

    // RTCPeerConnectionの作成
    _peerConnection = await createPeerConnection({...});
    
    _localStream.getTracks().forEach((track) {
      _peerConnection.addTrack(track, _localStream);
    });

    // Offerの作成
    final offer = await _peerConnection.createOffer();
    await _peerConnection.setLocalDescription(offer);
    
    // FirebaseにOfferを送信
    _signaling.createOffer(widget.roomId, offer.sdp!);

    // FirestoreからのAnswerの取得
    _signaling.getRoom(widget.roomId).listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data()!;
        if (data['answer'] != null) {
          _peerConnection.setRemoteDescription(RTCSessionDescription(data['answer'], 'answer'));
        }
      }
    });
  }

  @override
  void dispose() {
    _localStream.dispose();
    _peerConnection.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('配信画面')),
      body: RTCVideoView(_localStream.videoTracks[0]),
    );
  }
}


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(StreamScreen('1223'));
}
