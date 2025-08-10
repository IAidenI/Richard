import 'package:flutter/material.dart';
import 'package:richard/assets/constants.dart';
import 'package:richard/ui/customUI.dart';
import 'package:richard/ui/theme.dart';

class Reminder extends StatefulWidget {
  const Reminder({super.key});

  @override
  State<Reminder> createState() => _ReminderState();
}

class _ReminderState extends State<Reminder> {
  WeatherTheme theme = WeatherTheme(ColorCode.UNKNOW);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(child: const Text("Rappel")),
          FloatingMenu(theme),
        ],
      ),
    );
  }
}
