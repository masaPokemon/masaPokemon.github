import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'リアルタイムタイピングゲーム',
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
  late String gameId;
  late String playerId;
  String targetWord = '';
  int score = 0;
  int timeRemaining = 30;
  String gameStatus = 'waiting'; // waiting, started, finished

  @override
  void initState() {
    super.initState();
    gameId = "pokemon";  // 実際にはサーバーから取得する
    var random = math.Random();
    playerId = random.nextInt(10000000000000);    // 実際には認証情報を基に決定する

    _gameRef = FirebaseDatabase.instance.ref().child('games').child(gameId);
    
    // ゲーム開始前の待機状態
    _gameRef.child('gameStatus').onValue.listen((event) {
      final status = event.snapshot.value;
      if (status != null && status != gameStatus) {
        setState(() {
          gameStatus = status;
        });
        if (status == 'started') {
          _startTimer();
        }
      }
    });

    // プレイヤーのスコアとターゲットワードの更新をリスン
    _gameRef.child('players').child(playerId).onValue.listen((event) {
      final playerData = event.snapshot.value;
      if (playerData != null) {
        setState(() {
          targetWord = playerData['currentWord'] ?? '';
          score = playerData['score'] ?? 0;
        });
      }
    });
    
    // タイムカウントダウン
    _gameRef.child('timeRemaining').onValue.listen((event) {
      final time = event.snapshot.value;
      if (time != null) {
        setState(() {
          timeRemaining = time;
        });
      }
    });
  }

  void _startTimer() {
    Timer.periodic(Duration(seconds: 1), (timer) {
      if (timeRemaining <= 0) {
        timer.cancel();
        _endGame();
      } else {
        _gameRef.child('timeRemaining').set(timeRemaining - 1);
      }
    });
  }

  void _endGame() {
    _gameRef.child('gameStatus').set('finished');
  }

  void _onSubmit() {
    if (_controller.text == targetWord) {
      setState(() {
        score++;
        _controller.clear();
      });

      // スコアを更新
      _gameRef.child('players').child(playerId).child('score').set(score);

      // 次の単語を生成してセット
      _generateNewWord();
    } else {
      _controller.clear();
    }
  }

  void _generateNewWord() {
    final words = ["apple", "banana", "cherry", "date", "elderberry"];
    final randomWord = words[(words.length * (DateTime.now().millisecondsSinceEpoch % 1000) / 1000).floor()];
    _gameRef.child('players').child(playerId).child('currentWord').set(randomWord);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('リアルタイムタイピングゲーム')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('ターゲットワード: $targetWord', style: TextStyle(fontSize: 24)),
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
            SizedBox(height: 20),
            Text('残り時間: $timeRemaining', style: TextStyle(fontSize: 20)),
            if (gameStatus == 'waiting')
              Text('ゲームが開始されるのを待っています...', style: TextStyle(fontSize: 18)),
            if (gameStatus == 'finished')
              Text('ゲーム終了！', style: TextStyle(fontSize: 18)),
            if (gameStatus == 'started')
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
