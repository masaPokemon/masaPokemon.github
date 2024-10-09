import 'dart:html' as html; // Import for web functionality
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
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
      title: 'Classroom Screen Sharing',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ClassroomPage(),
    );
  }
}

class ClassroomPage extends StatefulWidget {
  @override
  _ClassroomPageState createState() => _ClassroomPageState();
}

class _ClassroomPageState extends State<ClassroomPage> {
  final List<RTCPeerConnection> _peerConnections = [];
  final List<RTCVideoRenderer> _renderers = [];
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();

  @override
  void initState() {
    super.initState();
    _initRenderers();
  }

  Future<void> _initRenderers() async {
    await _localRenderer.initialize();
  }

  Future<void> _startScreenShare() async {
    try {
      // Get the screen stream
      final stream = await navigator.mediaDevices.getDisplayMedia({
        'video': {
          'displaySurface': 'application', // Use 'browser' for browser windows
        },
      });

      // Set local renderer
      _localRenderer.srcObject = stream;

      // Here you would usually create a peer connection
      // and send the stream to other users
      // This is a placeholder for further implementation
    } catch (e) {
      print('Error sharing screen: $e');
    }
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Classroom Screen Sharing'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: RTCVideoView(_localRenderer),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _startScreenShare,
            child: Text('Start Screen Share'),
          ),
        ],
      ),
    );
  }
}
