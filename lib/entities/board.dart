import 'dart:async';
import 'dart:math';

import 'package:mosaic/entities/cell.dart';
import 'package:mosaic/utils/config.dart';

enum GenerationAlgorithm {
  /// Phase 1 current + Phase 2 current — O(N)
  easy,

  /// Phase 1 Option 1 (independent cell fills) + Phase 2 current — O(N)
  medium,

  /// Phase 1 Option 1 + Phase 2 Option 2 (enriched constraint propagation) — O(N·k)
  hard,

  /// Phase 1 Option 1 + Phase 2 Option 2 + Option 3 (backtracking uniqueness, 4 s timeout) — O(N²)
  expert,
}

class Board {
  final int height;
  final int width;
  late List<List<Cell>> cells;

  final double density;
  final GenerationAlgorithm algorithm;

  late final Random _rand;
  late final int seed;

  String? _gameDesc;

  /// Incremented each time cells are mutated so [FreePainter] can detect
  /// visual changes without relying on object identity.
  int version = 0;

  /// Increments [version] using a 30-bit mask to prevent silent overflow on
  /// all Dart platforms (native 64-bit wrap and web 53-bit JavaScript double
  /// saturation). The wrap-around space (~1 billion values) makes an accidental
  /// version collision practically impossible during a game session.
  void bumpVersion() => version = (version + 1) & 0x3FFFFFFF;

  Board({this.height = 8, this.width = 8, this.density = 0.5, int? seed, this.algorithm = GenerationAlgorithm.easy}) {
    this.seed = seed ?? Random().nextInt(1 << 32);
    _rand = Random(this.seed);
  }

  Board.from(Board other)
      : height = other.height,
        width = other.width,
        density = other.density,
        algorithm = other.algorithm,
        _rand = other._rand,
        seed = other.seed,
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

