import 'package:flutter/material.dart';
import 'package:richard/assets/constants.dart';
import 'package:richard/ui/customUI.dart';
import 'package:richard/ui/theme.dart';

class Life extends StatefulWidget {
  const Life({super.key});

  @override
  State<Life> createState() => _LifeState();
}

class _LifeState extends State<Life> {
  WeatherTheme theme = WeatherTheme(ColorCode.UNKNOW);
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
