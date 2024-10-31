import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:async';
import 'dart:math';
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
  String displayedNumber2 = '';
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
    int number = Random().nextInt(10000000); // 0-999999のランダムな数字を生成
    displayedNumber = number.toString().padLeft(7, '0'); // 4桁に揃える
    displayedNumber2 = number.toString().padLeft(7, '0'); // 4桁に揃える
    setState(() {});

    // 5秒後にユーザー入力を促す
    timer = Timer(Duration(seconds: 2), () {
      setState(() {
        displayedNumber = ''; // 数字を隠す
      });
    });
  }

  void checkAnswer() {
    if (inputController.text == displayedNumber2) {
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

  Future<List<Map<String, dynamic>>> fetchScores() async {
    var snapshot = await FirebaseFirestore.instance
        .collection('scores')
        .orderBy('score', descending: true)
        .limit(10)
        .get();
    return snapshot.docs.map((doc) {
      var data = doc.data();
      return {
        'username': data['username'],
        'score': data['score'],
      };
    }).toList();
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
                  SizedBox(height: 20),
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: fetchScores(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Text('No scores available.');
                      }
                      return Expanded(
                        child: ListView.builder(
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            final scoreEntry = snapshot.data![index];
                            return ListTile(
                              title: Text(scoreEntry['username']),
                              trailing: Text(scoreEntry['score'].toString()),
                            );
                          },
                        ),
                      );
                    },
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
