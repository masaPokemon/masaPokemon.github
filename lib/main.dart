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

  Future<void> _submitSurvey() async {
    String name = _nameController.text.trim();
    String preference = _preferenceController.text.trim();

    if (name.isNotEmpty && preference.isNotEmpty) {
      try {
        await FirebaseFirestore.instance.collection('surveys').add({
          'name': name,
          'preference': preference.split(',').map((s) => s.trim()).toList(),
        });
        _nameController.clear();
        _preferenceController.clear();
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
      );
    }).toList();

    // 席配置の初期化
    List<List<Student?>> seatingArrangement = List.generate(6, (_) => List.filled(6, null));

    // 合計ポイントを計算
    List<StudentWithPoints> studentsWithPoints = [];
    
    for (var student in students) {
      int points = _calculatePoints(student, seatingArrangement);
      studentsWithPoints.add(StudentWithPoints(student: student, points: points));
    }

    // 合計ポイントが高い順にソート
    studentsWithPoints.sort((a, b) => b.points.compareTo(a.points));

    // 学生を配置
    for (var entry in studentsWithPoints) {
      _placeStudentInSeat(entry.student, seatingArrangement);
    }

    // 最終的な座席配置を得る
    List<Widget> seatWidgets = seatingArrangement.expand((row) {
      return row.map((student) {
        return Card(
          child: Center(child: Text(student?.name ?? '')),
        );
      });
    }).toList();

    return seatWidgets;
  }

  int _calculatePoints(Student student, List<List<Student?>> seatingArrangement) {
    int points = 0;

    // 学生の好みの人が隣にいるかチェック
    for (String preference in student.preferences) {
      for (int row = 0; row < 6; row++) {
        for (int col = 0; col < 6; col++) {
          if (seatingArrangement[row][col]?.name == preference) {
            points += 1; // 好みの人が隣にいる場合ポイントを加算
          }
        }
      }
    }

    return points;
  }

  void _placeStudentInSeat(Student student, List<List<Student?>> seatingArrangement) {
    // 好みの人の隣に座るように配置
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

    // 好みの人がいない場合は空いている席に座らせる
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

  Student({required this.name, required this.preferences});
}

class StudentWithPoints {
  final Student student;
  final int points;

  StudentWithPoints({required this.student, required this.points});
}
