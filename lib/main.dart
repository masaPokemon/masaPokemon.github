import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:screenshot/screenshot.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Screenshot to Firestore',
      home: ScreenshotHome(),
    );
  }
}

class ScreenshotHome extends StatefulWidget {
  @override
  _ScreenshotHomeState createState() => _ScreenshotHomeState();
}

class _ScreenshotHomeState extends State<ScreenshotHome> {
  final ScreenshotController _screenshotController = ScreenshotController();
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _startScreenshotTimer();
  }

  void _startScreenshotTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _takeScreenshot();
    });
  }

  Future<void> _takeScreenshot() async {
    final image = await _screenshotController.capture();

    if (image != null) {
      // Firestoreに送信
      await FirebaseFirestore.instance.collection('screenshots').add({
        'timestamp': FieldValue.serverTimestamp(),
        'image': image, // ここでは画像のバイナリデータを保存する例を示しています
      });
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Screenshot(
      controller: _screenshotController,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Screenshot Example'),
        ),
        body: Center(
          child: Text('スクリーンショットを撮影中...'),
        ),
      ),
    );
  }
}
