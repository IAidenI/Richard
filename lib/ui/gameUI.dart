import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:richard/assets/constants.dart';
import 'package:richard/dbug.dart';
import 'package:richard/modeles/life.dart';
import 'package:richard/modeles/patterns.dart';
import 'package:richard/ui/theme.dart';
import 'package:richard/ui/weatherUI.dart';

// ==================================
// ====-------  DARWINGS  -------====
// ==================================
/*
  Permet de dessiner une grille dont les dimenssions sont en paramètres
*/
class GridPainter extends CustomPainter {
  final Color? gridColor;
  GridPainter({required this.cell, this.gridColor});

  final double cell;

  @override
  void paint(Canvas canvas, Size size) {
    // Crée les grosses bordures
    final minorLinePaint = Paint()
      ..color = gridColor ?? Colors.black
      ..strokeWidth = minorLineStrokeWidth;
    // Crée les petites bordures
    final majorLinePaint = Paint()
      ..color = gridColor ?? Colors.black
      ..strokeWidth = majorLineStrokeWidth;

    // Lignes verticales
    for (double x = 0; x <= size.width; x += cell) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        (x / cell) % littleGrid == 0 ? majorLinePaint : minorLinePaint,
      );
    }
    // Lignes horizontales
    for (double y = 0; y <= size.height; y += cell) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        (y / cell) % littleGrid == 0 ? majorLinePaint : minorLinePaint,
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
  final Set<Point<int>> positions;
  final double cellDimensions;
  final Color? cellColor;

  CellPaint({
    super.repaint,
    required this.positions,
    required this.cellDimensions,
    this.cellColor,
  });

  bool _isMajor(int index) => index % littleGrid == 0;

  @override
  void paint(Canvas canvas, Size size) {
    printDebug("Running cellPaint", debug: false);

    // Crée une cellule
    Paint cell = Paint()
      ..color = cellColor ?? Colors.white70
      ..style = PaintingStyle.fill;

    // Permet de peindre l'historique des cellules
    for (var position in positions) {
      // Indices de grille (colonne/ligne)
      final col = (position.x / cellDimensions).round();
      final row = (position.y / cellDimensions).round();

      // Moitiés d’épaisseur sur chaque bord de la cellule
      final leftInset =
          (_isMajor(col) ? majorLineStrokeWidth : minorLineStrokeWidth) / 2;
      final topInset =
          (_isMajor(row) ? majorLineStrokeWidth : minorLineStrokeWidth) / 2;
      final rightInset =
          (_isMajor(col + 1) ? majorLineStrokeWidth : minorLineStrokeWidth) / 2;
      final bottomInset =
          (_isMajor(row + 1) ? majorLineStrokeWidth : minorLineStrokeWidth) / 2;

      // Calcule la position de la cellule
      Rect rect = Rect.fromLTWH(
        position.x.toDouble() + leftInset,
        position.y.toDouble() + topInset,
        cellDimensions - (rightInset + leftInset),
        cellDimensions - (bottomInset + rightInset),
      );

      printDebug(
        "Painting $cellDimensions len cell at : (X=${position.x};Y=${position.y})",
        debug: false,
      );
      // Peint la cellule
      canvas.drawRect(rect, cell);
    }
  }

  @override
  bool shouldRepaint(covariant CellPaint oldDelegate) {
    // Si la liste à changer alors repeindre les cellules
    Function eq = const SetEquality<Point<int>>().equals;
    return !eq(oldDelegate.positions, positions);
  }
}

class FrameGradient extends CustomPainter {
  final Color color;

  FrameGradient({super.repaint, required this.color});

