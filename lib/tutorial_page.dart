import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mosaic/blocs/theme/theme_cubit.dart';
import 'package:mosaic/blocs/tutorial/tutorial_bloc.dart';
import 'package:mosaic/presentation/free_drawing.dart';
import 'package:mosaic/utils/themes.dart';

class TutorialPage extends StatelessWidget {
  const TutorialPage({Key? key}) : super(key: key);

  List<TextSpan> _parseText(BuildContext context, GameTheme theme, String text) {
    List<TextSpan> spans = [];
    final regex = RegExp(r'&([feu]);(\w+)', multiLine: true);
    final matches = regex.allMatches(text);

    var previous = 0;
    if (matches.isNotEmpty) {
      for (var match in matches) {
        if (match.start - 1 != previous) {
          spans.add(TextSpan(text: text.substring(previous, match.start)));
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
                fontWeight: FontWeight.bold, height: 1.4, backgroundColor: theme.cellEmpty, color: theme.cellTextEmpty);
            break;
          case 'u':
            style = TextStyle(
                fontWeight: FontWeight.bold, height: 1.4, backgroundColor: theme.cellBase, color: theme.cellTextBase);
            break;
          default:
            style = null;
            break;
        }

        spans.add(TextSpan(text: " ${match[2]!} ", style: style));
        previous = match.end;
      }
      if (previous < text.length) {
        spans.add(TextSpan(text: text.substring(previous)));
      }
    } else {
      spans.add(TextSpan(text: text));
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TutorialBloc, TutorialState>(builder: (BuildContext context, TutorialState state) {
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
                  children: _parseText(context, theme, state.text),
                ),
              ),
            ),
            Expanded(
              child: FreeDrawing(
                board: state.board,
                canPan: false,
                canZoom: false,
                overlay: state.overlay,
                overlayExceptions: state.overlayExceptions,
                onTap: (int i, int j, bool long) {
                  if ((state.allowTap && !long || state.allowLongTap && long) &&
                      (!state.overlay || state.overlayExceptions.contains(Offset(j.toDouble(), i.toDouble())))) {
                    context.read<TutorialBloc>().add(TutorialTilePressedEvent(i, j, long));
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
      return Scaffold(
        appBar: AppBar(
          title: const Text("Tutorial"),
          centerTitle: true,
        ),
        body: body,
        bottomNavigationBar: Material(
          elevation: 8.0,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                    onPressed: state.currentStep != 0
                        ? () {
                            context.read<TutorialBloc>().add(PreviousTutorialStepEvent());
                          }
                        : null,
                    icon: const Icon(Icons.chevron_left),
                    label: const Text("Previous")),
                if (state is TutorialBoardState && state.showPaintBucket)
                  Ink(
                    decoration: ShapeDecoration(shape: const CircleBorder(), color: theme.cellFilled),
                    child: IconButton(onPressed: null, icon: Icon(Icons.format_color_fill, color: theme.cellEmpty)),
                  ),
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: ElevatedButton.icon(
                      onPressed: state.canContinue
                          ? () {
                              if (state.currentStep + 1 < state.totalSteps) {
                                context.read<TutorialBloc>().add(NextTutorialStepEvent());
                              } else {
                                Navigator.pop(context);
                              }
                            }
                          : null,
                      icon: const Icon(Icons.chevron_left),
                      label:
                          state.currentStep + 1 < state.totalSteps ? const Text("  Next  ") : const Text(" Finish ")),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
