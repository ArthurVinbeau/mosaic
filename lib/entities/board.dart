import 'dart:math';

import 'package:mosaic/entities/cell.dart';
import 'package:mosaic/utils/config.dart';

class Board {
  final int height;
  final int width;
  late List<List<Cell>> cells;

  final double density;

  final Random _rand;

  String? _gameDesc;

  final int genVersion;

  Board({this.height = 8, this.width = 8, this.density = 0.5, this.genVersion = 0}) : _rand = Random();

  Board.from(Board other)
      : height = other.height,
        width = other.width,
        density = other.density,
        genVersion = other.genVersion,
        _rand = other._rand,
        _gameDesc = other._gameDesc {
    cells = [];
    for (int i = 0; i < other.height; i++) {
      final row = <Cell>[];
      for (int j = 0; j < other.width; j++) {
        final cell = other.cells[i][j];
        row.add(Cell(
          value: cell.value,
          state: cell.state,
          shown: cell.shown,
          clue: cell.clue,
          complete: cell.complete,
          empty: cell.empty,
          error: cell.error,
          full: cell.full,
        ));
      }
      cells.add(row);
    }
  }

  static Board fromString(String str) {
    final parts = str.split(";");
    final board = Board(height: int.parse(parts[0]), width: int.parse(parts[1]));
    board.cells = List.generate(board.height, (index) => List.generate(board.width, (index) => Cell(value: false)));
    board._gameDesc = parts[2];

    _parseString(parts[2], board.width, true, (i, j, value) {
      board.cells[i][j].clue = value;
      board.cells[i][j].shown = false;
    });
    _parseString(parts[3], board.width, false, (i, j, value) => board.cells[i][j].value = _getBoolFromInt(value)!);
    _parseString(parts[4], board.width, false, (i, j, value) => board.cells[i][j].state = _getBoolFromInt(value));

    int empty, count;
    for (int i = 0; i < board.height; i++) {
      for (int j = 0; j < board.width; j++) {
        board.cells[i][j].shown = !board.cells[i][j].shown;
        if (board.cells[i][j].shown) {
          empty = count = 0;
          iterateOnSquare(board.cells, i, j, (Cell cell, i, j) {
            count += (cell.state ?? false) ? 1 : 0;
            empty += cell.state == null ? 1 : 0;
          });
          board.cells[i][j].error = count > board.cells[i][j].clue || count < board.cells[i][j].clue && empty == 0;
          board.cells[i][j].complete = empty == 0;
        }
      }
    }

    return board;
  }

  static void _parseString(String curr, int width, bool once, void Function(int i, int j, int value) setVal) {
    int value;
    int count;
    final int baseSpace = "a".codeUnitAt(0) - 1;
    int i = 0;
    int j = 0;

    for (int k = 0; k < curr.length; k++) {
      if (curr.codeUnitAt(k) > baseSpace) {
        j += curr.codeUnitAt(k) - baseSpace;
      } else {
        value = int.parse(curr[k]);
        if (!once && k < curr.length - 1 && curr.codeUnitAt(k + 1) > baseSpace) {
          count = curr.codeUnitAt(++k) - baseSpace;
          for (int n = 0; n < count; n++, j++) {
            i += (j / width).floor();
            j = j % width;
            setVal(i, j, value);
          }
        } else {
          setVal(i, j++, value);
        }
      }
      i += (j / width).floor();
      j = j % width;
    }
  }

  void _generateNewBoard() {
    cells = [];
    for (int i = 0; i < height; i++) {
      List<Cell> row = [];
      for (int j = 0; j < width; j++) {
        row.add(Cell(value: _rand.nextDouble() <= density));
      }
      cells.add(row);
    }
  }

  static int iterateOnSquare<T>(List<List<T>> list, int i, int j, void Function(T e, int i, int j) callback) {
    int count = 0;
    for (int k = -1; k < 2; k++) {
      final targetI = i + k;
      if (targetI >= 0 && targetI < list.length) {
        for (int n = -1; n < 2; n++) {
          final targetJ = j + n;
          if (targetJ >= 0 && targetJ < list[targetI].length) {
            callback(list[targetI][targetJ], targetI, targetJ);
            count++;
          }
        }
      }
    }
    return count;
  }

