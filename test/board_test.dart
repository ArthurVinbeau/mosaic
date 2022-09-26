import 'dart:async';
import 'dart:math';

import 'package:mosaic/entities/board.dart';
import 'package:mosaic/entities/cell.dart';
import 'package:mosaic/utils/config.dart';
import 'package:test/test.dart';

void main() {
  group("Board save & load", () {
    test("board toString should be valid", () {
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

    test("board from string should be the same", () {
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
        cell.state = {1: true, 2: false}[rand.nextInt(3)];
        coords.add([(n / width).floor(), n % width]);
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
          expect(b.value, a.value, reason: reason);
          expect(b.state, a.state, reason: reason);
          expect(b.shown, a.shown, reason: reason);
          if (a.shown) {
            expect(b.clue, a.clue, reason: reason);
            expect(b.error, a.error, reason: reason);
            expect(b.complete, a.complete, reason: reason);
          }
        }
      }
    });
  });

  group("board generation", () {
    test("Board should be complete and empty", () {
      final sizes = [[3, 3], [8, 8], [25, 25], [100, 100], [50, 10]];

      final debugStreamController = StreamController<BoardGenerationStep>();
      final List<BoardGenerationStep> steps = [];
      debugStreamController.stream.listen(steps.add);
      for (var size in sizes) {
        final board = Board(height: size[0], width: size[1]);
        board.newGameDesc(debugStreamSink: debugStreamController.sink);

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
      }
    });
  });
}
