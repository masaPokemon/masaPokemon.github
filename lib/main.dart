import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameStateProvider(),
      child: MaterialApp(
        home: GameScreen(),
      ),
    );
  }
}

class GameStateProvider with ChangeNotifier {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // プレイヤーの位置、弾、敵の状態を保持
  Map<String, dynamic> playerState = {};
  List<Map<String, dynamic>> bullets = [];
  List<Map<String, dynamic>> enemies = [];

  // プレイヤーの位置を更新
  void updatePlayerPosition(String playerId, double x, double y) {
    firestore.collection('players').doc(playerId).update({
      'position': {'x': x, 'y': y},
    });
    playerState['position'] = {'x': x, 'y': y};
    notifyListeners();
  }

  // 弾を追加
  void addBullet(String playerId, double x, double y, double angle) {
    firestore.collection('bullets').add({
      'playerId': playerId,
      'position': {'x': x, 'y': y},
      'angle': angle,
    });
    bullets.add({'playerId': playerId, 'position': {'x': x, 'y': y}, 'angle': angle});
    notifyListeners();
  }

  // 敵を追加
  void addEnemy(String enemyId, double x, double y) {
    firestore.collection('enemies').add({
      'position': {'x': x, 'y': y},
      'health': 100, // 敵のHP
    });
    enemies.add({'id': enemyId, 'position': {'x': x, 'y': y}, 'health': 100});
    notifyListeners();
  }

  // ダメージを与える
  void applyDamage(String enemyId, int damage) {
    var enemyRef = firestore.collection('enemies').doc(enemyId);
    enemyRef.get().then((doc) {
      if (doc.exists) {
        int currentHealth = doc['health'];
        if (currentHealth > damage) {
          enemyRef.update({'health': currentHealth - damage});
        } else {
          enemyRef.update({'health': 0});
        }
      }
    });
  }

  // 弾が敵に当たったかをチェック
  void checkBulletCollisions() {
    for (var bullet in bullets) {
      for (var enemy in enemies) {
        double bulletX = bullet['position']['x'];
        double bulletY = bullet['position']['y'];
        double enemyX = enemy['position']['x'];
        double enemyY = enemy['position']['y'];

        // 衝突判定（簡単な距離で判定）
        double distance = ((bulletX - enemyX).abs() + (bulletY - enemyY).abs());
        if (distance < 20) { // 20は衝突判定の距離
          applyDamage(enemy['id'], 20); // ダメージを与える（20ダメージ）
        }
      }
    }
  }
}

class GameScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // プレイヤーを表示
          Player(playerId: 'player1'),

          // 敵を表示
          ...context.watch<GameStateProvider>().enemies.map((enemy) {
            return Positioned(
              left: enemy['position']['x'],
              top: enemy['position']['y'],
              child: Enemy(enemyId: enemy['id']),
            );
          }).toList(),

          // 弾を表示
          ...context.watch<GameStateProvider>().bullets.map((bullet) {
            return Positioned(
              left: bullet['position']['x'],
              top: bullet['position']['y'],
              child: Bullet(),
            );
          }).toList(),
        ],
      ),
    );
  }
}

class Player extends StatelessWidget {
  final String playerId;
  Player({required this.playerId});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        double newX = details.localPosition.dx;
        double newY = details.localPosition.dy;
        // Firebaseに位置更新
        context.read<GameStateProvider>().updatePlayerPosition(playerId, newX, newY);
      },
      onTap: () {
        // 弾を発射
        context.read<GameStateProvider>().addBullet(playerId, 100, 100, 0);
      },
      child: Container(
        width: 50,
        height: 50,
        color: Colors.blue,
      ),
    );
  }
}

class Enemy extends StatelessWidget {
  final String enemyId;
  Enemy({required this.enemyId});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      color: Colors.red,
    );
  }
}

class Bullet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      color: Colors.black,
    );
  }
}
