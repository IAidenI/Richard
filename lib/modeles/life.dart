import 'dart:math';
import 'dart:typed_data';
import 'package:richard/assets/constants.dart';

class Simulation {
  late LifeLogique life;

  Simulation() {
    List<Point<int>> initialCell = [
      Point(1, 6),
      Point(9, 2),
      Point(6, 18),
      Point(18, 16),
      Point(21, 7),
    ];
    LifeLogique life = LifeLogique(initialCell);
    life._initChunks();
  }

  void startGame() {}
}

class LifeLogique {
  final List<Point<int>> initialCell;
  int _getLog2 = 0;

  final Map<int, Chunk> _chunks = {};
  Map<int, Chunk> get getChunks => _chunks;

  LifeLogique(this.initialCell) {
    // Permet de faire un calcul de logarithme en base 2 pour résoudre chunkSize = 2^X
    _getLog2 = log(chunkSize) ~/ log(2);
    _initChunks();
  }

  void start() {
    final candidates = <Point<int>>{};
    for (var chunk in _chunks.entries) {
      // Récupère les coordonées du relatif aux chunk du chunk à partir de sa clé
      Point<int> chunkLocalPosition = _decodeUniqueKey(chunk.key);
      print("[ DEBUG ] key : ${chunk.key} => $chunkLocalPosition");

      // Récupère les coordonnées dans la grille
      Point<int> chunkPosition = _chunkToReal(
        chunkLocalPosition.x,
        chunkLocalPosition.y,
      );

      print("[ DEBUG ] Real chunck position $chunkPosition");
      print("");

      // Récupère les cellules vivantes et les 8 voisines
      for (int index = 0; index < chunk.value.state.length; index++) {
        if (chunk.value.state[index] == deadCell) continue;
        print("[ DEBUG ] index candidate : $index");
        Point<int> local = Chunk.convert1Dto2D(index);
        print("[ DEBUG ] Local position $local");
        for (int dy = -1; dy <= 1; dy++) {
          for (int dx = -1; dx <= 1; dx++) {
            print(
              "[ DEBUG ] Adding ${Point<int>(chunkPosition.x + local.x + dx, chunkPosition.y + local.y + dy)}...",
            );
            candidates.add(
              Point<int>(
                chunkPosition.x + local.x + dx,
                chunkPosition.y + local.y + dy,
              ),
            );
          }
        }
      }
    }
    print("");

    // Applique les règles du jeu
    print("[ DEBUG ] Applying rules...");
    for (var cell in candidates) {
      print("[ DEBUG ] Trying (X=${cell.x};Y=${cell.y})");
      _getCellAt(cell.x, cell.y) == livingCell
          ? ruleDying(cell.x, cell.y)
          : ruleBorn(cell.x, cell.y);
    }
    print("[ DEBUG ] Done.");

    print("[ DEBUG ] Swap.");
    for (var c in _chunks.values) {
      c.swap();
    }

    print("[ DEBUG ] == End generation ==");
    debug();
    print("[ DEBUG ] ====================");
    print("");
    print("");
    print("");
  }

  // Lance une simulation
  void simulation({int generations = 4}) {
    print("[ DEBUG ] === Start simulation. ===");
    _initChunks();

    print("[ DEBUG ] Starting $generations generations.");
    for (int i = 1; i <= generations; i++) {
      print("[ DEBUG ] $i° generation.");
      final candidates = <Point<int>>{};
      for (var chunk in _chunks.entries) {
        // Récupère les coordonées du relatif aux chunk du chunk à partir de sa clé
        Point<int> chunkLocalPosition = _decodeUniqueKey(chunk.key);
        print("[ DEBUG ] key : ${chunk.key} => $chunkLocalPosition");

        // Récupère les coordonnées dans la grille
        Point<int> chunkPosition = _chunkToReal(
          chunkLocalPosition.x,
          chunkLocalPosition.y,
        );

        print("[ DEBUG ] Real chunck position $chunkPosition");
        print("");

        // Récupère les cellules vivantes et les 8 voisines
        for (int index = 0; index < chunk.value.state.length; index++) {
          if (chunk.value.state[index] == deadCell) continue;
          print("[ DEBUG ] index candidate : $index");
          Point<int> local = Chunk.convert1Dto2D(index);
          print("[ DEBUG ] Local position $local");
          for (int dy = -1; dy <= 1; dy++) {
            for (int dx = -1; dx <= 1; dx++) {
              print(
                "[ DEBUG ] Adding ${Point<int>(chunkPosition.x + local.x + dx, chunkPosition.y + local.y + dy)}...",
              );
              candidates.add(
                Point<int>(
                  chunkPosition.x + local.x + dx,
                  chunkPosition.y + local.y + dy,
                ),
              );
            }
          }
        }
      }
      print("");

      // Applique les règles du jeu
      print("[ DEBUG ] Applying rules...");
      for (var cell in candidates) {
        print("[ DEBUG ] Trying (X=${cell.x};Y=${cell.y})");
        _getCellAt(cell.x, cell.y) == livingCell
            ? ruleDying(cell.x, cell.y)
            : ruleBorn(cell.x, cell.y);
      }
      print("[ DEBUG ] Done.");

      print("[ DEBUG ] Swap.");
      for (var c in _chunks.values) {
        c.swap();
      }

      print("[ DEBUG ] == End generation ==");
      debug();
      print("[ DEBUG ] ====================");
      print("");
      print("");
      print("");
    }
    print("[ DEBUG ] === Simulation done. ===");
  }

