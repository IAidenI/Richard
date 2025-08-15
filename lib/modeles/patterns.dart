import 'dart:math';
import 'dart:ui';
import 'package:richard/assets/constants.dart';

class LifePatterns {
  final String name;
  final String category;
  final Size size;
  final int generations;
  final Set<Point<int>> cells;
  final String sourceClass;

  LifePatterns({
    required this.name,
    required this.category,
    required this.size,
    required this.generations,
    required this.cells,
    required this.sourceClass,
  });

  // Renvoie la position avec l'offset appliqué
  LifePatterns translated({Point<int>? offset}) {
    // Si aucun offset, on centre par défaut
    offset ??= Point<int>(
      ((gridSize.width ~/ cellSize) ~/ 2) - (size.width ~/ 2),
      ((gridSize.height ~/ cellSize) ~/ 2) - (size.height ~/ 2),
    );

    return LifePatterns(
      name: name,
      category: category,
      size: size,
      generations: generations,
      cells: cells
          .map((p) => Point<int>(p.x + offset!.x, p.y + offset!.y))
          .toSet(),
      sourceClass: sourceClass,
    );
  }

  String get getName => name;
  String get getCategory => category;
  Size get getSize => size;
  int get getGenerations => generations;
  Set<Point<int>> get getCells => cells;
  String get getSourceClass => sourceClass;

  String get getFormattedName => "Nom : $name";
  String get getFormattedSize =>
      "Taille : ${size.width.toInt()}x${size.height.toInt()}";
  String get getFormattedGenerations =>
      "Générations : ${generations == -1 ? "Inconnu" : generations}";

  static final List<List<LifePatterns>> all = [
    StillLifes.all,
    Oscillators.all,
    Spaceships.all,
    Generators.all,
    Methuselah.all,
  ];
}

class StillLifes {
  static const String category = "Structures stables";
  static final String sourceClass = (StillLifes).toString();

  static final LifePatterns block = LifePatterns(
    name: "Block",
    category: category,
    size: Size(2, 2),
    generations: 0,
    cells: {Point(0, 0), Point(1, 0), Point(0, 1), Point(1, 1)},
    sourceClass: sourceClass,
  );

  static final LifePatterns beeHive = LifePatterns(
    name: "Bee Hive",
    category: category,
    size: Size(4, 3),
    generations: 0,
    cells: {
      Point(0, 1),
      Point(1, 0),
      Point(2, 0),
      Point(3, 1),
      Point(2, 2),
      Point(1, 2),
    },
    sourceClass: sourceClass,
  );

  static final LifePatterns loaf = LifePatterns(
    name: "Loaf",
    category: category,
    size: Size(4, 4),
    generations: 0,
    cells: {
      Point(0, 1),
      Point(1, 2),
      Point(2, 3),
      Point(1, 0),
      Point(2, 0),
      Point(3, 1),
      Point(3, 2),
    },
    sourceClass: sourceClass,
  );

  static final LifePatterns boat = LifePatterns(
    name: "Boat",
    category: category,
    size: Size(3, 3),
    generations: 0,
    cells: {Point(0, 1), Point(0, 0), Point(1, 0), Point(2, 1), Point(1, 2)},
    sourceClass: sourceClass,
  );

  static final LifePatterns tub = LifePatterns(
    name: "Tub",
    category: category,
    size: Size(3, 3),
    generations: 0,
    cells: {Point(1, 0), Point(2, 1), Point(1, 2), Point(0, 1)},
    sourceClass: sourceClass,
  );

  static final List<LifePatterns> all = [block, beeHive, loaf, boat, tub];
}

class Oscillators {
  static const String category = "Oscillateurs";
  static final String sourceClass = (Oscillators).toString();

  static final LifePatterns blinker = LifePatterns(
    name: "Blinker",
    category: category,
    size: Size(3, 3),
    generations: 2,
    cells: {Point(0, 1), Point(1, 1), Point(2, 1)},
    sourceClass: sourceClass,
  );

  static final LifePatterns figureEight = LifePatterns(
    name: "Figure Eight",
    category: category,
    size: Size(6, 6),
    generations: 8,
    cells: {
      Point(0, 0),
      Point(1, 0),
      Point(1, 1),
      Point(0, 1),
      Point(3, 1),
      Point(4, 2),
      Point(1, 3),
      Point(2, 4),
      Point(4, 5),
      Point(4, 4),
      Point(5, 4),
      Point(5, 5),
    },
    sourceClass: sourceClass,
  );

  static final LifePatterns pulsar = LifePatterns(
    name: "Pulsar",
    category: category,
    size: Size(13, 13),
    generations: 3,
    cells: {
      Point(2, 0),
      Point(3, 0),
      Point(4, 0),
      Point(0, 2),
      Point(0, 3),
      Point(0, 4),
      Point(5, 2),
      Point(5, 3),
      Point(5, 4),
      Point(4, 5),
      Point(3, 5),
      Point(2, 5),
      Point(7, 2),
      Point(7, 3),
      Point(7, 4),
      Point(8, 5),
      Point(9, 5),
      Point(10, 5),
      Point(8, 0),
      Point(9, 0),
      Point(10, 0),
      Point(12, 2),
      Point(12, 3),
      Point(12, 4),
      Point(10, 7),
      Point(9, 7),
      Point(8, 7),
      Point(7, 8),
      Point(7, 9),
      Point(7, 10),
      Point(12, 8),
      Point(12, 9),
      Point(12, 10),
      Point(10, 12),
      Point(9, 12),
      Point(8, 12),
      Point(5, 8),
      Point(5, 9),
      Point(5, 10),
      Point(4, 7),
      Point(3, 7),
      Point(2, 7),
      Point(0, 8),
      Point(0, 9),
      Point(0, 10),
      Point(4, 12),
      Point(3, 12),
      Point(2, 12),
    },
    sourceClass: sourceClass,
  );

