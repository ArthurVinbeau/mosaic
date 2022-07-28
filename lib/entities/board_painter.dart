import 'package:flutter/material.dart';
import 'package:mosaic/entities/board.dart';
import 'package:mosaic/utils/config.dart';
import 'package:mosaic/utils/theme/themes.dart';

class BoardPainter extends CustomPainter {
  final Board board;
  final GameTheme theme;
  final double tileSize;
  final double padding;

  late final offset = tileSize + padding;

  late final Paint cellBase = Paint()
    ..style = PaintingStyle.fill
    ..color = theme.cellBase;
  late final Paint cellFilled = Paint()
    ..style = PaintingStyle.fill
    ..color = theme.cellFilled;
  late final Paint cellEmpty = Paint()
    ..style = PaintingStyle.fill
    ..color = theme.cellEmpty;

  late final TextStyle cellTextBase = TextStyle(fontSize: 24, color: theme.cellTextBase);
  late final TextStyle cellTextError = TextStyle(fontSize: 24, color: theme.cellTextError);
  late final TextStyle cellTextComplete = TextStyle(fontSize: 24, color: theme.cellTextComplete);
  late final TextStyle cellTextFilled = TextStyle(fontSize: 24, color: theme.cellTextFilled);
  late final TextStyle cellTextEmpty = TextStyle(fontSize: 24, color: theme.cellTextEmpty);

  BoardPainter({required this.board, required this.theme, required this.tileSize, required this.padding});

  @override
  void paint(Canvas canvas, Size size) {
/*    var pH = 0.0;
    var pW = 0.0;

    final screenRatio = size.height / size.width;
    final boardRatio = board.height / board.width;

    if (screenRatio > boardRatio) {
      pH = (size.height - (size.height * boardRatio / screenRatio)) / 2;
    } else {
      pW = (size.width - (size.width * boardRatio / screenRatio)) / 2;
    }*/

    final height = size.height /* - pH * 2*/;
    final width = size.width /* - pW * 2*/;

    logger.i({
      /*"padding": {
        "height": pH,
        "width": pW,
      },*/
      /*"zone": {
        "height": height,
        "width": width,
      },*/
      "canvas": {
        "height": size.height,
        "width": size.width,
      },
      "board": {
        "height": board.height,
        "width": board.width,
      },
    });

    /*Paint paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true
      ..color = const Color(0xff404040);

    Path myPath = Path();

    myPath.moveTo(width * 0.25, 0);

    //myPath.quadraticBezierTo(
    //width * 0.70, height * 0.20, width * 0.40, height * 0.35);
    myPath.quadraticBezierTo(width * 0.7, height * 0.15, width * 0.4, height * 0.3);
    myPath.quadraticBezierTo(width * 0.15, height * 0.45, width * 0.4, height * 0.65);

    myPath.quadraticBezierTo(width * 0.51, height * 0.75, width * 1, height * 0.85);

    //myPath.quadraticBezierTo(
    //width * 0.2, height * 0.75, width * 1, height * 0.75);
    myPath.lineTo(width * 25, 0);

    myPath.lineTo(width, 0);

    canvas.drawPath(myPath, paint);*/

    for (int i = 0; i < board.height; i++) {
      for (int j = 0; j < board.width; j++) {
        final cell = board.cells[i][j];
        canvas.drawRect(
            Rect.fromPoints(Offset(j * offset, i * offset), Offset(j * offset + tileSize, i * offset + tileSize)),
            cell.state == null
                ? cellBase
                : cell.state!
                    ? cellFilled
                    : cellEmpty);
        if (cell.shown) {
          final textPainter = TextPainter(
              text: TextSpan(
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
              ),
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.center);
          textPainter.layout();
          final o = Offset(j * offset + (tileSize / 2) - (textPainter.width / 2),
              i * offset + (tileSize / 2) - (textPainter.height / 2));
          textPainter.paint(canvas, o);
        }
      }
    }

    // canvas.drawRect(Rect.fromCenter(center: Offset(pW + 50, pH + 100), width: 32, height: 32), squarePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
