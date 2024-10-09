import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Proxy Info App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ProxyInfoPage(),
    );
  }
}

class ProxyInfoPage extends StatefulWidget {
  @override
  _ProxyInfoPageState createState() => _ProxyInfoPageState();
}

class _ProxyInfoPageState extends State<ProxyInfoPage> {
  String _pacContent = '取得中...';

  @override
  void initState() {
    super.initState();
    _fetchPacFile();
  }

  Future<void> _fetchPacFile() async {
    try {
      // PACファイルを取得
      final response = await http.get(Uri.parse('https://www.cc.miyazaki-u.ac.jp/internal/proxy.pac'));
      if (response.statusCode == 200) {
        setState(() {
          _pacContent = response.body;
        });
      } else {
        setState(() {
          _pacContent = 'PACファイルの取得に失敗しました: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _pacContent = 'エラー: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('プロキシ情報'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Text(_pacContent, style: TextStyle(fontFamily: 'Courier', fontSize: 14)),
      ),
    );
  }
}
