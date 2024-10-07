import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

void main() {
  runApp(ScreenSharePage());
}

class ScreenSharePage extends StatefulWidget {
  @override
  _ScreenSharePageState createState() => _ScreenSharePageState();
}

class _ScreenSharePageState extends State<ScreenSharePage> {
  RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  MediaStream? _localStream;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _localRenderer.initialize();
    _startScreenShare();
  }

  Future<void> _startScreenShare() async {
    try {
      // Request screen capture
      MediaStream stream = await navigator.mediaDevices.getDisplayMedia({
        'video': {
          'mediaSource': 'screen', // Request the screen
        },
        'audio': true,
      });

      _localStream = stream;
      _localRenderer.srcObject = _localStream;

      setState(() {});
    } catch (e) {
      print("Error starting screen share: $e");
    }
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _localStream?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Screen Share with WebRTC')),
      body: Center(
        child: _localStream != null
            ? RTCVideoView(_localRenderer)
            : Text('Screen sharing not started'),
      ),
    );
  }
}
