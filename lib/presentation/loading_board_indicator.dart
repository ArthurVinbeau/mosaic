import 'package:animator/animator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mosaic/entities/loading_painter.dart';

import '../blocs/theme/theme_cubit.dart';

class LoadingBoardIndicator extends StatefulWidget {
  const LoadingBoardIndicator({Key? key}) : super(key: key);

  @override
  State<LoadingBoardIndicator> createState() => _LoadingBoardIndicatorState();
}

class _LoadingBoardIndicatorState extends State<LoadingBoardIndicator> {
  int cycle = 0;

  @override
  Widget build(BuildContext context) {
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
          builder: (BuildContext context, AnimatorState animatorState, Widget? _) {
            final progress = animatorState.value;
            return Container(
              padding: const EdgeInsets.all(64),
              width: double.infinity,
              height: double.infinity,
              child: CustomPaint(
                painter: LoadingPainter(
                    theme: state.theme,
                    boardSize: 4,
                    maxTileSize: 50,
                    paddingRatio: 1.125,
                    progress: progress,
                    cycle: cycle),
              ),
            );
          },
        );
      },
    );
  }
}
