import 'package:flutter/material.dart';
import 'package:mosaic/entities/board.dart';
import 'package:mosaic/utils/config.dart';

import '../entities/free_painter.dart';
import '../utils/theme/theme_container.dart';

class FreeDrawing extends StatefulWidget {
  final Board board;

  final double minScale;
  final double maxScale;

  const FreeDrawing({Key? key, required this.board, this.minScale = 0.8, this.maxScale = double.infinity})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _FreeDrawingState();
}

class _FreeDrawingState extends State<FreeDrawing> {
  late double _scale;
  Offset? _position;

  static const _paddingRatio = 1 / 8;

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
      return GestureDetector(
        onScaleUpdate: (ScaleUpdateDetails scaleDetails) {
          setState(() {
            _scale = (_scaleStart * scaleDetails.scale).clamp(widget.minScale, widget.maxScale);
          });
          _position = Offset(
            (_position!.dx - scaleDetails.focalPointDelta.dx).clamp(0, constraints.maxWidth),
            (_position!.dy - scaleDetails.focalPointDelta.dy).clamp(0, constraints.maxHeight),
          );
          logger.i(_position);
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
        child:
            CustomPaint(painter: FreePainter(board: widget.board, theme: theme, position: _position!, scale: _scale)),
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
