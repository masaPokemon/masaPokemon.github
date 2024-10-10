import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  MediaStream? _localStream;
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  bool _isCalling = false;
  DesktopCapturerSource? selected_source_;

  @override
  void initState() {
    super.initState();
    initRrenderers();
  }

  @override
  void deactivate() {
    super.deactivate();
    if (_isCalling) {
      _stop();
    }
    _localRenderer.dispose();
  }

  Future<void> initRrenderers() async {
    await _localRenderer.initialize();
  }

  Future<void> selectScreenSourceDialog(BuildContext context) async {
    await _makeCall(null);
  }

  Future<void> _makeCall(DesktopCapturerSource? source) async {
    setState(() {
      selected_source_ = source;
    });

    try {
      var stream =
          await navigator.mediaDevices.getDisplayMedia(<String, dynamic>{
        'video': selected_source_ == null
            ? true
            : {
                'devideId': {'exact': selected_source_!.id},
                'mandatory': {'frameRate': 30.0}
              }
      });
      stream.getVideoTracks()[0].onEnded = () {
        print(
            'By adding a listener on onEnded you can:1) catch stop video sharing on Web');
      };
      _localStream = stream;
      _localRenderer.srcObject = _localStream;
    } catch (e) {
      print(e.toString());
    }
    if (!mounted) return;
    setState(() {
      _isCalling = true;
    });
  }

  Future<void> _stop() async {
    try {
      if (kIsWeb) {
        _localStream?.getAudioTracks().forEach((track) => track.stop());
      }
      await _localStream?.dispose();
      _localStream = null;
      _localRenderer.srcObject = null;
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> _hungup() async {
    await _stop();
    setState(() {
      _isCalling = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width,
          color: Colors.white10,
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              if (_isCalling)
                Container(
                  margin: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  decoration: const BoxDecoration(color: Colors.black54),
                  child: RTCVideoView(_localRenderer),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _isCalling ? _hungup() : selectScreenSourceDialog(context);
        },
        tooltip: _isCalling ? 'hungup' : 'Call',
        child: Icon(_isCalling ? Icons.call_end : Icons.phone),
      ),
    );
  }
}
