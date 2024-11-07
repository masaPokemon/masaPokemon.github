import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(GameApp());
}

class GameApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Online Shooter Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  late String playerId;
  double playerX = 100.0, playerY = 100.0;
  double bulletX = 0.0, bulletY = 0.0;
  bool isFiring = false;
  final FirestoreService firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: 16))
      ..addListener(_gameLoop);
    _controller.repeat();

    _initializePlayer();
  }

  void _initializePlayer() async {
    User? user = await signInAnonymously();
    if (user != null) {
      setState(() {
        playerId = user.uid;
      });
      firestoreService.addPlayer(playerId, playerX, playerY);
    }
  }

  void _gameLoop() {
    setState(() {
      if (isFiring) {
        bulletY -= 5;
      }
    });
    firestoreService.updatePlayerPosition(playerId, playerX, playerY);
    firestoreService.updateBulletPosition(playerId, bulletX, bulletY);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CustomPaint(
            painter: GamePainter(playerX, playerY, bulletX, bulletY),
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  playerX = details.localPosition.dx;
                  playerY = details.localPosition.dy;
                });
              },
              onTap: () {
                setState(() {
                  isFiring = true;
                  bulletX = playerX;
                  bulletY = playerY;
                });
              },
              child: Container(color: Colors.white),
            ),
          ),
          Positioned(
            top: 20,
            left: 20,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Exit Game"),
            ),
          ),
        ],
      ),
    );
  }
}

class GamePainter extends CustomPainter {
  final double playerX, playerY, bulletX, bulletY;

  GamePainter(this.playerX, this.playerY, this.bulletX, this.bulletY);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint playerPaint = Paint()..color = Colors.blue;
    final Paint bulletPaint = Paint()..color = Colors.red;

    // Draw player
    canvas.drawCircle(Offset(playerX, playerY), 20, playerPaint);

    // Draw bullet
    if (bulletY > 0) {
      canvas.drawCircle(Offset(bulletX, bulletY), 5, bulletPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add player to Firestore
  Future<void> addPlayer(String playerId, double x, double y) async {
    await _firestore.collection('players').doc(playerId).set({
      'position': {'x': x, 'y': y},
    });
  }

  // Update player position
  Future<void> updatePlayerPosition(String playerId, double x, double y) async {
    await _firestore.collection('players').doc(playerId).update({
      'position': {'x': x, 'y': y},
    });
  }

  // Update bullet position
  Future<void> updateBulletPosition(String playerId, double x, double y) async {
    await _firestore.collection('bullets').doc(playerId).set({
      'position': {'x': x, 'y': y},
    });
  }

  // Get player position stream
  Stream<DocumentSnapshot> getPlayerPosition(String playerId) {
    return _firestore.collection('players').doc(playerId).snapshots();
  }

  // Get bullet position stream
  Stream<DocumentSnapshot> getBulletPosition(String playerId) {
    return _firestore.collection('bullets').doc(playerId).snapshots();
  }
}

Future<User?> signInAnonymously() async {
  UserCredential userCredential = await FirebaseAuth.instance.signInAnonymously();
  return userCredential.user;
}

class GameLobbyScreen extends StatefulWidget {
  @override
  _GameLobbyScreenState createState() => _GameLobbyScreenState();
}

class _GameLobbyScreenState extends State<GameLobbyScreen> {
  final TextEditingController roomController = TextEditingController();

  void createRoom() async {
    final roomRef = FirebaseFirestore.instance.collection('rooms').doc();
    await roomRef.set({
      'host': FirebaseAuth.instance.currentUser?.uid,
      'players': [],
      'status': 'waiting', // ゲームの状態（待機中、進行中など）
    });
  }

  void joinRoom(String roomId) async {
    final roomRef = FirebaseFirestore.instance.collection('rooms').doc(roomId);
    await roomRef.update({
      'players': FieldValue.arrayUnion([FirebaseAuth.instance.currentUser?.uid]),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ゲームロビー')),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: createRoom,
            child: Text('新しい部屋を作成'),
          ),
          TextField(
            controller: roomController,
            decoration: InputDecoration(labelText: '部屋IDを入力'),
          ),
          ElevatedButton(
            onPressed: () => joinRoom(roomController.text),
            child: Text('部屋に参加'),
          ),
        ],
      ),
    );
  }
}

class GameScreen extends StatefulWidget {
  final String roomId;

  GameScreen({required this.roomId});

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late DocumentReference roomRef;

  @override
  void initState() {
    super.initState();
    roomRef = FirebaseFirestore.instance.collection('rooms').doc(widget.roomId);
  }

  void startGame() async {
    // ここでゲームを開始するロジックを実装
    await roomRef.update({'status': 'playing'});
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: roomRef.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasData) {
          final roomData = snapshot.data!;
          final players = List.from(roomData['players']);
          final status = roomData['status'];

          return Scaffold(
            appBar: AppBar(title: Text('ゲーム: ${widget.roomId}')),
            body: Column(
              children: [
                Text('ゲーム状態: $status'),
                Text('参加者: ${players.join(', ')}'),
                if (status == 'waiting')
                  ElevatedButton(
                    onPressed: startGame,
                    child: Text('ゲームを開始'),
                  ),
              ],
            ),
          );
        }

        return Center(child: Text('エラーが発生しました'));
      },
    );
  }
}