    if (algorithm == GenerationAlgorithm.hard) {
      cells = _genHard(debugStreamSink);
    } else if (algorithm == GenerationAlgorithm.expert) {
      cells = _genExpert(debugStreamSink);
    } else {
      cells = _genV7(debugStreamSink, independentFill: algorithm == GenerationAlgorithm.medium);
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

  /// Hard difficulty: runs [_genV7] with Option 1 (independent fills) then
  /// applies an enriched constraint-propagation pass to remove clues that are
  /// uniquely deducible using both basic and intersection rules.
  List<List<Cell>> _genHard(StreamSink<BoardGenerationStep>? debugStreamSink) {
    final list = _genV7(debugStreamSink, independentFill: true);

    final List<_Coordinates> shown = [];
    for (int i = 0; i < height; i++) {
      for (int j = 0; j < width; j++) {
        if (list[i][j].shown) shown.add(_Coordinates(i, j));
      }
    }
    shown.shuffle(_rand);

    int removed = 0;
    for (final coord in shown) {
      list[coord.i][coord.j].shown = false;
      if (_canSolveEnrichedPropagation(list)) {
        removed++;
      } else {
        list[coord.i][coord.j].shown = true;
      }
    }

    logger.d('Hard pass removed $removed additional clues');
    return list;
  }

  /// Expert difficulty: Option 1 phase-1 + enriched propagation masking (same
  /// as [_genHard]) followed by a backtracking uniqueness pass within a 4 s
  /// budget, hiding every clue whose removal still leaves exactly one solution.
  List<List<Cell>> _genExpert(StreamSink<BoardGenerationStep>? debugStreamSink) {
    final list = _genV7(debugStreamSink, independentFill: true);
    final deadline = DateTime.now().add(const Duration(seconds: 4));

    final List<_Coordinates> shown = [];
    for (int i = 0; i < height; i++) {
      for (int j = 0; j < width; j++) {
        if (list[i][j].shown) shown.add(_Coordinates(i, j));
      }
    }
    shown.shuffle(_rand);

    // Phase 1 – enriched propagation masking (same as Hard)
    int removed = 0;
    for (final coord in shown) {
      if (DateTime.now().isAfter(deadline)) break;
      list[coord.i][coord.j].shown = false;
      if (_canSolveEnrichedPropagation(list)) {
        removed++;
      } else {
        list[coord.i][coord.j].shown = true;
      }
    }
    logger.d('Expert Phase 1 (enriched propagation) removed $removed clues');

    // Phase 2 – backtracking uniqueness verification (if time remains)
    int removed2 = 0;
    if (!DateTime.now().isAfter(deadline)) {
      final List<_Coordinates> remaining = [];
      for (int i = 0; i < height; i++) {
        for (int j = 0; j < width; j++) {
          if (list[i][j].shown) remaining.add(_Coordinates(i, j));
        }
      }
      remaining.shuffle(_rand);

      for (final coord in remaining) {
        if (DateTime.now().isAfter(deadline)) break;
        list[coord.i][coord.j].shown = false;
        final states = List.generate(height, (_) => List<bool?>.filled(width, null, growable: false));
        if (_countSolutions(list, states, deadline) == 1) {
          removed2++;
        } else {
          list[coord.i][coord.j].shown = true;
        }
      }
      logger.d('Expert Phase 2 (backtracking uniqueness) removed $removed2 more clues');
    }

    return list;
  }

  /// Returns true when enriched constraint propagation (basic forced-cell rules
  /// + pairwise-clue intersection rules) can uniquely determine every cell
  /// using only the shown clues.
  bool _canSolveEnrichedPropagation(List<List<Cell>> cells) {
    final states = List.generate(height, (_) => List<bool?>.filled(width, null, growable: false));
    return _runPropagation(cells, states) == 0;
  }

  /// Applies enriched constraint propagation to [states] in place.
  ///
  /// Returns the number of still-undecided cells (≥ 0), or -1 if a
  /// contradiction is detected (more filled than clue, or impossible to reach
  /// clue value).
  ///
  /// Rules applied in every pass:
  ///   Basic 1 – if filled == clue all unknowns in the window are set empty.
  ///   Basic 2 – if filled + unknown == clue all unknowns are set filled.
  ///   Intersection – for each pair of overlapping shown clues A and B, compute
  ///     tight bounds on how many of their shared unknown cells must be filled,
  ///     and propagate accordingly.
  int _runPropagation(List<List<Cell>> cells, List<List<bool?>> states) {
    int unsolved = 0;
    for (int i = 0; i < height; i++) {
      for (int j = 0; j < width; j++) {
        if (states[i][j] == null) unsolved++;
      }
    }

    bool progress = true;
    while (progress && unsolved > 0) {
      progress = false;
      for (int i = 0; i < height; i++) {
        for (int j = 0; j < width; j++) {
          final c = cells[i][j];
          if (!c.shown) continue;

          int filled = 0, unknown = 0;
          final unknownCoords = <_Coordinates>[];
          iterateOnSquare(states, i, j, (bool? s, ni, nj) {
            if (s == true) {
              filled++;
            } else if (s == null) {
              unknown++;
              unknownCoords.add(_Coordinates(ni, nj));
            }
          });

          // Contradiction checks
          if (filled > c.clue) return -1;
          if (filled + unknown < c.clue) return -1;

          if (unknown == 0) continue;

          // Basic Rule 1: filled == clue → all unknowns must be empty
          if (filled == c.clue) {
            for (final nc in unknownCoords) {
              if (states[nc.i][nc.j] == null) {
                states[nc.i][nc.j] = false;
                unsolved--;
                progress = true;
              }
            }
            continue;
          }

          // Basic Rule 2: filled + unknown == clue → all unknowns must be filled
          if (filled + unknown == c.clue) {
            for (final nc in unknownCoords) {
              if (states[nc.i][nc.j] == null) {
                states[nc.i][nc.j] = true;
                unsolved--;
                progress = true;
              }
            }
            continue;
          }

          // Enriched Rule – intersection with each overlapping shown clue B
          final needA = c.clue - filled;
          bool enrichedProgress = false;

          for (int di = -2; di <= 2 && !enrichedProgress; di++) {
            for (int dj = -2; dj <= 2 && !enrichedProgress; dj++) {
              if (di == 0 && dj == 0) continue;
              final ni = i + di, nj = j + dj;
              if (ni < 0 || ni >= height || nj < 0 || nj >= width) continue;
              final nb = cells[ni][nj];
              if (!nb.shown) continue;

              // Collect B's filled count and only-B unknown count
              int filledB = 0, onlyBCount = 0;
              iterateOnSquare(states, ni, nj, (bool? s, bi, bj) {
                if (s == true) {
                  filledB++;
                } else if (s == null && (bi < i - 1 || bi > i + 1 || bj < j - 1 || bj > j + 1)) {
                  onlyBCount++;
                }
              });

              final needB = nb.clue - filledB;
              if (needB < 0) return -1; // Contradiction

              // Partition A's unknowns into shared (also in B's window) and only-A
              final List<_Coordinates> shared = [];
              final List<_Coordinates> onlyA = [];
              for (final ac in unknownCoords) {
                if (ac.i >= ni - 1 && ac.i <= ni + 1 && ac.j >= nj - 1 && ac.j <= nj + 1) {
                  shared.add(ac);
                } else {
                  onlyA.add(ac);
                }
              }

              if (shared.isEmpty) continue;

              final sharedLen = shared.length;
              final onlyALen = onlyA.length;

              // Bounds on how many shared unknowns must be filled
              final sMin = [0, needA - onlyALen, needB - onlyBCount].reduce((a, b) => a > b ? a : b);
              final sMax = [sharedLen, needA, needB].reduce((a, b) => a < b ? a : b);

              if (sMin > sMax) continue; // Inconsistent bounds, skip

              void markCells(List<_Coordinates> coords, bool val) {
                for (final sc in coords) {
                  if (states[sc.i][sc.j] == null) {
                    states[sc.i][sc.j] = val;
                    unsolved--;
                    progress = true;
                    enrichedProgress = true;
                  }
                }
              }

              if (sMin == sharedLen) {
                markCells(shared, true);
              } else if (sMax == 0) {
                markCells(shared, false);
              }

              // When shared count is fully determined, deduce only-A as well
              if (!enrichedProgress && sMin == sMax) {
                final remainA = needA - sMin;
                if (remainA == onlyALen) {
                  markCells(onlyA, true);
                } else if (remainA == 0) {
                  markCells(onlyA, false);
                }
              }
            }
          }
        }
      }
    }

    return unsolved;
  }

  /// Returns the number of distinct solutions for the puzzle represented by
  /// [cells] and the current [states], capped at 2.  Returns 2 also on timeout.
  ///
  /// Uses [_runPropagation] to reduce the search space before each branch.
  int _countSolutions(List<List<Cell>> cells, List<List<bool?>> states, DateTime deadline) {
    if (DateTime.now().isAfter(deadline)) return 2;

    final result = _runPropagation(cells, states);
    if (result == -1) return 0; // Contradiction
    if (result == 0) return 1; // Unique solution found

    // Find first undecided cell to branch on
    for (int i = 0; i < height; i++) {
      for (int j = 0; j < width; j++) {
        if (states[i][j] == null) {
          int total = 0;
          for (final val in [true, false]) {
            if (DateTime.now().isAfter(deadline)) return 2;
            final branch = List.generate(height, (r) => List<bool?>.from(states[r]));
            branch[i][j] = val;
            total += _countSolutions(cells, branch, deadline);
            if (total >= 2) return 2;
          }
          return total;
        }
      }
    }
    return 0; // No undecided cell found despite result > 0 (shouldn't happen)
  }



  /// This algorithm may result in cells having ```{clue=-1, shown=false}```. Replace ```while (filled.length < size)```
  /// with ```while (pending.isNotEmpty)``` to fill all the clues.
  ///
  /// When [independentFill] is true (Option 1), each newly created null cell
  /// receives its own independent random value instead of sharing the single
  /// [filling] bool drawn for the current target.  This breaks up monochrome
  /// blocks, producing more varied patterns with fewer trivial 0/9 clues.
  List<List<Cell>> _genV7(StreamSink<BoardGenerationStep>? debugStreamSink, {bool independentFill = false}) {
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
          // Option 1: each new cell gets its own independent random value
          // instead of sharing the single `filling` bool drawn for this target.
          final cellValue = independentFill ? _rand.nextBool() : filling;
          e = Cell(value: cellValue, shown: false, clue: -1);
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
