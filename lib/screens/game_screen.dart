import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GameScreen extends StatefulWidget {
  final String roomId;

  GameScreen({required this.roomId});

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late Stream<DocumentSnapshot> _gameStream;

  @override
  void initState() {
    super.initState();
    _gameStream = FirebaseFirestore.instance
        .collection('gameRooms')
        .doc(widget.roomId)
        .snapshots();
  }

  void startGame() {
    FirebaseFirestore.instance.collection('gameRooms').doc(widget.roomId).update({
      'gameState': 'playing',
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("ゲーム進行中")),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _gameStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text("ゲームルームが見つかりません"));
          }

          final gameRoom = snapshot.data!.data() as Map<String, dynamic>;

          return Column(
            children: [
              Text("ゲーム状態: ${gameRoom['gameState']}"),
              ElevatedButton(
                onPressed: startGame,
                child: Text("ゲーム開始"),
              ),
              Text("参加者: ${gameRoom['players'].join(", ")}")
            ],
          );
        },
      ),
    );
  }
}
