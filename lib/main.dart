import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(MyGameApp());
}

class MyGameApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shape Drawing Game',
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
  List<Shape> shapes = [];
  List<Enemy> enemies = [];
  int score = 0;

  void _addPoint(Offset point) {
    setState(() {
      points.add(point);
    });
  }

  void _generateShape() {
    if (points.isNotEmpty) {
      // 線から円を生成する例
      shapes.add(Shape(center: points.last!, radius: 20.0));
      points.clear(); // 描いた線をリセット
    }
  }

  void _spawnEnemy() {
    // 敵をランダムな位置に生成
    enemies.add(Enemy(position: Offset(Random().nextDouble() * 300, Random().nextDouble() * 600)));
  }

  void _checkCollisions() {
    for (var shape in shapes) {
      for (var enemy in enemies) {
        if (shape.isCollidingWith(enemy)) {
          setState(() {
            enemies.remove(enemy);
            shapes.remove(shape);
            score += 10; // スコア加算
          });
          break; // 一度のループで一つの敵のみを削除
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // 定期的に敵を生成
    Future.delayed(Duration(seconds: 2), () {
      _spawnEnemy();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shape Drawing Game'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(child: Text('Score: $score')),
          ),
        ],
      ),
      body: GestureDetector(
        onPanUpdate: (details) {
          _addPoint(details.localPosition);
        },
        onPanEnd: (details) {
          _generateShape(); // 線を描いた後に図形を生成
        },
        child: CustomPaint(
          painter: GamePainter(points, shapes, enemies),
          child: Container(),
        ),
      ),
    );
  }
}

class GamePainter extends CustomPainter {
  final List<Offset?> points;
  final List<Shape> shapes;
  final List<Enemy> enemies;

  GamePainter(this.points, this.shapes, this.enemies);

  @override
  void paint(Canvas canvas, Size size) {
    // 線を描く
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

    // 図形を描く
    final shapePaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.fill;

    for (var shape in shapes) {
      canvas.drawCircle(shape.center, shape.radius, shapePaint);
    }

    // 敵を描く
    final enemyPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    for (var enemy in enemies) {
      canvas.drawCircle(enemy.position, 20.0, enemyPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class Shape {
  Offset center;
  double radius;

  Shape({required this.center, required this.radius});

  bool isCollidingWith(Enemy enemy) {
    double distance = (center - enemy.position).distance;
    return distance < (radius + 20.0); // 敵の半径を20と仮定
  }
}

class Enemy {
  Offset position;

  Enemy({required this.position});
}
