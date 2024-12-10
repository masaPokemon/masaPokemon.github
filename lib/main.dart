import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'タイピングゲーム',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TypingGame(),
    );
  }
}

class TypingGame extends StatefulWidget {
  @override
  _TypingGameState createState() => _TypingGameState();
}

class _TypingGameState extends State<TypingGame> {
  final TextEditingController _controller = TextEditingController();
  late DatabaseReference _gameRef;
  String targetWord = '';
  String currentWord = '';
  int score = 0;

  @override
  void initState() {
    super.initState();
    _gameRef = FirebaseDatabase.instance.ref().child('game');
    
    // Realtime Databaseから単語を受け取る
    _gameRef.child('currentWord').onValue.listen((event) {
      final word = event.snapshot.value;
      setState(() {
        currentWord = word ?? '';
        targetWord = currentWord;
      });
    });
    
    // 新しい単語をセットする
    _gameRef.child('score').set(0); // スコアを初期化
  }

  void _onSubmit() {
    if (_controller.text == targetWord) {
      setState(() {
        score++;
        _controller.clear();
      });

      // スコア更新
      _gameRef.child('score').set(score);

      // 次の単語を生成
      _generateNewWord();
    } else {
      // ミスした場合
      _controller.clear();
    }
  }

  // 新しい単語を生成してデータベースに反映させる
  void _generateNewWord() {
    final words = ["apple", "banana", "cherry", "date", "elderberry"];
    final randomWord = words[(words.length * (DateTime.now().millisecondsSinceEpoch % 1000) / 1000).floor()];
    _gameRef.child('currentWord').set(randomWord);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('タイピングゲーム')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('タイピング: $targetWord', style: TextStyle(fontSize: 24)),
            SizedBox(height: 20),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'ここに入力',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (text) => _onSubmit(),
            ),
            SizedBox(height: 20),
            Text('スコア: $score', style: TextStyle(fontSize: 20)),
            ElevatedButton(
              onPressed: () => _onSubmit(),
              child: Text('送信'),
            ),
          ],
        ),
      ),
    );
  }
}
