import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'pages/weather.dart';

void main() async {
  runApp(const MyApp());
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
    return MaterialApp(home: Weather());
  }
}
