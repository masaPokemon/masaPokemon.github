
class Player {
  final String name;
  final String role; // "werewolf" or "villager"
  bool isAlive;

  Player({
    required this.name,
    required this.role,
    this.isAlive = true,
  });
}
