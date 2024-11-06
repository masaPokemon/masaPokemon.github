import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  final bool gameWon;

  ResultScreen({required this.gameWon});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("ゲーム終了")),
      body: Center(
        child: Text(gameWon ? "村人の勝利！" : "人狼の勝利！"),
      ),
    );
  }
}
