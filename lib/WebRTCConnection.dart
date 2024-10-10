import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'SignalingService.dart';

class WebRTCConnection {
  RTCPeerConnection? _peerConnection;
  final SignalingService _signaling;

  WebRTCConnection(this._signaling);

  Future<void> createPeerConnection() async {
    final configuration = {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
      ],
    };

    _peerConnection = await createPeerConnection(configuration);

    // ICE Candidateが生成されたらシグナリングサーバーに送信
    _peerConnection?.onIceCandidate = (candidate) {
      if (candidate != null) {
        _signaling.addIceCandidate(candidate, 'callerCandidates');
      }
    };
  }

  Future<void> createOffer() async {
    RTCSessionDescription offer = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(offer);
    await _signaling.createOffer(offer);
  }

  Future<void> createAnswer() async {
    RTCSessionDescription offer = await _signaling.getOffer()!;
    await _peerConnection!.setRemoteDescription(offer);
    RTCSessionDescription answer = await _peerConnection!.createAnswer();
    await _peerConnection!.setLocalDescription(answer);
    await _signaling.createAnswer(answer);
  }

  Future<void> setRemoteAnswer() async {
    RTCSessionDescription answer = await _signaling.getAnswer()!;
    await _peerConnection!.setRemoteDescription(answer);
  }

  void listenForIceCandidates() {
    _signaling.onIceCandidate('calleeCandidates').listen((candidates) {
      for (var candidate in candidates) {
        _peerConnection!.addIceCandidate(candidate);
      }
    });
  }
}
