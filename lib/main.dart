import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:screenshot/screenshot.dart';
import 'firebase_options.dart'; // Firebase設定ファイル

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ScreenshotController screenshotController = ScreenshotController();
  Timer? timer;

  @override
  void initState() {
    super.initState();
    startScreenshotLoop();
  }

  // 毎秒スクリーンショットを撮影してFirestoreに送信する
  void startScreenshotLoop() {
    timer = Timer.periodic(Duration(seconds: 1), (timer) async {
      // スクリーンショットを取得
      Uint8List? screenshot = await screenshotController.capture();

      if (screenshot != null) {
        // Firestoreにスクリーンショットをアップロード
        await uploadScreenshotToFirestore(screenshot);
      }
    });
  }

  // Firestoreにスクリーンショットをアップロードする関数
  Future<void> uploadScreenshotToFirestore(Uint8List screenshot) async {
    try {
      // Firestoreのコレクションに追加
      await FirebaseFirestore.instance.collection('screenshots').add({
        'image': screenshot,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error uploading screenshot: $e");
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Flutter Web Screenshot Example')),
        body: Screenshot(
          controller: screenshotController,
          child: Center(
            child: Text('This is the screen being captured every second.'),
          ),
        ),
      ),
    );
  }
}
