import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:richard/assets/constants.dart';
import 'package:richard/modeles/life.dart';
import 'package:richard/ui/customUI.dart';
import 'package:richard/ui/theme.dart';

class Life extends StatefulWidget {
  const Life({super.key});

  @override
  State<Life> createState() => _LifeState();
}

class _LifeState extends State<Life> {
  WeatherTheme theme = WeatherTheme(ColorCode.UNKNOW);

  final List<Point<int>> _initialCell = [Point(6, 7), Point(7, 7), Point(8, 7)];
  late LifeLogique _life;

  Timer? _tick;
  int counter = 0;

  @override
  void initState() {
    super.initState();
    _life = LifeLogique(_initialCell);

    // Lance le timer qui s'exécute toutes les 2 secondes
    _tick = Timer.periodic(const Duration(seconds: 2), (timer) {
      setState(() {
        counter++;
      });
      print("[ DEBUG ] Tick n°$counter");
      _life.start();

      // Arrêt après 3 générations
      if (counter >= 3) {
        _tick?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _tick?.cancel(); // Toujours annuler le timer quand on quitte le widget
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          GridZoom(cell: 10),
          Align(
            alignment: Alignment.bottomRight,
            child: SizedBox(
              height: 115,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {},
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.settings,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  FloatingMenu(theme),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