  int _getSquareValue(int i, int j) {
    var counter = 0;
    iterateOnSquare(cells, i, j, (Cell cell, targetI, targetJ) => counter += cell.value ? 1 : 0);
    return counter;
  }

  String newGameDesc() {
    bool valid = false;

    String compressed = "";
    int baseSpace = 'a'.codeUnitAt(0) - 1;
    int maxSpace = 'z'.codeUnitAt(0);
    int spaceCount = baseSpace;

    if (genVersion == 1) {
      cells = _genV2();
    } else if (genVersion == 2) {
      cells = _genV3();
    } else if (genVersion == 3) {
      cells = _genV4();
    } else if (genVersion == 4) {
      cells = _genV5();
    } else {
      while (!valid) {
        _generateNewBoard();

        for (int i = 0; i < height; i++) {
          for (int j = 0; j < width; j++) {
            _populateCell(i, j);
          }
        }

        valid = _startPointCheck();

        if (!valid) {
          logger.d("Not valid, regenerating.");
        } else {
          valid = _solveCheck().result;
          if (!valid) {
            logger.d("Couldn't solve, regenerating.");
          } else {
            _hideClues();
          }
        }
      }
    }
    // uncompressed string generation omitted

    for (int i = 0; i < height; i++) {
      for (int j = 0; j < width; j++) {
        if (cells[i][j].shown) {
          if (spaceCount > baseSpace) {
            compressed += String.fromCharCode(spaceCount);
            spaceCount = baseSpace;
          }
          compressed += cells[i][j].clue.toString();
        } else {
          if (spaceCount < maxSpace) {
            spaceCount++;
          } else {
            compressed += String.fromCharCode(spaceCount);
            spaceCount = baseSpace;
          }
        }
      }
    }
    if (spaceCount > baseSpace) {
      compressed += String.fromCharCode(spaceCount);
    }
    logger.d("Compressed description (v$genVersion): $compressed");

    _gameDesc = compressed;

    return compressed;
  }

  void _populateCell(int i, int j) {
    int clue = _getSquareValue(i, j);
    bool xEdge = j == 0 || j + 1 == width;
    bool yEdge = i == 0 || i + 1 == height;

    final cell = cells[i][j];
    if (clue == 0) {
      cell.empty = true;
      cell.full = false;
    } else {
      // setting the default
      cell.empty = false;
      cell.full = false;
      if (clue == 9) {
        cell.full = true;
      } else if ((xEdge && yEdge && clue == 4) || ((xEdge || yEdge) && clue == 6)) {
        cell.full = true;
      }
    }

    cell.shown = true;
    cell.clue = clue;
  }

  bool _startPointCheck() {
    for (int i = 0; i < height; i++) {
      for (int j = 0; j < width; j++) {
        if (cells[i][j].full || cells[i][j].empty) {
          return true;
        }
      }
    }
    return false;
  }

  _SolutionResult _solveCheck() {
    List<List<_SolutionCell>> sol =
        List.generate(height, (i) => List.generate(width, (j) => _SolutionCell(), growable: false), growable: false);
    bool progress = true, error = false;
    int solved = 0, curr = 0, shown = 0;
    List<_NeededItem> neededList = [];

    for (int i = 0; i < height; i++) {
      for (int j = 0; j < width; j++) {
        if (cells[i][j].shown) {
          neededList.add(_NeededItem(i, j));
          shown++;
        }
      }
    }
    neededList.shuffle();

    while (solved < shown && progress && !error) {
      progress = false;
      for (int k = 0; k < shown; k++) {
        curr = _solveCell(cells, sol, neededList[k].i, neededList[k].j);
        if (curr < 0) {
          error = true;
          logger.d("error in cell [${neededList[k].i}][${neededList[k].j}]");
          break;
        }
        if (curr > 0) {
          solved++;
          progress = true;
        }
      }
    }

    solved = 0;
    /* verifying all the board is solved */
    if (progress) {
      for (int i = 0; i < height; i++) {
        for (int j = 0; j < width; j++) {
          if ((sol[i][j].cell & (CellState.marked | CellState.blank)) > 0) {
            solved++;
          }
        }
      }
    }

    return _SolutionResult(sol, solved == height * width);
  }

