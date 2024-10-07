import 'package:flutter/material.dart';

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
  final TextEditingController _urlController = TextEditingController();
  String? _videoId;

  void _extractVideoId() {
    final url = _urlController.text;
    // YouTubeのURLから動画IDを抽出
    final RegExp regex = RegExp(r'(?:youtu\.be/|(?:www\.)?youtube\.com/(?:[^/]+/.*|(?:v|e(?:mbed)?|watch(?:\?.*)?)/|.*[?&]v=))([^&]{11})');
    final match = regex.firstMatch(url);
    if (match != null && match.groupCount > 0) {
      setState(() {
        _videoId = match.group(1);
      });
    } else {
      // 入力されたURLが無効な場合はエラーメッセージを表示
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('無効なYouTube URLです。')),
      );
    }
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
              controller: _urlController,
              decoration: InputDecoration(
                labelText: 'YouTube URLを入力',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _extractVideoId,
            child: Text('動画を表示'),
          ),
          if (_videoId != null)
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16.0),
                child: HtmlElementView(
                  viewType: 'iframeElement',
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// HTMLにiframeを追加するための設定
class IframeElement extends HtmlElementView {
  IframeElement() : super(viewType: 'iframeElement');

  @override
  Widget build(BuildContext context) {
    // YouTube動画を埋め込むためのURL
    final url = 'https://www.youtube.com/embed/$_videoId?autoplay=1';
    final html = '''
      <iframe width="100%" height="100%" src="$url" frameborder="0" allowfullscreen></iframe>
    ''';
    final iframeElement = IFrameElement()
      ..src = url
      ..style.border = 'none';
    return HtmlElementView(viewType: 'iframeElement');
  }
}
