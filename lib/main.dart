import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Proxy History App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ProxyHistoryPage(),
    );
  }
}

class ProxyHistoryPage extends StatefulWidget {
  @override
  _ProxyHistoryPageState createState() => _ProxyHistoryPageState();
}

class _ProxyHistoryPageState extends State<ProxyHistoryPage> {
  List<Map<String, dynamic>> _history = [];

  @override
  void initState() {
    super.initState();
    _fetchProxyHistory();
  }

  Future<void> _fetchProxyHistory() async {
    try {
      // 擬似APIからデータを取得する（ここではローカルのJSONファイルなどを使うこともできます）
      final response = await http.get(Uri.parse('https://www.cc.miyazaki-u.ac.jp/internal/proxy.pac'));
      if (response.statusCode == 200) {
        setState(() {
          _history = List<Map<String, dynamic>>.from(json.decode(response.body));
        });
      } else {
        throw Exception('データの取得に失敗しました');
      }
    } catch (e) {
      print('エラー: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('プロキシ通信履歴'),
      ),
      body: ListView.builder(
        itemCount: _history.length,
        itemBuilder: (context, index) {
          final entry = _history[index];
          return ListTile(
            title: Text(entry['url']),
            subtitle: Text(entry['timestamp']),
          );
        },
      ),
    );
  }
}
