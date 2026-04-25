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

  // Pre-computed solid base fill paint (theme-dependent, not progress-dependent).
  late final Paint _cellBasePaint = Paint()
    ..style = PaintingStyle.fill
    ..color = theme.cellBase;

  LoadingPainter(
      {required this.theme,
      required this.paddingRatio,
      required this.height,
      required this.width,
      required this.progress,
      required this.cycle});

  @override
  bool shouldRepaint(covariant LoadingPainter oldDelegate) {
    return progress != oldDelegate.progress ||
        cycle != oldDelegate.cycle ||
        !identical(theme, oldDelegate.theme) ||
        height != oldDelegate.height ||
        width != oldDelegate.width;
  }

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

    // Y = (1/4*PI() + PI()*X)
    // Z = MAX(0;SIN(Y-1/2*PI()*(i+j)/N))
    final adjustedProgress = progress * 2 -
        0.25; // the pattern that we want starts at -0.25 and ends at 1.75
    final tmp = (1 / 4 * pi + pi * adjustedProgress);
    // Pre-compute the wave color for this frame (one allocation instead of one per cell).
    final Color waveColor = cycle % 2 == 0 ? theme.cellFilled : theme.cellEmpty;
    final double waveScale = 1 / 2 * pi / max(height, width);
    // Reuse a single overlay paint, updating only its alpha per cell.
    final Paint overlayPaint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < height; i++) {
      for (int j = 0; j < width; j++) {
        final offset = Offset(
            midW - (width / 2 - j) * tileSize * paddingRatio + padding,
            midH - (height / 2 - i) * tileSize * paddingRatio + padding);
        final tileRect =
            Rect.fromPoints(offset, Offset(offset.dx + tileSize, offset.dy + tileSize));

        canvas.drawRect(tileRect, _cellBasePaint);

        final double alpha = max(0.0, sin(tmp - waveScale * (i + j)));
        if (alpha > 0) {
          overlayPaint.color = waveColor.withValues(alpha: alpha);
          canvas.drawRect(tileRect, overlayPaint);
        }
      }
    }
  }
}
