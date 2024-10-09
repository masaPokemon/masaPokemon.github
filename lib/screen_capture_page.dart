import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';

class ScreenCapturePage extends StatefulWidget {
  @override
  _ScreenCapturePageState createState() => _ScreenCapturePageState();
}

class _ScreenCapturePageState extends State<ScreenCapturePage> {
  final ScreenshotController screenshotController = ScreenshotController();

  Future<void> _captureAndUpload() async {
    try {
      // スクリーンショットを撮影
      final image = await screenshotController.capture();

      if (image != null) {
        // 一時ディレクトリに保存
        final imagePath = 'screenshots/screenshot.png';
        XFile file = XFile(filePath);
        //await file.writeAsBytes(image);

        // Firebase Storageにアップロード
        final storageRef = FirebaseStorage.instance.ref().child('screenshots/screenshot.png');
        await storageRef.putFile(file);

        // Firebase Firestoreに画像のURLを保存
        final downloadUrl = await storageRef.getDownloadURL();
        await FirebaseFirestore.instance.collection('screenshots').add({
          'imageUrl': downloadUrl,
          'timestamp': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('スクリーンショットをアップロードしました')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Screen Capture and Upload'),
      ),
      body: Screenshot(
        controller: screenshotController,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('画面をキャプチャしてFirebaseにアップロード'),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _captureAndUpload,
                child: Text('キャプチャしてアップロード'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
