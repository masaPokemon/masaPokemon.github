import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: const Text("Model Viewer")),
        // ①ModelViewerウィジェットの各プロパティを設定する
        body: ModelViewer(
          src: 'models/Model.obj',
          iosSrc: 'https://modelviewer.dev/shared-assets/models/Astronaut.usdz',
          ar: true,
          autoRotate: true,
          cameraControls: true,
        ),
      ),
    );
  }
}
