import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  // Firebase初期化
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GamePage(),
    );
  }
}

class GamePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("PVP Action Game")),
      body: GameWidget(game: PvpGame()),
    );
  }
}

class PvpGame extends FlameGame {
  late PlayerComponent player1;
  late PlayerComponent player2;
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late String currentPlayerId;
  bool isPlayer1 = true;

  @override
  Future<void> onLoad() async {
    // プレイヤーIDを取得
    User? user = _auth.currentUser;
    if (user == null) {
      // ユーザーがサインインしていない場合、サインインする
      await _auth.signInAnonymously();
      user = _auth.currentUser;
    }
    currentPlayerId = user!.uid;

    // プレイヤーの作成
    player1 = PlayerComponent('player1.png', Vector2(100, 100));
    player2 = PlayerComponent('player2.png', Vector2(300, 100));

    add(player1);
    add(player2);

    // Firebaseのリスナーで他のプレイヤーの状態を監視
    _database.ref('players/$currentPlayerId').onValue.listen((event) {
      final data = Map<String, dynamic>.from(event.snapshot.value as Map);
      if (data['position'] != null) {
        player2.position = Vector2(data['position'][0], data['position'][1]);
      }
    });

    // プレイヤーの状態をFirebaseに保存
    _database.ref('players/$currentPlayerId').set({
      'position': [100, 100],
    });
  }

  @override
  void update(double dt) {
    super.update(dt);

    // プレイヤー1の動きの確認
    if (isPlayer1) {
      if (player1.position.x > size.x) {
        player1.position.x = size.x;
      }
      if (player1.position.x < 0) {
        player1.position.x = 0;
      }

      // プレイヤーの位置をFirebaseに同期
      _database.ref('players/$currentPlayerId').update({
        'position': [player1.position.x, player1.position.y],
      });
    }
  }

  // プレイヤーを移動させる処理
  @override
  void onTapDown(TapDownInfo info) {
    if (isPlayer1) {
      player1.position = info.localPosition;
    } else {
      player2.position = info.localPosition;
    }
  }
}

class PlayerComponent extends SpriteComponent {
  PlayerComponent(String imageName, Vector2 position)
      : super(size: Vector2(50, 50), position: position) {
    sprite = Sprite.load(imageName);
  }
}

