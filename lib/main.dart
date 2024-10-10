import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class ScreenSharePage extends StatefulWidget {
  @override
  _ScreenSharePageState createState() => _ScreenSharePageState();
}

class _ScreenSharePageState extends State<ScreenSharePage> {
  late RTCVideoRenderer _localRenderer;

  @override
  void initState() {
    super.initState();
    _localRenderer = RTCVideoRenderer();
    _initRenderer();
  }

  Future<void> _initRenderer() async {
    await _localRenderer.initialize();
  }

  Future<void> _startScreenShare() async {
    // 画面共有を開始するための処理
    final mediaStream = await navigator.mediaDevices.getDisplayMedia({
      'video': true,
    });
    _localRenderer.srcObject = mediaStream;
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Screen Share")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(child: RTCVideoView(_localRenderer)),
            ElevatedButton(
              onPressed: _startScreenShare,
              child: Text("画面共有を開始"),
            ),
          ],
        ),
      ),
    );
  }
}

void main() => runApp(MaterialApp(home: ScreenSharePage()));
