import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'game_service.dart';

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final GameService _gameService = GameService();
  String? _roomId;
  String _playerId = 'player1';  // プレイヤーIDは仮のものにしておく（後でFirebase Authなどで管理可能）

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Werewolf Game")),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () async {
              final roomId = await _gameService.createGameRoom(_playerId);
              setState(() {
                _roomId = roomId;
              });
            },
            child: Text('Create Game Room'),
          ),
          if (_roomId != null) Text('Room ID: $_roomId'),
          Expanded(
            child: StreamBuilder<List<GameRoom>>(
              stream: _gameService.getGameRooms(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No rooms available'));
                }

                final rooms = snapshot.data!;
                return ListView.builder(
                  itemCount: rooms.length,
                  itemBuilder: (context, index) {
                    final room = rooms[index];
                    return ListTile(
                      title: Text('Room ID: ${room.roomId}'),
                      subtitle: Text('Players: ${room.players.join(', ')}'),
                      onTap: () {
                        // ルームに参加するロジックを実装
                        _gameService.joinGameRoom(room.roomId, _playerId);
                        setState(() {
                          _roomId = room.roomId;
        
