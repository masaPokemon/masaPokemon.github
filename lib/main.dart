import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quiz App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: QuizHome(),
    );
  }
}

class QuizHome extends StatefulWidget {
  @override
  _QuizHomeState createState() => _QuizHomeState();
}

class _QuizHomeState extends State<QuizHome> {
  int score = 0;
  int wrongAttempts = 0;
  List<Question> questions = [];
  int currentQuestionIndex = 0;
  bool gameOver = false;

  @override
  void initState() {
    super.initState();
    fetchQuestions();
  }

  Future<void> fetchQuestions() async {
    var snapshot = await FirebaseFirestore.instance.collection('questions').get();
    questions = snapshot.docs.map((doc) {
      var data = doc.data();
      return Question(
        data['question'],
        List<String>.from(data['options']),
        data['answer'],
      );
    }).toList();
    setState(() {});
  }

  void answerQuestion(String answer) {
    if (answer == questions[currentQuestionIndex].answer) {
      score++;
    } else {
      wrongAttempts++;
      if (wrongAttempts >= 3) {
        setState(() {
          gameOver = true;
        });
        saveScore();
      }
    }
    setState(() {
      currentQuestionIndex++;
    });
  }

  Future<void> saveScore() async {
    // ここにユーザー名を入力するUIを追加することを検討してください
    String username = 'User'; // 例として固定のユーザー名
    await FirebaseFirestore.instance.collection('users').add({
      'username': username,
      'score': score,
    });
  }

  @override
  Widget build(BuildContext context) {
    if (gameOver) {
      return Scaffold(
        appBar: AppBar(title: Text('Game Over')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Your Score: $score'),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    score = 0;
                    wrongAttempts = 0;
                    currentQuestionIndex = 0;
                    gameOver = false;
                  });
                  fetchQuestions();
                },
                child: Text('Restart'),
              ),
            ],
          ),
        ),
      );
    }

    if (questions.isEmpty) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (currentQuestionIndex >= questions.length) {
      return Scaffold(
        appBar: AppBar(title: Text('Quiz Complete')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Your Score: $score'),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    score = 0;
                    wrongAttempts = 0;
                    currentQuestionIndex = 0;
                  });
                  fetchQuestions();
                },
                child: Text('Restart'),
              ),
            ],
          ),
        ),
      );
    }

    final currentQuestion = questions[currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(title: Text('Quiz')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(currentQuestion.question, style: TextStyle(fontSize: 24)),
          ...currentQuestion.options.map((option) {
            return ElevatedButton(
              onPressed: () => answerQuestion(option),
              child: Text(option),
            );
          }).toList(),
        ],
      ),
    );
  }
}

class Question {
  final String question;
  final List<String> options;
  final String answer;

  Question(this.question, this.options, this.answer);
}
