import 'dart:async';

import 'package:animator/animator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mosaic/entities/board.dart';
import 'package:mosaic/entities/loading_painter.dart';

import '../../blocs/theme/theme_cubit.dart';
import '../../l10n/app_localizations.dart';

class LoadingBoardIndicator extends StatefulWidget {
  final int height;
  final int width;
  final bool showLoadingText;
  final GenerationAlgorithm algorithm;
  final DateTime? startedAt;

  const LoadingBoardIndicator(
      {Key? key,
      required this.height,
      required this.width,
      this.showLoadingText = true,
      this.algorithm = GenerationAlgorithm.classic,
      this.startedAt})
      : super(key: key);

  @override
  State<LoadingBoardIndicator> createState() => _LoadingBoardIndicatorState();
}

class _LoadingBoardIndicatorState extends State<LoadingBoardIndicator> {
  int cycle = 0;
  Timer? _ticker;
  Duration _elapsed = Duration.zero;
  late DateTime _startedAt;

  static const Duration _showAfter = Duration(seconds: 10);

  /// Rough estimate of total generation time in seconds for a board of
  /// [widget.height]×[widget.width] cells with the given algorithm.
  double _estimatedTotalSeconds() {
    final cells = widget.height * widget.width;
    switch (widget.algorithm) {
      case GenerationAlgorithm.classic:
        return cells * 0.0012 + 1.0;
      case GenerationAlgorithm.hybrid:
        return cells * 0.006 + 2.0;
    }
  }

  @override
  void initState() {
    super.initState();
    _startedAt = widget.startedAt ?? DateTime.now();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _elapsed = DateTime.now().difference(_startedAt);
      });
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final showTimeInfo = _elapsed >= _showAfter;

    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        return Animator<double>(
          tween: Tween<double>(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 1500),
          triggerOnInit: true,
          endAnimationListener: (AnimatorState<double> state) {
            state.triggerAnimation(restart: true);
            cycle++;
          },
          builder:
              (BuildContext context, AnimatorState animatorState, Widget? _) {
            final progress = animatorState.value;
            return SizedBox.expand(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox.expand(
                    child: CustomPaint(
                      painter: LoadingPainter(
                          theme: state.theme,
                          height: widget.height,
                          width: widget.width,
                          paddingRatio: 1.125,
                          progress: progress,
                          cycle: cycle),
                    ),
                  ),
                  if (widget.showLoadingText)
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.75),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(20)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(loc.generatingBoard,
                              style: const TextStyle(color: Colors.white),
                              textAlign: TextAlign.center),
                          if (showTimeInfo) ...[
                            const SizedBox(height: 4),
                            Text(
                              loc.generatingElapsed(_elapsed.inSeconds),
                              style: const TextStyle(color: Colors.white70),
                              textAlign: TextAlign.center,
                            ),
                            Builder(builder: (context) {
                              final estimated = _estimatedTotalSeconds();
                              final remaining =
                                  (estimated - _elapsed.inSeconds).ceil();
                              if (remaining > 0) {
                                return Text(
                                  loc.generatingEstimatedRemaining(remaining),
                                  style: const TextStyle(color: Colors.white70),
                                  textAlign: TextAlign.center,
                                );
                              }
                              return const SizedBox.shrink();
                            }),
                          ],
                        ],
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
