import 'package:flutter/material.dart';

class QuizScreen extends StatelessWidget {
  final String matchId;

  QuizScreen({required this.matchId});

  @override
  Widget build(BuildContext context) {
    // クイズ問題の取得と表示を行うロジックを追加
    return Scaffold(
      appBar: AppBar(title: Text("クイズ対戦")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('対戦ID: $matchId'),
            // クイズ問題や選択肢をここに表示
            ElevatedButton(
              onPressed: () {
                // 解答の送信処理
              },
              child: Text('解答する'),
            ),
          ],
        ),
      ),
    );
  }
}
