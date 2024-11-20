import 'package:flutter/material.dart';

void main() => runApp(OthelloApp());

class OthelloApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Othello Game',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: OthelloBoard(),
    );
  }
}

class OthelloBoard extends StatefulWidget {
  @override
  _OthelloBoardState createState() => _OthelloBoardState();
}

class _OthelloBoardState extends State<OthelloBoard> {
  static const int size = 8;
  List<List<int>> board = List.generate(size, (_) => List.filled(size, 0));
  int currentPlayer = 1; // 1 = 黒, -1 = 白

  // 8方向の移動方向
  static const List<List<int>> directions = [
    [-1, 0],  // 上
    [1, 0],   // 下
    [0, -1],  // 左
    [0, 1],   // 右
    [-1, -1], // 左上
    [-1, 1],  // 右上
    [1, -1],  // 左下
    [1, 1],   // 右下
  ];

  @override
  void initState() {
    super.initState();
    // 初期配置（中央に黒と白を配置）
    board[3][3] = 1;
    board[3][4] = -1;
    board[4][3] = -1;
    board[4][4] = 1;
  }

  // ゲームの盤面の描画
  Widget buildBoard() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(size, (row) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(size, (col) {
            return GestureDetector(
              onTap: () => onTapCell(row, col),
              child: Container(
                width: 40,
                height: 40,
                margin: EdgeInsets.all(1),
                decoration: BoxDecoration(
                  color: Colors.green,
                  border: Border.all(color: Colors.black),
                ),
                child: Center(
                  child: board[row][col] == 0
                      ? null
                      : Icon(
                          board[row][col] == 1 ? Icons.circle : Icons.circle,
                          size: 30,
                          color: board[row][col] == 1 ? Colors.black : Colors.white,
                        ),
                ),
              ),
            );
          }),
        );
      }),
    );
  }

  // セルがタップされたときの処理
  void onTapCell(int row, int col) {
    if (board[row][col] != 0) {
      return; // 既に石が置かれている場合は何もしない
    }

    if (isValidMove(row, col)) {
      setState(() {
        board[row][col] = currentPlayer;
        flipStones(row, col);
        currentPlayer = -currentPlayer; // プレイヤー交代
      });
    }
  }

  // 有効な手かどうかをチェック
  bool isValidMove(int row, int col) {
    // 置く場所が空でなければ無効
    if (board[row][col] != 0) {
      return false;
    }

    // 8方向すべてを確認
    for (var direction in directions) {
      int dRow = direction[0];
      int dCol = direction[1];

      int r = row + dRow;
      int c = col + dCol;

      // 最初に相手の石があれば
      bool foundOpponent = false;
      while (r >= 0 && r < size && c >= 0 && c < size && board[r][c] == -currentPlayer) {
        foundOpponent = true;
        r += dRow;
        c += dCol;
      }

      // 相手の石が続き、その先に自分の石がある場合
      if (foundOpponent && r >= 0 && r < size && c >= 0 && c < size && board[r][c] == currentPlayer) {
        return true;
      }
    }

    return false;
  }

  // ひっくり返すロジック
  void flipStones(int row, int col) {
    // 現在のプレイヤー
    int player = board[row][col];

    // 各方向で石をひっくり返す処理
    for (var direction in directions) {
      int dRow = direction[0];
      int dCol = direction[1];

      // 一方向に石がひっくり返せるかどうか確認
      List<List<int>> toFlip = [];
      int r = row + dRow;
      int c = col + dCol;

      // 最初に相手の石があるかどうか確認
      while (r >= 0 && r < size && c >= 0 && c < size && board[r][c] == -player) {
        toFlip.add([r, c]);
        r += dRow;
        c += dCol;
      }

      // 相手の石が続いた後に自分の石がある場合、挟んだことになるのでひっくり返す
      if (r >= 0 && r < size && c >= 0 && c < size && board[r][c] == player) {
        // ひっくり返すべき石が存在する場合
        for (var cell in toFlip) {
          int flipRow = cell[0];
          int flipCol = cell[1];
          board[flipRow][flipCol] = player;
        }
      }
    }
  }

  // 勝敗判定
  bool checkGameOver() {
    // すべてのセルに石が置かれているか、どちらのプレイヤーも有効な手を打てない場合
    bool isFull = true;
    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        if (board[r][c] == 0) {
          isFull = false;
          break;
        }
      }
    }

    if (isFull) return true;

    // プレイヤーがどちらも動けない場合
    bool player1HasMove = false;
    bool player2HasMove = false;

    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        if (board[r][c] == 0) {
          if (isValidMove(r, c)) {
            if (currentPlayer == 1) {
              player1HasMove = true;
            } else {
              player2HasMove = true;
            }
          }
        }
      }
    }

    return !(player1HasMove || player2HasMove);
  }

  // ゲーム終了ダイアログ
  void showGameOverDialog() {
    int blackCount = board.fold(0, (sum, row) => sum + row.where((cell) => cell == 1).length);
    int whiteCount = board.fold(0, (sum, row) => sum + row.where((cell) => cell == -1).length);
    String winner = blackCount > whiteCount ? "黒" : (whiteCount > blackCount ? "白" : "引き分け");

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("ゲーム終了"),
          content: Text("$winner の勝ち\n黒: $blackCount, 白: $whiteCount"),
          actions: <Widget>[
            TextButton(
              child: Text('再挑戦'),
              onPressed: () {
                setState(() {
                  board = List.generate(size, (_) => List.filled(size, 0));
                  board[3][3] = 1;
                  board[3][4] = -1;
                  board[4][3] = -1;
                  board[4][4] = 1;
                  currentPlayer = 1;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (checkGameOver()) {
      Future.delayed(Duration(milliseconds: 300), showGameOverDialog);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Othello Game'),
      ),
      body: Center(
        child: buildBoard(),
      ),
    );
  }
}
