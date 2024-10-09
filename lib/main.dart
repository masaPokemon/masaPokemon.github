import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_screen_recording/flutter_screen_recording.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Screen Sharing App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ScreenSharingPage(),
    );
  }
}

class ScreenSharingPage extends StatefulWidget {
  @override
  _ScreenSharingPageState createState() => _ScreenSharingPageState();
}

class _ScreenSharingPageState extends State<ScreenSharingPage> {
  bool _isRecording = false;
  String? _filePath;

  Future<void> _startRecording() async {
    if (await Permission.storage.request().isGranted) {
      _filePath = (await getTemporaryDirectory()).path + "/screen_recording.mp4";
      await FlutterScreenRecording.startRecordScreen(
        _filePath!,
        title: "Screen Recording",
      );
      setState(() {
        _isRecording = true;
      });
    } else {
      // 権限が拒否された場合の処理
    }
  }

  Future<void> _stopRecording() async {
    await FlutterScreenRecording.stopRecordScreen;
    setState(() {
      _isRecording = false;
    });
    await _uploadToFirebase();
  }

  Future<void> _uploadToFirebase() async {
    if (_filePath != null) {
      File file = File(_filePath!);
      try {
        await FirebaseStorage.instance.ref('recordings/${file.path.split('/').last}').putFile(file);
        // アップロード成功時の処理
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload Successful!')));
      } catch (e) {
        // エラー処理
        print('Upload failed: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Screen Sharing'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _isRecording ? null : _startRecording,
              child: Text('Start Recording'),
            ),
            ElevatedButton(
              onPressed: _isRecording ? _stopRecording : null,
              child: Text('Stop Recording'),
            ),
          ],
        ),
      ),
    );
  }
}
