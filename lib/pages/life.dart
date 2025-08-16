import 'dart:async';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:richard/assets/constants.dart';
import 'package:richard/dbug.dart';
import 'package:richard/modeles/life.dart';
import 'package:richard/modeles/patterns.dart';
import 'package:richard/ui/gameUI.dart';
import 'package:richard/ui/generalUI.dart';
import 'package:richard/ui/theme.dart';
import 'package:url_launcher/url_launcher.dart';

class Life extends StatefulWidget {
  const Life({super.key});

  @override
  State<Life> createState() => _LifeState();
}

class _LifeState extends State<Life> {
  GameLifeThemes theme = GameLifeThemes();

  Set<Point<int>> _initialCell = <Point<int>>{};
  final LifeLogique _life = LifeLogique();
  bool _notInit = true;
  bool _center = false;

  int _resetId = 0;

  // Gestion du timer
  Timer? _tick;
  int _generation = 0;
  final Duration _initialSpeed = Duration(seconds: 1);
  late Duration _generationSpeed;
  final int _maxGenerations = 1000000;
  late Color _fastGeneration;
  late Color _realyFastGeneration;

  // Gestion de la pause
  bool _isPaused = true;
  IconData _pauseIcon = Icons.pause;

  final format = NumberFormat.decimalPattern('fr_FR');

  void printGrid(
    Set<Point<int>> cells, {
    int? width,
    int? height,
    Point<int>? center,
    int padding = 1,
    String live = '■',
    String dead = '·',
    bool showAxes = true,
    bool invertY = false,
  }) {
    if (cells.isEmpty) {
      print("Aucune cellule ❌");
      return;
    }

    // Bornes des points
    final xs = cells.map((p) => p.x);
    final ys = cells.map((p) => p.y);
    int minX = xs.reduce(min), maxX = xs.reduce(max);
    int minY = ys.reduce(min), maxY = ys.reduce(max);

    // Zone d'affichage (fit ou fenêtre)
    if (width == null || height == null) {
      minX -= padding;
      maxX += padding;
      minY -= padding;
      maxY += padding;
    } else {
      final c = center ?? Point<int>((minX + maxX) ~/ 2, (minY + maxY) ~/ 2);
      final halfW = width ~/ 2;
      final halfH = height ~/ 2;
      minX = c.x - halfW;
      maxX = c.x + (width - halfW - 1);
      minY = c.y - halfH;
      maxY = c.y + (height - halfH - 1);
    }

    final buf = StringBuffer();
    final set = cells; // alias

    // En-tête axes X (dizaines/units)
    if (showAxes) {
      // ligne des dizaines (mod 10) pour lisibilité
      buf.write('     ');
      for (int x = minX; x <= maxX; x++) {
        buf.write(((x ~/ 10) % 10).abs());
      }
      buf.write('\n     ');
      for (int x = minX; x <= maxX; x++) {
        buf.write((x % 10).abs());
      }
      buf.write('\n');
    }

    // Parcours lignes
    final yStart = invertY ? maxY : minY;
    final yEnd = invertY ? minY : maxY;
    final yStep = invertY ? -1 : 1;

    for (int y = yStart; invertY ? y >= yEnd : y <= yEnd; y += yStep) {
      // étiquette Y alignée
      if (showAxes) {
        buf.write(y.toString().padLeft(4));
        buf.write(' ');
      }
      for (int x = minX; x <= maxX; x++) {
        buf.write(set.contains(Point<int>(x, y)) ? live : dead);
      }
      buf.write('\n');
    }

    print(buf.toString());
  }

  @override
  void initState() {
    super.initState();
    _generationSpeed = _initialSpeed;
    _fastGeneration = theme.getIconSettings;
    _realyFastGeneration = theme.getIconSettings;
    _tickStart();
  }

