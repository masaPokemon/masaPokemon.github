import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screen_capture/screen_capture.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Classroom Monitoring',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ClassroomScreen(),
    );
  }
}

class ClassroomScreen extends StatefulWidget {
  @override
  _ClassroomScreenState createState() => _ClassroomScreenState();
}

class _ClassroomScreenState extends State<ClassroomScreen> {
  bool isRecording = false;

  Future<void> _startScreenCapture() async {
    // 権限のリクエスト
    if (await Permission.mediaLibrary.request().isGranted) {
      setState(() {
        isRecording = true;
      });
      ScreenCapture.start();
    } else {
      // 権限が拒否された場合の処理
      print('Screen capture permission denied');
    }
  }

  Future<void> _stopScreenCapture() async {
    ScreenCapture.stop();
    setState(() {
      isRecording = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Classroom Monitoring'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '生徒の画面を共有しています',
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: isRecording ? _stopScreenCapture : _startScreenCapture,
              child: Text(isRecording ? '停止' : '開始'),
            ),
          ],
        ),
      ),
    );
  }
}
