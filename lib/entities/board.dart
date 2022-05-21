import 'dart:math';

import 'package:mosaic/entities/cell.dart';
import 'package:mosaic/utils/config.dart';

class Board {
  final int height;
  final int width;
  late List<List<Cell>> cells;

  final double density;

  final Random _rand = Random();

  String? _gameDesc;

  Board({this.height = 8, this.width = 8, this.density = 0.5});

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

  static void iterateOnSquare<T>(List<List<T>> list, int i, int j, void Function(T e, int i, int j) callback) {
    for (int k = -1; k < 2; k++) {
      final targetI = i + k;
      if (targetI >= 0 && targetI < list.length) {
        for (int n = -1; n < 2; n++) {
          final targetJ = j + n;
          if (targetJ >= 0 && targetJ < list[targetI].length) {
            callback(list[targetI][targetJ], targetI, targetJ);
          }
        }
      }
    }
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
    logger.d("Compressed description: $compressed");

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
        logger.d("Hiding cell [${neededList[k].i}][${neededList[k].j}] not possible.");
        curr.shown = true;
      }
    }

    logger.d("needed $needed");
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
