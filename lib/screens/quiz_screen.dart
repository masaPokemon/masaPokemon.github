import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class QuizScreen extends StatefulWidget {
  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final DatabaseReference _db = FirebaseDatabase.instance.ref().child('questions');
  late List<Question> _questions;
  int _currentIndex = 0;
  int _score = 0;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    DataSnapshot snapshot = await _db.once(DatabaseEventType.value);
    var data = snapshot.value;
    setState(() {
      _questions = List<Question>.from(data.map((item) => Question.fromMap(item)));
    });
  }

  void _nextQuestion(String answer) {
    if (_questions[_currentIndex].correctAnswer == answer) {
      setState(() {
        _score++;
      });
    }

    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
      });
    } else {
      Navigator.pop(context);
      // 結果を表示
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final question = _questions[_currentIndex];
    return Scaffold(
      appBar: AppBar(title: Text('クイズ')),
      body: Column(
        children: [
          Text('問題: ${question.text}'),
          ...question.options.map((option) => ElevatedButton(
                onPressed: () => _nextQuestion(option),
                child: Text(option),
              )),
        ],
      ),
    );
  }
}

class Question {
  final String text;
  final List<String> options;
  final String correctAnswer;

  Question({required this.text, required this.options, required this.correctAnswer});

  factory Question.fromMap(Map<dynamic, dynamic> map) {
    return Question(
      text: map['question'],
      options: List<String>.from(map['options']),
      correctAnswer: map['correctAnswer'],
    );
  }
}
