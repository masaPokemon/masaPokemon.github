import 'package:flutter/material.dart';
import 'game.dart';
import 'models/player.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PvP Werewolf Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final Game game = Game();
  final TextEditingController _controller = TextEditingController();

  void _addPlayer() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        game.addPlayer(_controller.text);
        _controller.clear();
      });
    }
  }

  void _vote(Player player) {
    setState(() {
      game.vote(player);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PvP Werewolf Game'),
      ),
      body: Column(
        children: [
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: 'Enter player name',
              suffixIcon: IconButton(
                icon: Icon(Icons.add),
                onPressed: _addPlayer,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: game.players.length,
              itemBuilder: (context, index) {
                Player player = game.players[index];
                return ListTile(
                  title: Text('${player.name} (${player.role})'),
                  subtitle: Text(player.isAlive ? 'Alive' : 'Dead'),
                  onTap: player.isAlive ? () => _vote(player) : null,
                );
              },
            ),
          ),
          if (game.isGameOver())
            Text('Game Over!'),
        ],
      ),
    );
  }
}
