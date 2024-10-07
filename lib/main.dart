import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YouTube Viewer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: YouTubeViewer(),
    );
  }
}

class YouTubeViewer extends StatefulWidget {
  @override
  _YouTubeViewerState createState() => _YouTubeViewerState();
}

class _YouTubeViewerState extends State<YouTubeViewer> {
  final TextEditingController _controller = TextEditingController();
  String _url = '';

  void _loadVideo() {
    setState(() {
      _url = _controller.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('YouTube Viewer'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'YouTube URL',
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _loadVideo,
            child: Text('Load Video'),
          ),
          Expanded(
            child: _url.isNotEmpty
                ? WebviewScaffold(
                    url: _url,
                    withJavascript: true,
                    withZoom: true,
                    hidden: true,
                  )
                : Center(child: Text('Enter a YouTube URL to watch a video')),
          ),
        ],
      ),
    );
  }
}
