import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pokemon_ft/button.dart';
import 'package:pokemon_ft/characters/boy.dart';
import 'package:pokemon_ft/maps/litteleroot.dart';
import 'package:pokemon_ft/maps/pokelab.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /*

  VARIABLES

  */

  //littleroot
  double mapX = 5.625;
  double mapY = 0.899;

  //pokelab
  double labMapX = 3.125;
  double labMapY = -1.851;

  //boy character
  int boySpritecount = 0; //0 for standing, 1-2 for walking
  String boyDirection = 'Down';

  //game stuff
  String currentLocation = 'littleroot';
  double step = 0.75;

  //no mans land for littleroot
  List<List<double>> noMansLandLittleroot = [
    [2.375, 1.149],
    [3.125, 1.149],
  ];

  void moveUp() {
    boyDirection = 'Up';

    //no mans land for littleroot
    if (currentLocation == 'littleroot') {
      if (canMoveTo(boyDirection, noMansLandLittleroot, mapX, mapY)) {
        setState(() {
          mapY += (step / 4);
        });
      }

      //enter pokelab
      if (double.parse((mapX).toStringAsFixed(4)) == 3.375 &&
              double.parse((mapY).toStringAsFixed(4)) == -1.726 ||
          double.parse((mapX).toStringAsFixed(4)) == 2.625 &&
              double.parse((mapY).toStringAsFixed(4)) == -1.726) {
        setState(() {
          currentLocation = 'pokelab';
          labMapX = -1.875;
          labMapY = -15.97;
        });
      }

      animateWalk();
    }

    //no mans land for pokelab
    if (currentLocation == 'pokelab') {
      if (canMoveTo(boyDirection, noMansLandLittleroot, labMapX, labMapY)) {
        setState(() {
          labMapY += step;
        });
      }
      animateWalk();
    }
  }

  void moveDown() {
    boyDirection = 'Down';

    //no mans land for littleroot
    if (currentLocation == 'littleroot') {
      if (canMoveTo(boyDirection, noMansLandLittleroot, mapX, mapY)) {
        setState(() {
          mapY -= (step / 4);
        });
      }
      animateWalk();
    }

    //no mans land for pokelab
    if (currentLocation == 'pokelab') {
      if (canMoveTo(boyDirection, noMansLandLittleroot, labMapX, labMapY)) {
        setState(() {
          labMapY -= step;
        });
      }
      //enter littleroot
      if (double.parse((labMapX).toStringAsFixed(4)) == -1.125 &&
              double.parse((labMapY).toStringAsFixed(4)) == -16.72 ||
          double.parse((labMapX).toStringAsFixed(4)) == -1.875 &&
              double.parse((labMapY).toStringAsFixed(4)) == -16.72 ||
          double.parse((labMapX).toStringAsFixed(4)) == -3.375 &&
              double.parse((labMapY).toStringAsFixed(4)) == -16.72 ||
          double.parse((labMapX).toStringAsFixed(4)) == -0.375 &&
              double.parse((labMapY).toStringAsFixed(4)) == -16.72 ||
          double.parse((labMapX).toStringAsFixed(4)) == 0.375 &&
              double.parse((labMapY).toStringAsFixed(4)) == -16.72 ||
          double.parse((labMapX).toStringAsFixed(4)) == -2.625 &&
              double.parse((labMapY).toStringAsFixed(4)) == -16.72) {
        setState(() {
          currentLocation = 'littleroot';
          mapX = 2.625;
          mapY = -1.9135;
        });
      }
      animateWalk();
    }
  }

  void moveLeft() {
    boyDirection = 'Left';

    //no mans land for littleroot
    if (currentLocation == 'littleroot') {
      if (canMoveTo(boyDirection, noMansLandLittleroot, mapX, mapY)) {
        setState(() {
          mapX += step;
        });
      }
      animateWalk();
    }

    //no mans land for pokelab
    if (currentLocation == 'pokelab') {
      if (canMoveTo(boyDirection, noMansLandLittleroot, labMapX, labMapY)) {
        setState(() {
          labMapX += step;
        });
      }
      animateWalk();
    }
  }

  void moveRight() {
    boyDirection = 'Right';

    //no mans land for littleroot
    if (currentLocation == 'littleroot') {
      if (canMoveTo(boyDirection, noMansLandLittleroot, mapX, mapY)) {
        setState(() {
          mapX -= step;
        });
      }
      animateWalk();
    }

    //no mans land for pokelab
    if (currentLocation == 'pokelab') {
      if (canMoveTo(boyDirection, noMansLandLittleroot, labMapX, labMapY)) {
        setState(() {
          labMapX -= step;
        });
      }
      animateWalk();
    }
  }

  void pressedA() {}
  void pressedB() {}

  void animateWalk() {
    print('x: ' + mapX.toString());
    print('y: ' + mapY.toString());
    print('labx: ' + labMapX.toString());
    print('laby: ' + labMapY.toString());

    Timer.periodic(Duration(milliseconds: 50), (timer) {
      setState(() {
        boySpritecount++;
      });

      if (boySpritecount == 3) {
        boySpritecount = 0;
        timer.cancel();
      }
    });
  }

  cleanNum(double num) {
    return double.parse(num.toStringAsFixed(4));
  }

  bool canMoveTo(String direction, var noMansLand, double x, double y) {
    double stepX = 0;
    double stepY = 0;

    if (direction == 'Left') {
      stepX = step;
      stepY = 0;
    } else if (direction == 'Right') {
      stepX = -step;
      stepY = 0;
    } else if (direction == 'Up') {
      stepX = 0;
      stepY = step;
    } else if (direction == 'Down') {
      stepX = 0;
      stepY = -step;
    }

    for (int i = 0; i < noMansLand.length; i++) {
      if ((cleanNum(noMansLand[i][0]) == cleanNum(x + stepX)) &&
          (cleanNum(noMansLand[i][1]) == cleanNum(y + stepY))) {
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        AspectRatio(
          aspectRatio: 1,
          child: Container(
            color: Colors.black,
            child: Stack(
              children: [
                // little root
                LittleRoot(
                  x: mapX,
                  y: mapY,
                  currentMap: currentLocation,
                ),

                // pokelab
                MyPokeLab(
                  x: labMapX,
                  y: labMapY,
                  currentMap: currentLocation,
                ),

                // boy character
                Container(
                  alignment: Alignment(0, 0),
                  child: MyBoy(
                    location: currentLocation,
                    boySpriteCount: boySpritecount,
                    direction: boyDirection,
                  ),
                ),

                // border
                Container(
                  decoration: BoxDecoration(
                      border: Border.all(width: 20, color: Colors.black)),
                )
              ],
            ),
          ),
        ),
        Expanded(
            child: Container(
          color: Colors.grey[900],
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(
                    'G A M E B O Y',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  Text(
                    ' ★ ',
                    style: TextStyle(color: Colors.orange, fontSize: 20),
                  ),
                  Text(
                    'F L U T T E R',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ]),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      children: [
                        Column(
                          children: [
                            Container(
                              height: 50,
                              width: 50,
                            ),
                            MyButton(
                              text: '←',
                              function: moveLeft,
                            ),
                            Container(
                              height: 50,
                              width: 50,
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            MyButton(
                              text: '↑',
                              function: moveUp,
                            ),
                            Container(
                              height: 50,
                              width: 50,
                            ),
                            MyButton(
                              text: '↓',
                              function: moveDown,
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Container(
                              height: 50,
                              width: 50,
                            ),
                            MyButton(
                              text: '→',
                              function: moveRight,
                            ),
                            Container(
                              height: 50,
                              width: 50,
                            ),
                          ],
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Column(
                          children: [
                            Container(
                              height: 50,
                              width: 50,
                            ),
                            MyButton(
                              text: 'B',
                              function: pressedB,
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            MyButton(
                              text: 'A',
                              function: pressedA,
                            ),
                            Container(
                              height: 50,
                              width: 50,
                            ),
                          ],
                        )
                      ],
                    )
                  ],
                ),
                Text(
                  'CREATED BY GlanzVogal',
                  style: TextStyle(color: Colors.white),
                )
              ],
            ),
          ),
        ))
      ]),
    );
  }
}
