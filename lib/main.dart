import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Website Search App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WebsiteSearchPage(),
    );
  }
}

class WebsiteSearchPage extends StatefulWidget {
  @override
  _WebsiteSearchPageState createState() => _WebsiteSearchPageState();
}

class _WebsiteSearchPageState extends State<WebsiteSearchPage> {
  final TextEditingController _urlController = TextEditingController();
  String? _websiteContent;
  List<String> _savedWebsites = [];

  @override
  void initState() {
    super.initState();
    _loadSavedWebsites();
  }

  Future<void> _loadSavedWebsites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _savedWebsites = prefs.getStringList('saved_websites') ?? [];
    });
  }

  Future<void> _fetchWebsiteData() async {
    final url = _urlController.text;
    if (url.isEmpty) return;

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          _websiteContent = response.body; // Save raw HTML content
        });

        // Save the website to shared preferences
        _saveWebsite(url);
      } else {
        throw Exception('Failed to load website');
      }
    } catch (e) {
      print('Error fetching website: $e');
    }
  }

  Future<void> _saveWebsite(String url) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _savedWebsites.add(url);
    await prefs.setStringList('saved_websites', _savedWebsites);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Website Search'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _urlController,
              decoration: InputDecoration(
                labelText: 'Enter website URL',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.url,
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _fetchWebsiteData,
              child: Text('Fetch Website Data'),
            ),
            SizedBox(height: 20),
            _websiteContent != null
                ? Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Text(
                            'Website Content:',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10),
                          Text(
                            _websiteContent!,
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  )
                : Container(),
            SizedBox(height: 20),
            Text(
              'Saved Websites:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _savedWebsites.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_savedWebsites[index]),
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