  int _solveCell(List<List<Cell>>? desc, List<List<_SolutionCell>> sol, int i, int j) {
    if (sol[i][j].solved) {
      return 0;
    }

    Cell curr = Cell(
      value: desc?[i][j].value ?? cells[i][j].value,
      shown: desc?[i][j].shown ?? cells[i][j].shown,
      clue: desc?[i][j].clue ?? cells[i][j].clue,
      full: desc?[i][j].full ?? cells[i][j].full,
      empty: desc?[i][j].empty ?? cells[i][j].empty,
    );

    _MarkCounter counter = _countAround(sol, i, j);

    if (curr.shown) {
      if (curr.full) {
        sol[i][j].solved = true;
        if (counter.marked + counter.blank < counter.total) {
          sol[i][j].needed = true;
        }
        _markAround(sol, i, j, CellState.marked);
        return 1;
      }
      if (curr.empty) {
        sol[i][j].solved = true;
        if (counter.marked + counter.blank < counter.total) {
          sol[i][j].needed = true;
        }
        _markAround(sol, i, j, CellState.blank);
        return 1;
      }
      if (!sol[i][j].solved) {
        if (counter.marked == curr.clue) {
          sol[i][j].solved = true;
          if (counter.total != counter.marked + counter.blank) {
            sol[i][j].needed = true;
          }
          _markAround(sol, i, j, CellState.blank);
        } else if (curr.clue == (counter.total - counter.blank)) {
          sol[i][j].solved = true;
          if (counter.total != counter.marked + counter.blank) {
            sol[i][j].needed = true;
          }
          _markAround(sol, i, j, CellState.marked);
        } else if (counter.total == counter.marked + counter.blank) {
          return -1;
        } else {
          return 0;
        }
        return 1;
      }
      return 0;
    } else if (counter.total == counter.marked + counter.blank) {
      sol[i][j].solved = true;
      return 1;
    } else {
      return 0;
    }
  }

  static _MarkCounter _countAround(List<List<_SolutionCell>> sol, int i, int j) {
    var counter = _MarkCounter();
    iterateOnSquare(sol, i, j, (_SolutionCell cell, p1, p2) {
      counter.total++;
      if (cell.cell & CellState.blank != 0) {
        counter.blank++;
      } else if (cell.cell & CellState.marked != 0) {
        counter.marked++;
      }
    });
    return counter;
  }

  static void _markAround(List<List<_SolutionCell>> sol, int i, int j, int mark) {
    int marked = 0;
    iterateOnSquare(sol, i, j, (_SolutionCell cell, p1, p2) {
      if (cell.cell == CellState.unmarked) {
        cell.cell = mark;
        marked++;
      }
    });
    logger.v("Marked $marked cells with $mark.");
  }

  void _hideClues() {
    int needed = 0;
    List<_NeededItem> neededList = [];

    logger.d("Hiding clues");
    List<List<_SolutionCell>> sol = _solveCheck().sol;

    for (int i = 0; i < height; i++) {
      for (int j = 0; j < width; j++) {
        if (sol[i][j].needed) {
          neededList.add(_NeededItem(i, j));
          needed++;
        } else if (!sol[i][j].needed) {
          cells[i][j].shown = false;
        }
      }
    }

    neededList.shuffle();

    for (int k = 0; k < needed; k++) {
      var curr = cells[neededList[k].i][neededList[k].j];
      curr.shown = false;
      if (!_solveCheck().result) {
        logger.v("Hiding cell [${neededList[k].i}][${neededList[k].j}] not possible.");
        curr.shown = true;
      }
    }

    final size = height * width;
    logger.i("needed $needed/$size (${(needed / size * 100).toStringAsFixed(0)}%)");
  }

  static int _getIntFromBool(bool? value) => {null: 0, true: 1, false: 2}[value]!;

  static bool? _getBoolFromInt(int value) => {1: true, 2: false}[value];

  String _getCompressedString(bool? Function(Cell cell) getValue) {
    int baseSpace = 'a'.codeUnitAt(0) - 1;
    int maxSpace = 'z'.codeUnitAt(0);
    int spaceCount = baseSpace;
    bool? state = getValue(cells[0][0]);
    String compressed = _getIntFromBool(state).toString();

    for (int i = 0; i < height; i++) {
      for (int j = 0; j < width; j++) {
        var value = getValue(cells[i][j]);
        if (value != state) {
          if (spaceCount > baseSpace + 1) {
            compressed += String.fromCharCode(spaceCount);
            spaceCount = baseSpace + 1;
          }
          compressed += _getIntFromBool(value).toString();
          state = value;
        } else {
          if (spaceCount < maxSpace) {
            spaceCount++;
          } else {
            compressed += String.fromCharCode(spaceCount) + _getIntFromBool(value).toString();
            spaceCount = baseSpace + 1;
          }
        }
      }
    }
    if (spaceCount > baseSpace + 1) {
      compressed += String.fromCharCode(spaceCount);
    }

    return compressed;
  }

