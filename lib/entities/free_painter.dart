import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mosaic/entities/board.dart';

import 'cell.dart';
import 'game_theme.dart';

class FreePainter extends CustomPainter {
  final Board board;
  final GameTheme theme;
  final double scale;
  final double paddingRatio;
  final Offset boardPosition;

  final bool overlay;
  final List<Offset> overlayExceptions;

  // static final Random rand = Random();

  late final Paint cellBase = Paint()
    ..style = PaintingStyle.fill
    ..color = theme.cellBase;
  late final Paint cellFilled = Paint()
    ..style = PaintingStyle.fill
    ..color = theme.cellFilled;
  late final Paint cellEmpty = Paint()
    ..style = PaintingStyle.fill
    ..color = theme.cellEmpty;

  FreePainter(
      {required this.board,
      required this.theme,
      required this.scale,
      required this.boardPosition,
      required this.overlay,
      required this.overlayExceptions,
      this.paddingRatio = 1.125});

  @override
  void paint(Canvas canvas, Size size) {
    final screenRatio = size.height / size.width;
    final boardRatio = board.height / board.width;

    double tileSize;
    int iCount, jCount;

    if (screenRatio > boardRatio) {
      // pH = (size.height - (size.height * boardRatio / screenRatio)) / 2;
      tileSize = size.width / board.width * scale / paddingRatio;
      jCount = (board.width / scale).ceil();
      iCount = (jCount * screenRatio).ceil();
    } else {
      // pW = (size.width - (size.width * boardRatio / screenRatio)) / 2;
      tileSize = size.height / board.height * scale / paddingRatio;
      iCount = (board.height / scale).ceil();
      jCount = (iCount / screenRatio).ceil();
    }

    final padding = (tileSize * paddingRatio - tileSize) / 2;

    final double midW = size.width / 2;
    final double midH = size.height / 2;

    /*final Paint cellRandom = Paint()
      ..style = PaintingStyle.fill
      ..color = Color.fromARGB(255, rand.nextInt(256), rand.nextInt(256), rand.nextInt(256));*/

    final TextStyle cellTextBase =
        TextStyle(fontSize: 0.75 * tileSize, color: theme.cellTextBase);
    final TextStyle cellTextError =
        TextStyle(fontSize: 0.75 * tileSize, color: theme.cellTextError);
    final TextStyle cellTextComplete =
        TextStyle(fontSize: 0.75 * tileSize, color: theme.cellTextComplete);
    final TextStyle cellTextFilled =
        TextStyle(fontSize: 0.75 * tileSize, color: theme.cellTextFilled);
    final TextStyle cellTextEmpty =
        TextStyle(fontSize: 0.75 * tileSize, color: theme.cellTextEmpty);

    final iStart = max(0, (boardPosition.dy - iCount / 2).floor());
    final jStart = max(0, (boardPosition.dx - jCount / 2).floor());

    if (iStart == 0) {
      iCount += (boardPosition.dy - iCount / 2).floor();
    }
    if (jStart == 0) {
      jCount += (boardPosition.dx - jCount / 2).floor();
    }

    /*logger.i({
      "tileSize": tileSize,
      "count": {
        "i": iCount,
        "j": jCount,
      },
      "end-start": {
        "i": min(board.height, iStart + iCount + 1) - iStart,
        "j": min(board.width, jStart + jCount + 1) - jStart,
      },
      "boardPosition": boardPosition,
      "canvas": {
        "height": size.height,
        "width": size.width,
      },
      "board": {
        "height": board.height,
        "width": board.width,
      },
    });*/

    final textPainter = TextPainter(
        textDirection: TextDirection.ltr, textAlign: TextAlign.center);

    for (int i = iStart; i < min(board.height, iStart + iCount + 1); i++) {
      for (int j = jStart; j < min(board.width, jStart + jCount + 1); j++) {
        final cell = board.cells[i][j];
        final offset = Offset(
            midW - (boardPosition.dx - j) * tileSize * paddingRatio + padding,
            midH - (boardPosition.dy - i) * tileSize * paddingRatio + padding);
        var cellColor = cell.state == null
            ? cellBase
            : cell.state!
                ? cellFilled
                : cellEmpty;
        var textStyle = cell.error
            ? cellTextError
            : cell.complete
                ? cellTextComplete
                : cell.state == null
                    ? cellTextBase
                    : cell.state!
                        ? cellTextFilled
                        : cellTextEmpty;

        if (overlay) {
          cellColor = Paint()
            ..color = cellColor.color.withValues(alpha: 0.5)
            ..style = cellColor.style;
          textStyle = textStyle.copyWith(
              color: textStyle.color!.withValues(alpha: 0.5));
        }

        _paintCell(
            canvas, offset, cell, cellColor, tileSize, textPainter, textStyle);
      }
    }

    if (overlay) {
      for (var target in overlayExceptions) {
        final int i = target.dy.floor();
        final int j = target.dx.floor();

        final cell = board.cells[i][j];
        final offset = Offset(
            midW - (boardPosition.dx - j) * tileSize * paddingRatio + padding,
            midH - (boardPosition.dy - i) * tileSize * paddingRatio + padding);
        var cellColor = cell.state == null
            ? cellBase
            : cell.state!
                ? cellFilled
                : cellEmpty;
        var textStyle = cell.error
            ? cellTextError
            : cell.complete
                ? cellTextComplete
                : cell.state == null
                    ? cellTextBase
                    : cell.state!
                        ? cellTextFilled
                        : cellTextEmpty;

        _paintCell(
            canvas, offset, cell, cellColor, tileSize, textPainter, textStyle);
      }
    }
  }

  void _paintCell(Canvas canvas, Offset offset, Cell cell, Paint cellColor,
      double tileSize, textPainter, TextStyle textStyle) {
    canvas.drawRect(
        Rect.fromPoints(
          offset,
          Offset(offset.dx + tileSize, offset.dy + tileSize),
        ),
        cellColor);
    if (cell.shown) {
      textPainter.text = TextSpan(
        text: cell.clue.toString(),
        style: textStyle,
      );
      textPainter.layout();
      final o = Offset(offset.dx + (tileSize / 2) - (textPainter.width / 2),
          offset.dy + (tileSize / 2) - (textPainter.height / 2));
      textPainter.paint(canvas, o);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
