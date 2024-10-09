import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
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
      title: 'URL Capture App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: UrlCapturePage(),
    );
  }
}

class UrlCapturePage extends StatefulWidget {
  @override
  _UrlCapturePageState createState() => _UrlCapturePageState();
}

class _UrlCapturePageState extends State<UrlCapturePage> {
  final CollectionReference _urlCollection =
      FirebaseFirestore.instance.collection('captured_urls');
  String? _capturedUrl;

  @override
  void initState() {
    super.initState();
    _setupMethodChannel();
  }

  void _setupMethodChannel() {
    const platform = MethodChannel('url_channel');
    platform.setMethodCallHandler((call) async {
      if (call.method == 'receiveUrl') {
        String url = call.arguments;
        setState(() {
          _capturedUrl = url;
        });
        await _saveUrlToFirebase(url);
      }
    });
  }

  Future<void> _saveUrlToFirebase(String url) async {
    await _urlCollection.add({'url': url, 'timestamp': FieldValue.serverTimestamp()});
    print('URL saved: $url');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('URL Capture'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_capturedUrl != null)
              Text('Captured URL: $_capturedUrl')
            else
              Text('No URL captured yet.'),
          ],
        ),
      ),
    );
  }
}
