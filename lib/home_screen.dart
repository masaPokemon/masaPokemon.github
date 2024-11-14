import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quiz_app/auth_service.dart';
import 'leaderboard_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  User? _user;

  @override
  void initState() {
    super.initState();
    _checkUser();
  }

  // ユーザーがログインしているかチェック
  void _checkUser() {
    _authService._auth.onAuthStateChanged.listen((user) {
      setState(() {
        _user = user;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("クイズアプリ")),
      body: Center(
        child: _user == null
            ? ElevatedButton(
                onPressed: () async {
                  final user = await _authService.signInWithGoogle();
                  if (user != null) {
                    setState(() {
                      _user = user;
                    });
                  }
                },
                child: Text('Googleでログイン'),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('ようこそ, ${_user!.displayName}!'),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LeaderboardScreen()),
                      );
                    },
                    child: Text('ランキングを見る'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await _authService.signOut();
                      setState(() {
                        _user = null;
                      });
                    },
                    child: Text('ログアウト'),
                  ),
                ],
              ),
      ),
    );
  }
}
