import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'game_provider.dart';
import 'player_model.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GameProvider(),
      child: MaterialApp(
        home: GameScreen(),
      ),
    );
  }
}

class GameScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Werewolf Game')),
      body: Consumer<GameProvider>(
        builder: (context, gameProvider, child) {
          return Column(
            children: [
              Text(gameProvider.isNight ? "Night Time" : "Day Time", style: TextStyle(fontSize: 24)),
              Expanded(
                child: ListView.builder(
                  itemCount: gameProvider.players.length,
                  itemBuilder: (context, index) {
                    Player player = gameProvider.players[index];
                    return ListTile(
                      title: Text(player.name),
                      subtitle: Text(player.isAlive ? "Alive" : "Dead"),
                      trailing: player.isAlive && gameProvider.isNight
                          ? ElevatedButton(
                              onPressed: () {
                                gameProvider.werewolfAttack(player.name);
                              },
                              child: Text("Attack"),
                            )
                          : null,
                    );
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  gameProvider.toggleDayNight();
                },
                child: Text(gameProvider.isNight ? "Switch to Day" : "Switch to Night"),
              ),
              if (gameProvider.gameOver)
                Text("Game Over", style: TextStyle(fontSize: 32, color: Colors.red)),
            ],
          );
        },
      ),
    );
  }
}
