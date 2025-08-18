import 'package:flutter/material.dart';
import 'package:richard/ui/generalUI.dart';
import 'package:richard/ui/theme.dart';

class HomePage extends StatelessWidget {
  final theme = GameLifeThemes();

  HomePage({super.key});

  @override
  Widget build(Object context) {
    return Scaffold(
      appBar: AppBar(title: Text("Home Page")),
      body: Align(
        alignment: Alignment.bottomRight,
        child: SizedBox(height: 115, child: FloatingMenu(theme)),
      ),
    );
  }
}
