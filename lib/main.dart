import 'package:flutter/material.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Message Recipient Prediction',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Interpreter _interpreter;
  final TextEditingController _controller = TextEditingController();
  String _prediction = "";

  // TensorFlow Lite モデルのロード
  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('message_recipient_model.tflite');
      print("Model loaded successfully!");
    } catch (e) {
      print("Failed to load model: $e");
    }
  }

  // メッセージの予測
  Future<void> predictRecipient(String message) async {
    var input = preprocessMessage(message);
    var output = List.filled(1, 0); // 予測の出力用

    _interpreter.run(input, output);

    setState(() {
      _prediction = mapLabelToRecipient(output[0]);
    });
  }

  // メッセージの前処理（トークナイズなど）
  List<List<int>> preprocessMessage(String message) {
    // 実際には、ここでテキストをトークナイズし、数値ベクトルに変換します。
    // 簡単のため、仮に固定値を返します。
    return [[1, 2, 3]]; // 仮の数値入力
  }

  // ラベルを宛先名に変換
  String mapLabelToRecipient(int label) {
    switch (label) {
      case 0:
        return '佐藤さん';
      case 1:
        return '鈴木さん';
      case 2:
        return '高橋さん';
      default:
        return '不明';
    }
  }

  @override
  void initState() {
    super.initState();
    loadModel(); // アプリ起動時にモデルを読み込む
  }

  @override
  void dispose() {
    _interpreter.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Message Recipient Prediction'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter message',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                String message = _controller.text;
                predictRecipient(message);
              },
              child: Text('Predict Recipient'),
            ),
            SizedBox(height: 20),
            Text(
              'Predicted Recipient: $_prediction',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
