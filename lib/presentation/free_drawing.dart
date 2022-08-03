import 'package:flutter/material.dart';
import 'package:mosaic/entities/board.dart';

import '../entities/free_painter.dart';
import '../utils/theme/theme_container.dart';

class FreeDrawing extends StatefulWidget {
  final Board board;

  final double minScale;
  final double maxScale;

  final double paddingRatio;

  const FreeDrawing(
      {Key? key,
      required this.board,
      this.minScale = 0.8,
      this.maxScale = double.infinity,
      double paddingRatio = 1 / 8})
      : this.paddingRatio = 1 + paddingRatio,
        super(key: key);

  @override
  State<StatefulWidget> createState() => _FreeDrawingState();
}

class _FreeDrawingState extends State<FreeDrawing> {
  late double _scale;
  Offset? _position;

  @override
  void initState() {
    _scale = 6.0;
    super.initState();
  }

  late double _scaleStart = _scale;

  // late Offset _positionStart = _position;

  @override
  Widget build(BuildContext context) {
    final theme = GameThemeContainer.of(context);

    return LayoutBuilder(builder: (context, BoxConstraints constraints) {
      _position ??= Offset(constraints.maxWidth / 2, constraints.maxHeight / 2);

      final screenRatio = constraints.maxHeight / constraints.maxWidth;
      final boardRatio = widget.board.height / widget.board.width;

      double minHeight = 0;
      double maxHeight = constraints.maxHeight;
      double minWidth = 0;
      double maxWidth = constraints.maxWidth;

      if (screenRatio > boardRatio) {
        var offset = (maxHeight - (maxHeight / screenRatio * boardRatio)) / 2;
        minHeight += offset;
        maxHeight -= offset;
      } else {
        var offset = (maxWidth - (maxWidth / screenRatio * boardRatio)) / 2;
        minWidth += offset;
        maxWidth -= offset;
      }

      final boardPosition = Offset(
        (_position!.dx - minWidth) * widget.board.width / (maxWidth - minWidth),
        (_position!.dy - minHeight) * widget.board.height / (maxHeight - minHeight),
      );

      return GestureDetector(
        onScaleUpdate: (ScaleUpdateDetails scaleDetails) {
          setState(() {
            _scale = (_scaleStart * scaleDetails.scale).clamp(widget.minScale, widget.maxScale);
            _position = Offset(
              (_position!.dx - (scaleDetails.focalPointDelta.dx / _scale)).clamp(minWidth, maxWidth),
              (_position!.dy - (scaleDetails.focalPointDelta.dy / _scale)).clamp(minHeight, maxHeight),
            );
          });
          // logger.i({"constraints": constraints, "position": _position});
        },
        onScaleStart: (ScaleStartDetails details) {
          _scaleStart = _scale;
        },
        /*onTap: () {
            setState(() {
              _scale++;
              logger.i(_scale);
            });
          },*/
        /*child: Container(
            color: Colors.pinkAccent,
            alignment: Alignment.center,
            height: double.infinity,
            width: double.infinity,
            child: Text(_scale.toString()),
          ),*/
        child: CustomPaint(
            size: Size(constraints.maxWidth, constraints.maxHeight),
            painter: FreePainter(
                board: widget.board,
                theme: theme,
                boardPosition: boardPosition,
                scale: _scale,
                paddingRatio: widget.paddingRatio)),
      );
    });
  }
/*
  return LayoutBuilder(builder: (context, constraints) {
            const double tileSize = 32.0;
            const double padding = 4.0;
            final theme = GameThemeContainer.of(context);

            double? height;
            double? width;
            if (constraints.maxHeight / constraints.maxWidth > state.board.height / state.board.width) {
              height = (tileSize + padding) * state.board.width * constraints.maxHeight / constraints.maxWidth;
            } else {
              width = (tileSize + padding) * state.board.height * constraints.maxWidth / constraints.maxHeight;
            }

            logger.d("height: $height, width: $width");
            return SizedBox.expand(
              child: InteractiveViewer(
                minScale: 0.00000000001,
                maxScale: double.infinity,
                boundaryMargin: const EdgeInsets.all(16),
                constrained: false,
                child: Container(
                    height: height,
                    width: width,
                    alignment: Alignment.center,
                    child: GestureDetector(
                      onTapUp: (TapUpDetails details) {
                        final i = (details.localPosition.dy / (tileSize + padding)).floor();
                        final j = (details.localPosition.dx / (tileSize + padding)).floor();
                        context.read<GameBloc>().add(TilePressedGameEvent(i, j, false));
                      },
                      onLongPressEnd: (LongPressEndDetails details) {
                        final i = (details.localPosition.dy / (tileSize + padding)).floor();
                        final j = (details.localPosition.dx / (tileSize + padding)).floor();
                        context.read<GameBloc>().add(TilePressedGameEvent(i, j, true));
                      },
                      child: CustomPaint(
                        size: Size(state.board.width * (tileSize + padding), state.board.height * (tileSize + padding)),
                        painter: BoardPainter(board: state.board, theme: theme, tileSize: tileSize, padding: padding),
                      ),
                    )),
              ),
            );
          });
   */
}
