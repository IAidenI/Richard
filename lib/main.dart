import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:richard/pages/life.dart';
import 'package:richard/pages/weather.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // Force le mode portrait
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return MaterialApp(home: Life());
  }
}

/*import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('UrlLauchner')),
        body: Center(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'This is no Link, ',
                  style: TextStyle(color: Colors.black),
                ),
                TextSpan(
                  text: 'but this is',
                  style: TextStyle(color: Colors.blue),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      launch(
                        'https://docs.flutter.io/flutter/services/UrlLauncher-class.html',
                      );
                    },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}*/
