import 'package:cloud_firestore/cloud_firestore.dart';

class GameProgress {
  String currentTurn;
  List<PlayerStatus> players;

  GameProgress({required this.currentTurn, required this.players});

  Map<String, dynamic> toMap() {
    return {
      'currentTurn': currentTurn,
      'players': players.map((player) => player.toMap()).toList(),
    };
  }

  static GameProgress fromMap(Map<String, dynamic> map) {
    final players = (map['players'] as List)
        .map((playerMap) => PlayerStatus.fromMap(playerMap))
        .toList();
    return GameProgress(
      currentTurn: map['currentTurn'],
      players: players,
    );
  }
}

class PlayerStatus {
  String playerId;
  String role;
  bool isAlive;

  PlayerStatus({
    required this.playerId,
    required this.role,
    required this.isAlive,
  });

  Map<String, dynamic> toMap() {
    return {
      'playerId': playerId,
      'role': role,
      'isAlive': isAlive,
    };
  }

  static PlayerStatus fromMap(Map<String, dynamic> map) {
    return PlayerStatus(
      playerId: map['playerId'],
      role: map['role'],
      isAlive: map['isAlive'],
    );
  }
}

class GameProgressService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ゲームの進行状況を取得
  Stream<GameProgress> getGameProgress(String roomId) {
    return _db
        .collection('game_rooms')
        .doc(roomId)
        .snapshots()
        .map((doc) {
      final data = doc.data()!;
      final players = (data['players'] as List)
          .map((e) => PlayerStatus.fromMap(e))
          .toList();
      return GameProgress(
        currentTurn: data['currentTurn'],
        players: players,
      );
    });
  }

  // ゲームのターンを更新
  Future<void> updateTurn(String roomId, String newTurn) async {
    await _db.collection('game_rooms').doc(roomId).update({
      'currentTurn': newTurn,
    });
  }
}
