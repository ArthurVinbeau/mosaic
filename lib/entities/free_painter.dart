import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mosaic/entities/board.dart';

import 'cell.dart';
import 'game_theme.dart';

class FreePainter extends CustomPainter {
  final Board board;
  // Snapshot of board.version at construction time so shouldRepaint can detect
  // in-place cell mutations without relying on object identity.
  final int _boardVersion;
  final GameTheme theme;
  final double scale;
  final double paddingRatio;
  final Offset boardPosition;

  final bool overlay;
  final List<Offset> overlayExceptions;

  // Pre-computed solid fill paints.
  late final Paint cellBase = Paint()
    ..style = PaintingStyle.fill
    ..color = theme.cellBase;
  late final Paint cellFilled = Paint()
    ..style = PaintingStyle.fill
    ..color = theme.cellFilled;
  late final Paint cellEmpty = Paint()
    ..style = PaintingStyle.fill
    ..color = theme.cellEmpty;

  // Pre-computed half-alpha overlay paints (avoid per-cell Paint allocation).
  late final Paint cellBaseOverlay = Paint()
    ..style = PaintingStyle.fill
    ..color = theme.cellBase.withValues(alpha: 0.5);
  late final Paint cellFilledOverlay = Paint()
    ..style = PaintingStyle.fill
    ..color = theme.cellFilled.withValues(alpha: 0.5);
  late final Paint cellEmptyOverlay = Paint()
    ..style = PaintingStyle.fill
    ..color = theme.cellEmpty.withValues(alpha: 0.5);

  FreePainter(
      {required this.board,
      required this.theme,
      required this.scale,
      required this.boardPosition,
      required this.overlay,
      required this.overlayExceptions,
      this.paddingRatio = 1.125})
      : _boardVersion = board.version;

