import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:async';
import 'dart:math';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  options: DefaultFirebaseOptions.currentPlatform,
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Number Memory Game',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: NumberMemoryGame(),
    );
  }
}

class NumberMemoryGame extends StatefulWidget {
  @override
  _NumberMemoryGameState createState() => _NumberMemoryGameState();
}

class _NumberMemoryGameState extends State<NumberMemoryGame> {
  String displayedNumber = '';
  final TextEditingController inputController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  int wrongAttempts = 0;
  int score = 0;
  bool isGameOver = false;
  bool isUsernameEntered = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();
  }

  void startGame() {
    wrongAttempts = 0;
    score = 0;
    isGameOver = false;
    generateNumber();
  }

  void generateNumber() {
    int number = Random().nextInt(10000); // 0-9999のランダムな数字を生成
    displayedNumber = number.toString().padLeft(4, '0'); // 4桁に揃える
    setState(() {});

    // 5秒後にユーザー入力を促す
    timer = Timer(Duration(seconds: 5), () {
      setState(() {
        displayedNumber = ''; // 数字を隠す
      });
    });
  }

  void checkAnswer() {
    if (inputController.text == displayedNumber) {
      score++;
      generateNumber();
    } else {
      wrongAttempts++;
      if (wrongAttempts >= 3) {
        setState(() {
          isGameOver = true;
          saveScore();
        });
      } else {
        generateNumber();
      }
    }
    inputController.clear();
  }

  Future<void> saveScore() async {
    if (usernameController.text.isNotEmpty) {
      await FirebaseFirestore.instance.collection('scores').add({
        'username': usernameController.text,
        'score': score,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Number Memory Game')),
      body: Center(
        child: isGameOver
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Game Over! Your Score: $score', style: TextStyle(fontSize: 24)),
                  ElevatedButton(
                    onPressed: startGame,
                    child: Text('Restart'),
                  ),
                ],
              )
            : !isUsernameEntered
                ? Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Enter your username:', style: TextStyle(fontSize: 20)),
                        TextField(
                          controller: usernameController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Username',
                          ),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              isUsernameEntered = true;
                            });
                            startGame();
                          },
                          child: Text('Start Game'),
                        ),
                      ],
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (displayedNumber.isNotEmpty)
                        Text(
                          displayedNumber,
                          style: TextStyle(fontSize: 48),
                        ),
                      if (displayedNumber.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: TextField(
                            controller: inputController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Enter the number',
                            ),
                            keyboardType: TextInputType.number,
                            onSubmitted: (value) => checkAnswer(),
                          ),
                        ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: checkAnswer,
                        child: Text('Submit'),
                      ),
                    ],
                  ),
      ),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    inputController.dispose();
    usernameController.dispose();
    super.dispose();
  }
}
