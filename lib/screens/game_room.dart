import 'package:cloud_firestore/cloud_firestore.dart';

class GameRoom {
  final String roomId;
  final List<String> players;

  GameRoom({required this.roomId, required this.players});

  // ゲームルームをFirestoreに保存
  Future<void> createGameRoom() async {
    final gameRoomRef = FirebaseFirestore.instance.collection('gameRooms').doc(roomId);
    await gameRoomRef.set({
      'roomId': roomId,
      'players': players,
      'gameState': 'waiting', // ゲーム開始前
    });
  }

  // プレイヤーをゲームルームに参加させる
  Future<void> joinGame(String playerId) async {
    final gameRoomRef = FirebaseFirestore.instance.collection('gameRooms').doc(roomId);
    await gameRoomRef.update({
      'players': FieldValue.arrayUnion([playerId]),
    });
  }

  // ゲームの状態を更新
  Future<void> updateGameState(String state) async {
    final gameRoomRef = FirebaseFirestore.instance.collection('gameRooms').doc(roomId);
    await gameRoomRef.update({
      'gameState': state,
    });
  }
}
