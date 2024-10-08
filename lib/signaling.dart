// signaling.dart
import 'package:flutter_webrtc/flutter_webrtc.dart';

class Signaling {
  RTCPeerConnection _peerConnection;
  MediaStream _localStream;

  Future<void> createPeerConnection() async {
    Map<String, dynamic> configuration = {
      'iceServers': [
        {
          'urls': 'stun:stun.l.google.com:19302',
        },
      ],
    };

    _peerConnection = await createPeerConnection(configuration);
    _localStream = await _createStream();

    _peerConnection.addStream(_localStream);

    _peerConnection.onIceCandidate = (RTCIceCandidate candidate) {
      print('Ice Candidate: ${candidate.toMap()}');
    };

    // Handle remote stream
    _peerConnection.onAddStream = (MediaStream stream) {
      print('Received remote stream');
      // Here you can handle the remote stream (e.g., display it)
    };
  }

  Future<MediaStream> _createStream() async {
    return await navigator.mediaDevices.getDisplayMedia({'video': true});
  }

  Future<void> close() async {
    await _peerConnection.close();
    _localStream.dispose();
  }
}
