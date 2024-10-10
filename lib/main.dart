import 'firebase_options.dart'; // Firebaseの設定ファイルをインポート

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'BroadcastScreen.dart';
import 'ViewScreen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter WebRTC',
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final TextEditingController _roomIdController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('WebRTC Screen Share'),
      ),
      body: Column(
        children: [
          TextField(
            controller: _roomIdController,
            decoration: InputDecoration(labelText: "Enter Room ID"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => BroadcastScreen(_roomIdController.text)),
              );
            },
            child: Text("Start Broadcasting"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => ViewScreen(_roomIdController.text)),
              );
            },
            child: Text("View Broadcast"),
          ),
        ],
      ),
    );
  }
}
