import 'dart:async';
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

  Board({this.height = 8, this.width = 8, this.density = 0.5}) : _rand = Random();

  Board.from(Board other)
      : height = other.height,
        width = other.width,
        density = other.density,
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

  String newGameDesc({StreamSink<BoardGenerationStep>? debugStreamSink}) {
    String compressed = "";
    int baseSpace = 'a'.codeUnitAt(0) - 1;
    int maxSpace = 'z'.codeUnitAt(0);
    int spaceCount = baseSpace;

    cells = _genV7(debugStreamSink);

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
    logger.d("Compressed description : $compressed");

    _gameDesc = compressed;

    return compressed;
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

  /// This algorithm may result in cells having ```{clue=-1, shown=false}```. Replace ```while (filled.length < size)```
  /// with ```while (pending.isNotEmpty)``` to fill all the clues.
  List<List<Cell>> _genV7(StreamSink<BoardGenerationStep>? debugStreamSink) {
    final List<List<Cell?>> cells = List.generate(height, (i) => List.generate(width, (j) => null));
    final Set<_Coordinates> pending = {_Coordinates(_rand.nextInt(height), _rand.nextInt(width))};
    final Set<_Coordinates> filled = {};
    final size = height * width;
    final startPos = pending.first;
    int shown = 0;

    // board generation
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
          filled.add(_Coordinates(i, j));
          added++;
        }
        clue += e.value ? 1 : 0;
        if (e.clue == -1) pending.add(_Coordinates(i, j));
      });

      var cell = cells[target.i][target.j]!;

      debugStreamSink
          ?.add(BoardGenerationStepFill(i: target.i, j: target.j, clue: clue, value: cell.value, fill: filling));

      cell.clue = clue;
      if (added != 0) {
        cell.shown = true;
        shown++;
      }
    }

    final list = cells.map((row) => row.map((cell) => cell!).toList(growable: false)).toList(growable: false);

    // remove some excess clues
    if (height * width > 25) {
      pending.clear();
      pending.add(startPos);
      filled.clear();
      final Set<Cell> processed = {};
      final Set<_Coordinates> whole = {};

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

        if (cell.clue == 0 || cell.clue == 9) {
          whole.add(target);
        }

        if (empty == 0) {
          pending.remove(target);
        } else if (black == cell.clue || empty + black == cell.clue) {
          iterateOnSquare(list, target.i, target.j, (Cell e, i, j) {
            if (e.state == null) {
              e.state = black != cell.clue;
              filled.add(_Coordinates(i, j));
            }

            if (e.shown && !processed.contains(e)) {
              pending.add(_Coordinates(i, j));
            }
          });
          pending.remove(target);
        }
      }

    // remove unused clues
    for (var e in pending) {
      final cell = list[e.j][e.j];
      cell.shown = false;
      debugStreamSink
          ?.add(BoardGenerationStepHide(i: e.i, j: e.j, clue: cell.clue, value: cell.value, type: HideType.newPath));
    }
    int removed = pending.length;

    /*
    * remove excess 9s & 0s (the center one in the following examples)
    * .9.  ...  9.9
    * .9.  000  .9.
    * .9.  ...  9.9
     */
    for (var target in whole) {
      final cell = list[target.i][target.j];
      if (cell.shown) {
        int notCorner = 0;
        if (target.i > 1 && target.i + 1 < height) {
          notCorner++;
          final upper = list[target.i - 1][target.j];
          final lower = list[target.i + 1][target.j];
          if (upper.shown && upper.clue == cell.clue && lower.shown && lower.clue == cell.clue) {
            cell.shown = false;
            removed++;
            debugStreamSink?.add(BoardGenerationStepHide(
                i: target.i, j: target.j, clue: cell.clue, value: cell.value, type: HideType.fullSquare));
            continue;
          }
        }

        if (target.j > 1 && target.j + 1 < width) {
          notCorner++;
          final left = list[target.i][target.j - 1];
          final right = list[target.i][target.j + 1];
          if (left.shown && left.clue == cell.clue && right.shown && right.clue == cell.clue) {
            cell.shown = false;
            removed++;
            debugStreamSink?.add(BoardGenerationStepHide(
                i: target.i, j: target.j, clue: cell.clue, value: cell.value, type: HideType.fullSquare));
            continue;
          }
        }

        if (notCorner == 2) {
          final upperLeft = list[target.i - 1][target.j - 1];
          final upperRight = list[target.i - 1][target.j + 1];
          final lowerLeft = list[target.i + 1][target.j - 1];
          final lowerRight = list[target.i + 1][target.j + 1];
          if (upperLeft.shown &&
              upperLeft.clue == cell.clue &&
              upperRight.shown &&
              upperRight.clue == cell.clue &&
              lowerLeft.shown &&
              lowerLeft.clue == cell.clue &&
              lowerRight.shown &&
              lowerRight.clue == cell.clue) {
            cell.shown = false;
            removed++;
            debugStreamSink?.add(BoardGenerationStepHide(
                i: target.i, j: target.j, clue: cell.clue, value: cell.value, type: HideType.fullSquare));
            continue;
          }
        }
      }
    }

    shown -= removed;

    logger.d("removed $removed clues\n$shown/$size (${(shown / size * 100).toStringAsFixed(0)}%) clues displayed");

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

class _Coordinates {
  int i, j;

  _Coordinates(this.i, this.j);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _Coordinates && runtimeType == other.runtimeType && i == other.i && j == other.j;

  @override
  int get hashCode => i.hashCode ^ j.hashCode;
}

abstract class BoardGenerationStep {
  final int i;
  final int j;
  final int clue;
  final bool value;

  const BoardGenerationStep(this.i, this.j, this.clue, this.value);
}

class BoardGenerationStepFill extends BoardGenerationStep {
  final bool? fill;

  const BoardGenerationStepFill({
    required int i,
    required int j,
    required int clue,
    required bool value,
    this.fill,
  }) : super(i, j, clue, value);

  @override
  String toString() {
    return 'BoardGenerationStepFill{i: $i, j: $j, clue: $clue, value: $value, fill: $fill}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BoardGenerationStepFill &&
          runtimeType == other.runtimeType &&
          i == other.i &&
          j == other.j &&
          fill == other.fill &&
          value == other.value &&
          clue == other.clue;

  @override
  int get hashCode => i.hashCode ^ j.hashCode ^ fill.hashCode ^ clue.hashCode ^ value.hashCode;
}

enum HideType {
  newPath,
  fullSquare,
}

class BoardGenerationStepHide extends BoardGenerationStep {
  final HideType type;

  const BoardGenerationStepHide({
    required int i,
    required int j,
    required int clue,
    required bool value,
    required this.type,
  }) : super(i, j, clue, value);

  @override
  String toString() {
    return 'BoardGenerationStepHide{i: $i, j: $j, clue: $clue, value: $value, type: $type}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BoardGenerationStepHide &&
          runtimeType == other.runtimeType &&
          i == other.i &&
          j == other.j &&
          type == other.type &&
          value == other.value &&
          clue == other.clue;

  @override
  int get hashCode => i.hashCode ^ j.hashCode ^ type.hashCode ^ clue.hashCode ^ value.hashCode;
}