  // Fonctions permettant la convertion (pour mieux comprendre voir exemple en dessous de la classe)
  // Récupère les coordonnées d'un chunk à partir de points global
  Point<int> _realToChunk(int gx, int gy) => Point(
    gx >> _getLog2,
    gy >> _getLog2,
  ); // Car chunkSize = 8 donc 8 = 2^X => 8 = 2^3

  Point<int> _chunkToReal(int cx, int cy) =>
      Point(cx << _getLog2, cy << _getLog2);

  // Récupère les coordonnées local à un chunk
  Point<int> _localToChunk(int gx, int gy) => Point(
    gx & (chunkSize - 1),
    gy & (chunkSize - 1),
  ); // Comme si lx = x % chunkSize mais plus rapide

  // Génère un clé unique à partir du chunk
  int _generateUniqueKey(Point<int> chunk) =>
      ((chunk.x) << 32) | ((chunk.y) & 0xffffffff);
  Point<int> _decodeUniqueKey(int key) =>
      Point<int>(key >> 32, (key & 0xffffffff).toSigned(32));

  // Permet de convertir les coordonées en coordonées relatif au chunk
  void _initChunks() {
    print("[ DEBUG ] Generating chunks...");
    for (var cell in initialCell) {
      // Pour chaque cellule, détermine son chunk
      Point<int> chunk = _realToChunk(cell.x, cell.y);
      print(
        "[ DEBUG ] cell (${cell.x};${cell.y}) at chunk (${chunk.x};${chunk.y})",
      );
      // Génére une clé unique et l'ajoute le chunk à la liste dse chunks généré
      int key = _generateUniqueKey(chunk);
      _chunks.putIfAbsent(key, () => Chunk());

      // Détermine les coordonnées relative au chunk de la cellule
      Point<int> local = _localToChunk(cell.x, cell.y);
      int index = Chunk.convert2Dto1D(local.x, local.y);
      print("[ DEBUG ] local (${local.x};${local.y}) - index : $index");
      _chunks[key]!.state[index] = livingCell; // Indique la cellule vivante
    }

    debug();
    print("[ DEBUG ] InitChunks done.");
    print("");
  }

  // Permet de récupèrer l'index de la cellule si elle existe
  int _getCellAt(int gx, int gy) {
    //print("[ DEBUG ] == getCellAt ==");
    // Récupère le bon chunk à partir des coordonnées globals de la cellule
    Point<int> chunkPos = _realToChunk(gx, gy);
    int key = _generateUniqueKey(chunkPos);
    final chunk = _chunks[key];

    // Si il n'y a pas de chunk alors la cellule cible est morte
    // Sinon revoie le contenu de la cellule
    Point<int> local = _localToChunk(gx, gy);

    return chunk == null
        ? deadCell
        : chunk.state[Chunk.convert2Dto1D(local.x, local.y)];
  }

  // Permet de placer une cellul à un endroit
  void _setCellAt(int gx, int gy, int cellState) {
    //print("[ DEBUG ] == setCellAt ==");

    // Récupère le bon chunk
    Point<int> chunkPos = _realToChunk(gx, gy);
    int key = _generateUniqueKey(chunkPos);
    final chunk = _chunks.putIfAbsent(
      key,
      () => Chunk(),
    ); // Crée le chunk au besoin

    // Marque la cellule comme morte ou vivante
    Point<int> local = _localToChunk(gx, gy);
    print(
      "[ DEBUG ] set $cellState at (X=${local.x};Y=${local.y}) - ${Chunk.convert2Dto1D(local.x, local.y)}",
    );
    chunk.next[Chunk.convert2Dto1D(local.x, local.y)] = cellState;
    //print("[ DEBUG ] setCellAt : ");
    //chunk.printNextData();
    //chunk.printData();
  }

  // Permet de compter le nombre de voisin d'une cellule
  int _countNeighbors(int gx, int gy) {
    //print("[ DEBUG ] == count ==");

    int count = 0;
    for (int dy = -1; dy <= 1; dy++) {
      for (int dx = -1; dx <= 1; dx++) {
        // Si il s'agit de la cellule cible on ignore
        if (dx == 0 && dy == 0) continue;

        // On vérifie si la cellule voision est vivante ou non
        //print(
        //  "[ DEBUG ] (gx=$gx;gy=$gy) - (dx=$dx;dy=$dy) cell : ${_getCellAt(gx + dx, gy + dy)}",
        //);
        if (_getCellAt(gx + dx, gy + dy) == livingCell) count++;
        //print("[ DEBUG ] counter : $count");
      }
    }
    return count;
  }

