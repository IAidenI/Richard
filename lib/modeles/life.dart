import 'dart:math';
import 'dart:typed_data';
import 'package:richard/assets/constants.dart';
import 'package:richard/dbug.dart';

class LifeLogique {
  Set<Point<int>> _initialCell = <Point<int>>{};
  Set<Point<int>> get getInitialCell => _initialCell;
  int _generation = -1;

  Map<int, Chunk> _chunks = {};
  Map<int, Chunk> get getChunks => _chunks;
  void clear() => _chunks = {};

  LifeLogique();

  bool reStart(Set<Point<int>> initialCell) {
    _initialCell = initialCell;
    return _initChunks();
  }

  Set<Point<int>> startNextGeneration({int generation = -1}) {
    if (generation != -1) _generation = generation;

    final candidates = <Point<int>>{};
    for (var chunk in _chunks.entries) {
      // Récupère les coordonées du relatif aux chunk du chunk à partir de sa clé
      Point<int> chunkLocalPosition = _decodeUniqueKey(chunk.key);
      printDebug("[ DEBUG ] key : ${chunk.key} => $chunkLocalPosition");

      // Récupère les coordonnées dans la grille
      Point<int> chunkPosition = chunkToReal(
        chunkLocalPosition.x,
        chunkLocalPosition.y,
      );

      printDebug("[ DEBUG ] Real chunck position $chunkPosition");
      printDebug("");

      // Récupère les cellules vivantes et les 8 voisines
      for (int index = 0; index < chunk.value.state.length; index++) {
        if (chunk.value.state[index] == deadCell) continue;
        printDebug("[ DEBUG ] index candidate : $index");
        Point<int> local = Chunk.convert1Dto2D(index);
        printDebug("Local position $local");
        for (int dy = -1; dy <= 1; dy++) {
          for (int dx = -1; dx <= 1; dx++) {
            printDebug(
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
    printDebug("");

    // Applique les règles du jeu
    printDebug("[ DEBUG ] Applying rules...");
    for (var cell in candidates) {
      printDebug("[ DEBUG ] Trying (X=${cell.x};Y=${cell.y})");
      _safeGetCellAt(cell.x, cell.y) == livingCell
          ? _ruleDying(cell.x, cell.y)
          : _ruleBorn(cell.x, cell.y);
    }
    printDebug("[ DEBUG ] Done.");

    printDebug("[ DEBUG ] Swap.");
    for (var c in _chunks.values) {
      c.swap();
    }

    // Stock les nouvelles cellules pour les possibles pauses
    Set<Point<int>> newGeneration = <Point<int>>{};
    for (var chunk in _chunks.values) {
      Set<Point<int>> allCells = chunk.getAllCells();
      for (var chunkCell in allCells) {
        newGeneration.add(chunkCell);
      }
    }

    printDebug("[ DEBUG ] == End generation ==");
    printChunks();
    printDebug("[ DEBUG ] ====================");
    printDebug("");
    printDebug("");
    printDebug("");
    displayGameStats();
    return newGeneration;
  }

  // Fonctions permettant la convertion (pour mieux comprendre voir exemple en dessous de la classe)
  // Récupère les coordonnées d'un chunk à partir de points global
  static Point<int> realToChunk(int gx, int gy) => Point(
    gx >> getLog2,
    gy >> getLog2,
  ); // Car chunkSize = 8 donc 8 = 2^X => 8 = 2^3

  static Point<int> chunkToReal(int cx, int cy) =>
      Point(cx << getLog2, cy << getLog2);

  // Récupère les coordonnées local à un chunk
  static Point<int> localToChunk(int gx, int gy) => Point(
    gx & (chunkSize - 1),
    gy & (chunkSize - 1),
  ); // Comme si lx = x % chunkSize mais plus rapide

  // Génère un clé unique à partir du chunk
  int _generateUniqueKey(Point<int> chunk) =>
      ((chunk.x) << 32) | ((chunk.y) & 0xffffffff);
  Point<int> _decodeUniqueKey(int key) =>
      Point<int>(key >> 32, (key & 0xffffffff).toSigned(32));

  // Permet de convertir les coordonées en coordonées relatif au chunk
  bool _initChunks() {
    if (_initialCell.isEmpty) return true;

    printDebug("[ DEBUG ] Generating chunks...");
    for (var cell in _initialCell) {
      // Pour chaque cellule, détermine son chunk
      Point<int> chunk = realToChunk(cell.x, cell.y);
      printDebug(
        "[ DEBUG ] cell (${cell.x};${cell.y}) at chunk (${chunk.x};${chunk.y})",
      );
      // Génére une clé unique et l'ajoute le chunk à la liste dse chunks généré
      int key = _generateUniqueKey(chunk);
      _chunks.putIfAbsent(key, () => Chunk(chunk));

      // Détermine les coordonnées relative au chunk de la cellule
      Point<int> local = localToChunk(cell.x, cell.y);
      int index = Chunk.convert2Dto1D(local.x, local.y);
      printDebug("[ DEBUG ] local (${local.x};${local.y}) - index : $index");
      _chunks[key]!.state[index] = livingCell; // Indique la cellule vivante
    }

    printChunks();
    printDebug("[ DEBUG ] InitChunks done.");
    printDebug("");
    return false;
  }

  // Permet de récupèrer l'index de la cellule si elle existe
  int _getCellAt(int gx, int gy) {
    //printDebug("[ DEBUG ] == getCellAt ==",);
    // Récupère le bon chunk à partir des coordonnées globals de la cellule
    Point<int> chunkPos = realToChunk(gx, gy);
    int key = _generateUniqueKey(chunkPos);
    final chunk = _chunks[key];

    // Si il n'y a pas de chunk alors la cellule cible est morte
    // Sinon revoie le contenu de la cellule
    Point<int> local = localToChunk(gx, gy);

    return chunk == null
        ? deadCell
        : chunk.state[Chunk.convert2Dto1D(local.x, local.y)];
  }

  // Permet de placer une cellul à un endroit
  void _setCellAt(int gx, int gy, int cellState) {
    //printDebug("[ DEBUG ] == setCellAt ==",);

    // Récupère le bon chunk
    Point<int> chunkPos = realToChunk(gx, gy);
    int key = _generateUniqueKey(chunkPos);
    final chunk = _chunks.putIfAbsent(
      key,
      () => Chunk(chunkPos),
    ); // Crée le chunk au besoin

    // Marque la cellule comme morte ou vivante
    Point<int> local = localToChunk(gx, gy);
    printDebug(
      "[ DEBUG ] set $cellState at (X=${local.x};Y=${local.y}) - ${Chunk.convert2Dto1D(local.x, local.y)}",
    );
    chunk.next[Chunk.convert2Dto1D(local.x, local.y)] = cellState;
    //printDebug("[ DEBUG ] setCellAt : ",);
    //chunk.printDebugNextData();
    //chunk.printDebugData();
  }

  // Pour ne pas lire/écrire en dehors de la grille
  int _safeGetCellAt(int gx, int gy) {
    if (!inBounds(gx, gy)) return deadCell; // dehors = mort
    return _getCellAt(gx, gy);
  }

  void _safeSetCellAt(int gx, int gy, int v) {
    if (!inBounds(gx, gy)) return;
    _setCellAt(gx, gy, v);
  }

  // Permet de compter le nombre de voisin d'une cellule
  int _countNeighbors(int gx, int gy) {
    int count = 0;
    for (int dy = -1; dy <= 1; dy++) {
      for (int dx = -1; dx <= 1; dx++) {
        // Si il s'agit de la cellule cible on ignore
        if (dx == 0 && dy == 0) continue;

        // On vérifie si la cellule voision est vivante ou non
        if (_safeGetCellAt(gx + dx, gy + dy) == livingCell) count++;
      }
    }
    return count;
  }

  // Si exactement 3 cellules voisins sont vivant alors la cellule morte naît
  void _ruleBorn(int gx, int gy) {
    if (!inBounds(gx, gy)) return; // Si en dehors => ne naît pas
    int neighbors = _countNeighbors(gx, gy);
    if (neighbors == 3) {
      printDebug("[ DEBUG ] Born.");
      _safeSetCellAt(gx, gy, livingCell);
    }
  }

  // Si exactement 2 ou 3 cellules voisines ne sont pas vivante alors la cellule vivante meurt
  void _ruleDying(int gx, int gy) {
    // Si une vivante sort de la grille
    if (!inBounds(gx, gy)) {
      _safeSetCellAt(gx, gy, deadCell);
      return;
    }

    int neighbors = _countNeighbors(gx, gy);
    if (neighbors != 2 && neighbors != 3) {
      printDebug("[ DEBUG ] Dead.");
      _safeSetCellAt(gx, gy, deadCell);
    } else {
      printDebug("[ DEBUG ] Still alive.");
      _safeSetCellAt(gx, gy, livingCell);
    }
  }

  void printChunks() {
    printDebug("");
    printDebug("[ DEBUG ] ============================================");
    printDebug("[ DEBUG ] Chunks :");
    for (var chunk in _chunks.entries) {
      printDebug("[ DEBUG ]    ${chunk.key}: ");
      chunk.value.printDebugData();
      printDebug("");
    }
    printDebug("[ DEBUG ] ============================================");
    printDebug("");
  }

  void displayGameStats({bool debug = false}) {
    final chunks = _chunks.values;
    printDebug(
      "===================== STATISTIQUES =====================",
      debug: debug,
    );
    printDebug(
      " -- Nombres de chunks           : ${chunks.length}",
      debug: debug,
    );
    // Récupère le poids d'un chunk
    for (var chunk in _chunks.entries) {
      printDebug(
        "        - ${chunk.key.toString().padRight(8)} : ${chunk.value.state.length} octets (${chunk.value.state.length / 1024} kB)",
        debug: debug,
      );
    }

    // Récupère le nombre de cellules en vie
    int cellCounter = 0;
    for (var livingCell in chunks) {
      cellCounter += livingCell.getAllCells().length;
    }
    printDebug(" -- Nombres de cellules en vies : $cellCounter", debug: debug);
    printDebug(
      " -- Génération actuelle         : ${_generation == -1 ? "Non instancié" : _generation}",
      debug: debug,
    );
    printDebug(
      "========================================================",
      debug: debug,
    );
  }
}

class Chunk {
  final Point<int> position;

  Chunk(this.position);

  // Besoin de 2 états pour pas calculer directement dans l'état actuelle
  // pour pas que l'état suivant entrent en conflit avec le prochain calcul
  Uint8List state = Uint8List(chunkSize * chunkSize);
  Uint8List next = Uint8List(chunkSize * chunkSize);

  static int convert2Dto1D(int lx, int ly) => ly * chunkSize + lx;
  static Point<int> convert1Dto2D(int index) =>
      Point<int>(index % chunkSize, index ~/ chunkSize);

  // Permet de récupèrer la position dans la grille de toutes les cellules du chunk
  Set<Point<int>> getAllCells() {
    Set<Point<int>> cells = <Point<int>>{};
    for (int i = 0; i < state.length; i++) {
      if (state[i] == livingCell) {
        // Convertit la cellul en coordonnées réels
        Point<int> local = convert1Dto2D(i);

        Point<int> chunk = LifeLogique.chunkToReal(position.x, position.y);

        cells.add(Point<int>(chunk.x + local.x, chunk.y + local.y));
      }
    }
    return cells;
  }

  void swap() {
    state.setAll(0, next); // Passe met à jour l'état
    next.fillRange(0, next.length, deadCell); // Vide l'ancienne état
  }

  void printDebugData() {
    printDebug("[ DEBUG ] $state");
  }

  void printDebugNextData() {
    printDebug("[ DEBUG ] $next");
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
