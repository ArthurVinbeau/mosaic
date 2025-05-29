import 'dart:math';

import 'package:animator/animator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mosaic/blocs/theme/theme_cubit.dart';
import 'package:mosaic/blocs/tutorial/tutorial_bloc.dart';
import 'package:mosaic/presentation/elements/free_drawing.dart';
import 'package:mosaic/utils/config.dart';

import '../../entities/game_theme.dart';
import '../../l10n/app_localizations.dart';

class TutorialPage extends StatelessWidget {
  const TutorialPage({Key? key}) : super(key: key);

  List<TextSpan> _getText(
      BuildContext context, GameTheme theme, int step, AppLocalizations loc) {
    String text = [
      loc.tutorialStep0,
      loc.tutorialStep1,
      loc.tutorialStep2,
      loc.tutorialStep3,
      loc.tutorialStep4
    ][step];

    List<TextSpan> spans = [];
    final regex = RegExp(r'&([feu]);(\w+)', multiLine: true);
    final matches = regex.allMatches(text);
    final baseStyle = TextStyle(
        color: ThemeData.estimateBrightnessForColor(theme.gameBackground) ==
                Brightness.light
            ? Colors.black
            : Colors.white);

    var previous = 0;
    if (matches.isNotEmpty) {
      for (var match in matches) {
        if (match.start - 1 != previous) {
          spans.add(TextSpan(
              text: text.substring(previous, match.start), style: baseStyle));
        }
        final modifier = match[1]!;
        TextStyle? style;
        switch (modifier) {
          case 'f':
            style = TextStyle(
                fontWeight: FontWeight.bold,
                height: 1.4,
                backgroundColor: theme.cellFilled,
                color: theme.cellTextFilled);
            break;
          case 'e':
            style = TextStyle(
                fontWeight: FontWeight.bold,
                height: 1.4,
                backgroundColor: theme.cellEmpty,
                color: theme.cellTextEmpty);
            break;
          case 'u':
            style = TextStyle(
                fontWeight: FontWeight.bold,
                height: 1.4,
                backgroundColor: theme.cellBase,
                color: theme.cellTextBase);
            break;
          default:
            style = null;
            break;
        }

        spans.add(TextSpan(text: "\u00A0${match[2]!}\u00A0", style: style));
        previous = match.end;
      }
      if (previous < text.length) {
        spans.add(TextSpan(style: baseStyle, text: text.substring(previous)));
      }
    } else {
      spans.add(TextSpan(style: baseStyle, text: text));
    }

    return spans;
  }

  String _padString(String str, int maxSize) => str
      .padLeft(((maxSize - str.length + 1) / 2).floor(), ' ')
      .padRight(((maxSize - str.length) / 2).floor(), ' ');

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return BlocBuilder<TutorialBloc, TutorialState>(
        builder: (BuildContext context, TutorialState state) {
      Widget body;
      final theme = context.read<ThemeCubit>().state.theme;

      if (state is TutorialInitial) {
        body = const Center(child: CircularProgressIndicator());
      } else if (state is TutorialBoardState) {
        body = Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: _getText(context, theme, state.currentStep, loc),
                ),
              ),
            ),
            Expanded(
              child: FreeDrawing(
                board: state.board,
                canPan: state.canMove,
                canZoom: state.canMove,
                overlay: state.overlay,
                overlayExceptions: state.overlayExceptions,
                onTap: (int i, int j, bool long) {
                  if ((state.allowTap && !long || state.allowLongTap && long) &&
                      (!state.overlay ||
                          state.overlayExceptions
                              .contains(Offset(j.toDouble(), i.toDouble())))) {
                    context
                        .read<TutorialBloc>()
                        .add(TutorialTilePressedEvent(i, j, long));
                    return true;
                  }
                  return false;
                },
              ),
            ),
          ],
        );
      } else {
        Navigator.pop(context);
        body = const Center(child: CircularProgressIndicator());
      }

      final maxSize =
          max(loc.finish.length, max(loc.previous.length, loc.next.length));

      return Scaffold(
        appBar: AppBar(
          title: Text(loc.tutorialTitle),
          centerTitle: true,
        ),
        body: body,
        bottomNavigationBar: Material(
          elevation: 8.0,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Stack(
              alignment: Alignment.bottomCenter,
              clipBehavior: Clip.none,
              children: [
                if (state is TutorialBoardState && state.showPaintBucket)
                  Positioned(
                    bottom: 0,
                    child: AnimateWidget(
                      duration: const Duration(milliseconds: 750),
                      cycles: 0,
                      triggerOnInit: true,
                      builder: (BuildContext context, Animate animate) {
                        return Ink(
                          decoration: ShapeDecoration(
                              shape: const CircleBorder(),
                              color: theme.cellFilled),
                          child: IconButton(
                            onPressed: null,
                            iconSize: 24 *
                                (animate.fromTween(
                                    (currentValue) => 0.9.tweenTo(1.2)))!,
                            icon: Icon(Icons.format_color_fill,
                                color: theme.cellEmpty),
                          ),
                        );
                      },
                    ),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                        onPressed: state.currentStep != 0
                            ? () {
                                context
                                    .read<TutorialBloc>()
                                    .add(PreviousTutorialStepEvent());
                              }
                            : null,
                        icon: const Icon(Icons.chevron_left),
                        label: Text(_padString(loc.previous, maxSize))),
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: ElevatedButton.icon(
                          onPressed: state.canContinue
                              ? () {
                                  logger.i(
                                      "${state.currentStep}, ${state.totalSteps}");
                                  if (state.currentStep + 1 <
                                      state.totalSteps) {
                                    context
                                        .read<TutorialBloc>()
                                        .add(NextTutorialStepEvent());
                                  } else {
                                    Navigator.pop(context);
                                  }
                                }
                              : null,
                          icon: const Icon(Icons.chevron_left),
                          label: state.currentStep + 1 < state.totalSteps
                              ? Text(_padString(loc.next, maxSize))
                              : Text(_padString(loc.finish, maxSize))),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
