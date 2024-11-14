import 'package:cloud_firestore/cloud_firestore.dart';

class QuizService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // クイズ対戦を開始する
  Future<void> startMatch(String userId, int score) async {
    final matchRef = _db.collection('matches').doc(userId);
    await matchRef.set({
      'userId': userId,
      'score': score,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // スコアを更新
  Future<void> updateUserScore(String userId, int score) async {
    final userRef = _db.collection('users').doc(userId);
    final userDoc = await userRef.get();

    if (userDoc.exists) {
      final currentScore = userDoc['score'];
      if (score > currentScore) {
        await userRef.update({'score': score});
      }
    } else {
      await userRef.set({
        'score': score,
        'userId': userId,
      });
    }
  }

  // ランキングを取得
  Future<List<Map<String, dynamic>>> getLeaderboard() async {
    final leaderboardSnapshot = await _db
        .collection('users')
        .orderBy('score', descending: true)
        .limit(10)
        .get();

    return leaderboardSnapshot.docs.map((doc) {
      return {
        'userId': doc['userId'],
        'score': doc['score'],
      };
    }).toList();
  }
}
