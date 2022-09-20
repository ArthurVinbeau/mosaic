import 'dart:math';

import 'package:flutter/material.dart';

import '../utils/themes.dart';

class LoadingPainter extends CustomPainter {
  final GameTheme theme;
  final double paddingRatio;
  final double maxTileSize;
  final int boardSize;
  final double progress;
  final int cycle;

  LoadingPainter(
      {required this.theme,
      required this.paddingRatio,
      required this.maxTileSize,
      required this.boardSize,
      required this.progress,
      required this.cycle});

  @override
  void paint(Canvas canvas, Size size) {
    final screenRatio = size.height / size.width;

    double tileSize;

    if (screenRatio > 1) {
      tileSize = size.width / boardSize / paddingRatio;
    } else {
      tileSize = size.height / boardSize / paddingRatio;
    }

    tileSize = min(tileSize, maxTileSize);

    final padding = (tileSize * paddingRatio - tileSize) / 2;

    final double midW = size.width / 2;
    final double midH = size.height / 2;

    /*logger.i({
      "tileSize": tileSize,
      "padding": padding,
      "mid": {
        "width": midW,
        "height": midH,
      },
      "size": size,
      "progress": progress,
    });*/

    for (int i = 0; i < boardSize; i++) {
      for (int j = 0; j < boardSize; j++) {
        final offset = Offset(midW - (boardSize / 2 - j) * tileSize * paddingRatio + padding,
            midH - (boardSize / 2 - i) * tileSize * paddingRatio + padding);
        final cellColor = Paint()
          ..style = PaintingStyle.fill
          ..color = theme.cellBase;

        canvas.drawRect(Rect.fromPoints(offset, Offset(offset.dx + tileSize, offset.dy + tileSize)), cellColor);

        /*final tmp = (progress - (i + j) / (boardSize - 1) / 2);
        final overlayColor = Paint()
          ..style = PaintingStyle.fill
          ..color = theme.cellFilled.withOpacity(max(1 - 4 * tmp * tmp, 0));*/

        // Y = (1/4*PI() + PI()*X)
        // Z = MAX(0;SIN(Y-1/2*PI()*(i+j)/N))
        final adjustedProgress = progress * 2 - 0.25; // the pattern that we want starts at -0.25 and ends at 1.75
        final tmp = (1 / 4 * pi + pi * adjustedProgress);
        final overlayColor = Paint()
          ..style = PaintingStyle.fill
          ..color = (cycle % 2 == 0 ? theme.cellFilled : theme.cellEmpty)
              .withOpacity(max(0, sin(tmp - 1 / 2 * pi * (i + j) / boardSize)));

        canvas.drawRect(Rect.fromPoints(offset, Offset(offset.dx + tileSize, offset.dy + tileSize)), overlayColor);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
