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

    /*while (text.isNotEmpty) {
      final index = text.indexOf(RegExp(r'&[feu];'));
      if (index == -1) {
        spans.add(TextSpan(text: text));
        text = "";
      }
      if (index > 0) {
        spans.add(TextSpan(text: text.substring(0, index)));
        text = text.substring(index);
      }
      final modifier = text[1];
    }*/

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tutorial"),
        centerTitle: true,
      ),
      body: BlocBuilder<TutorialBloc, TutorialState>(
        builder: (BuildContext context, TutorialState state) {
          if (state is TutorialInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is TutorialBoardState) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: _parseText(context, context.read<ThemeCubit>().state.theme, state.text),
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
                  ),
                ),
              ],
            );
          } else {
            Navigator.pop(context);
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      persistentFooterButtons: [
        ElevatedButton(
            onPressed: () {
              context.read<TutorialBloc>().add(PreviousTutorialStepEvent());
            },
            child: Text("Previous")),
        ElevatedButton(
            onPressed: () {
              context.read<TutorialBloc>().add(NextTutorialStepEvent());
            },
            child: Text("Next")),
      ],
    );
  }
}
