import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:richard/assets/constants.dart';
import 'package:richard/dbug.dart';
import 'package:richard/modeles/life.dart';
import 'package:richard/modeles/weatherAPI.dart';
import 'package:richard/ui/theme.dart';

// __        _______    _  _____ _   _ _____ ____
// \ \      / / ____|  / \|_   _| | | | ____|  _ \
//  \ \ /\ / /|  _|   / _ \ | | | |_| |  _| | |_) |
//   \ V  V / | |___ / ___ \| | |  _  | |___|  _ <
//    \_/\_/  |_____/_/   \_\_| |_| |_|_____|_| \_\

// ==================================
// ====-------  DARWINGS  -------====
// ==================================

/*
  Crée un rond de couleur en fonction de la météo du jour
*/
class WeatherCircle extends CustomPainter {
  final WeatherTheme theme;

  WeatherCircle(this.theme);

  @override
  void paint(Canvas canvas, Size size) {
    // Initialise les couleurs

    // Crée les deux parties du cercle, la bordure et le centre
    final strokeWidth = 12.0;
    Paint borderCircle = Paint()
      ..strokeWidth = strokeWidth
      ..color = theme.getTertiary
      ..style = PaintingStyle.stroke;
    Paint fillCircle = Paint()
      ..color = theme.getPrimary
      ..style = PaintingStyle.fill;

    // Centre le cercle
    Offset center = Offset(size.width / 2, size.height / 2);
    double radius = size.width / 2;

    // Dessine le cercle
    canvas.drawCircle(center, radius, fillCircle);
    canvas.drawCircle(center, radius + strokeWidth / 2, borderCircle);
  }

  // Pas utile car le cercle ne changera pas
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

/*
  Crée une ligne horizontal équitablement bicolor
*/
class DividedLine extends CustomPainter {
  final bool day;

  DividedLine(this.day);

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 7.0;

    // Crée les deux parties de la ligne et assigne une couleur
    // en fonction d'une variable qui change lors d'un appuie sur un bouton
    Color colorDay = day
        ? Colors.white
        : const Color.fromARGB(225, 104, 76, 124);
    Color colorWeek = day
        ? const Color.fromARGB(225, 104, 76, 124)
        : Colors.white;

    Paint lineDay = Paint()
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap
          .round // Rend les bouts de la ligne rond
      ..color = colorDay
      ..style = PaintingStyle.fill;

    Paint lineWeek = Paint()
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap
          .round // Rend les bouts de la ligne rond
      ..color = colorWeek
      ..style = PaintingStyle.fill;

    // Calcul les dimenssion des lignes pour être équitablement divisé
    Offset p1Day = Offset(0, 0);
    Offset p2Day = Offset(size.width / 2, 0);
    Offset p1Week = Offset(size.width / 2, 0);
    Offset p2Week = Offset(size.width, 0);

    // Les bouts des lignes sont arrondis, la ligne qui est dessiné en dernier
    // chevauchera la première. De cette manière c'est toujours celui séléctionné
    // qui a le focus
    if (day) {
      canvas.drawLine(p1Week, p2Week, lineWeek);
      canvas.drawLine(p1Day, p2Day, lineDay);
    } else {
      canvas.drawLine(p1Day, p2Day, lineDay);
      canvas.drawLine(p1Week, p2Week, lineWeek);
    }
  }

  // Permet de recharger l'affichage au changement de la variable day
  @override
  bool shouldRepaint(covariant DividedLine oldDelegate) {
    return oldDelegate.day != day;
  }
}

/*
  Permet de créer un cadre arrondi de couleur
*/
class FrameRounded extends CustomPainter {
  final Color colorFrame;

  FrameRounded(this.colorFrame);

  @override
  void paint(Canvas canvas, Size size) {
    final double strokeWidth = 2;

    // Crée un cadre rectangulaire
    Paint rectangle = Paint()
      ..strokeWidth = strokeWidth
      ..color = colorFrame
      ..style = PaintingStyle.stroke;

    // Ajoute les contraintes pour les bords arrondis
    final rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );

    // Dessine le rectangle
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(5)),
      rectangle,
    );
  }

  // Pas utile car le cercle ne changera pas
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

