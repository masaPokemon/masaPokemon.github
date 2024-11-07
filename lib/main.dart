import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

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
