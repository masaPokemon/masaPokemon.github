import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:screenshot/screenshot.dart';
import 'firebase_options.dart'; // Firebaseの設定ファイルをインポート

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Screen Distribution App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ScreenCapturePage(),
    );
  }
}

class ScreenCapturePage extends StatefulWidget {
  @override
  _ScreenCapturePageState createState() => _ScreenCapturePageState();
}

class _ScreenCapturePageState extends State<ScreenCapturePage> {
  final ScreenshotController _screenshotController = ScreenshotController();
  String? _downloadUrl;

  Future<void> _captureAndUpload() async {
    // 画面をキャプチャ
    final image = await _screenshotController.capture();
    if (image != null) {
      // 画像をFirebaseにアップロード
      await _uploadImage(image);
    }
  }

  Future<void> _uploadImage(Uint8List image) async {
    // Firebase Storageにアップロード
    final storageRef = FirebaseStorage.instance.ref().child('screenshots/${DateTime.now().millisecondsSinceEpoch}.png');
    await storageRef.putData(image);
    final downloadUrl = await storageRef.getDownloadURL();

    setState(() {
      _downloadUrl = downloadUrl;
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('画像がアップロードされました: $downloadUrl')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('画面配信アプリ'),
      ),
      body: Screenshot(
        controller: _screenshotController,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('画面をキャプチャしてFirebaseにアップロードします。'),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _captureAndUpload,
                child: Text('画面をキャプチャしてアップロード'),
              ),
              if (_downloadUrl != null) ...[
                SizedBox(height: 20),
                Text('アップロードされた画像:'),
                Image.network(_downloadUrl!),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
