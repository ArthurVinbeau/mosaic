import 'dart:math';

import 'package:flutter/material.dart';

import 'game_theme.dart';

class LoadingPainter extends CustomPainter {
  final GameTheme theme;
  final double paddingRatio;
  final int height;
  final int width;
  final double progress;
  final int cycle;

  LoadingPainter(
      {required this.theme,
      required this.paddingRatio,
      required this.height,
      required this.width,
      required this.progress,
      required this.cycle});

  @override
  void paint(Canvas canvas, Size size) {
    final screenRatio = size.height / size.width;
    final boardRatio = height / width;

    double tileSize;

    if (screenRatio > boardRatio) {
      tileSize = size.width * 0.9 / width / paddingRatio;
    } else {
      tileSize = size.height * 0.9 / height / paddingRatio;
    }

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

    for (int i = 0; i < height; i++) {
      for (int j = 0; j < width; j++) {
        final offset = Offset(
            midW - (width / 2 - j) * tileSize * paddingRatio + padding,
            midH - (height / 2 - i) * tileSize * paddingRatio + padding);
        final cellColor = Paint()
          ..style = PaintingStyle.fill
          ..color = theme.cellBase;

        canvas.drawRect(
            Rect.fromPoints(
                offset, Offset(offset.dx + tileSize, offset.dy + tileSize)),
            cellColor);

        /*final tmp = (progress - (i + j) / (boardSize - 1) / 2);
        final overlayColor = Paint()
          ..style = PaintingStyle.fill
          ..color = theme.cellFilled.withValues(alpha: max(1 - 4 * tmp * tmp, 0));*/

        // Y = (1/4*PI() + PI()*X)
        // Z = MAX(0;SIN(Y-1/2*PI()*(i+j)/N))
        final adjustedProgress = progress * 2 -
            0.25; // the pattern that we want starts at -0.25 and ends at 1.75
        final tmp = (1 / 4 * pi + pi * adjustedProgress);
        final overlayColor = Paint()
          ..style = PaintingStyle.fill
          ..color = (cycle % 2 == 0 ? theme.cellFilled : theme.cellEmpty)
              .withValues(
                  alpha: max(
                      0, sin(tmp - 1 / 2 * pi * (i + j) / max(height, width))));

        canvas.drawRect(
            Rect.fromPoints(
                offset, Offset(offset.dx + tileSize, offset.dy + tileSize)),
            overlayColor);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
