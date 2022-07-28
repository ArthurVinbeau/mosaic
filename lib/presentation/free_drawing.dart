import 'package:flutter/material.dart';
import 'package:mosaic/entities/board.dart';
import 'package:mosaic/entities/free_painter.dart';

import '../utils/theme/theme_container.dart';

class FreeDrawing extends StatefulWidget {
  final Board board;

  const FreeDrawing({Key? key, required this.board}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _FreeDrawingState();
}

class _FreeDrawingState extends State<FreeDrawing> {
  double scale = 6.0;
  late Offset position = Offset(widget.board.width / 2, widget.board.height / 2);

  static const paddingRatio = 1 / 8;

  @override
  Widget build(BuildContext context) {
    final theme = GameThemeContainer.of(context);

    return CustomPaint(painter: FreePainter(board: widget.board, theme: theme, position: position, scale: scale));
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
