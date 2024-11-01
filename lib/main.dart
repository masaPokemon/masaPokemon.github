import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '線で描くゲーム',
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
  Random random = Random();
  
  @override
  void initState() {
    super.initState();
    _spawnEnemies();
  }

  void _spawnEnemies() {
    for (int i = 0; i < 5; i++) {
      enemies.add(Enemy(
        position: Offset(random.nextDouble() * 300, random.nextDouble() * 600),
        size: 40,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('線で描くゲーム')),
      body: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            points.add(details.localPosition);
          });
        },
        onPanEnd: (details) {
          _generateShape();
          points.clear();
        },
        child: CustomPaint(
          painter: GamePainter(points, shapes, enemies),
          child: Container(),
        ),
      ),
    );
  }

  void _generateShape() {
    if (points.length > 5) {
      // ランダムに図形のタイプを選択
      ShapeType type = ShapeType.values[random.nextInt(ShapeType.values.length)];
      shapes.add(Shape(
        position: points.last!,
        type: type,
      ));
    }
    _checkCollisions();
  }

  void _checkCollisions() {
    for (var shape in shapes) {
      for (var enemy in enemies) {
        if ((shape.position - enemy.position).distance <= enemy.size) {
          enemies.remove(enemy);
          break;
        }
      }
    }
  }
}

class GamePainter extends CustomPainter {
  final List<Offset?> points;
  final List<Shape> shapes;
  final List<Enemy> enemies;

  GamePainter(this.points, this.shapes, this.enemies);

  @override
  void paint(Canvas canvas, Size size) {
    var linePaint = Paint()
      ..color = Colors.blue
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, linePaint);
      }
    }

    for (var shape in shapes) {
      Paint shapePaint;
      switch (shape.type) {
        case ShapeType.circle:
          shapePaint = Paint()..color = Colors.red;
          canvas.drawCircle(shape.position, 20, shapePaint);
          break;
        case ShapeType.square:
          shapePaint = Paint()..color = Colors.green;
          canvas.drawRect(Rect.fromCenter(center: shape.position, width: 40, height: 40), shapePaint);
          break;
        case ShapeType.star:
          shapePaint = Paint()..color = Colors.yellow;
          _drawStar(canvas, shape.position, 20, 10, 5, shapePaint);
          break;
      }
    }

    var enemyPaint = Paint()..color = Colors.black;

    for (var enemy in enemies) {
      canvas.drawCircle(enemy.position, enemy.size, enemyPaint);
    }
  }

  void _drawStar(Canvas canvas, Offset position, double outerRadius, double innerRadius, int points, Paint paint) {
    final path = Path();
    final angle = (pi * 2) / points;

    for (int i = 0; i < points; i++) {
      double outerX = position.dx + outerRadius * cos(i * angle);
      double outerY = position.dy + outerRadius * sin(i * angle);
      path.lineTo(outerX, outerY);

      double innerX = position.dx + innerRadius * cos(i * angle + angle / 2);
      double innerY = position.dy + innerRadius * sin(i * angle + angle / 2);
      path.lineTo(innerX, innerY);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class Shape {
  final Offset position;
  final ShapeType type;

  Shape({required this.position, required this.type});
}

enum ShapeType {
  circle,
  square,
  star,
}

class Enemy {
  final Offset position;
  final double size;

  Enemy({required this.position, required this.size});
}
