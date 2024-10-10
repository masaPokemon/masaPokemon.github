import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class SignalingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String roomId;
  
  SignalingService(this.roomId);

  Future<void> createOffer(RTCSessionDescription offer) async {
    await _firestore.collection('rooms').doc(roomId).set({
      'offer': offer.toMap(),
    });
  }

  Future<RTCSessionDescription?> getOffer() async {
    final doc = await _firestore.collection('rooms').doc(roomId).get();
    if (doc.exists && doc.data()!['offer'] != null) {
      return RTCSessionDescription(
        doc.data()!['offer']['sdp'], 
        doc.data()!['offer']['type'],
      );
    }
    return null;
  }

  Future<void> createAnswer(RTCSessionDescription answer) async {
    await _firestore.collection('rooms').doc(roomId).update({
      'answer': answer.toMap(),
    });
  }

  Future<RTCSessionDescription?> getAnswer() async {
    final doc = await _firestore.collection('rooms').doc(roomId).get();
    if (doc.exists && doc.data()!['answer'] != null) {
      return RTCSessionDescription(
        doc.data()!['answer']['sdp'], 
        doc.data()!['answer']['type'],
      );
    }
    return null;
  }

  Future<void> addIceCandidate(RTCIceCandidate candidate, String collection) async {
    await _firestore.collection('rooms/$roomId/$collection').add(candidate.toMap());
  }

  Stream<List<RTCIceCandidate>> onIceCandidate(String collection) {
    return _firestore.collection('rooms/$roomId/$collection').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return RTCIceCandidate(
          doc.data()['candidate'],
          doc.data()['sdpMid'],
          doc.data()['sdpMLineIndex'],
        );
      }).toList();
    });
  }
}