  // Si exactement 3 cellules voisins sont vivant alors la cellule morte naît
  void ruleBorn(int gx, int gy) {
    //print("[ DEBUG ] ===================");
    int neighbors = _countNeighbors(gx, gy);
    if (neighbors == 3) {
      print("[ DEBUG ] Born.");
      _setCellAt(gx, gy, livingCell);
    }
    //print("[ DEBUG ] ===================");
    //print("");
  }

  // Si exactement 2 ou 3 cellules voisines ne sont pas vivante alors la cellule vivante meurt
  void ruleDying(int gx, int gy) {
    int neighbors = _countNeighbors(gx, gy);
    if (neighbors != 2 && neighbors != 3) {
      print("[ DEBUG ] Dead.");
      _setCellAt(gx, gy, deadCell);
    } else {
      print("[ DEBUG ] Still alive.");
      _setCellAt(gx, gy, livingCell);
    }
  }

  void debug() {
    print("");
    print("[ DEBUG ] ============================================");
    print("[ DEBUG ] Chunks :");
    for (var chunk in _chunks.entries) {
      print("[ DEBUG ]    ${chunk.key}: ");
      chunk.value.printData();
      print("");
    }
    print("[ DEBUG ] ============================================");
    print("");
  }
}

class Chunk {
  // Besoin de 2 états pour pas calculer directement dans l'état actuelle
  // pour pas que l'état suivant entrent en conflit avec le prochain calcul
  Uint8List state = Uint8List(chunkSize * chunkSize);
  Uint8List next = Uint8List(chunkSize * chunkSize);

  static int convert2Dto1D(int lx, int ly) => ly * chunkSize + lx;
  static Point<int> convert1Dto2D(int index) =>
      Point<int>(index % chunkSize, index ~/ chunkSize);

  void swap() {
    state.setAll(0, next); // Passe met à jour l'état
    next.fillRange(0, next.length, deadCell); // Vide l'ancienne état
  }

  void printData() {
    print("[ DEBUG ] $state");
  }

  void printNextData() {
    print("[ DEBUG ] $next");
  }
}

/*

Exemple avec un chunk size de 8 avec une grille de 6 grosses case divisé en 4 petites, donc un chunk = 4 grosses cases

[Point(3, 6), Point(13, 10), Point(7, 21), Point(21, 17)]

x = 3 - y = 6
bin 3 = 00000011 - 6 = 00000110
cx = x >> 3 - cy = y >> 3      // Car chunkSize = 8 donc 8 = 2^X => 8 = 2^3
cx = 00000000 - cy = 00000000
cx = 0        - cy = 0         // Coordonées en chunk

      lx = x & 7        -        ly = y & 7         // Comme si lx = x % (chunkSize - 1) mais plus rapide
  00000011 & 00000111         00000110 & 00000111
= 00000011                  = 00000110
= 3                         = 6       // Coordonées local au chunk
Donc le point se trouve dans le chunk (0;0) au coordonées (3;6)



x = 13 - y = 10
bin 13 = 00001101 - 10 = 00001010
cx = x >> 3 - cy = y >> 3      // Car chunkSize = 8 donc 8 = 2^X => 8 = 2^3
cx = 00000001 - cy = 00000001
cx = 1        - cy = 1         // Coordonées en chunk

      lx = x & 7        -        ly = y & 7         // Comme si lx = x % (chunkSize - 1) mais plus rapide
  00001101 & 00000111         00001010 & 00000111
= 00000101                  = 00000010
= 5                         = 2       // Coordonées local au chunk
Donc le point se trouve dans le chunk (1;1) au coordonées (5;2)



x = 7 - y = 21
bin 7 = 00000111 - 21 = 00010101
cx = x >> 3 - cy = y >> 3      // Car chunkSize = 8 donc 8 = 2^X => 8 = 2^3
cx = 00000000 - cy = 00000010
cx = 0        - cy = 2         // Coordonées en chunk

      lx = x & 7        -        ly = y & 7         // Comme si lx = x % (chunkSize - 1) mais plus rapide
  00000111 & 00000111         00010101 & 00000111
= 00000111                  = 00000101
= 7                         = 5       // Coordonées local au chunk
Donc le point se trouve dans le chunk (0;2) au coordonées (7;5)



x = 21 - y = 17
bin 21 = 00010101 - 17 = 00010001
cx = x >> 3 - cy = y >> 3      // Car chunkSize = 8 donc 8 = 2^X => 8 = 2^3
cx = 00000010 - cy = 00000010
cx = 2        - cy = 2         // Coordonées en chunk

      lx = x & 7        -        ly = y & 7         // Comme si lx = x % (chunkSize - 1) mais plus rapide
  00010101 & 00000111         00010001 & 00000111
= 00000101                  = 00000001
= 5                         = 1       // Coordonées local au chunk
Donc le point se trouve dans le chunk (2;2) au coordonées (5;1)

*/
