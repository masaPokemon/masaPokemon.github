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
  String _proxyInfo = 'プロキシ情報を取得中...';

  @override
  void initState() {
    super.initState();
    _fetchProxyInfo();
  }

  Future<void> _fetchProxyInfo() async {
    try {
      // 指定されたURLからproxy.pacファイルを取得
      final response = await http.get(Uri.parse('https://www.cc.miyazaki-u.ac.jp/internal/proxy.pac'));
      if (response.statusCode == 200) {
        setState(() {
          _proxyInfo = response.body; // 取得したPACファイルの内容を表示
        });
      } else {
        setState(() {
          _proxyInfo = 'データの取得に失敗しました';
        });
      }
    } catch (e) {
      setState(() {
        _proxyInfo = 'エラー: $e';
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
        child: Text(_proxyInfo),
      ),
    );
  }
}
