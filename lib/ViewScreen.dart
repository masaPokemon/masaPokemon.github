import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'WebRTCConnection.dart';
import 'SignalingService.dart';

class ViewScreen extends StatefulWidget {
  final String roomId;

  ViewScreen(this.roomId);

  @override
  _ViewScreenState createState() => _ViewScreenState();
}

class _ViewScreenState extends State<ViewScreen> {
  late WebRTCConnection _webRTCConnection;
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();

  @override
  void initState() {
    super.initState();
    _initRenderer();
    _startViewing();
  }

  void _initRenderer() async {
    await _remoteRenderer.initialize();
  }

  void _startViewing() async {
    SignalingService signalingService = SignalingService(widget.roomId);
    _webRTCConnection = WebRTCConnection(signalingService);
    await _webRTCConnection.createPeerConnection();
    await _webRTCConnection.createAnswer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("View Screen"),
      ),
      body: Column(
        children: [
          Expanded(child: RTCVideoView(_remoteRenderer)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _remoteRenderer.dispose();
    super.dispose();
  }
}
