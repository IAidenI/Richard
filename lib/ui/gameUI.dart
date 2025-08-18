import 'dart:math';
import 'dart:math' as math;
import 'dart:ui';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:richard/assets/constants.dart';
import 'package:richard/dbug.dart';
import 'package:richard/modeles/life.dart';
import 'package:richard/modeles/patterns.dart';
import 'package:richard/ui/theme.dart';

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

/*
  Permet de crée un cadre avec un légé effet dégradé vers l'intérieur
*/
class FrameGradient extends CustomPainter {
  final Color color;
  final int gradient;
  final double alpha;

  FrameGradient({
    super.repaint,
    required this.color,
    this.gradient = 20,
    this.alpha = 0.8,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double strokeWidth = 2;

    // Crée 3 cadre, avec un décalage passé en paramètre, par défaut il est de +20
    Color color1 = color;
    Color color2 = AppTheme.addToColor(
      color: color,
      r: gradient,
      g: gradient,
      b: gradient,
      alphaFactor: alpha,
    );
    Color color3 = AppTheme.addToColor(
      color: color2,
      r: gradient,
      g: gradient,
      b: gradient,
      alphaFactor: alpha,
    );

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

    // Calcul l'emplacement des 3 cadres
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

    // Dessine les cadres
    canvas.drawRect(rect1, frame1);
    canvas.drawRect(rect2, frame2);
    canvas.drawRect(rect3, frame3);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

/*
  Permet d'afficher un cader stylisé avec 3 lignes dont celle du moliieu est plus grosse
  avec des chanfrein sur les côtés
*/
class FrameInformation extends CustomPainter {
  final double strokeMajor;
  final double strokeMinor;
  final double cut;
  final Color backgroundColor;
  final Color frameColor;

  FrameInformation({
    super.repaint,
    this.strokeMajor = 5,
    this.strokeMinor = 1,
    this.cut = 20,
    required this.backgroundColor,
    required this.frameColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint background = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    Paint majorFrame = Paint()
      ..color = frameColor
      ..strokeWidth = strokeMajor
      ..style = PaintingStyle.stroke;

    Paint minorFrame = Paint()
      ..color = frameColor
      ..strokeWidth = strokeMinor
      ..style = PaintingStyle.stroke;

    Paint cornerFrame = Paint()
      ..color = frameColor
      ..style = PaintingStyle.fill;

    Rect rectBackground = Rect.fromLTWH(0, 0, size.width, size.height);

    Offset padding = Offset(7, 7);
    Offset paddingCorner = Offset(1, 1);
    Offset gap = Offset(strokeMinor, strokeMinor);

    // drawRect va centrer au milieu du trait donc pour une largeur de 4
    // au lieu d'avoir |■■■■ se sera ■■|■■, donc à chaque fois il faut ajouter
    // le stroke / 2 du précédent et le stroke / 2 du suivant
    Offset offset = Offset(
      padding.dx + strokeMinor / 2,
      padding.dy + strokeMinor / 2,
    );

    // Pour un chanfrein de 45°, le déplacement réel entre les deux points est de
    // √2·d On se déplace en réalité de x=d et y=d, donc le chanfrein est une droite de y=x
    // donc si on prend juste l'offset on se déplace de √(d^2 + d^2) car pythagore et donc √(2·d^2)
    // => √2·√d^2 => √2·d donc pour avoir le bon offset il faut trouver un delta tel que
    // √(Δ^2 + Δ^2) = d => √2·Δ = d => Δ = d / √2 donc pour les chanfrein il faut en plus
    // ajouter/enlever cd delta

    double ax(Offset o) => o.dx * (math.sqrt(2) - 1);
    double ay(Offset o) => o.dy * (math.sqrt(2) - 1);

    double ax0 = ax(offset);
    double ay0 = ay(offset);

    final pathMinorExt = Path()
      // Démarre sur le bord supérieur, après le chanfrein haut-gauche
      ..moveTo(cut + ay0, offset.dy)
      // Trace la ligne supérieure jusqu’avant le chanfrein haut-droit
      ..lineTo(size.width - cut - ay0, offset.dy)
      // Trace le chanfrein haut-droit (segment diagonal)
      ..lineTo(size.width - offset.dx, cut + ax0)
      // Trace le bord droit jusqu’avant le chanfrein bas-droit
      ..lineTo(size.width - offset.dx, size.height - cut - ax0)
      // Trace le chanfrein bas-droit (segment diagonal)
      ..lineTo(size.width - cut - ay0, size.height - offset.dy)
      // Trace le bord inférieur jusqu’avant le chanfrein bas-gauche
      ..lineTo(cut + ay0, size.height - offset.dy)
      // Trace le chanfrein bas-gauche (segment diagonal)
      ..lineTo(offset.dx, size.height - cut - ax0)
      // Trace le bord gauche jusqu’avant le chanfrein haut-gauche
      ..lineTo(offset.dx, cut + ax0)
      // Ferme le chemin (retrace le chanfrein haut-gauche implicite)
      ..close();

    // Crée le triangle pour faire le coin en haut à gauche
    final g = strokeMinor; // écart visible entre les 2 diagonales
    final d = g * math.sqrt2; // décalage à appliquer sur x/y

    // Sommets du triangle de bordure
    Offset A = Offset(
      offset.dx + paddingCorner.dx,
      offset.dy + paddingCorner.dy,
    );
    Offset B = Offset(
      (cut + ay0) - (paddingCorner.dy + ay0),
      offset.dy + paddingCorner.dy,
    );
    Offset C = Offset(
      offset.dx + paddingCorner.dy,
      (cut + ax0) - (paddingCorner.dx + ax0),
    );

    // Sommets du triangle de remplissage
    Offset A2 = A + Offset(d, d); // avance le coin vers le bas-droite
    Offset B2 = Offset(
      B.dx - d - paddingCorner.dx,
      B.dy + paddingCorner.dy,
    ); // recule sur l’axe x
    Offset C2 = Offset(
      C.dx + paddingCorner.dy,
      C.dy - d - paddingCorner.dy,
    ); // recule sur l’axe y

    final topLeftCornerBorder = Path()
      ..moveTo(A.dx, A.dy)
      ..lineTo(B.dx, B.dy)
      ..lineTo(C.dx, C.dy)
      ..close();

    final topLeftCorner = Path()
      ..moveTo(A2.dx, A2.dy)
      ..lineTo(B2.dx, B2.dy)
      ..lineTo(C2.dx, C2.dy)
      ..close();

    /// Crée le triangle pour faire le coin en haut à droite

    // Sommets du triangle de bordure
    A = Offset(
      size.width - (offset.dx + paddingCorner.dx),
      offset.dy + paddingCorner.dy,
    );
    B = Offset(
      size.width - ((cut + ay0) - (paddingCorner.dy + ay0)),
      offset.dy + paddingCorner.dy,
    );
    C = Offset(
      size.width - (offset.dx + paddingCorner.dy),
      (cut + ax0) - (paddingCorner.dx + ax0),
    );

    // Sommets du triangle de remplissage
    A2 = A + Offset(-d, d); // avance le coin vers le bas-droite
    B2 = Offset(
      B.dx + d + paddingCorner.dx,
      B.dy + paddingCorner.dy,
    ); // recule sur l’axe x
    C2 = Offset(
      C.dx - paddingCorner.dy,
      C.dy - d - paddingCorner.dy,
    ); // recule sur l’axe y

    final topRightCornerBorder = Path()
      ..moveTo(A.dx, A.dy)
      ..lineTo(B.dx, B.dy)
      ..lineTo(C.dx, C.dy)
      ..close();

    final topRightCorner = Path()
      ..moveTo(A2.dx, A2.dy)
      ..lineTo(B2.dx, B2.dy)
      ..lineTo(C2.dx, C2.dy)
      ..close();

    /// Crée le triangle pour faire le coin en bas à droite

    // Sommets du triangle de bordure
    A = Offset(
      size.width - (offset.dx + paddingCorner.dx),
      size.height - (offset.dy + paddingCorner.dy),
    );
    B = Offset(
      size.width - ((cut + ay0) - (paddingCorner.dy + ay0)),
      size.height - (offset.dy + paddingCorner.dy),
    ); // bas
    C = Offset(
      size.width - (offset.dx + paddingCorner.dy),
      size.height - ((cut + ax0) - (paddingCorner.dx + ax0)),
    ); // droite

    // Sommets du triangle de remplissage
    A2 = A + Offset(-d, -d);
    B2 = Offset(
      B.dx + d + paddingCorner.dx,
      B.dy - paddingCorner.dy,
    ); // bas : “rabat” vers le HAUT
    C2 = Offset(
      C.dx - paddingCorner.dy,
      C.dy + d + paddingCorner.dy,
    ); // droite : avance vers le BAS

    final botRightCornerBorder = Path()
      ..moveTo(A.dx, A.dy)
      ..lineTo(B.dx, B.dy)
      ..lineTo(C.dx, C.dy)
      ..close();

    final botRightCorner = Path()
      ..moveTo(A2.dx, A2.dy)
      ..lineTo(B2.dx, B2.dy)
      ..lineTo(C2.dx, C2.dy)
      ..close();

    /// Crée le triangle pour faire le coin en bas à gauche

    // Sommets du triangle de bordure
    A = Offset(
      offset.dx + paddingCorner.dx,
      size.height - (offset.dy + paddingCorner.dy),
    );
    B = Offset(
      (cut + ay0) - (paddingCorner.dy + ay0),
      size.height - (offset.dy + paddingCorner.dy),
    ); // bas
    C = Offset(
      offset.dx + paddingCorner.dy,
      size.height - ((cut + ax0) - (paddingCorner.dx + ax0)),
    ); // gauche

    // Sommets du triangle de remplissage
    A2 = A + Offset(d, -d);
    B2 = Offset(
      B.dx - d - paddingCorner.dx,
      B.dy - paddingCorner.dy,
    ); // bas : “rabat” vers le HAUT
    C2 = Offset(
      C.dx + paddingCorner.dy,
      C.dy + d + paddingCorner.dy,
    ); // gauche : avance vers le BAS

    final botLeftCornerBorder = Path()
      ..moveTo(A.dx, A.dy)
      ..lineTo(B.dx, B.dy)
      ..lineTo(C.dx, C.dy)
      ..close();

    final botLeftCorner = Path()
      ..moveTo(A2.dx, A2.dy)
      ..lineTo(B2.dx, B2.dy)
      ..lineTo(C2.dx, C2.dy)
      ..close();

    // Calcule du nouveau cadre

    offset = Offset(
      offset.dx + gap.dx + (strokeMinor + strokeMajor) / 2,
      offset.dy + gap.dy + (strokeMinor + strokeMajor) / 2,
    );

    ax0 = ax(offset);
    ay0 = ay(offset);

    final pathMajor = Path()
      // Démarre sur le bord supérieur, après le chanfrein haut-gauche
      ..moveTo(cut + ay0, offset.dy)
      // Trace la ligne supérieure jusqu’avant le chanfrein haut-droit
      ..lineTo(size.width - cut - ay0, offset.dy)
      // Trace le chanfrein haut-droit (segment diagonal)
      ..lineTo(size.width - offset.dx, cut + ax0)
      // Trace le bord droit jusqu’avant le chanfrein bas-droit
      ..lineTo(size.width - offset.dx, size.height - cut - ax0)
      // Trace le chanfrein bas-droit (segment diagonal)
      ..lineTo(size.width - cut - ay0, size.height - offset.dy)
      // Trace le bord inférieur jusqu’avant le chanfrein bas-gauche
      ..lineTo(cut + ay0, size.height - offset.dy)
      // Trace le chanfrein bas-gauche (segment diagonal)
      ..lineTo(offset.dx, size.height - cut - ax0)
      // Trace le bord gauche jusqu’avant le chanfrein haut-gauche
      ..lineTo(offset.dx, cut + ax0)
      // Ferme le chemin (retrace le chanfrein haut-gauche implicite)
      ..close();

    // Calcule du nouveau cadre

    offset = Offset(
      offset.dx + (strokeMajor + strokeMinor) / 2 + gap.dx,
      offset.dy + (strokeMajor + strokeMinor) / 2 + gap.dy,
    );

    ax0 = ax(offset);
    ay0 = ay(offset);

    final pathMinorInt = Path()
      // Démarre sur le bord supérieur, après le chanfrein haut-gauche
      ..moveTo(cut + ay0, offset.dy)
      // Trace la ligne supérieure jusqu’avant le chanfrein haut-droit
      ..lineTo(size.width - cut - ay0, offset.dy)
      // Trace le chanfrein haut-droit (segment diagonal)
      ..lineTo(size.width - offset.dx, cut + ax0)
      // Trace le bord droit jusqu’avant le chanfrein bas-droit
      ..lineTo(size.width - offset.dx, size.height - cut - ax0)
      // Trace le chanfrein bas-droit (segment diagonal)
      ..lineTo(size.width - cut - ay0, size.height - offset.dy)
      // Trace le bord inférieur jusqu’avant le chanfrein bas-gauche
      ..lineTo(cut + ay0, size.height - offset.dy)
      // Trace le chanfrein bas-gauche (segment diagonal)
      ..lineTo(offset.dx, size.height - cut - ax0)
      // Trace le bord gauche jusqu’avant le chanfrein haut-gauche
      ..lineTo(offset.dx, cut + ax0)
      // Ferme le chemin (retrace le chanfrein haut-gauche implicite)
      ..close();

    canvas.drawRect(rectBackground, background);

    canvas.drawPath(pathMinorExt, minorFrame);
    canvas.drawPath(pathMajor, majorFrame);
    canvas.drawPath(pathMinorInt, minorFrame);

    canvas.drawPath(topLeftCornerBorder, minorFrame);
    canvas.drawPath(topLeftCorner, cornerFrame);

    canvas.drawPath(topRightCornerBorder, minorFrame);
    canvas.drawPath(topRightCorner, cornerFrame);

    canvas.drawPath(botRightCornerBorder, minorFrame);
    canvas.drawPath(botRightCorner, cornerFrame);

    canvas.drawPath(botLeftCornerBorder, minorFrame);
    canvas.drawPath(botLeftCorner, cornerFrame);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class FrameInformationDelimiter extends CustomPainter {
  final Color frameColor;

  FrameInformationDelimiter({super.repaint, required this.frameColor});

  @override
  void paint(Canvas canvas, Size size) {
    Paint line = Paint()
      ..color = frameColor
      ..style = PaintingStyle.fill;

    // Calcul l'emplacement des 3 cadres
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    // Dessine les cadres
    canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(5)), line);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

// ===================================================
// ====-------  CUSTOM EXISTING COMPONANT  -------====
// ===================================================
class InformationsFrame extends StatelessWidget {
  final Color backgroundColor;
  final Color frameColor;
  final Widget child;
  const InformationsFrame({
    super.key,
    required this.backgroundColor,
    required this.frameColor,
    required this.child,
  });

  @override
  Widget build(Object context) {
    return CustomPaint(
      painter: FrameInformation(
        backgroundColor: backgroundColor,
        frameColor: frameColor,
      ),
      child: child,
    );
  }
}

// ===============================
// ====-------  POPUP  -------====
// ===============================
/*
  Permet d'obtenir un popup générique personalisable
*/
class PopupWorkShop extends StatefulWidget {
  final List<List<LifePatterns>> patterns = LifePatterns.all;
  final double delimiterSize = 2.0;
  final GameLifeThemes theme;

  PopupWorkShop({super.key, required this.theme});

  @override
  State<PopupWorkShop> createState() => _PopupWorkShopState();
}

class _PopupWorkShopState extends State<PopupWorkShop> {
  int _selectedMenuIndex = 0; // Index pour la catégorie selectionné
  int _selectedItemIndex = 0;

  Widget _buildScrollMenu() {
    return SizedBox(
      height: 40,
      // Crée un menu déroulant horizontalement
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          // Crée un fond uniforme
          decoration: BoxDecoration(
            color: widget.theme.getUnselectedMenu,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            // Crée des petits contour pour chaque élément des patterns
            // pour indiqué si ils sont séléctionné ou non
            children: List.generate(widget.patterns.length, (index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                child: GestureDetector(
                  onTap: () => setState(
                    () => _selectedMenuIndex = index,
                  ), // Mets à jour l'objet selectionné et notifie la class
                  child: Container(
                    decoration: BoxDecoration(
                      // Mets à jour la couleur du menu selectionné
                      color: _selectedMenuIndex == index
                          ? widget.theme.getSelectedMenu
                          : widget.theme.getUnselectedMenu,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 5,
                        horizontal: 12,
                      ),
                      // Insert le nom du menu
                      child: Text(
                        widget.patterns[index].first.category,
                        style: widget.theme.popupMenuLabel(),
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

  Widget _buildButton({
    required String data,
    required VoidCallback onTap,
    Color color = Colors.black,
  }) {
    // Crée un bouton personalisable
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          child: Center(
            child: Text(data, style: widget.theme.textButtonStyle()),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection({
    required List<String> infos,
    required int index,
    required String category,
    required String name,
  }) {
    return GestureDetector(
      onTap: () => setState(
        () => _selectedItemIndex = index,
      ), // Mets à jour l'objet selectionné et notifie la class
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(10),
          // Permet de pouvoir scroller horizontalement si la card est trop grande à cause des contraintes
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              decoration: BoxDecoration(
                // Mets à jour la couleur de la card selectionné
                color: _selectedItemIndex == index
                    ? widget.theme.getSelectedCard
                    : widget.theme.getUnselectedCard,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Affiche l'image correspondante
                    SizedBox(
                      width: 75,
                      height: 75,
                      child: Image.asset(
                        "assets/games/GameOfLife/$category/gif/$name.gif",
                      ),
                    ),

                    const SizedBox(width: 5),

                    // Affiche les informations le concernant
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (var info in infos) ...[
                          Text(info, style: widget.theme.popupContentLabel()),
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
          // Ajoute un cadre avec un effet dégradé
          foregroundPainter: FrameGradient(
            color: widget.theme.getFrameColor,
            gradient: -20,
          ),
          // Crée une liste déroulante pour les items
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            padding: const EdgeInsets.all(5),
            child: Column(
              children: [
                // Parmis la catégorie selectionné, on affiche les items qu'elle contient avec ses informations
                for (
                  int item = 0;
                  item < widget.patterns[_selectedMenuIndex].length;
                  item++
                ) ...[
                  // Pour chaque item création d'une card personalisé
                  _buildInfoSection(
                    infos: [
                      widget
                          .patterns[_selectedMenuIndex][item]
                          .getFormattedName,
                      widget
                          .patterns[_selectedMenuIndex][item]
                          .getFormattedSize,
                      widget
                          .patterns[_selectedMenuIndex][item]
                          .getFormattedGenerations,
                    ],
                    index: item,
                    // Permet de récupèrer le nom de la class associé et le nom
                    // sans caractères spéciaux pour le chemin d'accès de l'image
                    category: widget
                        .patterns[_selectedMenuIndex][item]
                        .getSourceClass,
                    name: widget.patterns[_selectedMenuIndex][item].getName
                        .toLowerCase()
                        .replaceAll(RegExp(r'[^a-z0-9]'), ''),
                  ),
                ],
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
      backgroundColor: widget.theme.getPrimary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: IntrinsicWidth(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 15),

              // Crée la section qui contient le titre et le logo
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.handyman, color: widget.theme.getPopupTitleColor),
                  const SizedBox(width: 5),
                  Text("Workshop", style: widget.theme.popupTitle()),
                ],
              ),

              const SizedBox(height: 15),

              // Menu déroulant horizontalement
              _buildScrollMenu(),

              const SizedBox(height: 15),

              // Cadre + Contenu déroulant verticalement
              _buildCategoryCard(),

              const SizedBox(height: 15),

              // Boutons valider et annuler
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildButton(
                    data: "Valider",
                    color: widget.theme.getButtonColorOK,
                    onTap: () => Navigator.of(context).pop(
                      Point<int>(_selectedMenuIndex, _selectedItemIndex),
                    ), // Renvoie la catégorie et l'objet selectionné
                  ),
                  _buildButton(
                    data: "Annuler",
                    color: widget.theme.getButtonColorExit,
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
  final Set<Point<int>> selectedPattern;
  final int applyPattern;
  final bool addPattern;
  final bool centerRequest;
  final GameLifeThemes? theme;

  const GridZoom({
    super.key,
    this.cell = cellSize,
    required this.life,
    required this.isPaused,
    required this.addPattern,
    required this.generation,
    required this.screenSize,
    required this.selectedPattern,
    required this.applyPattern,
    this.centerRequest = false,
    this.theme,
  });

  @override
  State<GridZoom> createState() => _GridZoomState();
}

class _GridZoomState extends State<GridZoom> {
  final TransformationController _controller =
      TransformationController(); // Pour définir la zone de spawn

  // Permet d'avoir un historique des cellules à afficher et donc de garder d'afficher les cellules peintes
  Set<Point<int>> _baseUI = <Point<int>>{};
  Set<Point<int>> _overlayUI = <Point<int>>{};

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
      _baseUI = next; // Notifie le shouldRepaint
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

  void _stampOverlay() {
    setState(() {
      _baseUI.addAll(_overlayUI);
      _overlayUI.clear();
    });
  }

  @override
  void initState() {
    super.initState();

    _getNextGeneration();

    _centerGrid();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant GridZoom oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.centerRequest) _centerGrid();

    // Fusionne l'overlay et la base si demandé
    if (oldWidget.applyPattern != widget.applyPattern) _stampOverlay();

    // Mets à jour l'overlay en fonction de la saisie utilisateur
    if (oldWidget.selectedPattern != widget.selectedPattern) {
      if (widget.selectedPattern.isEmpty) {
        _overlayUI = <Point<int>>{};
      } else {
        _overlayUI = convertBackToUi(widget.selectedPattern);
      }
    }

    // A chaque génération mets à jour l'affichage
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
      maxScale: 20,
      child: GestureDetector(
        // Détecte chaque clique dans la grille et détermine sa position
        onTapUp: (TapUpDetails details) {
          if (widget.isPaused && !widget.addPattern) {
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
              if (!_baseUI.contains(posUI)) {
                _baseUI = Set.of(_baseUI)
                  ..add(
                    posUI,
                  ); // Copie l'ancienne liste dans une nouvelle instance et assigne cette nouvelle liste à l'ancienne pour que le shouldRepaint détécte une nouvelle liste
                widget.life.editCell(
                  posBack,
                  livingCell,
                ); // Mets à jour le backend
                widget.life.incrementCounterCellsAlive();
              } else {
                // Si le point existe déjà alors le supprimer
                _baseUI = Set.of(_baseUI)
                  ..removeWhere((position) => position == posUI);
                widget.life.editCell(
                  posBack,
                  deadCell,
                ); // Mets à jour le backend
                widget.life.decrementCounterCellsAlive();
              }
            });
          }
        },
        child: Stack(
          children: [
            // Affiche la grille
            CustomPaint(
              size: gridSize,
              painter: GridPainter(
                cell: widget.cell,
                gridColor: widget.theme?.getGridLineColor,
              ),
            ),
            // Affiche devant la grille les cellules déjà positionné
            CustomPaint(
              size: gridSize,
              foregroundPainter: CellPaint(
                positions: _baseUI,
                cellDimensions: widget.cell,
                cellColor: widget.theme?.getCellsColor,
              ),
            ),
            // Affiche devant la grille les cellules du pattern séléctionné
            CustomPaint(
              size: gridSize,
              foregroundPainter: CellPaint(
                positions: _overlayUI,
                cellDimensions: widget.cell,
                cellColor: widget.theme?.getCellsPatternColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