  void _tickStart() {
    _tick?.cancel(); // Evite les doublons
    _tick = Timer.periodic(_generationSpeed, (timer) {
      if (_isPaused) return;

      if (_notInit) return;

      printDebug("Start $_generation° generation.");
      _initialCell = _life.startNextGeneration(generation: _generation);

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
          builder: (context) => PopupGeneric(
            title: 'ATTENTION',
            content: [
              StyledText(
                "Vous avez atteint le maximum ($_maxGenerations) de génération",
              ),
            ],
            theme: theme,
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
    _initialCell.clear();

    // Vide les buffers
    _life.clear();

    // Remet à 0 le timer
    _tickPause(reset: true);
    _tickReset();

    _generationSpeed = _initialSpeed;
    _fastGeneration = theme.getIconSettings;
    _realyFastGeneration = theme.getIconSettings;

    _resetId++; // Pour recrée un nouveau GridZoom
  }

  Widget _buildSettingsButton({
    required IconData icon,
    required Function() onPressed,
    Color? color,

    double size = 25,
  }) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero, // pas de padding
        minimumSize: Size(40, 40), // pas de taille mini
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Icon(icon, size: size, color: color ?? theme.getIconSettings),
    );
  }

  void _buildAboutPopup() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => PopupGeneric(
        title: 'Le jeu de la vie',
        content: [
          StyledText(
            "Créé par le mathématicien John Conway en 1970,\n",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          StyledText(
            "il s'agit d'un jeu à « zéro joueur ».\n\n",
            style: const TextStyle(fontSize: 16),
          ),
          StyledText(
            "C'est un automate cellulaire, un modèle où chaque état\n",
            style: const TextStyle(fontSize: 16),
          ),
          StyledText(
            "de la grille conduit au suivant selon des règles prédéfinies.\n\n",
            style: const TextStyle(fontSize: 16),
          ),
          StyledText(
            "Les règles sont :\n",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          StyledText(
            "    • Une cellule morte ayant exactement\n",
            style: const TextStyle(fontSize: 16),
          ),
          StyledText(
            "      trois voisines vivantes devient vivante (naissance).\n\n",
            style: const TextStyle(fontSize: 16),
          ),
          StyledText(
            "    • Une cellule vivante ayant moins de deux ou plus detrois\n",
            style: const TextStyle(fontSize: 16),
          ),
          StyledText(
            "      voisines vivantes meurt (sous-population ou surpopulation).\n\n",
            style: const TextStyle(fontSize: 16),
          ),
          StyledText(
            "En résumé, la vie dans les bonnes conditions engendre la vie,\n",
            style: const TextStyle(fontSize: 16),
          ),
          StyledText(
            "tandis qu'un excès ou un manque entraîne la mort.\n\n",
            style: const TextStyle(fontSize: 16),
          ),
          StyledText(
            "Ce jeu illustre comment des règles très simples peuvent\n",
            style: const TextStyle(fontSize: 16),
          ),
          StyledText(
            "engendrer une complexité et des motifs fascinants.\n\n",
            style: const TextStyle(fontSize: 16),
          ),
          StyledText(
            "Source : ",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          StyledText(
            "wikipédia",
            style: const TextStyle(
              color: Colors.blue,
              decoration: TextDecoration.underline,
              fontSize: 16,
            ),
            onTap: () => launchUrl(
              Uri.parse("https://fr.wikipedia.org/wiki/Jeu_de_la_vie"),
              mode: LaunchMode.externalApplication,
            ),
          ),
          StyledText(" - "),
          StyledText(
            "vidéo (EGO)",
            style: const TextStyle(
              color: Colors.blue,
              decoration: TextDecoration.underline,
              fontSize: 16,
            ),
            onTap: () => launchUrl(
              Uri.parse("https://www.youtube.com/watch?v=eMn43As24Bo"),
              mode: LaunchMode.externalApplication,
            ),
          ),
        ],
        theme: theme,
        scroll: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: theme.getGridBackgroundColor,
      // Le LayoutBuilder permet de récupèrer les dimenssions du téléphone
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenSize = Size(constraints.maxWidth, constraints.maxHeight);
          if (screenSize.width == 0 || screenSize.height == 0) {
            // tant que c'est 0, on n'utilise pas la taille
            return const SizedBox.shrink();
          }

          return Stack(
            children: [
              GridZoom(
                key: ValueKey(_resetId),
                life: _life,
                isPaused: _isPaused,
                generation: _generation,
                screenSize: Size(
                  MediaQuery.of(context).size.width,
                  MediaQuery.of(context).size.height,
                ),
                centerRequest: _center,
                initialCells: Set.of(_initialCell),
                theme: theme,
                getCells: (cells) {
                  _initialCell = Set.of(cells);
                },
              ),

              // Menu supéreur
              Align(
                alignment: Alignment.topCenter,
                child: Stack(
                  children: [
                    InformationsFrame(
                      backgroundColor: theme.getInformationBackground,
                      frameColor: theme.getInformationFrame,
                      // Pour garder la frame autour du child
                      child: IntrinsicWidth(
                        child: IntrinsicHeight(
                          child: Padding(
                            padding: const EdgeInsets.all(30),
                            child: Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Place les deux boutons
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Bouton pour le workshop
                                      Container(
                                        width: 35,
                                        height: 35,
                                        decoration: BoxDecoration(
                                          color: theme.getPrimary,
                                          borderRadius: BorderRadius.circular(
                                            5,
                                          ),
                                        ),
                                        child: _buildSettingsButton(
                                          icon: Icons.handyman,
                                          size: 25,
                                          onPressed: () async {
                                            // Permet de lancer le workshop que si le jeu n'est pas en cours
                                            if (!_isPaused) {
                                              InfoDisplayer.buildInfoDisplayer(
                                                context,
                                                "Impossible, générations en cours...",
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 50,
                                                      vertical: 20,
                                                    ),
                                                duration: const Duration(
                                                  seconds: 10,
                                                ),
                                              );
                                              return;
                                            }

                                            // Récuère le nom de la catégorie et l'objet séléctionné
                                            final indexPattern =
                                                await showDialog<Point<int>?>(
                                                  context: context,
                                                  barrierDismissible: true,
                                                  builder: (context) =>
                                                      PopupWorkShop(
                                                        theme: theme,
                                                      ),
                                                );

                                            // Si un objet à été séléctionner alors mets à jours la liste initial avec et notifie tout le monde
                                            if (indexPattern != null) {
                                              setState(() {
                                                _initialCell = LifePatterns
                                                    .all[indexPattern
                                                        .x][indexPattern.y]
                                                    .translated()
                                                    .getCells;
                                              });
                                            }
                                          },
                                        ),
                                      ),

                                      const SizedBox(height: 10),

                                      // Bouton help
                                      Container(
                                        width: 25,
                                        height: 25,
                                        decoration: BoxDecoration(
                                          color: theme.getPrimary,
                                          shape: BoxShape.circle,
                                        ),
                                        child: _buildSettingsButton(
                                          icon: Icons.help,
                                          size: 15,
                                          onPressed: () => _buildAboutPopup(),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(width: 15),

                                  CustomPaint(
                                    painter: FrameInformationDelimiter(
                                      frameColor: theme.getInformationFrame,
                                    ),
                                    child: SizedBox(
                                      width: 2,
                                      height: double.infinity,
                                    ),
                                  ),

                                  const SizedBox(width: 15),

                                  // Informations sur le jeu en cours
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Générations : $_generation",
                                        style: theme.popupContentLabel(),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        "Nombre de cellules en vie : ${_life.getCounterCellsAlive}",
                                        style: theme.popupContentLabel(),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        "Chunks : ${_life.getChunks.length}",
                                        style: theme.popupContentLabel(),
                                      ),
                                      Text(
                                        "Grille : ${format.format((gridSize.width / 10).toInt())}x${format.format((gridSize.height / 10).toInt())}",
                                        style: theme.popupContentLabel(),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Menu général
              Align(
                alignment: Alignment.bottomRight,
                child: SizedBox(height: 115, child: FloatingMenu(theme)),
              ),

              // Menu inférieur
              Align(
                alignment: Alignment.bottomCenter,
                // Crée une boîte pour contenir les settings
                child: TextButton(
                  onPressed: () {},
                  child: Container(
                    width: 200,
                    height: 50,
                    decoration: BoxDecoration(
                      color: theme.getPrimary,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    // Place les élément de paramètres
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Bouton pour ouvrir les settings
                        _buildSettingsButton(
                          icon: Icons.gps_fixed,
                          onPressed: () {
                            setState(() => _center = true);
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              _center = false;
                            });
                          },
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
                            setState(() {
                              Duration newSpeed = Duration(milliseconds: 300);
                              if (_generationSpeed != newSpeed) {
                                _realyFastGeneration = theme.getIconSettings;
                                _fastGeneration = theme.getselectedIconSettings;
                                _changeInterval(newSpeed);
                              } else {
                                _fastGeneration = theme.getIconSettings;
                                _changeInterval(_initialSpeed);
                              }
                            });
                          },
                        ),

                        // Bouton pour avance très rapide de la génération
                        _buildSettingsButton(
                          icon: Icons.fast_forward,
                          color: _realyFastGeneration,
                          onPressed: () {
                            setState(() {
                              Duration newSpeed = Duration(milliseconds: 50);
                              if (_generationSpeed != newSpeed) {
                                _realyFastGeneration =
                                    theme.getselectedIconSettings;
                                _fastGeneration = theme.getIconSettings;
                                _changeInterval(newSpeed);
                              } else {
                                _realyFastGeneration = theme.getIconSettings;
                                _changeInterval(_initialSpeed);
                              }
                            });
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
          );
        },
      ),
    );
  }
}
