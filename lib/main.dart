import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  DateTime now = DateTime.now();
  DateTime tomorrow = DateTime(10, 11, 1);
  @override
  Widget build(BuildContext context) {
    if (now.isAfter(tomorrow)) {
      return MaterialApp(
        title: 'アンケートアプリ',
        home: SurveyPage(),
      );
    } else {
      return MaterialApp(
        title: '席替え結果',
        home: SeatOptimizationPage(),
      );
    }
  }
}

class SurveyPage extends StatefulWidget {
  @override
  _SurveyPageState createState() => _SurveyPageState();
}

class _SurveyPageState extends State<SurveyPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _preferenceController = TextEditingController();

  void _submitSurvey() async {
    String name = _nameController.text;
    String preference = _preferenceController.text;

    if (name.isNotEmpty && preference.isNotEmpty) {
      await FirebaseFirestore.instance.collection('surveys').add({
        'name': name,
        'preference': preference,
      });
      _nameController.clear();
      _preferenceController.clear();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('アンケートを送信しました')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('アンケート')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: '名前'),
            ),
            TextField(
              controller: _preferenceController,
              decoration: InputDecoration(labelText: '好みの人'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitSurvey,
              child: Text('送信'),
            ),
          ],
        ),
      ),
    );
  }
}
class SeatOptimizationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('席替え最適化')),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance.collection('surveys').get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          List<Widget> seats = _optimizeSeats(snapshot.data!.docs);

          return GridView.count(
            crossAxisCount: 3,
            children: seats,
          );
        },
      ),
    );
  }

  List<Widget> _optimizeSeats(List<QueryDocumentSnapshot> documents) {
    // 生徒の好みを考慮して席替えを最適化
    Map<String, List<String>> preferences = {};
    for (var doc in documents) {
      String name = doc['name'];
      String preference = doc['preference'];
      preferences[name] = _evaluatePreference(preference);
    }

    // 各生徒の評価値を基に最適な席を決定（ここでは単純にランダム化しているが、評価に基づくロジックを入れることができる）
    List<String> sortedNames = preferences.keys.toList();
    sortedNames.sort((a, b) => preferences[b]!.length.compareTo(preferences[a]!.length));

    return sortedNames.map((name) {
      return Card(
        child: Center(child: Text(name)),
      );
    }).toList();
  }

  List<String> _evaluatePreference(String preference) {
    // 好みに基づく評価値を計算
    // ここでは単純なロジックとして、カンマ区切りの文字列を返す
    return preference.split(',').map((p) => p.trim()).toList();
  }
}
