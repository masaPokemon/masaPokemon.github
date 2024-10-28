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
      theme: ThemeData(primarySwatch: Colors.blue),
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
  final TextEditingController _satisfactionController = TextEditingController();

  Future<void> _submitSurvey() async {
    String name = _nameController.text.trim();
    String preference = _preferenceController.text.trim();
    String satisfaction = _satisfactionController.text.trim();

    if (name.isNotEmpty && preference.isNotEmpty && satisfaction.isNotEmpty) {
      try {
        await FirebaseFirestore.instance.collection('surveys').add({
          'name': name,
          'preference': preference.split(',').map((s) => s.trim()).toList(),
          'satisfaction': int.parse(satisfaction),
        });
        _nameController.clear();
        _preferenceController.clear();
        _satisfactionController.clear();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('アンケートを送信しました')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('送信中にエラーが発生しました')));
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
            TextField(
              controller: _satisfactionController,
              decoration: InputDecoration(labelText: '満足度ポイント（1-10）'),
              keyboardType: TextInputType.number,
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

          List<Widget> seats = _createSeatingArrangement(snapshot.data!.docs);

          return GridView.count(
            crossAxisCount: 6,
            children: seats,
          );
        },
      ),
    );
  }

  List<Widget> _createSeatingArrangement(List<QueryDocumentSnapshot> documents) {
    List<Student> students = documents.map((doc) {
      return Student(
        name: doc['name'],
        preferences: List<String>.from(doc['preference']),
        satisfaction: doc['satisfaction'],
      );
    }).toList();

    // 満足度ポイントでソート
    students.sort((a, b) => b.satisfaction.compareTo(a.satisfaction));

    // 席配置の初期化
    List<List<Student?>> seatingArrangement = List.generate(6, (_) => List.filled(6, null));

    for (Student student in students) {
      _placeStudentInSeat(student, seatingArrangement);
    }

    return seatingArrangement.expand((row) {
      return row.map((student) {
        return Card(
          child: Center(child: Text(student?.name ?? '')),
        );
      });
    }).toList();
  }

  void _placeStudentInSeat(Student student, List<List<Student?>> seatingArrangement) {
    for (String preference in student.preferences) {
      for (int row = 0; row < 6; row++) {
        for (int col = 0; col < 6; col++) {
          if (seatingArrangement[row][col]?.name == preference) {
            _tryToPlaceAdjacent(student, seatingArrangement, row, col);
            return;
          }
        }
      }
    }

    // 好みの席が見つからなかった場合は空いている席に座らせる
    _findEmptySeat(student, seatingArrangement);
  }

  void _tryToPlaceAdjacent(Student student, List<List<Student?>> seatingArrangement, int row, int col) {
    for (var delta in [[0, 1], [0, -1], [1, 0], [-1, 0]]) {
      int newRow = row + delta[0];
      int newCol = col + delta[1];
      if (_isValidSeat(newRow, newCol, seatingArrangement)) {
        seatingArrangement[newRow][newCol] = student;
        return;
      }
    }
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
  final int satisfaction;

  Student({required this.name, required this.preferences, required this.satisfaction});
}
