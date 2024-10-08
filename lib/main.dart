import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:screenshot/screenshot.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
    FirebaseStorage storage = FirebaseStorage.instance;
    try {
      await storage.ref('sample.png').putFile(image);
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
              onPressed: () async {
                captureScreen();
              }
              child: Text('Capture and Stream'),
            ),
          ),
        ),
      ),
    );
  }
}
