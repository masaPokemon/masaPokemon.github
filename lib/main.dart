import 'firebase_options.dart';
import 'dart:html' as html; // Import for web functionality
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';

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
      title: 'Student Monitoring App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: StudentScreen(),
    );
  }
}

class StudentScreen extends StatefulWidget {
  @override
  _StudentScreenState createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> _captureScreen() async {
    try {
      // Get the screen stream
      final stream = await html.window.navigator.mediaDevices.getDisplayMedia({
        'video': {
          'displaySurface': 'monitor', // Capture the entire monitor
        },
      });

      // Create a canvas to capture the video stream
      final videoElement = html.VideoElement()..srcObject = stream;
      final canvas = html.CanvasElement(width: 1280, height: 720);
      final context = canvas.getContext('2d')!;
      videoElement.play();

      // Draw the video frame to the canvas
      videoElement.onLoadedData.listen((_) {
        context.drawImage(videoElement, 0, 0);
        _uploadImage(canvas.toDataUrl('image/png'));
      });
    } catch (e) {
      print('Error capturing screen: $e');
    }
  }

  Future<void> _uploadImage(String dataUrl) async {
    // Convert base64 data URL to a Blob
    final base64String = dataUrl.split(',')[1];
    final blob = html.Blob([html.window.atob(base64String)], 'image/png');

    // Create a file from the Blob
    final file = html.File([blob], 'screenshot.png', {'type': 'image/png'});

    // Upload the file to Firebase Storage
    try {
      await _storage.ref('screenshots/${file.name}').putBlob(blob);
      print('Screenshot uploaded successfully');
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Monitoring App'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _captureScreen,
          child: Text('Capture Screen'),
        ),
      ),
    );
  }
}
