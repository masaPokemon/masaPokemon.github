import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';  // Firebase設定ファイルをインポート
import 'package:flutter/material.dart';
import 'package:screen_shot/screen_shot.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';

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
      title: 'Screen Streaming App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScreenShotController _screenShotController = ScreenShotController();
  bool _isUploading = false;
  String? _downloadUrl;

  Future<void> _captureAndUploadScreen() async {
    setState(() {
      _isUploading = true;
    });

    try {
      // 画面のキャプチャ
      Uint8List? capturedImage = await _screenShotController.capture();

      if (capturedImage != null) {
        // Firebase Storageにアップロード
        String fileName = 'screenshots/screen_${DateTime.now().millisecondsSinceEpoch}.png';
        Reference firebaseStorageRef = FirebaseStorage.instance.ref().child(fileName);
        UploadTask uploadTask = firebaseStorageRef.putData(capturedImage);
        TaskSnapshot snapshot = await uploadTask;
        
        // ダウンロードURLの取得
        String downloadUrl = await snapshot.ref.getDownloadURL();
        
        setState(() {
          _downloadUrl = downloadUrl;
        });
        
        print('Uploaded to Firebase: $downloadUrl');
      }
    } catch (e) {
      print('エラーが発生しました: $e');
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Screen Streaming'),
      ),
      body: Center(
        child: _isUploading
            ? CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _captureAndUploadScreen,
                    child: Text('画面をキャプチャしてアップロード'),
                  ),
                  if (_downloadUrl != null)
                    Column(
                      children: [
                        Text('アップロード成功:'),
                        Text(_downloadUrl!),
                        Image.network(_downloadUrl!),
                      ],
                    ),
                ],
              ),
      ),
    );
  }
}
