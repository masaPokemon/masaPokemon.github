import 'dart:ui';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flame/gesture.dart';
import 'package:flame/components.dart';

void main() {
  runApp(GameWidget(game: ShapeGame()));
}

class ShapeGame extends FlameGame with PanDetector {
  List<Offset?> points = [];
  List<Shape> shapes = [];
  List<Enemy> enemies = [];

  @override
  Future<void> onLoad() async {
    spawnEnemies();
  }

  void spawnEnemies() {
    for (int i = 0; i < 5; i++) {
      enemies.add(Enemy(position: Offset(100.0 * (i + 1), 50.0)));
    }
  }

  @override
  void onPanStart(DragStartInfo info) {
    points.add(info.globalPosition);
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    points.add(info.globalPosition);
  }

  @override
  void onPanEnd(DragEndInfo info) {
    if (points.isNotEmpty) {
      convertToShape();
      points.clear();
    }
  }

  void convertToShape() {
    final shape = Shape(points);
    shapes.add(shape);
    points.clear();
  }

  @override
  void update(double dt) {
    for (var enemy in enemies) {
      enemy.update(dt);
    }
    
    // 衝突判定
    for (var shape in shapes) {
      for (var enemy in enemies) {
        if (shape.checkCollision(enemy.position)) {
          // 衝突処理: 敵を削除
          enemies.remove(enemy);
          break; // ループを抜ける
        }
      }
    }
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0;

    // 描いた線を描画
    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }

    // 図形を描画
    for (var shape in shapes) {
      shape.render(canvas);
    }

    // 敵を描画
    for (var enemy in enemies) {
      enemy.render(canvas);
    }
  }
}

class Shape {
  final List<Offset?> points;

  Shape(this.points);

  void render(Canvas canvas) {
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    if (points.isNotEmpty) {
      final path = Path()..moveTo(points[0]!.dx, points[0]!.dy);
      for (var point in points) {
        if (point != null) {
          path.lineTo(point.dx, point.dy);
        }
      }
      path.close();
      canvas.drawPath(path, paint);
    }
  }

  // 衝突判定メソッド
  bool checkCollision(Offset enemyPosition) {
    // 簡単な衝突判定：図形の中心から敵までの距離を測る
    final path = Path()..moveTo(points[0]!.dx, points[0]!.dy);
    for (var point in points) {
      if (point != null) {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();

    final bool contains = path.contains(enemyPosition);
    return contains;
  }
}

class Enemy {
  Offset position;

  Enemy({required this.position});

  void update(double dt) {
    position = Offset(position.dx, position.dy + 20 * dt); // 簡単な移動
  }

  void render(Canvas canvas) {
    final paint = Paint()..color = Colors.red;
    canvas.drawCircle(position, 10.0, paint);
  }
}