  List<List<Cell>> _genV2() {
    final List<List<Cell?>> cells = List.generate(height, (i) => List.generate(width, (j) => null));
    final Set<_NeededItem> pending = {_NeededItem(_rand.nextInt(height), _rand.nextInt(width))};
    final Set<_NeededItem> filled = {};
    final size = height * width;
    final Stopwatch timer = Stopwatch();
    timer.start();

    while (filled.length < size) {
      var target = pending.elementAt(_rand.nextInt(pending.length));
      pending.remove(target);

      var filling = _rand.nextBool();
      var clue = 0;
      var added = 0;
      // List<_NeededItem> neighbours = [];
      iterateOnSquare(cells, target.i, target.j, (Cell? e, int i, int j) {
        if (e == null) {
          e = Cell(value: filling, shown: false, clue: -1);
          cells[i][j] = e;
          filled.add(_NeededItem(i, j));
          added++;
        }
        clue += e.value ? 1 : 0;
        if (e.clue == -1) pending.add(_NeededItem(i, j));
      });

      /*if (neighbours.isNotEmpty) {
        final limit = _rand.nextInt(neighbours.length) + 1;
        for (int i = 0; i < limit; i++) {
          pending.add(neighbours[_rand.nextInt(neighbours.length)]);
        }
      }*/
      var cell = cells[target.i][target.j]!;

      cell.clue = clue;
      if (added != 0) {
        cell.shown = true;
      }

      if (timer.elapsed > const Duration(seconds: 15)) {
        logger.d("filled ${filled.length} cells out of $size (${(filled.length / size * 100).toStringAsFixed(2)}%)");
        timer.reset();
      }
    }
    return cells.map((row) => row.map((cell) => cell!).toList()).toList();
  }

  List<List<Cell>> _genV3() {
    final List<List<Cell?>> cells = List.generate(height, (i) => List.generate(width, (j) => null));
    final Set<_NeededItem> pending = {_NeededItem(_rand.nextInt(height), _rand.nextInt(width))};
    final Set<_NeededItem> filled = {};
    final size = height * width;
    final Stopwatch timer = Stopwatch();
    final startPos = pending.first;
    timer.start();
    int shown = 0;

    while (filled.length < size) {
      var target = pending.elementAt(_rand.nextInt(pending.length));
      pending.remove(target);

      var filling = _rand.nextBool();
      var clue = 0;
      var added = 0;

      iterateOnSquare(cells, target.i, target.j, (Cell? e, int i, int j) {
        if (e == null) {
          e = Cell(value: filling, shown: false, clue: -1);
          cells[i][j] = e;
          filled.add(_NeededItem(i, j));
          added++;
        }
        clue += e.value ? 1 : 0;
        if (e.clue == -1) pending.add(_NeededItem(i, j));
      });

      var cell = cells[target.i][target.j]!;

      cell.clue = clue;
      if (added != 0) {
        cell.shown = true;
        shown++;
      }

      if (timer.elapsed > const Duration(seconds: 15)) {
        logger.d("filled ${filled.length} cells out of $size (${(filled.length / size * 100).toStringAsFixed(2)}%)");
        timer.reset();
      }
    }

    final list = cells.map((row) => row.map((cell) => cell!).toList(growable: false)).toList(growable: false);

    // V3

    pending.clear();
    pending.add(startPos);
    filled.clear();
    final Set<Cell> processed = {};

    while (filled.length < size) {
      var target = pending.elementAt(_rand.nextInt(pending.length));
      final cell = list[target.i][target.j];

      if (!cell.shown) continue;

      int black = 0, empty = 0;

      iterateOnSquare(list, target.i, target.j, (Cell cell, i, j) {
        switch (cell.state) {
          case true:
            black++;
            break;
          case null:
            empty++;
        }
      });

      processed.add(cell);

      if (empty == 0) {
        pending.remove(target);
      } else if (black == cell.clue || empty + black == cell.clue) {
        iterateOnSquare(list, target.i, target.j, (Cell e, i, j) {
          e.state ??= black != cell.clue;
          filled.add(_NeededItem(i, j)); // ptet optimiser avec un if
          if (e.shown && !processed.contains(e)) {
            // ptet uniquement quand elles sont vide au suivant
            pending.add(_NeededItem(i, j));
          }
        });
        pending.remove(target);
      }
      if (timer.elapsed > const Duration(seconds: 5)) {
        logger.d(
            "filled ${filled.length} cells out of $size (${(filled.length / size * 100).toStringAsFixed(2)}%) with ${pending.length} pending and ${processed.length} processed");
        timer.reset();
      }
    }

    for (var e in pending) {
      list[e.j][e.j].shown = false;
    }

    shown -= pending.length;
    logger.i(
        "removed ${pending.length} clues\n$shown/$size (${(shown / size * 100).toStringAsFixed(0)}%) clues displayed");

    for (var row in list) {
      for (var cell in row) {
        cell.state = null;
      }
    }

    return list;
  }

