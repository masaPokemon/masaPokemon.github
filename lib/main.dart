import 'package:flutter/material.dart';
import 'dart:ui' as ui;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Drawing Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DrawingScreen(),
    );
  }
}

class DrawingScreen extends StatefulWidget {
  @override
  _DrawingScreenState createState() => _DrawingScreenState();
}

class _DrawingScreenState extends State<DrawingScreen> {
  List<Offset?> points = [];
  List<Shape> shapes = [];
  List<Enemy> enemies = [];

  @override
  void initState() {
    super.initState();
    _spawnEnemies();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      points.add(details.localPosition);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      if (points.isNotEmpty) {
        // 線が描かれた場合、図形を生成
        shapes.add(Shape(points));
        points.add(null); // 線の終点
      }
    });
  }

  void _spawnEnemies() {
    // 敵を生成するロジック（例としてランダムに追加）
    for (int i = 0; i < 5; i++) {
      enemies.add(Enemy(Offset(100.0 * i, 50.0)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Drawing Game')),
      body: GestureDetector(
        onPanUpdate: _onPanUpdate,
        onPanEnd: _onPanEnd,
        child: Stack(
          children: [
            CustomPaint(
              painter: DrawingPainter(points, shapes, enemies),
              size: Size.infinite,
            ),
            // ここにUI要素を追加することも可能
          ],
        ),
      ),
    );
  }
}

class DrawingPainter extends CustomPainter {
  final List<Offset?> points;
  final List<Shape> shapes;
  final List<Enemy> enemies;

  DrawingPainter(this.points, this.shapes, this.enemies);

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.blue
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0;

    // 線を描く
    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }

    // 生成された図形を描く
    for (var shape in shapes) {
      shape.draw(canvas);
    }

    // 敵を描く
    for (var enemy in enemies) {
      enemy.draw(canvas);
    }
  }

  @override
  bool shouldRepaint(DrawingPainter oldDelegate) {
    return oldDelegate.points != points || oldDelegate.shapes != shapes || oldDelegate.enemies != enemies;
  }
}

class Shape {
  final List<Offset?> points;

  Shape(this.points);

  void draw(Canvas canvas) {
    var paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    // シンプルな図形（ここでは三角形を例に）
    if (points.length > 2) {
      Path path = Path();
      path.moveTo(points[0]!.dx, points[0]!.dy);
      for (int i = 1; i < points.length - 1; i++) {
        if (points[i] != null) {
          path.lineTo(points[i]!.dx, points[i]!.dy);
        }
      }
      path.close();
      canvas.drawPath(path, paint);
    }
  }
}

class Enemy {
  Offset position;

  Enemy(this.position);

  void draw(Canvas canvas) {
    var paint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.fill;

    // 敵を描く（例として円）
    canvas.drawCircle(position, 20, paint);
  }
}
