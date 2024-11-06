import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'game_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _signOut(BuildContext context) async {
    await _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PvP人狼ゲーム'),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () => _signOut(context),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // ゲームルームを作成
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GameScreen(roomId: 'newRoomId')),
                );
              },
              child: Text("新しいゲームルームを作成"),
            ),
            ElevatedButton(
              onPressed: () {
                // ゲームルームに参加
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GameScreen(roomId: 'sampleRoomId')),
                );
              },
              child: Text("ゲームルームに参加"),
            ),
          ],
        ),
      ),
    );
  }
}
