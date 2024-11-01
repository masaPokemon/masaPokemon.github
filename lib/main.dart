import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(MyGameApp());
}

class MyGameApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '線の攻撃ゲーム',
      home: GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  List<Offset?> points = [];
  List<Enemy> enemies = [];
  int score = 0;
  final Random random = Random();
  int enemyCount = 5;

  @override
  void initState() {
    super.initState();
    _generateEnemies();
  }

  void _generateEnemies() {
    enemies = List.generate(enemyCount, (index) {
      return Enemy(
        position: Offset(random.nextDouble() * 300, random.nextDouble() * 600),
        speed: random.nextDouble() * 2 + 1,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('線の攻撃ゲーム'),
      ),
      body: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            points.add(details.localPosition);
          });
        },
        onPanEnd: (details) {
          checkAttack();
          points.clear(); // 描いた線をクリア
        },
        child: CustomPaint(
          painter: LinePainter(points, enemies),
          child: Container(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            score = 0; // スコアをリセット
            _generateEnemies(); // 敵を再生成
          });
        },
        child: Icon(Icons.refresh),
      ),
    );
  }

  void checkAttack() {
    // 敵に当たった場合の処理
    enemies.removeWhere((enemy) {
      // 線が敵に当たったかをチェック
      for (int i = 0; i < points.length - 1; i++) {
        if (enemy.isHit(points[i]!, points[i + 1]!)) {
          setState(() {
            score++;
          });
          return true; // 敵を削除
        }
      }
      return false;
    });
    print('Score: $score');
  }
}

class Enemy {
  Offset position;
  double speed;

  Enemy({required this.position, required this.speed});

  void move() {
    position = Offset(position.dx, position.dy + speed);
  }

  bool isHit(Offset start, Offset end) {
    // 敵の位置が線の範囲内にあるかチェック
    double distance = pointToLineDistance(position, start, end);
    return distance < 20; // 衝突判定の距離
  }

  double pointToLineDistance(Offset point, Offset start, Offset end) {
    final double A = point.dy - start.dy;
    final double B = start.dx - end.dx;
    final double C = start.dx * end.dy - start.dy * end.dx;
    return (A * B + C).abs() / sqrt(A * A + B * B);
  }
}

class LinePainter extends CustomPainter {
  final List<Offset?> points;
  final List<Enemy> enemies;

  LinePainter(this.points, this.enemies);

  @override
  void paint(Canvas canvas, Size size) {
    // 線を描画
    if (points.isNotEmpty) {
      final paint = Paint()
        ..color = Colors.blue
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 5.0;

      for (int i = 0; i < points.length - 1; i++) {
        if (points[i] != null && points[i + 1] != null) {
          canvas.drawLine(points[i]!, points[i + 1]!, paint);
        }
      }
    }

    // 敵を描画
    final enemyPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    for (var enemy in enemies) {
      canvas.drawCircle(enemy.position, 15, enemyPaint);
      enemy.move(); // 敵を移動させる
      // 画面外に出た敵を削除
      if (enemy.position.dy > size.height) {
        enemies.remove(enemy);
        break;
      }
    }
  }

  @override
  bool shouldRepaint(LinePainter oldDelegate) {
    return oldDelegate.points != points || oldDelegate.enemies != enemies;
  }
}