  List<List<Cell>> _genV4() {
    final List<List<Cell?>> cells = List.generate(height, (i) => List.generate(width, (j) => null));
    final Set<_NeededItem> pending = {_NeededItem(_rand.nextInt(height), _rand.nextInt(width))};
    final Set<_NeededItem> filled = {};
    final size = height * width;
    final Stopwatch timer = Stopwatch();
    final startPos = pending.first;
    timer.start();

    while (pending.isNotEmpty) {
      var target = pending.elementAt(_rand.nextInt(pending.length));
      pending.remove(target);

      var filling = _rand.nextBool();
      var clue = 0;

      iterateOnSquare(cells, target.i, target.j, (Cell? e, int i, int j) {
        if (e == null) {
          e = Cell(value: filling, shown: false, clue: -1);
          cells[i][j] = e;
          filled.add(_NeededItem(i, j));
        }
        clue += e.value ? 1 : 0;
        if (e.clue == -1) pending.add(_NeededItem(i, j));
      });

      var cell = cells[target.i][target.j]!;

      cell.clue = clue;

      if (timer.elapsed > const Duration(seconds: 15)) {
        logger.d("filled ${filled.length} cells out of $size (${(filled.length / size * 100).toStringAsFixed(2)}%)");
        timer.reset();
      }
    }

    final list = cells.map((row) => row.map((cell) => cell!).toList(growable: false)).toList(growable: false);

    // V4

    pending.clear();
    pending.add(startPos);
    filled.clear();
    final Set<Cell> processed = {};
    int shown = 0;

    while (filled.length < size) {
      var target = pending.elementAt(_rand.nextInt(pending.length));
      final cell = list[target.i][target.j];

      int black = 0, empty = 0;

      iterateOnSquare(list, target.i, target.j, (Cell cell, i, j) {
        switch (cell.state) {
          case true:
            black++;
            break;
          case null:
            empty++;
        }
      });

      processed.add(cell);

      if (empty == 0) {
        pending.remove(target);
      } else if (black == cell.clue || empty + black == cell.clue) {
        cell.shown = true;
        shown++;
        iterateOnSquare(list, target.i, target.j, (Cell e, i, j) {
          e.state ??= black != cell.clue;
          filled.add(_NeededItem(i, j)); // ptet optimiser avec un if
          if (!processed.contains(e)) {
            // ptet uniquement quand elles sont vide au suivant
            pending.add(_NeededItem(i, j));
          }
        });
        pending.remove(target);
      }
      if (timer.elapsed > const Duration(seconds: 5)) {
        logger.d(
            "filled ${filled.length} cells out of $size (${(filled.length / size * 100).toStringAsFixed(2)}%) with ${pending.length} pending and ${processed.length} processed");
        timer.reset();
      }
    }

    logger.i("$shown/$size (${(shown / size * 100).toStringAsFixed(0)}%) clues displayed");

    for (var row in list) {
      for (var cell in row) {
        cell.state = null;
      }
    }

    return list;
  }

