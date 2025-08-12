import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:richard/assets/constants.dart';
import 'package:richard/dbug.dart';
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

  //final List<Point<int>> _initialCell = [Point(6, 7), Point(7, 7), Point(8, 7)];
  List<Point<int>> _initialCell = [];
  final LifeLogique _life = LifeLogique();
  bool _notInit = true;

  int _resetId = 0;

  // Gestion du timer
  Timer? _tick;
  int _generation = 0;
  final Duration _initialSpeed = Duration(seconds: 1);
  late Duration _generationSpeed;
  final int _maxGenerations = 100000;
  Color _fastGeneration = Colors.black;
  Color _realyFastGeneration = Colors.black;

  // Gestion de la pause
  bool _isPaused = true;
  IconData _pauseIcon = Icons.pause;

  @override
  void initState() {
    super.initState();
    _generationSpeed = _initialSpeed;
    _tickStart();
  }

  void _tickStart() {
    _tick?.cancel(); // Evite les doublons
    _tick = Timer.periodic(_generationSpeed, (timer) {
      if (_isPaused) return;

      if (_notInit) return;

      printDebug("Start $_generation° generation.");
      _initialCell = _life.startNextGeneration();

      setState(() {
        _generation++;
      });
      printDebug("Tick n°$_generation");

      // Arrêt après 3 générations
      if (_generation >= _maxGenerations) {
        _tick?.cancel();
        // Si le maximum de générations est atteint alors afficher un message
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (context) => PopupDisplayInfos(
            title: 'ATTENTION',
            content: {
              "Vous avez atteint le maximum ($_maxGenerations) de génération":
                  null,
            },
            style: PopupColorCode(theme),
          ),
        );

        _resetGeneration();
      }
    });
  }

  void _changeInterval(Duration newInterval) {
    _generationSpeed = newInterval;
    _tickStart();
  }

  void _tickPause({bool reset = false}) {
    setState(() {
      if (reset) {
        _isPaused = true;
        _pauseIcon = Icons.pause;
      } else {
        _notInit = _life.reStart(_initialCell);
        _isPaused = !_isPaused;
        _pauseIcon = _isPaused ? Icons.pause : Icons.play_arrow;
      }
    });
  }

  void _tickReset() {
    _tick?.cancel();
    _tick = null;
    _tickStart();
  }

  @override
  void dispose() {
    _tick?.cancel(); // Toujours annuler le timer quand on quitte le widget
    super.dispose();
  }

  void _resetGeneration() {
    _generation = 0;
    _initialCell = [];

    // Vide les buffers
    _life.clear();

    // Remet à 0 le timer
    _tickPause(reset: true);
    _tickReset();

    _generationSpeed = _initialSpeed;
    _fastGeneration = Colors.black;
    _realyFastGeneration = Colors.black;

    _resetId++; // Pour recrée un nouveau GridZoom
  }

  Widget _buildSettingsButton({
    required IconData icon,
    required Function() onPressed,
    Color color = Colors.black,
    double size = 25,
  }) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero, // pas de padding
        minimumSize: Size(40, 40), // pas de taille mini
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Icon(icon, size: size, color: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          GridZoom(
            key: ValueKey(_resetId),
            life: _life,
            isPaused: _isPaused,
            generation: _generation,
            getCells: (cells) {
              _initialCell = List.of(cells);
            },
          ),

          // Menu général
          Align(
            alignment: Alignment.bottomRight,
            child: SizedBox(height: 115, child: FloatingMenu(theme)),
          ),

          // Menu du jeu
          Align(
            alignment: Alignment.bottomCenter,
            // Crée une boîte pour contenir les settings
            child: TextButton(
              onPressed: () {},

              child: Container(
                width: 200,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(20),
                ),
                // Place les élément de paramètres
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Bouton pour ouvrir les settings
                    _buildSettingsButton(
                      icon: Icons.settings,
                      onPressed: () {},
                    ),

                    // Bouton pour lance/stoper la génération
                    _buildSettingsButton(
                      icon: _pauseIcon,
                      onPressed: () {
                        _tickPause();

                        for (var cell in _initialCell) {
                          printDebug("$cell");
                        }
                      },
                    ),

                    // Bouton pour avance rapide de la génération
                    _buildSettingsButton(
                      icon: Icons.skip_next,
                      color: _fastGeneration,
                      onPressed: () {
                        Duration newSpeed = Duration(milliseconds: 300);
                        if (_generationSpeed != newSpeed) {
                          _realyFastGeneration = Colors.black;
                          _fastGeneration = Colors.deepPurple;
                          _changeInterval(newSpeed);
                        } else {
                          _fastGeneration = Colors.black;
                          _changeInterval(_initialSpeed);
                        }
                      },
                    ),

                    // Bouton pour avance très rapide de la génération
                    _buildSettingsButton(
                      icon: Icons.fast_forward,
                      color: _realyFastGeneration,
                      onPressed: () {
                        Duration newSpeed = Duration(milliseconds: 50);
                        if (_generationSpeed != newSpeed) {
                          _realyFastGeneration = Colors.deepPurple;
                          _fastGeneration = Colors.black;
                          _changeInterval(newSpeed);
                        } else {
                          _realyFastGeneration = Colors.black;
                          _changeInterval(_initialSpeed);
                        }
                      },
                    ),

                    // Bouton pour avance très rapide de la génération
                    _buildSettingsButton(
                      icon: Icons.refresh,
                      onPressed: () {
                        setState(() => _resetGeneration());
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
