import 'package:flutter/material.dart';

class MyBoy extends StatelessWidget {
  final int boySpriteCount; //0 for standing, 1-2 for walking
  final String direction;
  final String location;
  double height = 30;

  MyBoy(
      {required this.boySpriteCount,
      required this.direction,
      required this.location});

  @override
  Widget build(BuildContext context) {
    if (location == 'littleroot') {
      height = 30;
    } else if (location == 'pokelab') {
      height = 45;
    } else if (location == 'battleground' ||
        location == 'attackopyions' ||
        location == 'battlefinishedscreen') {
      height = 0;
    }

    return Container(
      height: height,
      child: Image.asset(
        'lib/images/boy' + direction + boySpriteCount.toString() + '.png',
        fit: BoxFit.cover,
      ),
    );
  }
}
