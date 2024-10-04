import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'player_model.dart';

class GameProvider with ChangeNotifier {
  List<Player> players = [];
  bool isNight = true; // 夜か昼かを管理
  bool gameOver = false;

  GameProvider() {
    _initializePlayers();
  }

  void _initializePlayers() {
    players = [
      Player(name: 'Alice', isAlive: true, isWerewolf: false),
      Player(name: 'Bob', isAlive: true, isWerewolf: false),
      Player(name: 'Charlie', isAlive: true, isWerewolf: true), // 人狼
      Player(name: 'Dave', isAlive: true, isWerewolf: false),
    ];
    notifyListeners();
  }

  void toggleDayNight() {
    isNight = !isNight;
    notifyListeners();
  }

  void werewolfAttack(String playerName) {
    if (isNight) {
      Player? target = players.firstWhere(
        (player) => player.name == playerName && player.isAlive,
        orElse: () => Player(name: '', isAlive: false, isWerewolf: false),
      );

      if (target != null && target.isAlive) {
        target.isAlive = false;
        Fluttertoast.showToast(msg: "$playerName has been attacked by the Werewolf!");
        _checkGameOver();
      } else {
        Fluttertoast.showToast(msg: "Invalid target!");
      }
      notifyListeners();
    }
  }

  void _checkGameOver() {
    int aliveVillagers = players.where((player) => player.isAlive && !player.isWerewolf).length;
    int aliveWerewolves = players.where((player) => player.isAlive && player.isWerewolf).length;

    if (aliveVillagers == 0 || aliveWerewolves == 0) {
      gameOver = true;
      Fluttertoast.showToast(msg: "Game Over");
    }
  }

  List<Player> getAlivePlayers() {
    return players.where((player) => player.isAlive).toList();
  }
}
