import 'dart:html' as html;
import 'package:flutter/material.dart';

class ScreenRecorderApp extends StatefulWidget {
  @override
  _ScreenRecorderAppState createState() => _ScreenRecorderAppState();
}

class _ScreenRecorderAppState extends State<ScreenRecorderApp> {
  html.MediaRecorder? _mediaRecorder;
  List<html.Blob> _recordedChunks = [];

  void _startRecording() async {
    final stream = await html.window.navigator.mediaDevices!.getDisplayMedia({
      'video': true,
      'audio': true,
    });

    _mediaRecorder = html.MediaRecorder(stream);
    _mediaRecorder!.onDataAvailable.listen((event) {
      if (event.data != null) {
        _recordedChunks.add(event.data);
      }
    });

    _mediaRecorder!.onStop.listen((event) {
      final blob = html.Blob(_recordedChunks);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final a = html.AnchorElement(href: url)
        ..setAttribute('download', 'recording.webm')
        ..click();
      html.Url.revokeObjectUrl(url);
      _recordedChunks.clear();
    });

    _mediaRecorder!.start();
  }

  void _stopRecording() {
    _mediaRecorder?.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("画面録画アプリ")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _startRecording,
              child: Text("録画開始"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _stopRecording,
              child: Text("録画停止"),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(home: ScreenRecorderApp()));
}
