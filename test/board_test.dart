import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';

import 'package:mosaic/entities/board.dart';
import 'package:mosaic/entities/cell.dart';
import 'package:mosaic/utils/config.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

bool solveBoard(Board board) {
  Set<Cell> processed = {};
  final Queue<Coordinates> pending = Queue();

  for (int i = 0; i < board.height; i++) {
    final hSide = i == 0 || i + 1 == board.height ? 1 : 0;
    for (int j = 0; j < board.height; j++) {
      final side = hSide + (j == 0 || j + 1 == board.width ? 1 : 0);
      final cell = board.cells[i][j];

      if (cell.shown &&
          (cell.clue == 0 ||
              (cell.clue == 9 && side == 0) ||
              (cell.clue == 6 && side == 1) ||
              (cell.clue == 4 && side == 2))) {
        pending.add(Coordinates(i, j));
      }
    }
  }

  if (pending.isEmpty) {
    logger.e("No starting position found");
    return false;
  }

  while (pending.isNotEmpty) {
    final target = pending.removeFirst();
    final cell = board.cells[target.i][target.j];
    int empty = 0;
    int filled = 0;
    Board.iterateOnSquare(board.cells, target.i, target.j, (Cell cell, i, j) {
      if (cell.state == true) {
        filled++;
      } else if (cell.state == null) {
        empty++;
      }
    });

    processed.add(cell);

    if (empty != 0 && cell.shown) {
      if (filled == cell.clue || filled + empty == cell.clue) {
        Board.iterateOnSquare(board.cells, target.i, target.j, (Cell e, i, j) {
          e.state ??= filled != cell.clue;
          if (e.shown && !processed.contains(e)) pending.addFirst(Coordinates(i, j));
        });
      } else {
        pending.addLast(target);
      }
    }
  }

  for (int i = 0; i < board.height; i++) {
    for (int j = 0; j < board.height; j++) {
      final cell = board.cells[i][j];
      if (cell.value != cell.state) {
        logger.w("Error while checking solved board at ($i, $j): state is ${cell.state} but value is ${cell.value}");
        return false;
      }
      if (cell.shown) {
        int filled = 0;
        Board.iterateOnSquare(board.cells, i, j, (Cell e, i, j) {
          if (e.value) {
            filled++;
          }
        });
        if (filled != cell.clue) {
          logger.w(
              "Error while checking solved board at ($i, $j): filled cells around are $filled but clue is ${cell.clue}");
          return false;
        }
      }
    }
  }

  return true;
}

bool generateAndSolveBoard(DebugStreamController controller) {
  final identifier = controller.registerStream("8x8");
  final board = Board(height: 8, width: 8);
  board.newGameDesc(debugStreamSink: controller.get(identifier));

  final result = solveBoard(board);
  if (result) controller.close(identifier);
  return result;
}

