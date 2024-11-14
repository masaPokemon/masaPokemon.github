import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quiz_app/quiz_service.dart';

class QuizScreen extends StatefulWidget {
  final String matchId;

  QuizScreen({required this.matchId});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final QuizService _quizService = QuizService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Map<String, dynamic>> _questions = [];
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _isAnswerSelected = false;
  String? _selectedAnswer;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  // 問題のリストをFirestoreから取得
  Future<void> _loadQuestions() async {
    try {
      // Firestoreからクイズ問題を取得
      final querySnapshot = await FirebaseFirestore.instance.collection('quiz_questions').get();
      final questions = querySnapshot.docs.map((doc) {
        return doc.data();
      }).toList();

      setState(() {
        _questions = List<Map<String, dynamic>>.from(questions);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('クイズ問題の読み込みエラー: $e');
    }
  }

  // ユーザーが選んだ答えを確認し、スコアを更新
  void _checkAnswer(String selectedAnswer) {
    if (_isAnswerSelected) return;

    setState(() {
      _isAnswerSelected = true;
    });

    final correctAnswer = _questions[_currentQuestionIndex]['correct_answer'];

    // 答えが正しいかどうかを確認
    if (selectedAnswer == correctAnswer) {
      setState(() {
        _score++;
      });
    }

    // 少し遅延を入れて次の問題に進む
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        _currentQuestionIndex++;
        _isAnswerSelected = false;
        _selectedAnswer = null;
      });

      if (_currentQuestionIndex >= _questions.length) {
        // クイズ終了
        _endQuiz();
      }
    });
  }

  // クイズ終了時の処理
  void _endQuiz() async {
    final user = _auth.currentUser;
    if (user != null) {
      // スコアをFirestoreに保存
      await _quizService.submitScore(widget.matchId, user.uid, _score);
    }

    // 結果画面に遷移
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(score: _score, totalQuestions: _questions.length),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("クイズ対戦"),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _questions.isEmpty
              ? Center(child: Text("問題がありません"))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "問題 ${_currentQuestionIndex + 1} / ${_questions.length}",
                        style: TextStyle(fontSize: 18),
                      ),
                      SizedBox(height: 20),
                      Text(
                        _questions[_currentQuestionIndex]['question'],
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 20),
                      ..._questions[_currentQuestionIndex]['options']
                          .map<Widget>((option) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: _selectedAnswer == option
                                  ? Colors.blueAccent
                                  : null,
                            ),
                            onPressed: () {
                              setState(() {
                                _selectedAnswer = option;
                              });
                              _checkAnswer(option);
                            },
                            child: Text(option),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
    );
  }
}

// 結果画面
class ResultScreen extends StatelessWidget {
  final int score;
  final int totalQuestions;

  ResultScreen({required this.score, required this.totalQuestions});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("結果")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "あなたのスコア: $score / $totalQuestions",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // ホームに戻る
                Navigator.popUntil(context, ModalRoute.withName('/'));
              },
              child: Text('ホームに戻る'),
            ),
          ],
        ),
      ),
    );
  }
}
