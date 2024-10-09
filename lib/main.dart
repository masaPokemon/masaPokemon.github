
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screen_capture_page.dart';

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
      title: 'Screen Distribution App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ScreenCapturePage(),
    );
  }
}
