import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '席替え最適化アプリ',
      home: SurveyPage(),
    );
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
    String name = _nameController.text.trim();
    String preference = _preferenceController.text.trim();

    if (name.isNotEmpty && preference.isNotEmpty) {
      try {
        await FirebaseFirestore.instance.collection('surveys').add({
          'name': name,
          'preference': preference,
        });
        _nameController.clear();
        _preferenceController.clear();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('アンケートを送信しました')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('エラーが発生しました')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('すべてのフィールドを入力してください')));
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
              decoration: InputDecoration(labelText: '好みの人（カンマ区切り）'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitSurvey,
              child: Text('送信'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => SeatOptimizationPage()));
              },
              child: Text('席替え結果を表示'),
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
      appBar: AppBar(title: Text('席替え結果')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('surveys').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('データがありません'));
          }

          List<Widget> seats = _generateSeatingArrangement(snapshot.data!.docs);

          return GridView.count(
            crossAxisCount: 6,
            children: seats,
          );
        },
      ),
    );
  }

  List<Widget> _generateSeatingArrangement(List<QueryDocumentSnapshot> documents) {
    Map<String, List<String>> preferences = {};

    for (var doc in documents) {
      String name = doc['name'];
      String preference = doc['preference'];
      preferences[name] = preference.split(',').map((s) => s.trim()).toList();
    }

    List<Student> students = preferences.entries.map((entry) {
      return Student(name: entry.key, preferences: entry.value);
    }).toList();

    // 学生をランダムにシャッフル
    //students.shuffle();

    List<List<Student?>> seatingArrangement = List.generate(6, (_) => List.filled(6, null));

    for (Student student in students) {
      bool placed = _placeStudent(student, seatingArrangement);
      if (!placed) {
        _findEmptySeat(student, seatingArrangement);
      }
    }

    return seatingArrangement.expand((row) {
      return row.map((student) {
        return Card(
          child: Center(child: Text(student?.name ?? '')),
        );
      });
    }).toList();
  }

  bool _placeStudent(Student student, List<List<Student?>> seatingArrangement) {
    for (String preference in student.preferences) {
      for (int row = 0; row < 6; row++) {
        for (int col = 0; col < 6; col++) {
          if (seatingArrangement[row][col]?.name == preference) {
            for (var delta in [[0, 1], [0, -1], [1, 0], [-1, 0]]) {
              int newRow = row + delta[0];
              int newCol = col + delta[1];
              if (_isValidSeat(newRow, newCol, seatingArrangement)) {
                seatingArrangement[newRow][newCol] = student;
                return true;
              }
            }
          }
        }
      }
    }
    return false;
  }

  void _findEmptySeat(Student student, List<List<Student?>> seatingArrangement) {
    for (int row = 0; row < 6; row++) {
      for (int col = 0; col < 6; col++) {
        if (seatingArrangement[row][col] == null) {
          seatingArrangement[row][col] = student;
          return;
        }
      }
    }
  }

  bool _isValidSeat(int row, int col, List<List<Student?>> seatingArrangement) {
    return row >= 0 && row < 6 && col >= 0 && col < 6 && seatingArrangement[row][col] == null;
  }
}

class Student {
  final String name;
  final List<String> preferences;

  Student({required this.name, required this.preferences});
}
