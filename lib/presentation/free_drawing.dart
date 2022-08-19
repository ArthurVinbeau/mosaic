import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mosaic/blocs/theme/theme_cubit.dart';
import 'package:mosaic/entities/board.dart';
import 'package:vibration/vibration.dart';

import '../entities/free_painter.dart';
import '../utils/themes.dart';

class FreeDrawing extends StatefulWidget {
  final Board board;

  final double minScale;
  final double maxScale;

  final double paddingRatio;

  final GameTheme? theme;

  final bool Function(int i, int j, bool long)? onTap;

  final bool vibration;

  final bool canPan;
  final bool canZoom;

  final bool overlay;
  final List<Offset> overlayExceptions;

  const FreeDrawing(
      {Key? key,
      required this.board,
      this.minScale = 0.9,
      this.maxScale = double.infinity,
      this.vibration = true,
      this.theme,
      this.onTap,
      this.canPan = true,
      this.canZoom = true,
      this.overlay = false,
      this.overlayExceptions = const [],
      double paddingRatio = 1 / 8})
      : paddingRatio = 1 + paddingRatio,
        super(key: key);

  @override
  State<StatefulWidget> createState() => _FreeDrawingState();
}

class _FreeDrawingState extends State<FreeDrawing> with WidgetsBindingObserver {
  late double _scale;
  Offset? _position;
  late bool _vibration;

  @override
  void initState() {
    _scale = widget.minScale;
    if (widget.vibration) {
      Vibration.hasVibrator().then((value) => _vibration = value ?? false);
    } else {
      _vibration = false;
    }
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  late double _scaleStart = _scale;
  late Offset _tapTarget;

  Offset _getBoardPosition(Offset position, BoxConstraints constraints) {
    return Offset(
      (position.dx - constraints.minWidth) * widget.board.width / (constraints.maxWidth - constraints.minWidth),
      (position.dy - constraints.minHeight) * widget.board.height / (constraints.maxHeight - constraints.minHeight),
    );
  }

  void _onTap(bool long, Offset boardPosition, Offset center, BoxConstraints boardSize) {
    if (widget.onTap != null) {
      // _position doesn't include _scale but _tapTarget depends on the scaled painted grid so they are not in the same
      // coordinate system. We first need to transpose _tapTarget to the _position system.
      final absoluteCenteredTapTarget = (_tapTarget - center) / _scale;
      final target = _getBoardPosition(_position! + absoluteCenteredTapTarget, boardSize);
      if (widget.onTap!(target.dy.floor(), target.dx.floor(), long) && long && _vibration) {
        Vibration.vibrate(duration: 50);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme ?? context.read<ThemeCubit>().state.theme;

    return LayoutBuilder(builder: (context, BoxConstraints constraints) {
      _position ??= Offset(constraints.maxWidth / 2, constraints.maxHeight / 2);

      final screenRatio = constraints.maxHeight / constraints.maxWidth;
      final boardRatio = widget.board.height / widget.board.width;

      var boardSize = BoxConstraints(
        minHeight: 0,
        maxHeight: constraints.maxHeight,
        minWidth: 0,
        maxWidth: constraints.maxWidth,
      );

      if (screenRatio > boardRatio) {
        var offset = (boardSize.maxHeight - (boardSize.maxHeight / screenRatio * boardRatio)) / 2;
        boardSize = boardSize.copyWith(
          minHeight: boardSize.minHeight + offset,
          maxHeight: boardSize.maxHeight - offset,
        );
      } else {
        var offset = (boardSize.maxWidth - (boardSize.maxWidth * screenRatio / boardRatio)) / 2;
        boardSize = boardSize.copyWith(
          minWidth: boardSize.minWidth + offset,
          maxWidth: boardSize.maxWidth - offset,
        );
      }
      final boardPosition = _getBoardPosition(_position!, boardSize);
      final center = Offset(constraints.maxWidth / 2, constraints.maxHeight / 2);

      final limitH = (boardSize.maxHeight - boardSize.minHeight) * widget.minScale / _scale / 2;
      final limitW = (boardSize.maxWidth - boardSize.minWidth) * widget.minScale / _scale / 2;

      return GestureDetector(
        onScaleUpdate: (ScaleUpdateDetails scaleDetails) {
          setState(() {
            if (widget.canZoom) {
              _scale = (_scaleStart * scaleDetails.scale).clamp(widget.minScale, widget.maxScale);
            }
            if (widget.canPan) {
              _position = Offset(
                (_position!.dx - (scaleDetails.focalPointDelta.dx / _scale))
                    .clamp(boardSize.minWidth + limitW, boardSize.maxWidth - limitW),
                (_position!.dy - (scaleDetails.focalPointDelta.dy / _scale))
                    .clamp(boardSize.minHeight + limitH, boardSize.maxHeight - limitH),
              );
            }
          });
          // logger.i({"constraints": constraints, "position": _position});
        },
        onScaleStart: (ScaleStartDetails details) {
          _scaleStart = _scale;
        },
        onTapDown: (TapDownDetails details) {
          _tapTarget = details.localPosition;
        },
        onTap: () => _onTap(false, boardPosition, center, boardSize),
        onLongPress: () => _onTap(true, boardPosition, center, boardSize),
        child: CustomPaint(
            size: Size(constraints.maxWidth, constraints.maxHeight),
            painter: FreePainter(
                board: widget.board,
                theme: theme,
                boardPosition: boardPosition,
                scale: _scale,
                paddingRatio: widget.paddingRatio,
                overlay: widget.overlay,
                overlayExceptions: widget.overlayExceptions)),
      );
    });
  }

  @override
  void didChangeMetrics() {
    _position = null;
  }
}
