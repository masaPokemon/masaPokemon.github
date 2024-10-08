import 'package:flutter/material.dart';
import 'database_helper.dart';

void main() {
  runApp(KidsSearchHistoryApp());
}

class KidsSearchHistoryApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kids Search History',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: SearchHistoryPage(),
    );
  }
}

class SearchHistoryPage extends StatefulWidget {
  @override
  _SearchHistoryPageState createState() => _SearchHistoryPageState();
}

class _SearchHistoryPageState extends State<SearchHistoryPage> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    List<Map<String, dynamic>> history = await _databaseHelper.getHistory();
    setState(() {
      _history = history;
    });
  }

  Future<void> _addSearchHistory() async {
    String query = _searchController.text.trim();
    if (query.isNotEmpty) {
      await _databaseHelper.insertHistory(query);
      _searchController.clear();
      _loadHistory();
    }
  }

  Future<void> _deleteHistory(int id) async {
    await _databaseHelper.deleteHistory(id);
    _loadHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Kids Search History')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Query',
                suffixIcon: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: _addSearchHistory,
                ),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _history.length,
                itemBuilder: (context, index) {
                  final item = _history[index];
                  return ListTile(
                    title: Text(item['query']),
                    subtitle: Text(item['date']),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _deleteHistory(item['id']),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
