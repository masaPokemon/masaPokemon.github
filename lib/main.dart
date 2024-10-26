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
            crossAxisCount: 6, // 6x6の机の配置
            children: seats,
          );
        },
      ),
    );
  }

  List<Widget> _optimizeSeats(List<QueryDocumentSnapshot> documents) {
    // 生徒の名前と好みを保持するマップ
    Map<String, List<String>> preferences = {};

    // データを取得して好みをマップに保存
    for (var doc in documents) {
      String name = doc['name'];
      String preference = doc['preference'];
      preferences[name] = preference.split(','); // 好みをカンマで分割してリストに
    }

    List<Student> students = preferences.entries.map((entry) {
      return Student(name: entry.key, preferences: entry.value);
    }).toList();

    // 席の配置を最適化するロジック
    List<List<Student?>> seatingArrangement = List.generate(6, (_) => List.filled(6, null));

    // 生徒をランダムに並べる
    students.shuffle();

    for (Student student in students) {
      bool seated = false;

      // 好みの生徒が近くにいる場合、そこに座らせる
      for (String preference in student.preferences) {
        // 好みの生徒を探す
        for (int row = 0; row < 6; row++) {
          for (int col = 0; col < 6; col++) {
            if (seatingArrangement[row][col]?.name == preference) {
              // 好みの生徒が見つかった場合、近くの席に配置
              for (var delta in [
                [0, 1], [0, -1], [1, 0], [-1, 0] // 右、左、下、上
              ]) {
                int newRow = row + delta[0];
                int newCol = col + delta[1];
                if (newRow >= 0 && newRow < 6 && newCol >= 0 && newCol < 6 && seatingArrangement[newRow][newCol] == null) {
                  seatingArrangement[newRow][newCol] = student;
                  seated = true;
                  break;
                }
              }
              break;
            }
          }
          if (seated) break;
        }

        // 座れなかった場合、空いている席に座らせる
        if (!seated) {
          for (int row = 0; row < 6; row++) {
            for (int col = 0; col < 6; col++) {
              if (seatingArrangement[row][col] == null) {
                seatingArrangement[row][col] = student;
                seated = true;
                break;
              }
            }
            if (seated) break;
          }
        }

        if (seated) break; // 好みの生徒の近くに座ったらループを抜ける
      }
    }

    // 6x6の座席をCardウィジェットとして表示
    List<Widget> seatWidgets = [];
    for (var row in seatingArrangement) {
      for (var student in row) {
        seatWidgets.add(Card(
          child: Center(child: Text(student?.name ?? '')),
        ));
      }
    }

    return seatWidgets;
  }
}

class Student {
  final String name;
  final List<String> preferences;

  Student({required this.name, required this.preferences});
}
