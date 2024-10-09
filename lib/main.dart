import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Screen Recording App',
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
  bool _isRecording = false;
  List<html.MediaStream> _mediaStreams = [];
  late html.VideoElement _videoElement;
  late html.MediaRecorder _mediaRecorder;
  List<html.Blob> _recordedChunks = [];

  @override
  void initState() {
    super.initState();
    _videoElement = html.VideoElement();
  }

  Future<void> _startRecording() async {
    try {
      // Request screen capture
      html.MediaStream stream = await html.window.navigator.mediaDevices.getDisplayMedia({
        'video': true,
        'audio': true,
      });

      _videoElement.srcObject = stream;
      _videoElement.play();

      // Create a MediaRecorder instance
      _mediaRecorder = html.MediaRecorder(stream);
      _mediaRecorder.onDataAvailable.listen((event) {
        if (event.data.size > 0) {
          _recordedChunks.add(event.data);
        }
      });

      _mediaRecorder.onStop.listen((event) async {
        // Create a blob from the recorded chunks
        final blob = html.Blob(_recordedChunks, 'video/webm');

        // Upload to Firebase (optional)
        await _uploadToFirebase(blob);

        // Reset the recorded chunks
        _recordedChunks.clear();
      });

      // Start recording
      _mediaRecorder.start();
      setState(() {
        _isRecording = true;
      });
    } catch (e) {
      print('Error starting recording: $e');
    }
  }

  Future<void> _stopRecording() async {
    if (_isRecording) {
      _mediaRecorder.stop();
      _mediaRecorder.stream.getTracks().forEach((track) => track.stop());
      _videoElement.pause();
      setState(() {
        _isRecording = false;
      });
    }
  }

  Future<void> _uploadToFirebase(html.Blob blob) async {
    try {
      // Create a file from the blob
      final reader = html.FileReader();
      reader.readAsArrayBuffer(blob);
      reader.onLoadEnd.listen((event) async {
        final storageRef = FirebaseStorage.instance.ref().child('recordings/${DateTime.now().millisecondsSinceEpoch}.webm');

        // Upload the blob to Firebase Storage
        await storageRef.putData(reader.result as Uint8List);
        print('File uploaded successfully!');
      });
    } catch (e) {
      print('Error uploading file: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Screen Recording'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: 640,
              height: 480,
              child: _isRecording ? Container(child: _videoElement) : Container(color: Colors.black),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isRecording ? _stopRecording : _startRecording,
              child: Text(_isRecording ? 'Stop Recording' : 'Start Recording'),
            ),
          ],
        ),
      ),
    );
  }
}