/*
  Permet de créer un rectangle avec bordure et avec une ombre
*/
class FrameTitle extends CustomPainter {
  final double padding;
  final WeatherTheme theme;
  Color border = const Color.fromARGB(255, 140, 140, 140);
  Color shadowColor = const Color.fromARGB(127, 162, 162, 162);

  FrameTitle({required this.padding, required this.theme});

  @override
  void paint(Canvas canvas, Size size) {
    const double borderWidth = 2;
    // Crée un rectange plein
    Paint rectangle = Paint()
      ..color = theme.getSecondary
      ..style = PaintingStyle.fill;
    Rect rect = Rect.fromLTRB(-padding, 0, size.width + padding, size.height);

    // Crée le cadre exterieur du rectangle plein
    Paint frameExt = Paint()
      ..strokeWidth = borderWidth
      ..color = border
      ..style = PaintingStyle.stroke;
    // Ajoute les contraintes pour les bords arrondis
    Rect rectFrameExt = Rect.fromLTRB(
      -padding,
      0,
      size.width + padding,
      size.height,
    );

    // Crée un cadre intérieur du rectange plein
    Paint frameInt = Paint()
      ..strokeWidth = borderWidth
      ..color = border
      ..style = PaintingStyle.stroke;
    double offset = 4;
    // Ajoute les contraintes pour les bords arrondis
    Rect rectFrameInt = Rect.fromLTRB(
      offset - padding,
      offset,
      size.width - offset + padding,
      size.height - offset,
    );

    // Crée un effet d'ombre pour le rectangle plein
    Paint shadow = Paint()
      ..strokeWidth = borderWidth
      ..color = shadowColor
      ..style = PaintingStyle.fill;
    // Ajoute les contraintes pour les bords arrondis
    Rect rectShadow = Rect.fromLTRB(
      offset - padding,
      offset,
      size.width + offset + padding,
      size.height + offset,
    );

    // Dessin les rectangles dans l'ordre pour avoir le compsent final
    canvas.drawRRect(
      RRect.fromRectAndRadius(rectShadow, Radius.circular(5)),
      shadow,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(5)),
      rectangle,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rectFrameExt, Radius.circular(5)),
      frameExt,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rectFrameInt, Radius.circular(5)),
      frameInt,
    );
  }

  // Pas utile car le cercle ne changera pas
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

/*
  Permet de créer un bouton stylisé
*/
class ButtonPopup extends CustomPainter {
  final Color fill;

  ButtonPopup({super.repaint, required this.fill});

  @override
  void paint(Canvas canvas, Size size) {
    // Crée un rectangle plein
    Paint rectangle = Paint()
      ..color = fill
      ..style = PaintingStyle.fill;

    // Ajoute les contraintes pour les bords arrondis
    Rect rect = Rect.fromLTRB(0, 0, size.width, size.height);

    // Dessine le rectangle
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(10)),
      rectangle,
    );
  }

  // Pas utile car le cercle ne changera pas
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

// ===================================================
// ====-------  CUSTOM EXISTING COMPONANT  -------====
// ===================================================

/*
  Crée un carte pour afficher les prévisions météo
*/
class WeatherCard extends StatelessWidget {
  final String title;
  final String temperature;
  final WeatherTheme theme;
  final ColorCode weather;
  final void Function()? onTap;

  const WeatherCard({
    super.key,
    required this.title,
    required this.temperature,
    required this.weather,
    required this.theme,
    this.onTap,
  });

