import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:richard/modeles/life.dart';
import 'package:richard/pages/life.dart';
import 'pages/weather.dart';

void main() async {
  // Blinker1 : [Point(1, 2), Point(2, 2), Point(3, 2)]
  // Blinker2 : [Point(6, 2), Point(7, 2), Point(8, 2)]
  // Blinker3 : [Point(6, 7), Point(7, 7), Point(8, 7)]

  // Glyder1 : [Point(4, 5), Point(5, 5), Point(6, 5), Point(6, 4), Point(5, 3)]
  // Glyder2 : [Point(5, 7), Point(6, 7), Point(7, 7), Point(7, 6), Point(6, 5)]

  List<Point<int>> initialCell = [
    Point(5, 7),
    Point(6, 7),
    Point(7, 7),
    Point(7, 6),
    Point(6, 5),
  ];
  LifeLogique life = LifeLogique(initialCell);
  life.simulation();
  //runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext) {
    //SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // Force le mode portrait
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(home: Life());
  }
}