  List<List<Cell>> _genV5() {
    final List<List<Cell?>> cells = List.generate(height, (i) => List.generate(width, (j) => null));
    final Set<_NeededItem> pending = {_NeededItem(_rand.nextInt(height), _rand.nextInt(width))};
    final Set<_NeededItem> filled = {};
    final Set<_NeededItem> startPositions = {pending.first};
    final size = height * width;
    final Stopwatch timer = Stopwatch();
    timer.start();

    while (pending.isNotEmpty) {
      var target = pending.elementAt(_rand.nextInt(pending.length));
      pending.remove(target);

      var filling = _rand.nextBool();
      var clue = 0;

      final count = iterateOnSquare(cells, target.i, target.j, (Cell? e, int i, int j) {
        if (e == null) {
          e = Cell(value: filling, shown: false, clue: -1);
          cells[i][j] = e;
          filled.add(_NeededItem(i, j));
        }
        clue += e.value ? 1 : 0;
        if (e.clue == -1) pending.add(_NeededItem(i, j));
      });

      if (clue == 0 || clue == count) {
        startPositions.add(target);
      }

      var cell = cells[target.i][target.j]!;

      cell.clue = clue;

      if (timer.elapsed > const Duration(seconds: 15)) {
        logger.d("filled ${filled.length} cells out of $size (${(filled.length / size * 100).toStringAsFixed(2)}%)");
        timer.reset();
      }
    }

    final list = cells.map((row) => row.map((cell) => cell!).toList(growable: false)).toList(growable: false);

    // V5

    logger.i("${startPositions.length} start positions");

    pending.clear();
    filled.clear();
    final Set<Cell> processed = {};
    int shown = 0;

    while (filled.length < size) {
      final startPos = startPositions.elementAt(_rand.nextInt(startPositions.length));
      startPositions.remove(startPos);
      pending.add(startPos);
      while (pending.isNotEmpty && filled.length < size) {
        var target = pending.elementAt(_rand.nextInt(pending.length));
        final cell = list[target.i][target.j];

        int black = 0, empty = 0;

        iterateOnSquare(list, target.i, target.j, (Cell cell, i, j) {
          switch (cell.state) {
            case true:
              black++;
              break;
            case null:
              empty++;
          }
        });

        processed.add(cell);

        if (empty == 0) {
          pending.remove(target);
        } else if (black == cell.clue || empty + black == cell.clue) {
          cell.shown = true;
          shown++;
          iterateOnSquare(list, target.i, target.j, (Cell e, i, j) {
            e.state ??= black != cell.clue;
            filled.add(_NeededItem(i, j)); // ptet optimiser avec un if
            if (!processed.contains(e)) {
              // ptet uniquement quand elles sont vide au suivant
              pending.add(_NeededItem(i, j));
            }
          });
          pending.remove(target);
        }
        if (timer.elapsed > const Duration(seconds: 5)) {
          logger.d(
              "filled ${filled.length} cells out of $size (${(filled.length / size * 100).toStringAsFixed(2)}%) with ${pending.length} pending and ${processed.length} processed");
          timer.reset();
        }
      }
    }

    logger.i("$shown/$size (${(shown / size * 100).toStringAsFixed(0)}%) clues displayed");

    for (var row in list) {
      for (var cell in row) {
        cell.state = null;
      }
    }

    return list;
  }

  @override
  String toString() {
    return "$height;$width;$_gameDesc;${_getCompressedString((cell) => cell.value)};${_getCompressedString((cell) => cell.state)}";
  }
}

abstract class CellState {
  static const int unmarked = 0;
  static const int marked = 1;
  static const int blank = 2;
  static const int solved = 4;
  static const int error = 8;
  static const int unmarkedError = error | unmarked;
  static const int markedError = error | marked;
  static const int blankError = error | blank;
  static const int blankSolved = solved | blank;
  static const int markedSolved = marked | solved;
  static const int okNum = blank | marked;
}

class _NeededItem {
  int i, j;

  _NeededItem(this.i, this.j);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _NeededItem && runtimeType == other.runtimeType && i == other.i && j == other.j;

  @override
  int get hashCode => i.hashCode ^ j.hashCode;
}

class _SolutionCell {
  int cell = CellState.unmarked;
  bool solved = false;
  bool needed = false;
}

class _SolutionResult {
  List<List<_SolutionCell>> sol;
  bool result;

  _SolutionResult(this.sol, this.result);
}

class _MarkCounter {
  int marked = 0;
  int total = 0;
  int blank = 0;
}
