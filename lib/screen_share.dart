import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class ScreenShare extends StatefulWidget {
  @override
  _ScreenShareState createState() => _ScreenShareState();
}

class _ScreenShareState extends State<ScreenShare> {
  late RTCPeerConnection _peerConnection;
  late MediaStream _localStream;
  final List<RTCVideoRenderer> _renderers = [];
  bool _isSharing = false;

  @override
  void initState() {
    super.initState();
    _initRenderers();
    _createPeerConnection();
  }

  Future<void> _initRenderers() async {
    for (var renderer in _renderers) {
      await renderer.initialize();
    }
  }

  Future<void> _createPeerConnection() async {
    final config = <String, dynamic>{
      'iceServers': [
        {'url': 'stun:stun.l.google.com:19302'},
      ],
    };

    _peerConnection = await createPeerConnection(config);

    _peerConnection.onIceCandidate = (RTCIceCandidate candidate) {
      // Handle IceCandidate
    };

    _peerConnection.onTrack = (RTCTrackEvent event) {
      if (event.track.kind == 'video') {
        // Add remote stream
      }
    };
  }

  Future<void> _startScreenSharing() async {
    _localStream = await navigator.mediaDevices.getDisplayMedia({'video': true});
    _localStream.getTracks().forEach((track) {
      _peerConnection.addTrack(track, _localStream);
    });

    _renderers.add(RTCVideoRenderer());
    _renderers.last.srcObject = _localStream;

    setState(() {
      _isSharing = true;
    });
  }

  Future<void> _stopScreenSharing() async {
    _localStream.getTracks().forEach((track) {
      track.stop();
    });
    await _peerConnection.close();
    setState(() {
      _isSharing = false;
    });
  }

  @override
  void dispose() {
    _localStream.dispose();
    _peerConnection.close();
    for (var renderer in _renderers) {
      renderer.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Screen Sharing'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_isSharing)
              Expanded(
                child: RTCVideoView(_renderers.last),
              ),
            ElevatedButton(
              onPressed: _isSharing ? _stopScreenSharing : _startScreenSharing,
              child: Text(_isSharing ? 'Stop Sharing' : 'Start Sharing'),
            ),
          ],
        ),
      ),
    );
  }
}
