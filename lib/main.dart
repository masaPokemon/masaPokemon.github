import 'dart:html';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_screen_recording/flutter_screen_recording.dart';

void main() async {
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
      title: '画面録画アプリ',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ScreenRecordingPage(),
    );
  }
}

class ScreenRecordingPage extends StatefulWidget {
  @override
  _ScreenRecordingPageState createState() => _ScreenRecordingPageState();
}

class _ScreenRecordingPageState extends State<ScreenRecordingPage> {
  String? _recordingFilePath;
  bool _isRecording = false;

  Future<void> _startRecording() async {
    try {
      // 録画を開始
      _recordingFilePath = await FlutterScreenRecording.startRecordScreen();
      setState(() {
        _isRecording = true;
      });
    } catch (e) {
      print('録画開始エラー: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      // 録画を停止
      String? filePath = await FlutterScreenRecording.stopRecordScreen();
      setState(() {
        _isRecording = false;
      });

      // 録画したファイルをFirebaseにアップロード
      if (filePath != null) {
        await _uploadFile(filePath);
      }
    } catch (e) {
      print('録画停止エラー: $e');
    }
  }

  Future<void> _uploadFile(String filePath) async {
    try {
      final reader = FileReader();
      reader.readAsArrayBuffer(File(filePath));
      reader.onLoadEnd.listen((event) async {
        final bytes = reader.result as Uint8List;
        final storageRef = FirebaseStorage.instance.ref().child('recordings/${DateTime.now().millisecondsSinceEpoch}.mp4');

        // Firebase StorageにBlobをアップロード
        await storageRef.putData(bytes);
        print('ファイルがアップロードされました！');
      });
    } catch (e) {
      print('ファイルアップロードエラー: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('画面録画'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _isRecording ? null : _startRecording,
              child: Text('録画開始'),
            ),
            ElevatedButton(
              onPressed: _isRecording ? _stopRecording : null,
              child: Text('録画停止'),
            ),
            SizedBox(height: 20),
            if (_recordingFilePath != null)
              Text('録画ファイル: $_recordingFilePath'),
          ],
        ),
      ),
    );
  }
}
