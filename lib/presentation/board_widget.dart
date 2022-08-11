import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mosaic/blocs/game/game_bloc.dart';
import 'package:mosaic/presentation/free_drawing.dart';
import 'package:mosaic/utils/config.dart';

class BoardWidget extends StatelessWidget {
  const BoardWidget({Key? key}) : super(key: key);

  void _showBlocDialog(BuildContext context, ShowDialogState state) async {
    final theme = Theme.of(context);
    Widget? content;
    if (state.description != null) {
      content = Text(state.description!);
    }
    final pop = await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: Text(state.title),
              content: content,
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(primary: theme.errorColor),
                    child: Text(state.dismiss)),
                ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, state.pop);
                      context.read<GameBloc>().add(state.confirmationEvent);
                    },
                    child: Text(state.confirmation)),
              ],
            ));
    if (pop ?? false) {
      navigatorKey.currentState!.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GameBloc, GameState>(
      listener: (context, state) {
        _showBlocDialog(context, state as ShowDialogState);
      },
      listenWhen: (_, b) => b is ShowDialogState,
      buildWhen: (_, b) => b is BoardGameState || b is GeneratingBoardGameState,
      builder: (BuildContext context, state) {
        if (state is GeneratingBoardGameState) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(value: state.progress),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("Generating a new board..."),
                ),
              ],
            ),
          );
        } else if (state is BoardGameState) {
          return SizedBox.expand(
            child: FreeDrawing(
              board: state.board,
              onTap: (int i, int j, bool long) {
                context.read<GameBloc>().add(TilePressedGameEvent(i, j, long));
              },
            ),
          );
        } else {
          throw UnimplementedError("State ${state.runtimeType} is not implemented");
        }
      },
    );
  }
}
