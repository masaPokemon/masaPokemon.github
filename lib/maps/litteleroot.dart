import 'package:flutter/material.dart';

class LittleRoot extends StatelessWidget {
  double x;
  double y;
  String currentMap;

  LittleRoot({required this.x, required this.y, required this.currentMap});

  @override
  Widget build(BuildContext context) {
    if (currentMap == 'littleroot') {
      return Container(
        alignment: Alignment(x, y),
        child: Image.asset(
          'lib/images/littleroot.png',
          width: MediaQuery.of(context).size.width * 0.95,
          fit: BoxFit.cover,
        ),
      );
    } else {
      return Container();
    }
  }
}
