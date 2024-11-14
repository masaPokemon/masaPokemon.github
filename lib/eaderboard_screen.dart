import 'package:flutter/material.dart';
import 'quiz_service.dart';

class LeaderboardScreen extends StatelessWidget {
  final QuizService quizService = QuizService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("ランキング")),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: quizService.getLeaderboard(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('ランキングはまだありません'));
          }

          final leaderboard = snapshot.data!;
          return ListView.builder(
            itemCount: leaderboard.length,
            itemBuilder: (context, index) {
              final user = leaderboard[index];
              return ListTile(
                title: Text('ユーザーID: ${user['userId']}'),
                subtitle: Text('スコア: ${user['score']}'),
              );
            },
          );
        },
      ),
    );
  }
}
