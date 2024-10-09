import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
  List<dynamic> _history = [];

  Future<void> _fetchProxyHistory() async {
    try {
      final response = await http.get(Uri.parse('https://www.cc.miyazaki-u.ac.jp/internal/proxy.pac'));
      if (response.statusCode == 200) {
        setState(() {
          _history = json.decode(response.body);
        });
      } else {
        throw Exception('Failed to load history');
      }
    } catch (e) {
      print('Error fetching history: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchProxyHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('通信履歴'),
      ),
      body: _history.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _history.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_history[index]['url']),
                  subtitle: Text('Method: ${_history[index]['method']}'),
                );
              },
            ),
    );
  }
}
