import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class RankingScreen extends StatefulWidget {
  @override
  _RankingScreenState createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  final DatabaseReference _db = FirebaseDatabase.instance.ref().child('scores');
  late Stream<List<Player>> _rankingStream;

  @override
  void initState() {
    super.initState();
    _rankingStream = _db.orderByChild('score').onValue.map((event) {
      var players = <Player>[];
      var data = event.snapshot.value as Map<dynamic, dynamic>;
      data.forEach((key, value) {
        players.add(Player.fromMap(value));
      });
      return players;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ランキング')),
      body: StreamBuilder<List<Player>>(
        stream: _rankingStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final players = snapshot.data!;
          return ListView.builder(
            itemCount: players.length,
            itemBuilder: (context, index) {
              final player = players[index];
              return ListTile(
                title: Text(player.name),
                trailing: Text(player.score.toString()),
              );
            },
          );
        },
      ),
    );
  }
}

class Player {
  final String name;
  final int score;

  Player({required this.name, required this.score});

  factory Player.fromMap(Map<dynamic, dynamic> map) {
    return Player(
      name: map['name'],
      score: map['score'],
    );
  }
}
