// main.dart
import 'package:flutter/material.dart';
import 'signaling.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Screen Sharing App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ScreenSharingPage(),
    );
  }
}

class ScreenSharingPage extends StatefulWidget {
  @override
  _ScreenSharingPageState createState() => _ScreenSharingPageState();
}

class _ScreenSharingPageState extends State<ScreenSharingPage> {
  Signaling _signaling;
  bool _isSharing = false;

  @override
  void initState() {
    super.initState();
    _signaling = Signaling();
  }

  void _startSharing() async {
    await _signaling.createPeerConnection();
    setState(() {
      _isSharing = true;
    });
  }

  void _stopSharing() async {
    await _signaling.close();
    setState(() {
      _isSharing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Screen Sharing'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _isSharing ? _stopSharing : _startSharing,
              child: Text(_isSharing ? 'Stop Sharing' : 'Start Sharing'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _signaling.close();
    super.dispose();
  }
}
