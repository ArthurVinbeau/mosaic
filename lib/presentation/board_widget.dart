import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mosaic/game_bloc.dart';
import 'package:mosaic/presentation/new_game_widget.dart';
import 'package:mosaic/presentation/tile.dart';

import '../entities/board.dart';
import '../utils/config.dart';

class BoardWidget extends StatelessWidget {
  const BoardWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GameBloc, GameState>(
      listener: (context, state) {
        showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
                  title: const Text("You WIN!"),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          context.read<GameBloc>().add(NewBoardDialogButtonPressedGameEvent());
                        },
                        child: const Text("New Game")),
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text("Dismiss")),
                  ],
                ));
      },
      listenWhen: (_, b) => b is FinishedGameState,
      buildWhen: (_, b) => b is! ControlsGameState,
      builder: (BuildContext context, state) {
        if (state is NotStartedGameState) {
          return Center(child: NewGameWidget(height: state.baseHeight, width: state.baseWidth));
        } else if (state is GeneratingBoardGameState) {
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
          return LayoutBuilder(builder: (context, constraints) {
            double tileSize;
            if (constraints.maxHeight > constraints.maxWidth) {
              tileSize = constraints.maxWidth / state.board.width;
            } else {
              tileSize = constraints.maxHeight / state.board.height;
            }

            logger.d("tileSize: $tileSize");

            return SizedBox.expand(
              child: InteractiveViewer(
                  minScale: 0.01,
                  boundaryMargin: EdgeInsets.all(tileSize * 0.6),
                  child: Center(
                      child:
                          Column(mainAxisSize: MainAxisSize.min, children: getTableRows(state.board, tileSize - 4)))),
            );
          });
        } else {
          throw UnimplementedError("State ${state.runtimeType} is not implemented");
        }
      },
    );
  }

  List<Widget> getTableRows(Board board, double size) {
    List<Widget> rows = [];
    for (int i = 0; i < board.height; i++) {
      List<Widget> row = [];
      for (int j = 0; j < board.width; j++) {
        final cell = board.cells[i][j];
        row.add(Padding(
          padding: const EdgeInsets.all(2.0),
          child: Tile(
              i: i,
              j: j,
              label: cell.shown ? cell.clue.toString() : null,
              state: cell.state,
              size: size,
              error: cell.error,
              complete: cell.complete),
        ));
      }
      rows.add(Row(mainAxisSize: MainAxisSize.min, children: row));
    }
    return rows;
  }
}
