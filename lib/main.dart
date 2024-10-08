import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:screenshot/screenshot.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(ScreenCapture());
}  

class ScreenCapture extends StatefulWidget {
  @override
  _ScreenCaptureState createState() => _ScreenCaptureState();
}

class _ScreenCaptureState extends State<ScreenCapture> {
  ScreenshotController screenshotController = ScreenshotController();

  void captureScreen() {
    screenshotController.capture().then((image) {
      // Send image to server or stream it
      uploadToServer(image);
    }).catchError((onError) {
      print(onError);
    });
  }

  void uploadToServer(image) async {
    final imageFile = File(image.path);
    FirebaseStorage storage = FirebaseStorage.instance;
    try {
      await storage.ref('sample.png').putFile(imageFile);
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Screen Capture')),
      body: Screenshot(
        controller: screenshotController,
        child: Container(
          color: Colors.white,
          child: Center(
            child: ElevatedButton(
              onPressed: captureScreen(),
              child: Text('Capture and Stream'),
            ),
          ),
        ),
      ),
    );
  }
}
