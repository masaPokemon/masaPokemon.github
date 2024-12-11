import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'dart:math';

// ゲームクラス
void main() {
  runApp(GameWidget(game: RPGGame()));
}

class RPGGame extends FlameGame with TapDetector {
  late Player player;
  late List<Enemy> enemies;
  late List<Tile> tiles; // マップタイルのリスト
  late Battle battle;

  final int mapWidth = 10;
  final int mapHeight = 10;
  final Random random = Random();

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // プレイヤーの初期化
    player = Player();
    add(player);

    // 敵の初期化
    enemies = [
      Enemy(Vector2(200, 100)),
      Enemy(Vector2(300, 300)),
    ];
    enemies.forEach((enemy) => add(enemy));

    // マップの初期化
    tiles = generateMap(mapWidth, mapHeight);
    tiles.forEach((tile) => add(tile));

    // バトルの初期化
    battle = Battle(player, enemies[0]);
  }

  @override
  void update(double dt) {
    super.update(dt);
    player.update(dt);

    // プレイヤーと敵が接触した場合にバトル開始
    for (var enemy in enemies) {
      if (player.toRect().overlaps(enemy.toRect())) {
        startBattle(player, enemy);
      }
    }
  }

  // バトル開始処理
  void startBattle(Player player, Enemy enemy) {
    battle.start(player, enemy);
  }

  // ランダムにマップを生成する関数
  List<Tile> generateMap(int width, int height) {
    List<Tile> map = [];
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        // タイルの種類をランダムに決定
        TileType type = TileType.values[random.nextInt(TileType.values.length)];
        map.add(Tile(type, Vector2(x * 50.0, y * 50.0)));
      }
    }
    return map;
  }
}

// プレイヤークラス（プレイヤーキャラクター）
class Player extends SpriteComponent {
  Player() : super(size: Vector2(50, 50), position: Vector2(50, 50));

  void update(double dt) {
    // プレイヤーの移動ロジック（ここでは簡単に右下に移動）
    if (position.x < 400) position.x += 1;
    if (position.y < 400) position.y += 1;
  }
}

// 敵モンスタークラス（ガクモン）
class Enemy extends SpriteComponent {
  final String name = 'ガクモン';

  Enemy(Vector2 position) : super(position: position, size: Vector2(50, 50));
}

// バトルクラス（戦闘のロジック）
class Battle {
  final Player player;
  final Enemy enemy;
  late Skill skill;

  Battle(this.player, this.enemy);

  // バトルの開始処理
  void start(Player player, Enemy enemy) {
    print('Battle started with ${enemy.name}');
    skill = MathSkill();  // 使用する技を選択

    // 問題を出題
    print('技選択: ${skill.question}');
    print('選択肢: ${skill.options.join(", ")}');
  }

  // プレイヤーが選んだ答えを判定
  bool useSkill(String answer) {
    if (skill.use(answer)) {
      print('技発動成功');
      return true;
    } else {
      print('技失敗');
      return false;
    }
  }
}

// 技クラス（技の基盤）
class Skill {
  final String name;
  final String question;
  final List<String> options;
  final String correctAnswer;

  Skill(this.name, this.question, this.options, this.correctAnswer);

  bool use(String answer) {
    return answer == correctAnswer;
  }
}

// 数学の技（ピタゴラスの定理）
class MathSkill extends Skill {
  MathSkill()
      : super(
          'ピタゴラスの定理', // 技名
          'a² + b² = c² のcは何か？', // 問題
          ['a', 'b', 'c', 'd'], // 選択肢
          'c', // 正解
        );

  @override
  bool use(String answer) {
    if (super.use(answer)) {
      print('技成功: ピタゴラスの定理');
      return true;
    } else {
      print('技失敗');
      return false;
    }
  }
}

// タイルタイプの列挙
enum TileType { grass, tree, water }

// タイルクラス（マップのタイル）
class Tile extends SpriteComponent {
  final TileType type;

  Tile(this.type, Vector2 position) : super(position: position, size: Vector2(50, 50));

  @override
  Future<void> onLoad() async {
    super.onLoad();
    // タイルタイプに応じた画像を設定
    switch (type) {
      case TileType.grass:
        sprite = await loadSprite('grass.png');
        break;
      case TileType.tree:
        sprite = await loadSprite('tree.png');
        break;
      case TileType.water:
        sprite = await loadSprite('water.png');
        break;
    }
  }
}
