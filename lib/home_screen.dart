import 'package:flutter/material.dart';
import 'package:quiz_app/auth_service.dart';
import 'leaderboard_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  User? _user;
  
  // ログイン情報
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _signUpEmailController = TextEditingController();
  final _signUpPasswordController = TextEditingController();
  
  bool _isLoginMode = true;

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
            ? _isLoginMode
                ? _buildLoginForm()
                : _buildSignUpForm()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('ようこそ, ${_user!.email}!'),
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

  // ログインフォーム
  Widget _buildLoginForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: _emailController,
            decoration: InputDecoration(labelText: 'メールアドレス'),
          ),
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(labelText: 'パスワード'),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              final email = _emailController.text;
              final password = _passwordController.text;

              final user = await _authService.signInWithEmailPassword(email, password);
              if (user != null) {
                setState(() {
                  _user = user;
                });
              } else {
                // エラーハンドリング
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('ログイン失敗'),
                    content: Text('メールアドレスまたはパスワードが間違っています。'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('OK'),
                      ),
                    ],
                  ),
                );
              }
            },
            child: Text('ログイン'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _isLoginMode = false;
              });
            },
            child: Text('新規登録'),
          ),
        ],
      ),
    );
  }

  // 新規登録フォーム
  Widget _buildSignUpForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: _signUpEmailController,
            decoration: InputDecoration(labelText: 'メールアドレス'),
          ),
          TextField(
            controller: _signUpPasswordController,
            obscureText: true,
            decoration: InputDecoration(labelText: 'パスワード'),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              final email = _signUpEmailController.text;
              final password = _signUpPasswordController.text;

              final user = await _authService.signUpWithEmailPassword(email, password);
              if (user != null) {
                setState(() {
                  _user = user;
                  _isLoginMode = true; // 新規登録後、ログイン画面に戻る
                });
              } else {
                // エラーハンドリング
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('登録失敗'),
                    content: Text('登録中にエラーが発生しました。'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('OK'),
                      ),
                    ],
                  ),
                );
              }
            },
            child: Text('新規登録'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _isLoginMode = true;
              });
            },
            child: Text('ログイン画面に戻る'),
          ),
        ],
      ),
    );
  }
}
