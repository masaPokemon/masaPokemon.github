import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:permission_handler/permission_handler.dart';

class StudentScreen extends StatefulWidget {
  @override
  _StudentScreenState createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;

  @override
  void initState() {
    super.initState();
    _initScreenCapture();
  }

  Future<void> _initScreenCapture() async {
    // 権限を取得
    if (await Permission.camera.request().isGranted) {
      // WebRTC用のPeerConnectionを初期化
      _peerConnection = await createPeerConnection({});

      // スクリーンキャプチャのストリームを取得
      _localStream = await navigator.mediaDevices.getDisplayMedia({
        'video': {'mandatory': {}, 'optional': []},
        'audio': false,
      });

      // ストリームをPeerConnectionに追加
      _peerConnection?.addStream(_localStream!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Screen'),
      ),
      body: Center(
        child: _localStream != null
            ? RTCVideoView(RTCVideoRenderer()..srcObject = _localStream)
            : Text('Capturing screen...'),
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
