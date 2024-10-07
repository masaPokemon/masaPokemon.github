import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_screen_recording/flutter_screen_recording.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Classroom App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ScreenSharePage(),
    );
  }
}

class ScreenSharePage extends StatefulWidget {
  @override
  _ScreenSharePageState createState() => _ScreenSharePageState();
}

class _ScreenSharePageState extends State<ScreenSharePage> {
  late IO.Socket socket;
  bool isRecording = false;

  @override
  void initState() {
    super.initState();
    socket = IO.io('http://localhost:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    socket.on('screen-shared', (data) {
      // Handle screen shared data (display it)
    });
  }

  void startScreenShare() async {
    await FlutterScreenRecording.startRecordScreen('classroom');
    setState(() {
      isRecording = true;
    });
  }

  void stopScreenShare() async {
    String? path = await FlutterScreenRecording.stopRecordScreen;
    if (path != null) {
      // Send the recorded video to the server
      socket.emit('screen-share', path);
    }
    setState(() {
      isRecording = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Classroom Screen Share')),
      body: Center(
        child: isRecording
            ? ElevatedButton(
                onPressed: stopScreenShare,
                child: Text('Stop Sharing'),
              )
            : ElevatedButton(
                onPressed: startScreenShare,
                child: Text('Start Sharing'),
              ),
      ),
    );
  }
}
