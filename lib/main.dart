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
      title: 'Flutter Table Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyTableScreen(),
    );
  }
}

class MyTableScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter DataTable Example'),
      ),
      body: SingleChildScrollView(
        child: DataTable(
          columns: [
            DataColumn(label: Text('名前')),
            DataColumn(label: Text('年齢')),
            DataColumn(label: Text('役職')),
          ],
          rows: [
            DataRow(cells: [
              DataCell(Text('山田太郎')),
              DataCell(Text('25')),
              DataCell(Text('エンジニア')),
            ]),
            DataRow(cells: [
              DataCell(Text('佐藤花子')),
              DataCell(Text('30')),
              DataCell(Text('デザイナー')),
            ]),
            DataRow(cells: [
              DataCell(Text('鈴木一郎')),
              DataCell(Text('28')),
              DataCell(Text('PM')),
            ]),
          ],
        ),
      ),
    );
  }
}
