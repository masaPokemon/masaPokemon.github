import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'WebRTCConnection.dart';
import 'SignalingService.dart';

class BroadcastScreen extends StatefulWidget {
  final String roomId;

  BroadcastScreen(this.roomId);

  @override
  _BroadcastScreenState createState() => _BroadcastScreenState();
}

class _BroadcastScreenState extends State<BroadcastScreen> {
  late WebRTCConnection _webRTCConnection;
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();

  @override
  void initState() {
    super.initState();
    _initRenderer();
    _startBroadcast();
  }

  void _initRenderer() async {
    await _localRenderer.initialize();
  }

  void _startBroadcast() async {
    SignalingService signalingService = SignalingService(widget.roomId);
    _webRTCConnection = WebRTCConnection(signalingService);
    await _webRTCConnection.createPeerConnection();
    await _webRTCConnection.createOffer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Broadcast Screen"),
      ),
      body: Column(
        children: [
          Expanded(child: RTCVideoView(_localRenderer)),
          ElevatedButton(
            onPressed: () {
              // 配信を停止するロジック
            },
            child: Text("Stop Broadcast"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    super.dispose();
  }
}