void main() {
  group("Board save & load", () {
    test("toString should be valid", () {
      const height = 8;
      const width = 9;
      const boardSize = height * width;
      final board = Board(height: height, width: width);
      final desc = board.newGameDesc();

      final rand = Random();

      for (int k = 0; k < boardSize / 2; k++) {
        int n = rand.nextInt(boardSize);
        final cell = board.cells[(n / width).floor()][n % width];
        cell.error = rand.nextBool();
        cell.full = rand.nextBool();
        cell.state = {1: true, 2: false}[rand.nextInt(3)];
      }

      final str = board.toString();
      final parts = str.split(";");
      logger.d(parts);

      expect(parts.length, 5);
      expect(parts[0], height.toString());
      expect(parts[1], width.toString());
      expect(parts[2], desc);
      expect(RegExp(r"[a-z0-9]+").stringMatch(desc), desc);
      expect(RegExp(r"([1-2][b-z]?)+").stringMatch(parts[3]), parts[3]);
      expect(RegExp(r"([0-2][b-z]?)+").stringMatch(parts[4]), parts[4]);
    });

    test("from string should be the same", () {
      const height = 8;
      const width = 9;
      const boardSize = height * width;
      final board = Board(height: height, width: width);
      board.newGameDesc();

      final rand = Random();
      int count, empty;
      List<List<int>> coords = [];
      for (int k = 0; k < boardSize / 2; k++) {
        int n = rand.nextInt(boardSize);
        final cell = board.cells[(n / width).floor()][n % width];
        cell.state = {1: true, 2: false}[rand.nextInt(3)]; // 0: null
        coords.add([(n / width).floor(), n % width]);
      }

      for (int i = 0; i < board.height; i++) {
        for (int j = 0; j < board.width; j++) {
          int count = 0;
          int empty = 0;
          final cell = board.cells[i][j];
          Board.iterateOnSquare(board.cells, i, j, (Cell e, i, j) {
            count += e.state == true ? 1 : 0;
            empty += e.state == null ? 1 : 0;
          });
          cell.error = count > cell.clue || count < cell.clue && empty == 0;
          cell.complete = empty == 0;
        }
      }

      for (final coord in coords) {
        final cell = board.cells[coord[0]][coord[1]];
        empty = count = 0;
        Board.iterateOnSquare(board.cells, coord[0], coord[1], (Cell cell, i, j) {
          count += (cell.state ?? false) ? 1 : 0;
          empty += cell.state == null ? 1 : 0;
        });
        cell.error = count > cell.clue || count < cell.clue && empty == 0;
        cell.complete = empty == 0;
      }

      final str = board.toString();

      final newBoard = Board.fromString(str);
      expect(newBoard.height, height);
      expect(newBoard.width, width);
      expect(newBoard.toString(), str);
      logger.d(newBoard.toString().split(";"));

      Cell a, b;
      for (int i = 0; i < height; i++) {
        for (int j = 0; j < width; j++) {
          a = board.cells[i][j];
          b = newBoard.cells[i][j];
          final reason = "$i, $j:\nexpected: $a\nactual: $b";
          expect(b.value, a.value, reason: "(value) $reason");
          expect(b.state, a.state, reason: "(state) $reason");
          expect(b.shown, a.shown, reason: "(shown) $reason");
          if (a.shown) {
            expect(b.clue, a.clue, reason: "(clue) $reason");
            expect(b.error, a.error, reason: "(error) $reason");
            expect(b.complete, a.complete, reason: "(complete) $reason");
          }
        }
      }
    });
  });

  group("board generation", () {
    late DebugStreamController controller;

    setUpAll(() {
      controller = DebugStreamController();
    });

    tearDownAll(() async {
      final result = await controller.dump();
      final pad = result.length.toString().length;
      final outputDir = Directory('test/generationErrors');
      if (outputDir.existsSync()) {
        outputDir.deleteSync(recursive: true);
      }
      if (result.isNotEmpty) {
        outputDir.createSync();
        final List<Future> futures = [];
        for (int i = 0; i < result.length; i++) {
          futures.add((File("${outputDir.path}/${i.toString().padLeft(pad, '0')}")).writeAsString(result[i]));
        }
        await Future.wait(futures);
      }
    });

    test("Board should be complete and empty", () {
      final sizes = [
        [3, 3],
        [8, 8],
        [25, 25],
        [100, 100],
        [50, 10]
      ];

      for (var size in sizes) {
        final identifier = controller.registerStream("${size[0]}x${size[1]}");
        final board = Board(height: size[0], width: size[1]);
        board.newGameDesc(debugStreamSink: controller.get(identifier));

        expect(board.height, size[0]);
        expect(board.width, size[1]);
        expect(board.cells.length, size[0]);

        for (int i = 0; i < size[0]; i++) {
          expect(board.cells[i].length, size[1]);
          for (int j = 0; j < size[1]; j++) {
            final cell = board.cells[i][j];

            expect(cell.state, null);
            expect(cell.clue, greaterThan(-2));
            expect(cell.clue, lessThan(10));
          }
        }

        controller.close(identifier);
      }
    });

    void tmp(SendPort p) {
      final res = generateAndSolveBoard(controller);
      Isolate.exit(p, res);
    }

    test("Brute generation", () async {
      List<Future<dynamic>> list = [];
      for (int i = 0; i < 100; i++) {
        final p = ReceivePort();
        list.add(Isolate.spawn(tmp, p.sendPort).then((value) => p.first));
      }
      expect((await Future.wait(list)).every((element) => element is bool && element), true);
    });
  }, timeout: const Timeout(Duration(minutes: 1)));
}

enum DebugState {
  init,
  generating,
  solving,
  checking,
  done,
}

class DebugStreamController {
  final Map<String, StreamController<BoardGenerationStep>> _map = {};
  final Map<String, DebugState> _states = {};
  int opened = 0;
  int closed = 0;

  String registerStream(String name) {
    String identifier = "$name-${Uuid().v1()}";
    opened++;
    _map[identifier] = StreamController<BoardGenerationStep>();
    _states[identifier] = DebugState.init;
    return identifier;
  }

  StreamSink<BoardGenerationStep>? get(String name) {
    return _map[name]?.sink;
  }

  void setState(String name, DebugState state) {
    _states[name] = state;
  }

  void close(String name) {
    _map[name]?.close();
    _map.remove(name);
    _states.remove(name);
    closed++;
  }

  Future<List<String>> dump() async {
    final List<String> list = [];
    logger.i("opened $opened, closed $closed, remains ${_map.length}");
    for (MapEntry<String, StreamController<BoardGenerationStep>> entry in _map.entries) {
      final str = entry.value.stream.fold("", (String p, e) => "$p$e\n");
      entry.value.close();
      list.add("${entry.key} at ${_states[entry.key]}\n${await str}");
    }

    _map.clear();
    return list;
  }
}
