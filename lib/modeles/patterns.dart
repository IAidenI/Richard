import 'dart:math';

class LifePatterns {
  final String name;
  final String category;
  final List<Point<int>> cells;

  LifePatterns({
    required this.name,
    required this.category,
    required this.cells,
  });

  // Renvoie la position avec l'offset appliqué
  LifePatterns translated(Point<int> offset) {
    return LifePatterns(
      name: name,
      category: category,
      cells: cells
        ..map((p) => Point<int>(p.x + offset.x, p.y + offset.y)).toList(),
    );
  }

  String get getName => name;
  String get getCategory => category;
  List<Point<int>> get getCells => cells;
}

class StillLifes {
  static const String category = "Structures stables";

  static final LifePatterns block = LifePatterns(
    name: "Block",
    category: category,
    cells: [Point(0, 0), Point(1, 0), Point(0, 1), Point(1, 1)],
  );

  static final LifePatterns beeHive = LifePatterns(
    name: "Bee Hive",
    category: category,
    cells: [
      Point(0, 1),
      Point(1, 0),
      Point(2, 0),
      Point(3, 1),
      Point(2, 2),
      Point(1, 2),
    ],
  );

  static final LifePatterns loaf = LifePatterns(
    name: "Loaf",
    category: category,
    cells: [
      Point(0, 1),
      Point(1, 2),
      Point(2, 3),
      Point(1, 0),
      Point(2, 0),
      Point(3, 1),
      Point(3, 2),
    ],
  );

  static final LifePatterns boat = LifePatterns(
    name: "Boat",
    category: category,
    cells: [Point(0, 1), Point(0, 0), Point(1, 0), Point(2, 1), Point(1, 2)],
  );

  static final LifePatterns tub = LifePatterns(
    name: "Tub",
    category: category,
    cells: [Point(1, 0), Point(2, 1), Point(1, 2), Point(0, 1)],
  );
}

class Oscillators {
  static const String category = "Oscillateurs";

  static final LifePatterns blinker = LifePatterns(
    name: "Blinker",
    category: category,
    cells: [Point(0, 1), Point(1, 1), Point(2, 1)],
  );

  static final LifePatterns figureEight = LifePatterns(
    name: "Figure Eight",
    category: category,
    cells: [
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
    ],
  );

  static final LifePatterns pulsar = LifePatterns(
    name: "Pulsar",
    category: category,
    cells: [
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
    ],
  );

  static final LifePatterns pentaDecathlon = LifePatterns(
    name: "Penta-Decathlon",
    category: category,
    cells: [
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
    ],
  );
}

class Spacships {
  static const String category = "Vaisseaux";

  // Left down
  static final LifePatterns glider = LifePatterns(
    name: "Glider",
    category: category,
    cells: [Point(0, 2), Point(1, 2), Point(2, 2), Point(2, 1), Point(1, 0)],
  );

  // Left
  static final LifePatterns lightWeightSpacship = LifePatterns(
    name: "Light Weight Spaceship",
    category: category,
    cells: [
      Point(0, 0),
      Point(0, 2),
      Point(3, 0),
      Point(1, 3),
      Point(2, 3),
      Point(3, 3),
      Point(4, 3),
      Point(4, 2),
      Point(4, 1),
    ],
  );

  // Left
  static final LifePatterns middleWeightSpaceship = LifePatterns(
    name: "Middle Weight Spaceship",
    category: category,
    cells: [
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
    ],
  );

  // Left
  static final LifePatterns heavyWeightSpaceship = LifePatterns(
    name: "Heavy Weight Spaceship",
    category: category,
    cells: [
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
    ],
  );
}

class Generators {
  static const String category = "Générateurs";

  static final LifePatterns gun = LifePatterns(
    name: "Gospel's glider gun",
    category: category,
    cells: [
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
    ],
  );
}

class Methuselah {
  static const String category = "Mathusalem";

  static final LifePatterns arcon = LifePatterns(
    name: "Arcon",
    category: category,
    cells: [
      Point(1, 0),
      Point(0, 2),
      Point(1, 2),
      Point(3, 1),
      Point(4, 2),
      Point(5, 2),
      Point(6, 2),
    ],
  );

  static final LifePatterns rabbits = LifePatterns(
    name: "Rabbits",
    category: category,
    cells: [
      Point(0, 1),
      Point(2, 1),
      Point(1, 2),
      Point(1, 3),
      Point(4, 0),
      Point(6, 0),
      Point(5, 1),
      Point(5, 2),
      Point(7, 3),
    ],
  );
}

class Soup {
  void generateLittle() {}

  void generateMedium() {}

  void generateBig() {}
}
