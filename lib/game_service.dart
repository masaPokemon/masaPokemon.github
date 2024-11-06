import 'package:cloud_firestore/cloud_firestore.dart';

class GameRoom {
  final String roomId;
  final List<String> players;
  final String hostId;
  final DateTime createdAt;

  GameRoom({
    required this.roomId,
    required this.players,
    required this.hostId,
    required this.createdAt,
  });

  // Firestoreに保存するためのデータ
  Map<String, dynamic> toMap() {
    return {
      'roomId': roomId,
      'players': players,
      'hostId': hostId,
      'createdAt': createdAt,
    };
  }

  // Firestoreから取得するためのデータ
  static GameRoom fromMap(Map<String, dynamic> map) {
    return GameRoom(
      roomId: map['roomId'],
      players: List<String>.from(map['players']),
      hostId: map['hostId'],
      createdAt: map['createdAt'].toDate(),
    );
  }
}

class GameService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ゲームルームを作成
  Future<String> createGameRoom(String hostId) async {
    final roomRef = _db.collection('game_rooms').doc();
    final newRoom = GameRoom(
      roomId: roomRef.id,
      players: [hostId],
      hostId: hostId,
      createdAt: DateTime.now(),
    );

    await roomRef.set(newRoom.toMap());
    return roomRef.id;
  }

  // ゲームルームに参加
  Future<void> joinGameRoom(String roomId, String playerId) async {
    final roomRef = _db.collection('game_rooms').doc(roomId);
    final roomSnapshot = await roomRef.get();
    if (roomSnapshot.exists) {
      final room = GameRoom.fromMap(roomSnapshot.data()!);
      if (!room.players.contains(playerId)) {
        await roomRef.update({
          'players': FieldValue.arrayUnion([playerId]),
        });
      }
    }
  }

  // ゲームルームのリストを取得
  Stream<List<GameRoom>> getGameRooms() {
    return _db
        .collection('game_rooms')
        .orderBy('createdAt')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => GameRoom.fromMap(doc.data()))
            .toList());
  }
}
