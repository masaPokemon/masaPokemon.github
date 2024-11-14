import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quiz_app/auth_service.dart';
import 'package:quiz_app/quiz_service.dart';
import 'leaderboard_screen.dart';
import 'quiz_screen.dart'; // クイズ画面のインポート

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  final QuizService _quizService = QuizService();
  
  User? _user;
  
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

  void _checkUser() {
    FirebaseAuth.instance
      .authStateChanges()
      .listen((User? user) {
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
            : _buildUserLoggedIn(),
      ),
    );
  }

  // ユーザーがログインしている場合の画面
  Widget _buildUserLoggedIn() {
    return Column(
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
        // マッチング開始ボタン
        ElevatedButton(
          onPressed: _startMatch,
          child: Text('マッチングを開始'),
        ),
      ],
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

  // マッチングを開始する処理
  void _startMatch() async {
    if (_user != null) {
      // Firebase Firestoreに対戦を開始する情報を送信（マッチング用）
      final matchId = await _quizService.startMatch(_user!.uid);

      // マッチングが成功したらクイズ画面に遷移
      if (matchId != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QuizScreen(matchId: matchId),
          ),
        );
      } else {
        // マッチング失敗の場合の処理
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('マッチング失敗'),
            content: Text('対戦相手が見つかりませんでした。'),
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
    }
  }
}