  @override
  bool shouldRepaint(covariant FreePainter oldDelegate) {
    // Skip repaint when nothing visible has changed.
    // Check board identity first: a different Board object (e.g. new game,
    // tutorial copy) always requires a repaint regardless of version.
    // For the same Board object mutated in place, version tracks changes.
    if (!identical(board, oldDelegate.board) ||
        _boardVersion != oldDelegate._boardVersion ||
        scale != oldDelegate.scale ||
        boardPosition != oldDelegate.boardPosition ||
        !identical(theme, oldDelegate.theme) ||
        overlay != oldDelegate.overlay ||
        overlayExceptions.length != oldDelegate.overlayExceptions.length) {
      return true;
    }
    // Deep-compare overlay exceptions to catch position changes with same count.
    for (int k = 0; k < overlayExceptions.length; k++) {
      if (overlayExceptions[k] != oldDelegate.overlayExceptions[k]) return true;
    }
    return false;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final screenRatio = size.height / size.width;
    final boardRatio = board.height / board.width;

    double tileSize;
    int iCount, jCount;

    if (screenRatio > boardRatio) {
      tileSize = size.width / board.width * scale / paddingRatio;
      jCount = (board.width / scale).ceil();
      iCount = (jCount * screenRatio).ceil();
    } else {
      tileSize = size.height / board.height * scale / paddingRatio;
      iCount = (board.height / scale).ceil();
      jCount = (iCount / screenRatio).ceil();
    }

    final padding = (tileSize * paddingRatio - tileSize) / 2;

    final double midW = size.width / 2;
    final double midH = size.height / 2;

    final double fontSize = 0.75 * tileSize;

    // Pre-compute text styles (depend on tileSize so must live inside paint).
    final TextStyle cellTextBase =
        TextStyle(fontSize: fontSize, color: theme.cellTextBase);
    final TextStyle cellTextError =
        TextStyle(fontSize: fontSize, color: theme.cellTextError);
    final TextStyle cellTextComplete =
        TextStyle(fontSize: fontSize, color: theme.cellTextComplete);
    final TextStyle cellTextFilled =
        TextStyle(fontSize: fontSize, color: theme.cellTextFilled);
    final TextStyle cellTextEmpty =
        TextStyle(fontSize: fontSize, color: theme.cellTextEmpty);

    // Pre-compute overlay text styles outside the loop (avoid per-cell copyWith).
    TextStyle? cellTextBaseOvl;
    TextStyle? cellTextErrorOvl;
    TextStyle? cellTextCompleteOvl;
    TextStyle? cellTextFilledOvl;
    TextStyle? cellTextEmptyOvl;
    if (overlay) {
      cellTextBaseOvl =
          TextStyle(fontSize: fontSize, color: theme.cellTextBase.withValues(alpha: 0.5));
      cellTextErrorOvl =
          TextStyle(fontSize: fontSize, color: theme.cellTextError.withValues(alpha: 0.5));
      cellTextCompleteOvl =
          TextStyle(fontSize: fontSize, color: theme.cellTextComplete.withValues(alpha: 0.5));
      cellTextFilledOvl =
          TextStyle(fontSize: fontSize, color: theme.cellTextFilled.withValues(alpha: 0.5));
      cellTextEmptyOvl =
          TextStyle(fontSize: fontSize, color: theme.cellTextEmpty.withValues(alpha: 0.5));
    }

    final iStart = max(0, (boardPosition.dy - iCount / 2).floor());
    final jStart = max(0, (boardPosition.dx - jCount / 2).floor());

    if (iStart == 0) {
      iCount += (boardPosition.dy - iCount / 2).floor();
    }
    if (jStart == 0) {
      jCount += (boardPosition.dx - jCount / 2).floor();
    }

    // Per-call TextPainter cache keyed by (clue, styleIndex).
    // styleIndex 0–4: normal; 5–9: overlay variants of the same order.
    // Within one paint call each unique (clue, style) is laid out only once,
    // reducing layout() calls from O(visible cells) to O(10 × 5) = O(50).
    final Map<(int, int), TextPainter> tpCache = {};

    // Returns a cached, already-laid-out TextPainter for the given clue/style.
    TextPainter _getTP(int clue, int styleIndex, TextStyle style) {
      return tpCache.putIfAbsent((clue, styleIndex), () {
        return TextPainter(
            textDirection: TextDirection.ltr, textAlign: TextAlign.center)
          ..text = TextSpan(text: clue.toString(), style: style)
          ..layout();
      });
    }

    // Collect styles in order: [base, error, complete, filled, empty]
    final List<TextStyle> normalStyles = [
      cellTextBase,
      cellTextError,
      cellTextComplete,
      cellTextFilled,
      cellTextEmpty
    ];
    final List<TextStyle>? overlayStyles = overlay
        ? [
            cellTextBaseOvl!,
            cellTextErrorOvl!,
            cellTextCompleteOvl!,
            cellTextFilledOvl!,
            cellTextEmptyOvl!
          ]
        : null;

    for (int i = iStart; i < min(board.height, iStart + iCount + 1); i++) {
      for (int j = jStart; j < min(board.width, jStart + jCount + 1); j++) {
        final cell = board.cells[i][j];
        final offset = Offset(
            midW - (boardPosition.dx - j) * tileSize * paddingRatio + padding,
            midH - (boardPosition.dy - i) * tileSize * paddingRatio + padding);
        final baseIdx = _baseStyleIndex(cell);
        _paintCell(
            canvas,
            offset,
            cell,
            _cellPaint(cell, useOverlay: overlay),
            tileSize,
            overlay ? baseIdx + 5 : baseIdx,
            overlay ? overlayStyles![baseIdx] : normalStyles[baseIdx],
            _getTP);
      }
    }

    if (overlay) {
      // Draw overlay exceptions at full opacity, reusing the same tp cache.
      for (var target in overlayExceptions) {
        final int i = target.dy.floor();
        final int j = target.dx.floor();

        final cell = board.cells[i][j];
        final offset = Offset(
            midW - (boardPosition.dx - j) * tileSize * paddingRatio + padding,
            midH - (boardPosition.dy - i) * tileSize * paddingRatio + padding);
        final baseIdx = _baseStyleIndex(cell);
        _paintCell(canvas, offset, cell, _cellPaint(cell, useOverlay: false),
            tileSize, baseIdx, normalStyles[baseIdx], _getTP);
      }
    }

    // Dispose all TextPainters created in this frame.
    for (final tp in tpCache.values) {
      tp.dispose();
    }
  }

  /// Returns the fill paint for [cell]. When [useOverlay] is true the
  /// half-alpha pre-computed overlay variant is returned.
  Paint _cellPaint(Cell cell, {required bool useOverlay}) {
    if (useOverlay) {
      return cell.state == null
          ? cellBaseOverlay
          : cell.state!
              ? cellFilledOverlay
              : cellEmptyOverlay;
    }
    return cell.state == null
        ? cellBase
        : cell.state!
            ? cellFilled
            : cellEmpty;
  }

  /// Returns a base style index in [0–4] for [cell]:
  /// 0=base, 1=error, 2=complete, 3=filled, 4=empty.
  /// Add 5 to get the corresponding overlay variant.
  int _baseStyleIndex(Cell cell) {
    return cell.error
        ? 1
        : cell.complete
            ? 2
            : cell.state == null
                ? 0
                : cell.state!
                    ? 3
                    : 4;
  }

  void _paintCell(
      Canvas canvas,
      Offset offset,
      Cell cell,
      Paint cellColor,
      double tileSize,
      int styleIndex,
      TextStyle textStyle,
      TextPainter Function(int clue, int styleIndex, TextStyle style) getTP) {
    canvas.drawRect(
        Rect.fromPoints(
          offset,
          Offset(offset.dx + tileSize, offset.dy + tileSize),
        ),
        cellColor);
    if (cell.shown) {
      final tp = getTP(cell.clue, styleIndex, textStyle);
      final o = Offset(offset.dx + (tileSize / 2) - (tp.width / 2),
          offset.dy + (tileSize / 2) - (tp.height / 2));
      tp.paint(canvas, o);
    }
  }
}
