import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mosaic/blocs/game/game_bloc.dart';
import 'package:mosaic/presentation/elements/free_drawing.dart';
import 'package:mosaic/presentation/free_drawing.dart';
import 'package:mosaic/presentation/loading_board_indicator.dart';
import 'package:mosaic/utils/config.dart';

class BoardWidget extends StatelessWidget {
  const BoardWidget({Key? key}) : super(key: key);

  void _showBlocDialog(BuildContext context, ShowDialogState state) async {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    Widget? content;
    String title = "";
    String? description;
    String confirmation = loc.confirmDialog;
    String dismiss = loc.denyDialog;

    if (state is ShowWinDialogState) {
      title = loc.youWin;
      confirmation = loc.newGame;
      dismiss = loc.dismiss;

      final elapsed = state.elapsedTime.split(":");
      var str = loc.elapsedSeconds(elapsed[2]);
      if (elapsed[1] != "00" || elapsed[0] != "00") {
        str = loc.elapsedMinutes(elapsed[1], str);
      }
      if (elapsed[0] != "00") {
        str = loc.elapsedHours(elapsed[0], str);
      }
      description = loc.winDescription(str, state.height, state.width);
    } else if (state is ShowRestartDialogState) {
      title = loc.restartConfirmation;
      description = loc.restartConfirmationDescription;
      content = Text(loc.restartConfirmationDescription);
    }

    if (description != null) {
      content = Text(description);
    }

    final pop = await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: Text(title),
              content: content,
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(primary: theme.errorColor),
                    child: Text(dismiss)),
                ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, state.pop);
                      context.read<GameBloc>().add(state.confirmationEvent);
                    },
                    child: Text(confirmation)),
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
          return LoadingBoardIndicator(
            height: state.height,
            width: state.width,
          );
        } else if (state is BoardGameState) {
          return SizedBox.expand(
            child: FreeDrawing(
              board: state.board,
              onTap: (int i, int j, bool long) {
                context.read<GameBloc>().add(TilePressedGameEvent(i, j, long));
                return true;
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
