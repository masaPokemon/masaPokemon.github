import 'dart:html' as html; // For accessing HTML features
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
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
      title: 'Screen Capture App',
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
  String? _imageUrl;

  Future<void> _captureAndUpload() async {
    // Capture the screen
    html.CanvasElement canvas = html.CanvasElement(
      width: html.window.screen!.width!.toInt(),
      height: html.window.screen!.height!.toInt(),
    );

    html.CanvasRenderingContext2D context = canvas.getContext('2d')!;

    // Draw the current window content on the canvas
    context.drawImage(html.window.document!.documentElement!.querySelector('body')!, 0, 0);

    // Convert the canvas to a data URL (PNG format)
    String dataUrl = canvas.toDataUrl('image/png');

    // Convert data URL to byte array
    final byteString = html.window.atob(dataUrl.split(',')[1]);
    final buffer = Uint8List(byteString.length);
    for (int i = 0; i < byteString.length; i++) {
      buffer[i] = byteString.codeUnitAt(i);
    }

    // Upload to Firebase
    try {
      final storageRef = FirebaseStorage.instance.ref().child('screenshots/screenshot_${DateTime.now().millisecondsSinceEpoch}.png');
      await storageRef.putData(buffer);
      _imageUrl = await storageRef.getDownloadURL();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Screenshot saved to Firebase: $_imageUrl')));
    } catch (e) {
      print('Error uploading screenshot: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to upload screenshot')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Screen Capture'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _captureAndUpload,
              child: Text('Capture Screen and Upload to Firebase'),
            ),
            if (_imageUrl != null) ...[
              SizedBox(height: 20),
              Text('Uploaded Image URL:'),
              SelectableText(_imageUrl!),
            ],
          ],
        ),
      ),
    );
  }
}
