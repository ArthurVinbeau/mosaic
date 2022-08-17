import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mosaic/entities/board.dart';
import 'package:mosaic/utils/themes.dart';

import '../utils/config.dart';

class FreePainter extends CustomPainter {
  final Board board;
  final GameTheme theme;
  final double scale;
  final double paddingRatio;
  final Offset boardPosition;

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
    var baseStyle = TextStyle(
        fontFeatures: const [FontFeature.tabularFigures()],
        height: 1,
        fontSize: 0.75 * tileSize,
        fontFamily: "JetBrainsMono");

    final textPainter = TextPainter(
        textDirection: TextDirection.ltr, textAlign: TextAlign.center, text: TextSpan(text: "0", style: baseStyle));
    textPainter.layout();

    final letterSize = textPainter.width;

    baseStyle = baseStyle.copyWith(letterSpacing: tileSize * paddingRatio * 1.02 - letterSize, height: 1.5);

    final TextStyle cellTextBase = baseStyle.copyWith(color: theme.cellTextBase);
    final TextStyle cellTextError = baseStyle.copyWith(color: theme.cellTextError);
    final TextStyle cellTextComplete = baseStyle.copyWith(color: theme.cellTextComplete);
    final TextStyle cellTextFilled = baseStyle.copyWith(color: theme.cellTextFilled);
    final TextStyle cellTextEmpty = baseStyle.copyWith(color: theme.cellTextEmpty);

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

    var txt = "";

    for (int i = iStart; i < min(board.height, iStart + iCount + 1); i++) {
      for (int j = jStart; j < min(board.width, jStart + jCount + 1); j++) {
        final cell = board.cells[i][j];
        final offset = Offset(midW - (boardPosition.dx - j) * tileSize * paddingRatio + padding,
            midH - (boardPosition.dy - i) * tileSize * paddingRatio + padding);
        canvas.drawRect(
            Rect.fromPoints(
              offset,
              Offset(offset.dx + tileSize, offset.dy + tileSize),
            ),
            cell.state == null
                ? cellBase
                : cell.state!
                    ? cellFilled
                    : cellEmpty);

        if (cell.shown) {
          textPainter.text = TextSpan(
            text: cell.clue.toString(),
            style: cell.error
                ? cellTextError
                : cell.complete
                    ? cellTextComplete
                    : cell.state == null
                        ? cellTextBase
                        : cell.state!
                            ? cellTextFilled
                            : cellTextEmpty,
          );
          textPainter.layout();
          final o = Offset(offset.dx + (tileSize / 2) - (textPainter.width / 2),
              offset.dy + (tileSize / 2) - (textPainter.height / 2));
          // textPainter.paint(canvas, o);
          txt += cell.clue.toString();
        } else {
          txt += " ";
        }
      }
      txt += "\n";
    }
    logger.i(txt);
    textPainter.text = TextSpan(text: txt, style: cellTextBase);
    textPainter.layout();
    final off = Offset(midW - (boardPosition.dx - jStart) * tileSize * paddingRatio + padding,
        midH - (boardPosition.dy - iStart) * tileSize * paddingRatio + padding);
    final origin =
        Offset(off.dx + (tileSize / 2) - (textPainter.width / 2), off.dy + (tileSize / 2) - (textPainter.height / 2));
    logger.i({
      "position": boardPosition,
      "off": off,
      "origin": origin,
      "start": {"i": iStart, "j": jStart},
      "mid": {"h": midH, "w": midW},
      "style": baseStyle,
    });
    textPainter.paint(canvas, off);

    // canvas.drawRect(Rect.fromCenter(center: Offset(pW + 50, pH + 100), width: 32, height: 32), squarePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
