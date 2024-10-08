import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screen_recording/flutter_screen_recording.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:async';

import 'firebase_options.dart';

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
      title: 'Screen Sharing App',
      home: ScreenShare(),
    );
  }
}

class ScreenShare extends StatefulWidget {
  @override
  _ScreenShareState createState() => _ScreenShareState();
}

class _ScreenShareState extends State<ScreenShare> {
  String? filePath;

  Future<void> _startRecording() async {
    await FlutterScreenRecording.startRecordScreen('Recording');
  }

  Future<void> _stopRecording() async {
    final filePath = await FlutterScreenRecording.stopRecordScreen;

    if (filePath != null) {
      await _uploadToFirebase(filePath);
    }
  }

  Future<void> _uploadToFirebase(String filePath) async {
    XFile file = XFile(filePath);
    FirebaseStorage storage = FirebaseStorage.instance;
    bool test = true;
    try {
      test = true;
      Reference referenceRoot = FirebaseStorage.instance.ref("screenshots/${DateTime.now()}.webm").child(file.name); //cloud storageの/imagesフォルダにアップロード

      UploadTask uploadTask = referenceRoot.putData(await file.readAsBytes());

      print('アップロード完了');
      var downloadUrl = await referenceRoot.getDownloadURL(); //url取得
      print('downloadUrl:$downloadUrl');
      //await storage.ref('screenshots/${DateTime.now()}.png').putFile(file);
      print('Upload complete');
    } catch (e) {
      test = false;
      print('Upload failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Screen Sharing')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _startRecording,
              child: Text('Start Recording'),
            ),
            ElevatedButton(
              onPressed: _stopRecording,
              child: Text('Stop Recording'),
            ),
          ],
        ),
      ),
    );
  }
}
