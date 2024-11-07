import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Online Gunfight Game',
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
  late FirebaseAuth _auth;
  late FirebaseFirestore _firestore;
  late String _userId;
  double playerX = 100, playerY = 100; // Player's position
  double bulletX = -1, bulletY = -1; // Bullet's position (off-screen initially)

  @override
  void initState() {
    super.initState();
    _auth = FirebaseAuth.instance;
    _firestore = FirebaseFirestore.instance;
    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: 16))
      ..addListener(_gameLoop);
    _controller.repeat();
    _signInAnonymously();
  }

  // Sign-in anonymously to Firebase
  Future<void> _signInAnonymously() async {
    UserCredential userCredential = await _auth.signInAnonymously();
    setState(() {
      _userId = userCredential.user!.uid;
    });

    // Listen to the player's position in Firestore
    _firestore.collection('players').doc(_userId).snapshots().listen((snapshot) {
      if (snapshot.exists) {
        setState(() {
          playerX = snapshot['position']['x'].toDouble();
          playerY = snapshot['position']['y'].toDouble();
        });
      }
    });

    // Initialize the player's position in Firestore
    _firestore.collection('players').doc(_userId).set({
      'position': {'x': playerX, 'y': playerY},
    });
  }

  // Game loop
  void _gameLoop() {
    setState(() {
      // Update the bullet's position
      if (bulletY >= 0) {
        bulletY -= 5; // Move bullet upwards
      }
    });
    _syncPlayerPosition();
  }

  // Sync player position to Firebase
  Future<void> _syncPlayerPosition() async {
    if (_userId.isNotEmpty) {
      await _firestore.collection('players').doc(_userId).update({
        'position': {'x': playerX, 'y': playerY},
      });
    }
  }

  // Fire a bullet
  void _fireBullet() {
    setState(() {
      bulletX = playerX;
      bulletY = playerY;
    });
  }

  // Move player on screen
  void _movePlayer(Offset offset) {
    setState(() {
      playerX += offset.dx;
      playerY += offset.dy;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Online Gunfight Game"),
      ),
      body: Stack(
        children: [
          // Draw background
          Positioned.fill(
            child: Container(
              color: Colors.green,
            ),
          ),
          // Draw player
          Positioned(
            left: playerX,
            top: playerY,
            child: Icon(
              Icons.person,
              size: 50,
              color: Colors.blue,
            ),
          ),
          // Draw bullet
          if (bulletY >= 0)
            Positioned(
              left: bulletX,
              top: bulletY,
              child: Icon(
                Icons.fiber_manual_record,
                size: 10,
                color: Colors.red,
              ),
            ),
          // Controls
          Positioned(
            bottom: 20,
            left: 20,
            child: ElevatedButton(
              onPressed: () {
                _movePlayer(Offset(0, -10)); // Move up
              },
              child: Text("Up"),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 100,
            child: ElevatedButton(
              onPressed: () {
                _movePlayer(Offset(-10, 0)); // Move left
              },
              child: Text("Left"),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 180,
            child: ElevatedButton(
              onPressed: () {
                _movePlayer(Offset(10, 0)); // Move right
              },
              child: Text("Right"),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 260,
            child: ElevatedButton(
              onPressed: () {
                _movePlayer(Offset(0, 10)); // Move down
              },
              child: Text("Down"),
            ),
          ),
          Positioned(
            bottom: 100,
            left: 150,
            child: ElevatedButton(
              onPressed: _fireBullet, // Fire bullet
              child: Text("Fire"),
            ),
          ),
        ],
      ),
    );
  }
}
