import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<List<List<String>>> _bingoData;
  List<List<bool>> _markedCells = List.generate(5, (_) => List.filled(5, false));

  @override
  void initState() {
    super.initState();
    _bingoData = BingoService().getBingoData();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('ビンゴカード')),
        body: FutureBuilder<List<List<String>>>(
          future: _bingoData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('エラーが発生しました'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('データがありません'));
            }

            List<List<String>> bingoData = snapshot.data!;
            return BingoCard(
              bingoData: bingoData,
              markedCells: _markedCells,
              onCellTap: (row, col) {
                setState(() {
                  _markedCells[row][col] = !_markedCells[row][col]; // タップ時に当たりを切り替え
                });
              },
            );
          },
        ),
      ),
    );
  }
}

class BingoService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<List<String>>> getBingoData() async {
    final snapshot = await _firestore.collection('bingo_items').get();
    List<List<String>> bingoData = List.generate(5, (_) => List.filled(5, ''));

    int index = 0;
    for (var doc in snapshot.docs) {
      int row = index ~/ 5;
      int col = index % 5;
      bingoData[row][col] = doc['image_url']; // Firestoreに格納された画像URLを使用
      index++;
    }
    return bingoData;
  }
}

class BingoCard extends StatelessWidget {
  final List<List<String>> bingoData;
  final List<List<bool>> markedCells;
  final void Function(int, int) onCellTap;

  BingoCard({required this.bingoData, required this.markedCells, required this.onCellTap});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: 4.0,
        mainAxisSpacing: 4.0,
      ),
      itemCount: 25, // 5x5のビンゴカード
      itemBuilder: (context, index) {
        final row = index ~/ 5;
        final col = index % 5;
        bool isMarked = markedCells[row][col];

        return GestureDetector(
          onTap: () => onCellTap(row, col), // セルをタップしたとき
          child: Card(
            color: isMarked ? Colors.green : Colors.white, // 当たりを緑に
            child: Center(
              child: bingoData[row][col].isEmpty
                  ? Icon(Icons.close, color: Colors.grey) // 画像がなければアイコン
                  : Image.network(bingoData[row][col]), // Firebaseの画像URLを表示
            ),
          ),
        );
      },
    );
  }
}
