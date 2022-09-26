import 'package:animator/animator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mosaic/entities/loading_painter.dart';

import '../blocs/theme/theme_cubit.dart';

class LoadingBoardIndicator extends StatefulWidget {
  final int height;
  final int width;

  const LoadingBoardIndicator({Key? key, required this.height, required this.width}) : super(key: key);

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
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.75),
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                    ),
                    child: Text(AppLocalizations.of(context)!.generatingBoard,
                        style: const TextStyle(color: Colors.white), textAlign: TextAlign.center),
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
