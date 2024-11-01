import 'package:flutter/material.dart';
import 'dart:ui' as ui;

void main() {
  runApp(LineAttackGame());
}

class LineAttackGame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
  List<Offset?> enemies = [Offset(100, 100), Offset(200, 200)];
  
  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      points.add(details.localPosition);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    // 線を書いた後の処理（攻撃の判定など）
    for (var enemy in enemies) {
      if (_isLineIntersecting(points, enemy)) {
        // 敵が攻撃された場合の処理
        print('Enemy hit at ${enemy}');
      }
    }
    points.clear();
  }

  bool _isLineIntersecting(List<Offset?> line, Offset? enemy) {
    // 線と敵の当たり判定をここで実装
    // 簡単な例として、線の距離を計算して敵が近いかどうかを判定する
    if (line.isEmpty || enemy == null) return false;

    for (int i = 0; i < line.length - 1; i++) {
      if (_distanceToSegment(enemy, line[i]!, line[i + 1]!) < 20) {
        return true; // 敵が攻撃された
      }
    }
    return false;
  }

  double _distanceToSegment(Offset point, Offset start, Offset end) {
    final l2 = (end - start).distanceSquared;
    if (l2 == 0) return (point - start).distance; // startとendが同じ場合
    final t = ((point - start).dot(end - start)) / l2;
    if (t < 0) return (point - start).distance; // startが近い
    if (t > 1) return (point - end).distance; // endが近い
    final projection = start + (end - start) * t;
    return (point - projection).distance;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: CustomPaint(
        size: Size.infinite,
        painter: GamePainter(points, enemies),
      ),
    );
  }
}

class GamePainter extends CustomPainter {
  final List<Offset?> points;
  final List<Offset?> enemies;

  GamePainter(this.points, this.enemies);

  @override
  void paint(Canvas canvas, Size size) {
    final paintLine = Paint()
      ..color = Colors.blue
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5;

    final paintEnemy = Paint()
      ..color = Colors.red;

    // 線を描画
    for (int i = 0; i < points.length - 1; i++) {
      canvas.drawLine(points[i]!, points[i + 1]!, paintLine);
    }

    // 敵を描画
    for (var enemy in enemies) {
      canvas.drawCircle(enemy!, 10, paintEnemy);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
