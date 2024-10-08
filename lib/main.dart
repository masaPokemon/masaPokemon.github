import 'package:flutter/material.dart';
import 'screen_share.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Screen Sharing',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ScreenShare(),
    );
  }
}
