
import 'models/player.dart';
import 'dart:math';

class Game {
  List<Player> players = [];
  Random random = Random();

  void addPlayer(String name) {
    String role = random.nextBool() ? "werewolf" : "villager"; // 役職をランダムに割り当て
    players.add(Player(name: name, role: role));
  }

  void vote(Player player) {
    if (player.isAlive) {
      player.isAlive = false; // 投票されたプレイヤーを死亡状態にする
    }
  }

  List<Player> getAlivePlayers() {
    return players.where((player) => player.isAlive).toList();
  }

  bool isGameOver() {
    int werewolves = players.where((player) => player.role == "werewolf" && player.isAlive).length;
    int villagers = players.where((player) => player.role == "villager" && player.isAlive).length;

    return werewolves == 0 || villagers == 0; // ゲームの終了条件
  }
}