  // Associe chaque temps à un icon
  Image getCorrectIcon() {
    final String path;
    switch (weather) {
      case ColorCode.SUN:
        path = "assets/icons/sun.png";
        break;
      case ColorCode.SOME_CLOUDS:
        path = "assets/icons/some_clouds.png";
        break;
      case ColorCode.CLOUDS:
        path = "assets/icons/clouds.png";
        break;
      case ColorCode.RAIN:
        path = "assets/icons/rain.png";
        break;
      case ColorCode.SNOW:
        path = "assets/icons/snow.png";
        break;
      case ColorCode.THUNDERSTORM:
        path = "assets/icons/thunderstorm.png";
        break;
      case ColorCode.HAIL:
        path = "assets/icons/hail.png";
        break;
      case ColorCode.UNKNOW:
        path = "assets/icons/no_signal.png";
        break;
    }
    return Image.asset(path, fit: BoxFit.contain);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 6,
      shadowColor: const Color.fromARGB(62, 212, 212, 212),
      color: const Color.fromARGB(25, 255, 255, 255),
      // Forme de capsule avec des fin bords blancs
      shape: const StadiumBorder(
        side: BorderSide(color: Color.fromARGB(51, 255, 255, 255), width: 1.2),
      ),
      clipBehavior: Clip.antiAlias, // Découpe en suivant la forme
      // Comme GestureDetector mais avec un effet de splash
      child: InkWell(
        onTap: onTap,
        customBorder:
            const StadiumBorder(), // Fait en sorte que le splash soit en forme de capsule
        splashFactory:
            InkRipple.splashFactory, // Animation d'onde de choc au clic
        splashColor: const Color.fromARGB(
          76,
          255,
          255,
          255,
        ), // Couleur de l'onde
        highlightColor: const Color.fromARGB(
          5,
          255,
          255,
          255,
        ), // Couleur lors du maintient du clic
        child: SizedBox(
          width: 100,
          height: 180,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Affiche l'heure, l'icon et la température souhaité
              Text(title, style: theme.weatherCard()),
              const SizedBox(height: 12),
              SizedBox(width: 60, height: 60, child: getCorrectIcon()),
              const SizedBox(height: 12),
              Text(temperature, style: theme.weatherCard()),
            ],
          ),
        ),
      ),
    );
  }
}

/*
  Crée un bouton switch personalisé
*/
class SwitchLine extends StatelessWidget {
  final WeatherTheme theme;
  final double width;
  final bool day; // Reçoit l’état du parent
  final VoidCallback onTap; // Callback pour informer le parent du tap

  const SwitchLine({
    super.key,
    required this.theme,
    required this.width,
    required this.day,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap, // Appelle le parent
      child: SizedBox(
        width: width,
        child: Column(
          children: [
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("DAY", style: theme.customSwitch(day)),
                Text("WEEK", style: theme.customSwitch(!day)),
              ],
            ),
            const SizedBox(height: 5),
            CustomPaint(
              painter: DividedLine(day),
              child: SizedBox(width: width),
            ),
          ],
        ),
      ),
    );
  }
}

// ===============================
// ====-------  POPUP  -------====
// ===============================

/*
  Crée un popup informatif pour des données supplémentaires
*/
class PopupDisplayInfos extends StatefulWidget {
  final String title;
  final Map<String, String?> content;
  final PopupColorCode style;

  const PopupDisplayInfos({
    super.key,
    required this.title,
    required this.content,
    required this.style,
  });

  @override
  State<StatefulWidget> createState() => _PopupDisplayInfosState();
}