  Color addToColor(Color color, {int amount = 20, double alphaFactor = 0.8}) {
    int clamp(int value) => value.clamp(0, 255);

    return Color.fromARGB(
      clamp((color.a * 255 * alphaFactor).round()),
      clamp((color.r * 255).round() + amount),
      clamp((color.g * 255).round() + amount),
      clamp((color.b * 255).round() + amount),
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final double strokeWidth = 2;
    Color color1 = color;
    Color color2 = addToColor(color);
    Color color3 = addToColor(color2);

    Paint frame1 = Paint()
      ..strokeWidth = strokeWidth
      ..color = color1
      ..style = PaintingStyle.stroke;

    Paint frame2 = Paint()
      ..strokeWidth = strokeWidth
      ..color = color2
      ..style = PaintingStyle.stroke;

    Paint frame3 = Paint()
      ..strokeWidth = strokeWidth
      ..color = color3
      ..style = PaintingStyle.stroke;

    // Ajoute les contraintes pour les bords arrondis
    final rect1 = Rect.fromLTWH(0, 0, size.width, size.height);
    final rect2 = Rect.fromLTWH(
      strokeWidth,
      strokeWidth,
      size.width - strokeWidth * 2,
      size.height - strokeWidth * 2,
    );
    final rect3 = Rect.fromLTWH(
      strokeWidth * 2,
      strokeWidth * 2,
      size.width - strokeWidth * 4,
      size.height - strokeWidth * 4,
    );

    // Dessine le rectangle
    canvas.drawRect(rect1, frame1);
    canvas.drawRect(rect2, frame2);
    canvas.drawRect(rect3, frame3);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

// ===================================================
// ====-------  CUSTOM EXISTING COMPONANT  -------====
// ===================================================

// ===============================
// ====-------  POPUP  -------====
// ===============================
/*
  Permet d'obtenir un popup générique personalisable
*/
class PopupWorkShop extends StatefulWidget {
  final GameLifeThemes theme;
  final List<List<LifePatterns>> patterns = LifePatterns.all;
  final double delimiterSize = 2.0;

  PopupWorkShop({super.key, required this.theme});

  @override
  State<PopupWorkShop> createState() => _PopupWorkShopState();
}

class _PopupWorkShopState extends State<PopupWorkShop> {
  int _selectedMenuIndex = 0;
  int _selectedItemIndex = 0;

  Widget _buildScrollMenu() {
    return SizedBox(
      height: 40,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 238, 238, 238),
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.patterns.length, (index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedMenuIndex = index),
                  child: Container(
                    decoration: BoxDecoration(
                      color: _selectedMenuIndex == index
                          ? const Color.fromARGB(255, 44, 44, 44)
                          : const Color.fromARGB(255, 238, 238, 238),
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 5,
                        horizontal: 12,
                      ),
                      child: Text(
                        widget.patterns[index].first.category,
                        style: TextStyle(
                          color: const Color.fromARGB(255, 187, 187, 187),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildButtoon({required String data, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: widget.theme.getButtonColor,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          child: Center(
            child: Text(data, style: TextStyle(color: widget.theme.getPrimary)),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection(List<String> infos, int index) {
    return GestureDetector(
      onTap: () => setState(() => _selectedItemIndex = index),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              decoration: BoxDecoration(
                color: _selectedItemIndex == index
                    ? const Color.fromARGB(255, 44, 44, 44)
                    : const Color.fromARGB(255, 217, 217, 217),
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 75,
                      height: 75,
                      child: Image.asset(
                        "assets/games/GameOfLife/patterns/glider.png",
                      ),
                    ),

                    const SizedBox(width: 5),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (var info in infos) ...[
                          Text(info, style: widget.theme.popupLabel()),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard() {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: 350),
      child: IntrinsicWidth(
        child: CustomPaint(
          foregroundPainter: FrameGradient(
            color: const Color.fromARGB(255, 100, 100, 100),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            padding: const EdgeInsets.all(5),
            child: Column(
              children: [
                for (
                  int item = 0;
                  item < widget.patterns[_selectedMenuIndex].length;
                  item++
                ) ...[
                  _buildInfoSection([
                    widget.patterns[_selectedMenuIndex][item].getFormattedName,
                    widget.patterns[_selectedMenuIndex][item].getFormattedSize,
                    widget
                        .patterns[_selectedMenuIndex][item]
                        .getFormattedGenerations,
                  ], item),
                ],
                /*for (var pattern in widget.patterns[_selectedMenuIndex]) ...[
                  _buildInfoSection([
                    pattern.getFormattedName,
                    pattern.getFormattedSize,
                    pattern.getFormattedGenerations,
                  ]),
                ],*/
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: IntrinsicWidth(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Crée un cadre et place à l'interieur les données passé en paramètre
              const SizedBox(height: 15),

              Text("Workshop", style: widget.theme.popupTitle()),

              const SizedBox(height: 15),

              _buildScrollMenu(),

              const SizedBox(height: 15),

              _buildCategoryCard(),

              const SizedBox(height: 15),

              // Crée un bouton personalisé qui prend la même largeur que le cadre
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildButtoon(
                    data: "Valider",
                    onTap: () => Navigator.of(
                      context,
                    ).pop(Point<int>(_selectedMenuIndex, _selectedItemIndex)),
                  ),
                  _buildButtoon(
                    data: "Annuler",
                    onTap: () => Navigator.of(context).pop(null),
                  ),
                ],
              ),
            ],
          ),
        ),
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
  final Size screenSize;
  final bool centerRequest;
  final Set<Point<int>>? initialCells;
  final GameLifeThemes? theme;
  final void Function(Set<Point<int>>) getCells;

  const GridZoom({
    super.key,
    this.cell = cellSize,
    required this.life,
    required this.isPaused,
    required this.generation,
    required this.screenSize,
    this.centerRequest = false,
    this.initialCells,
    this.theme,
    required this.getCells,
  });

  @override
  State<GridZoom> createState() => _GridZoomState();
}

class _GridZoomState extends State<GridZoom> {
  final TransformationController _controller =
      TransformationController(); // Pour définir la zone de spawn

  // Permet d'avoir un historique des cellules à afficher et donc de garder d'afficher les cellules peintes
  Set<Point<int>> cellPositionsUI = <Point<int>>{};
  // Permet d'avoir un historique des cellules à envoyer à la logique et donc de garder d'afficher les cellules peintes
  Set<Point<int>> cellPositionsBack = <Point<int>>{};

  Set<Point<int>> convertBackToUi(Set<Point<int>> back) {
    Set<Point<int>> ui = <Point<int>>{};
    for (var cell in back) {
      ui.add(
        Point<int>(
          (cell.x * widget.cell).toInt(),
          (cell.y * widget.cell).toInt(),
        ),
      );
    }
    return ui;
  }

  void _getNextGeneration() {
    final next = <Point<int>>{};
    for (var chunk in widget.life.getChunks.values) {
      for (var c in chunk.getAllCells()) {
        next.add(
          Point<int>((c.x * widget.cell).toInt(), (c.y * widget.cell).toInt()),
        );
      }
    }
    setState(() {
      cellPositionsUI = next; // Notifie le shouldRepaint
    });
  }

  void _centerGrid() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final phoneWidth = widget.screenSize.width;
      final phoneHeight = widget.screenSize.height;
      final gridWidth = gridSize.width;
      final gridHeight = gridSize.height;

      _controller.value = Matrix4.identity()
        ..translate(
          (phoneWidth - gridWidth) / 2,
          (phoneHeight - gridHeight) / 2,
        );
    });
  }

  @override
  void initState() {
    super.initState();

    // Si demandé, ajouté une liste de cellules prédéfinit
    if (widget.initialCells != null) {
      printDebug("Adding initial cell...");
      for (var initCell in widget.initialCells!) {
        printDebug("$initCell");
      }

      cellPositionsBack.addAll(widget.initialCells!);
      cellPositionsUI.addAll(convertBackToUi(widget.initialCells!));
    }

    if (!widget.isPaused) {
      _getNextGeneration();
    }

    _centerGrid();
  }

  @override
  void didUpdateWidget(covariant GridZoom oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.centerRequest) _centerGrid();

    // Si demandé, ajouté une liste de cellules prédéfinit
    if (widget.initialCells != null) {
      for (var initCell in widget.initialCells!) {
        printDebug("$initCell");
      }

      cellPositionsBack.addAll(widget.initialCells!);
      cellPositionsUI.addAll(convertBackToUi(widget.initialCells!));
    }

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
      minScale: 0.3,
      maxScale: 10,
      child: GestureDetector(
        // Détecte chaque clique dans la grille et détermine sa position
        onTapUp: (TapUpDetails details) {
          if (widget.isPaused) {
            // Convertit la position en int (ex X=28.9 - Y=34.2 => X=20.0 Y=30.0) affine de faire les calculs en backend avec une grille plus petite
            Point<int> posUI = Point<int>(
              ((details.localPosition.dx ~/ widget.cell).toDouble() *
                      widget.cell)
                  .toInt(), // Sans widget.cell si le doit est sur X=1 - Y=1 il sera interprété
              ((details.localPosition.dy ~/ widget.cell).toDouble() *
                      widget.cell)
                  .toInt(), // comme 1px - 1px au lieu de la case 1-1, donc widget.cell permet de convertir
            );

            Point<int> posBack = Point<int>(
              details.localPosition.dx ~/ widget.cell,
              details.localPosition.dy ~/ widget.cell,
            );

            setState(() {
              printDebug("cellPositions : $cellPositionsBack", debug: false);
              if (!cellPositionsUI.contains(posUI)) {
                cellPositionsUI = Set.of(cellPositionsUI)
                  ..add(
                    posUI,
                  ); // Copie l'ancienne liste dans une nouvelle instance et assigne cette nouvelle liste à l'ancienne pour que le shouldRepaint détécte une nouvelle liste
              } else {
                // Si le point existe déjà alors le supprimer
                cellPositionsUI = Set.of(cellPositionsUI)
                  ..removeWhere((position) => position == posUI);
              }

              // Mets à jour la liste pour le backend
              if (!cellPositionsBack.contains(posBack)) {
                cellPositionsBack = Set.of(cellPositionsBack)..add(posBack);
              } else {
                cellPositionsBack = Set.of(cellPositionsBack)
                  ..removeWhere((position) => position == posBack);
              }

              widget.getCells(Set.of(cellPositionsBack));
            });
          }
        },
        child: CustomPaint(
          size: gridSize,
          painter: GridPainter(
            cell: widget.cell,
            gridColor: widget.theme?.getGridLineColor,
          ),
          foregroundPainter: CellPaint(
            positions: cellPositionsUI,
            cellDimensions: widget.cell,
            cellColor: widget.theme?.getCellsColor,
          ),
        ),
      ),
    );
  }
}
