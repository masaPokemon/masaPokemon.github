import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late List<List<int>> board;
  int currentPlayer = 1;  // 1: Player 1, 2: Player 2

  @override
  void initState() {
    super.initState();
    board = List.generate(8, (i) => List.filled(8, 0)); // 0: Empty, 1: Black, 2: White
    // 初期駒の配置
    board[3][3] = 1;
    board[4][4] = 1;
    board[3][4] = 2;
    board[4][3] = 2;
  }

  // 駒を置くメソッド
  void placePiece(int row, int col) {
    setState(() {
      board[row][col] = currentPlayer;
      currentPlayer = currentPlayer == 1 ? 2 : 1;  // プレイヤー交代
    });
  }

  // UI表示
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Othello Game')),
      body: GridView.builder(
        itemCount: 64,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 8,
          childAspectRatio: 1,
        ),
        itemBuilder: (context, index) {
          int row = index ~/ 8;
          int col = index % 8;
          return GestureDetector(
            onTap: () {
              if (board[row][col] == 0) {
                placePiece(row, col);
              }
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(),
                color: board[row][col] == 1
                    ? Colors.black
                    : board[row][col] == 2
                        ? Colors.white
                        : Colors.green,
              ),
            ),
          );
        },
      ),
    );
  }
}