class _PopupDisplayInfosState extends State<PopupDisplayInfos> {
  // Construit une section de texte pour avoir un label avec un style (ex regular)
  // et la variable associé avec un autre style (ex bold)
  RichText _buildDataSection(String label, String? variable) {
    return RichText(
      text: TextSpan(
        children: [
          // Affichage du label
          TextSpan(text: label, style: widget.style.getLabelStyle),
          // Sur la même ligne affichage de la variable
          TextSpan(text: variable ?? "", style: widget.style.getVariableStyle),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: widget.style.getBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: IntrinsicWidth(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Crée un cadre et place à l'interieur les données passé en paramètre
              CustomPaint(
                painter: FrameRounded(widget.style.getFrameColor),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 15),
                      Text(widget.title, style: widget.style.getTitleStyle),
                      const SizedBox(height: 16),
                      Column(
                        children: [
                          for (var data in widget.content.entries)
                            _buildDataSection(data.key, data.value),
                          const SizedBox(height: 15),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Crée un bouton personalisé qui prend la même largeur que le cadre
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop(true);
                },
                child: SizedBox(
                  width: double.infinity,
                  child: CustomPaint(
                    painter: ButtonPopup(fill: widget.style.getButtonColor),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Center(
                        child: Text(
                          "OK",
                          style: widget.style.getButtonTextColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/*
  Crée une zone d'auto-completion à partir d'une valeur initial et d'une liste
*/
class CityAutoComplete<T> extends StatelessWidget {
  final T currentData;
  final Map<T, String> dataList;
  final TextStyle style;
  final void Function(City)? onSelected;
  const CityAutoComplete({
    super.key,
    required this.currentData,
    required this.dataList,
    required this.style,
    this.onSelected,
  });

  static String _displayStringForOption(City option) => option.name;

  @override
  Widget build(BuildContext context) {
    final List<City<T>> cities = dataList.entries
        .map((entry) => City<T>(name: entry.value, codeInsee: entry.key))
        .toList();
    printDebug("Autocomplete : $currentData");
    return Autocomplete<City<T>>(
      initialValue: TextEditingValue(
        text: dataList.entries
            .firstWhere(
              (entry) => entry.key == currentData,
              orElse: () => MapEntry<T, String>(currentData, "Inconnue"),
            )
            .value,
      ),
      displayStringForOption: _displayStringForOption,

      // Filtrage dynamique des options selon la saisie utilisateur
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text == '') {
          return Iterable<City<T>>.empty();
        }
        return cities.where((City option) {
          return option.getName.toLowerCase().contains(
            textEditingValue.text.toLowerCase(),
          );
        });
      },

      // Construction du champ de saisie personnalisé (le style du composent)
      fieldViewBuilder:
          (context, textEditingController, focusNode, onFieldSubmitted) {
            return TextField(
              controller: textEditingController,
              focusNode: focusNode,
              onSubmitted: (value) => onFieldSubmitted(),
              decoration: const InputDecoration.collapsed(hintText: ''),
              style: style,
              textAlign: TextAlign.center,
            );
          },

      // Callback appelé quand une ville est sélectionnée
      onSelected: (City selection) {
        if (onSelected != null) {
          onSelected!(selection);
        }
      },
    );
  }
}

/*
  Crée un popup de chargement
*/
class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 120,
        height: 120,
        child: Material(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 60,
                height: 60,
                child: LoadingIndicator(
                  indicatorType: Indicator.lineSpinFadeLoader,
                  colors: [
                    Colors.black,
                    Colors.grey[800]!,
                    Colors.grey[600]!,
                    Colors.grey[400]!,
                    Colors.grey[200]!,
                  ],
                  strokeWidth: 2,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "Loading...",
                style: TextStyle(
                  fontFamily: 'BebasNeue',
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/*
  Crée un menu déroulant personalisé
*/
class FloatingMenu extends StatefulWidget {
  final WeatherTheme theme;
  const FloatingMenu(this.theme, {super.key});

  @override
  State<FloatingMenu> createState() => _FloatingMenuState();
}

class _FloatingMenuState extends State<FloatingMenu> {
  bool _menuOpen = false;

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      style: MenuStyle(
        backgroundColor: WidgetStateProperty.all(widget.theme.getSecondary),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        elevation: WidgetStateProperty.all(6),
      ),
      onOpen: () => setState(() => _menuOpen = true),
      onClose: () => setState(() => _menuOpen = false),
      alignmentOffset: const Offset(-80, 0),
      builder: (context, controller, child) {
        return TextButton(
          onPressed: () =>
              controller.isOpen ? controller.close() : controller.open(),
          child: Container(
            decoration: BoxDecoration(
              color: widget.theme.getButton,
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(8),
            child: Icon(
              _menuOpen ? Icons.close : Icons.menu,
              size: 30,
              color: Colors.white,
            ),
          ),
        );
      },
      menuChildren: <Widget>[
        MenuItemButton(
          leadingIcon: const Icon(Icons.person),
          child: const Text("Météo"),
          onPressed: () {},
        ),

        MenuItemButton(
          leadingIcon: const Icon(Icons.person),
          child: const Text("Rapel"),
          onPressed: () {},
        ),

        MenuItemButton(
          leadingIcon: const Icon(Icons.person),
          child: const Text("Liste course"),
          onPressed: () {},
        ),
      ],
    );
  }
}

//   ____    _    __  __ _____ ____
//  / ___|  / \  |  \/  | ____/ ___|
// | |  _  / _ \ | |\/| |  _| \___ \
// | |_| |/ ___ \| |  | | |___ ___) |
//  \____/_/   \_\_|  |_|_____|____/

// ==================================
// ====-------  DARWINGS  -------====
// ==================================
/*
  Permet de dessiner un petit rond plein pour les settings
*/
class RoundButton extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint round = Paint()
      ..color = Colors.amber
      ..style = PaintingStyle.fill;

    Offset center = Offset(size.width / 2, size.height / 2);
    double radius = size.width / 2;

    canvas.drawCircle(center, radius, round);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

/*
  Permet de dessiner une grille dont les dimenssions sont en paramètres
*/
class GridPainter extends CustomPainter {
  GridPainter({required this.cell});

  final double cell;

  @override
  void paint(Canvas canvas, Size size) {
    printDebug("Running gridPainter", debug: false);

    // Crée les grosses bordures
    final minorLinePaint = Paint()
      ..color = Colors.white54
      ..strokeWidth = 0.6;
    // Crée les petites bordures
    final majorLinePaint = Paint()
      ..color = Colors.white70
      ..strokeWidth = 1.0;

    // Lignes verticales
    for (double x = 0; x <= size.width; x += cell) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        (x / cell) % 4 == 0 ? majorLinePaint : minorLinePaint,
      );
    }
    // Lignes horizontales
    for (double y = 0; y <= size.height; y += cell) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        (y / cell) % 4 == 0 ? majorLinePaint : minorLinePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant GridPainter old) => old.cell != cell;
}

/*
  Permet de dessiner une cellule (dans la grille de GridPainter)
  à un emplacement passé en paramètre
*/
class CellPaint extends CustomPainter {
  final List<Offset> positions;
  final double cellDimensions;

  CellPaint({
    super.repaint,
    required this.positions,
    required this.cellDimensions,
  });

  @override
  void paint(Canvas canvas, Size size) {
    printDebug("Running cellPaint", debug: false);

    // Crée une cellule
    Paint cell = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Permet de peindre l'historique des cellules
    for (var position in positions) {
      // Calcule la position de la cellule
      Rect rect = Rect.fromLTWH(
        position.dx,
        position.dy,
        cellDimensions,
        cellDimensions,
      );

      printDebug(
        "Painting $cellDimensions len cell at : (X=${position.dx};Y=${position.dy})",
        debug: false,
      );
      // Peint la cellule
      canvas.drawRect(rect, cell);
    }
  }

  @override
  bool shouldRepaint(covariant CellPaint oldDelegate) {
    // Si la liste à changer alors repeindre les cellules
    Function eq = const ListEquality().equals;
    return !eq(oldDelegate.positions, positions);
  }
}

// ===================================================
// ====-------  CUSTOM EXISTING COMPONANT  -------====
// ===================================================

// ===============================
// ====-------  POPUP  -------====
// ===============================
/*
  Permet d'obtenir un bouton personaliser pour les settings
*/
class SettingsMenu extends StatelessWidget {
  const SettingsMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: RoundButton(),
      child: SizedBox(
        width: 30,
        height: 30,
        child: Icon(Icons.settings, color: Colors.white),
      ),
    );
  }
}

// ==============================
// ====-------  GAME  -------====
// ==============================
/*
  Permet de déterminer la position de tap sur la grille généré
  et dessine un cellule à cette emplacement
*/
class GridZoom extends StatefulWidget {
  final double cell;
  final LifeLogique life;
  final bool isPaused;
  final int generation;
  final void Function(List<Point<int>>) getCells;

  const GridZoom({
    super.key,
    this.cell = cellSize,
    required this.life,
    required this.isPaused,
    required this.generation,
    required this.getCells,
  });

  @override
  State<GridZoom> createState() => _GridZoomState();
}

class _GridZoomState extends State<GridZoom> {
  late TransformationController _controller; // Pour définir la zone de spawn

  List<Offset> cellPositionsUI =
      []; // Permet d'avoir un historique des cellules à afficher et donc de garder d'afficher les cellules peintes
  List<Point<int>> cellPositionsBack =
      []; // Permet d'avoir un historique des cellules à envoyer à la logique et donc de garder d'afficher les cellules peintes

  void _getNextGeneration() {
    cellPositionsUI = [];
    for (var chunk in widget.life.getChunks.values) {
      List<Point<int>> allCells = chunk.getAllCells();
      for (var chunkCell in allCells) {
        cellPositionsUI.add(
          Offset(chunkCell.x * widget.cell, chunkCell.y * widget.cell),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    if (!widget.isPaused) {
      _getNextGeneration();
    }

    _controller = TransformationController();

    // Centre initial + zoom 1x
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final gridWidth = gridSize.width;
      final gridHeight = gridSize.height;
      final viewportWidth = MediaQuery.of(context).size.width;
      final viewportHeight = MediaQuery.of(context).size.height;

      // Décalage pour centrer la grille
      final dx = (viewportWidth - gridWidth) / 2;
      final dy = (viewportHeight - gridHeight) / 2;

      _controller.value = Matrix4.identity()
        ..translate(dx, dy) // déplacement
        ..scale(1.0); // zoom initial
    });
  }

  @override
  void didUpdateWidget(covariant GridZoom oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.generation != widget.generation ||
        oldWidget.life != widget.life) {
      _getNextGeneration();
    }
  }

  @override
  Widget build(BuildContext context) {
    // InteractiveViewer permet de se déplacer et zoomer dans un widget (ici la grille)
    return InteractiveViewer(
      transformationController: _controller,
      constrained: false,
      boundaryMargin: const EdgeInsets.all(170),
      minScale: 0.5,
      maxScale: 5,
      child: GestureDetector(
        // Détecte chaque clique dans la grille et détermine sa position
        onTapDown: (TapDownDetails details) {
          if (widget.isPaused) {
            printDebug("local position : ${details.localPosition}");
            // Convertit la position en int (ex X=28.9 - Y=34.2 => X=20.0 Y=30.0) affine de faire les calculs en backend avec une grille plus petite
            Offset posUI = Offset(
              (details.localPosition.dx ~/ widget.cell).toDouble() *
                  widget
                      .cell, // Sans widget.cell si le doit est sur X=1 - Y=1 il sera interprété
              (details.localPosition.dy ~/ widget.cell).toDouble() *
                  widget
                      .cell, // comme 1px - 1px au lieu de la case 1-1, donc widget.cell permet de convertir
            );

            Point<int> posBack = Point<int>(
              details.localPosition.dx ~/ widget.cell,
              details.localPosition.dy ~/ widget.cell,
            );

            printDebug("X = ${posUI.dx} - Y = ${posUI.dy}");
            setState(() {
              printDebug("cellPositions : back : $cellPositionsBack");
              if (!cellPositionsUI.contains(posUI)) {
                printDebug("add ui $posUI");
                cellPositionsUI = List.of(cellPositionsUI)
                  ..add(
                    posUI,
                  ); // Copie l'ancienne liste dans une nouvelle instance et assigne cette nouvelle liste à l'ancienne pour que le shouldRepaint détécte une nouvelle liste
              } else {
                // Si le point existe déjà alors le supprimer
                cellPositionsUI = List.of(cellPositionsUI)
                  ..removeWhere((position) => position == posUI);
              }

              // Mets à jour la liste pour le backend
              if (!cellPositionsBack.contains(posBack)) {
                printDebug("add back $posBack");
                cellPositionsBack = List.of(cellPositionsBack)..add(posBack);
              } else {
                cellPositionsBack = List.of(cellPositionsBack)
                  ..removeWhere((position) => position == posBack);
              }

              widget.getCells(List.of(cellPositionsBack));
            });
          }
        },
        child: CustomPaint(
          size: gridSize,
          painter: GridPainter(cell: widget.cell),
          foregroundPainter: CellPaint(
            positions: cellPositionsUI,
            cellDimensions: widget.cell,
          ),
        ),
      ),
    );
  }
}
