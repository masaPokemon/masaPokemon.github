import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'クイズアプリ',
      home: HomeScreen(),
    );
  }
}

class Quiz {
  final String id;
  final String question;
  final List<String> options;
  final String answer;

  Quiz({required this.id, required this.question, required this.options, required this.answer});

  factory Quiz.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Quiz(
      id: doc.id,
      question: data['question'] ?? '',
      options: List<String>.from(data['options'] ?? []),
      answer: data['answer'] ?? '',
    );
  }
}

class QuizScreen extends StatefulWidget {
  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<Quiz> quizzes = [];
  int currentQuizIndex = 0;
  int score = 0;

  @override
  void initState() {
    super.initState();
    fetchQuizzes();
  }

  Future<void> fetchQuizzes() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('quizzes').get();
    quizzes = snapshot.docs.map((doc) => Quiz.fromFirestore(doc)).toList();
    setState(() {});
  }

  void checkAnswer(String selectedAnswer) {
    if (selectedAnswer == quizzes[currentQuizIndex].answer) {
      score++;
    }
    if (currentQuizIndex < quizzes.length - 1) {
      setState(() {
        currentQuizIndex++;
      });
    } else {
      // 結果を保存して次の画面に遷移
      Navigator.push(context, MaterialPageRoute(builder: (context) => ResultScreen(score: score)));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (quizzes.isEmpty) return Center(child: CircularProgressIndicator());
    
    return Scaffold(
      appBar: AppBar(title: Text('クイズ')),
      body: Column(
        children: [
          Text(quizzes[currentQuizIndex].question),
          ...quizzes[currentQuizIndex].options.map((option) {
            return ElevatedButton(
              onPressed: () => checkAnswer(option),
              child: Text(option),
            );
          }).toList(),
        ],
      ),
    );
  }
}

class ResultScreen extends StatelessWidget {
  final int score;
  late TextEditingController _controller = TextEditingController();
  late username = "";

  ResultScreen({required this.score});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('結果')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('あなたのスコア: $score'),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Enter your name',
                border: OutlineInputBorder(),
              ),
              onChanged: (text) {
                username = text;
              },
            ),
            ElevatedButton(
              onPressed: () {
                saveScore(username, score)
              },
              child: Text('ランキングに登録'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: Text('ホームに戻る'),
            ),
          ],
        ),
      ),
    );
  }
}

class RankingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ランキング')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('rankings').orderBy('score', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();
          
          var rankings = snapshot.data!.docs.map((doc) => {'name': doc['name'], 'score': doc['score']}).toList();

          return ListView.builder(
            itemCount: rankings.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text('${rankings[index]['name']}'),
                trailing: Text('${rankings[index]['score']}'),
              );
            },
          );
        },
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('クイズアプリ')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => QuizScreen()));
              },
              child: Text('クイズを始める'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => RankingScreen()));
              },
              child: Text('ランキングを見る'),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> saveScore(String userName, int score) async {
  await FirebaseFirestore.instance.collection('rankings').add({
    'name': userName,
    'score': score,
  });
}
