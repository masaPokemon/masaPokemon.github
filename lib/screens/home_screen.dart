import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'package:quiz_app/screens/quiz_screen.dart';
import 'package:quiz_app/screens/ranking_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  User? _user;
  bool _isSignUp = false; // サインインかサインアップかを判別

  @override
  void initState() {
    super.initState();
    _authService.authStateChanges.listen((user) {
      setState(() {
        _user = user;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Quiz App')),
      body: Center(
        child: _user == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(labelText: 'Email'),
                  ),
                  TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(labelText: 'Password'),
                    obscureText: true,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      if (_isSignUp) {
                        // サインアップ
                        await _authService.createUserWithEmailPassword(
                          _emailController.text,
                          _passwordController.text,
                        );
                      } else {
                        // サインイン
                        await _authService.signInWithEmailPassword(
                          _emailController.text,
                          _passwordController.text,
                        );
                      }
                    },
                    child: Text(_isSignUp ? 'サインアップ' : 'サインイン'),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isSignUp = !_isSignUp;
                      });
                    },
                    child: Text(_isSignUp ? 'サインインに切り替え' : 'サインアップに切り替え'),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('ようこそ, ${_user?.email} さん'),
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => QuizScreen()),
                      );
                    },
                    child: Text('対戦開始'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RankingScreen()),
                      );
                    },
                    child: Text('ランキング'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await _authService.signOut();
                    },
                    child: Text('サインアウト'),
                  ),
                ],
              ),
      ),
    );
  }
}
