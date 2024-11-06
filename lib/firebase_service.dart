import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // サインイン
  Future<User?> signIn(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print("サインイン失敗: $e");
      return null;
    }
  }

  // ゲームルームの作成
  Future<void> createGameRoom(String roomId, List<String> players) async {
    await FirebaseFirestore.instance.collection('gameRooms').doc(roomId).set({
      'roomId': roomId,
      'players': players,
      'gameState': 'waiting',
    });
  }

  // ゲームルームに参加
  Future<void> joinGameRoom(String roomId, String playerId) async {
    await FirebaseFirestore.instance.collection('gameRooms').doc(roomId).update({
      'players': FieldValue.arrayUnion([playerId]),
    });
  }
}
