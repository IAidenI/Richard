import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:richard/pages/home.dart';
import 'package:richard/pages/life.dart';
import 'package:richard/pages/weather.dart';
import 'package:richard/ui/generalUI.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lance la requête GPS en arrière-plan
  Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 5),
        ),
      )
      .then((pos) {
        InitialData.gpsPosition = pos;
      })
      .catchError((_) {});

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    //SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // Force le mode portrait
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (_) => HomePage(),
        '/weather': (_) => const Weather(),
        '/game/life': (_) => const Life(),
      },
    );
  }
}
