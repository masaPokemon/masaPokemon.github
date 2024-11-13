import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);  // Firebaseの初期化
  runApp(GameWidget(game: EscapeGame()));
}

class EscapeGame extends FlameGame with KeyboardEvents {
  late Player player;
  late List<Enemy> enemies;
  late DatabaseReference playerRef;  // プレイヤーの位置をFirebaseに保存するための参照
  late DatabaseReference enemiesRef; // ハンター（敵）の位置をFirebaseで管理

  @override
  Future<void> onLoad() async {
    player = Player()..position = Vector2(100, 100);
    add(player);

    // Firebase Realtime Databaseの参照を取得
    playerRef = FirebaseDatabase.instance.ref().child('players').child('player1');
    enemiesRef = FirebaseDatabase.instance.ref().child('enemies');

    // プレイヤー位置をFirebaseに同期
    playerRef.onValue.listen((event) {
      final playerData = event.snapshot.value;
      if (playerData != null) {
        final playerPos = playerData as Map<dynamic, dynamic>;
        player.position = Vector2(playerPos['x'], playerPos['y']);
      }
    });

    // 初期のハンター数を設定
    summonEnemies(3);
  }

  // 敵を召喚する関数
  void summonEnemies(int numberOfHunters) {
    for (int i = 0; i < numberOfHunters * 3; i++) {
      var enemy = Enemy()..position = Vector2(300 + i * 50.0, 100.0);
      add(enemy);
      // Firebaseにハンターの位置情報を保存
      enemiesRef.child('hunter$i').set({
        'x': enemy.position.x,
        'y': enemy.position.y,
      });
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    // プレイヤーが移動した場合、その位置をFirebaseに送信
    playerRef.update({
      'x': player.position.x,
      'y': player.position.y,
    });

    // 他のプレイヤー（ハンター）の位置もFirebaseで更新
    enemiesRef.once().then((event) {
      final data = event.snapshot.value as Map?;
      if (data != null) {
        data.forEach((key, value) {
          final enemyData = value;
          var enemyPos = Vector2(enemyData['x'], enemyData['y']);
          // ここで敵の位置を更新する処理を実装
        });
      }
    });
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
  }

  @override
  void onKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        player.position.add(Vector2(0, -10));  // 上に移動
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        player.position.add(Vector2(0, 10));  // 下に移動
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        player.position.add(Vector2(-10, 0));  // 左に移動
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        player.position.add(Vector2(10, 0));  // 右に移動
      }
    }
  }
}

class Player extends SpriteComponent with HasGameRef {
  @override
  Future<void> onLoad() async {
    sprite = await gameRef.loadSprite('player.png');
    size = Vector2(50, 50);
  }

  @override
  void update(double dt) {
    super.update(dt);
  }
}

class Enemy extends SpriteComponent with HasGameRef {
  @override
  Future<void> onLoad() async {
    sprite = await gameRef.loadSprite('enemy.png');
    size = Vector2(50, 50);
  }

  @override
  void update(double dt) {
    super.update(dt);
  }
}