  static final LifePatterns pentaDecathlon = LifePatterns(
    name: "Penta-Decathlon",
    category: category,
    size: Size(10, 3),
    generations: 15,
    cells: {
      Point(0, 1),
      Point(1, 1),
      Point(2, 0),
      Point(2, 2),
      Point(3, 1),
      Point(4, 1),
      Point(5, 1),
      Point(6, 1),
      Point(7, 0),
      Point(7, 2),
      Point(8, 1),
    },
    sourceClass: sourceClass,
  );

  static final List<LifePatterns> all = [
    blinker,
    figureEight,
    pulsar,
    pentaDecathlon,
  ];
}

class Spaceships {
  static const String category = "Vaisseaux";
  static final String sourceClass = (Spaceships).toString();

  // Left down
  static final LifePatterns glider = LifePatterns(
    name: "Glider",
    category: category,
    size: Size(3, 3),
    generations: 4,
    cells: {Point(0, 2), Point(1, 2), Point(2, 2), Point(2, 1), Point(1, 0)},
    sourceClass: sourceClass,
  );

  // Left
  static final LifePatterns lightWeightSpaceship = LifePatterns(
    name: "Light Weight Spaceship",
    category: category,
    size: Size(5, 4),
    generations: 4,
    cells: {
      Point(0, 0),
      Point(0, 2),
      Point(3, 0),
      Point(1, 3),
      Point(2, 3),
      Point(3, 3),
      Point(4, 3),
      Point(4, 2),
      Point(4, 1),
    },
    sourceClass: sourceClass,
  );

  // Left
  static final LifePatterns middleWeightSpaceship = LifePatterns(
    name: "Middle Weight Spaceship",
    category: category,
    size: Size(6, 5),
    generations: 4,
    cells: {
      Point(0, 1),
      Point(0, 3),
      Point(2, 0),
      Point(1, 4),
      Point(2, 4),
      Point(3, 4),
      Point(4, 4),
      Point(5, 4),
      Point(5, 3),
      Point(5, 2),
      Point(4, 1),
    },
    sourceClass: sourceClass,
  );

  // Left
  static final LifePatterns heavyWeightSpaceship = LifePatterns(
    name: "Heavy Weight Spaceship",
    category: category,
    size: Size(7, 5),
    generations: 4,
    cells: {
      Point(0, 1),
      Point(0, 3),
      Point(2, 0),
      Point(3, 0),
      Point(5, 1),
      Point(1, 4),
      Point(2, 4),
      Point(3, 4),
      Point(4, 4),
      Point(5, 4),
      Point(6, 4),
      Point(6, 3),
      Point(6, 2),
    },
    sourceClass: sourceClass,
  );

  static final List<LifePatterns> all = [
    glider,
    lightWeightSpaceship,
    middleWeightSpaceship,
    heavyWeightSpaceship,
  ];
}

class Generators {
  static const String category = "Générateurs";
  static final String sourceClass = (Generators).toString();

  static final LifePatterns gun = LifePatterns(
    name: "Gospel's glider gun",
    category: category,
    size: Size(36, 9),
    generations: 30,
    cells: {
      Point(0, 4),
      Point(1, 4),
      Point(1, 5),
      Point(0, 5),
      Point(10, 4),
      Point(10, 5),
      Point(10, 6),
      Point(11, 7),
      Point(11, 3),
      Point(12, 2),
      Point(13, 2),
      Point(12, 8),
      Point(13, 8),
      Point(15, 7),
      Point(15, 3),
      Point(16, 6),
      Point(16, 4),
      Point(16, 5),
      Point(17, 5),
      Point(14, 5),
      Point(20, 4),
      Point(20, 3),
      Point(20, 2),
      Point(21, 2),
      Point(21, 3),
      Point(21, 4),
      Point(22, 1),
      Point(24, 0),
      Point(24, 1),
      Point(22, 5),
      Point(24, 5),
      Point(24, 6),
      Point(34, 2),
      Point(34, 3),
      Point(35, 2),
      Point(35, 3),
    },
    sourceClass: sourceClass,
  );

  static final List<LifePatterns> all = [gun];
}

class Methuselah {
  static const String category = "Mathusalem";
  static final String sourceClass = (Methuselah).toString();

  static final LifePatterns arcon = LifePatterns(
    name: "Arcon",
    category: category,
    size: Size(7, 3),
    generations: -1,
    cells: {
      Point(1, 0),
      Point(0, 2),
      Point(1, 2),
      Point(3, 1),
      Point(4, 2),
      Point(5, 2),
      Point(6, 2),
    },
    sourceClass: sourceClass,
  );

  static final LifePatterns rabbits = LifePatterns(
    name: "Rabbits",
    category: category,
    size: Size(8, 4),
    generations: -1,
    cells: {
      Point(0, 1),
      Point(2, 1),
      Point(1, 2),
      Point(1, 3),
      Point(4, 0),
      Point(6, 0),
      Point(5, 1),
      Point(5, 2),
      Point(7, 3),
    },
    sourceClass: sourceClass,
  );

  static final List<LifePatterns> all = [arcon, rabbits];
}

class Soup {
  void generateLittle() {}

  void generateMedium() {}

  void generateBig() {}
}
