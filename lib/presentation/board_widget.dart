import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mosaic/game_bloc.dart';
import 'package:mosaic/presentation/tile.dart';

import '../entities/board.dart';
import '../utils/config.dart';

class BoardWidget extends StatelessWidget {
  const BoardWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameBloc, GameState>(
      buildWhen: (_, b) => b is! ControlsGameState,
      builder: (BuildContext context, state) {
        if (state is NotStartedGameState) {
          return Center(
            child: ElevatedButton(
              child: const Text("New Game"),
              onPressed: () => context.read<GameBloc>().add(NewBoardButtonPressedGameEvent()),
            ),
          );
        } else if (state is GeneratingBoardGameState) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(value: state.progress),
              const Text("Generating a new board..."),
            ],
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
              error: cell.error),
        ));
      }
      rows.add(Row(mainAxisSize: MainAxisSize.min, children: row));
    }
    return rows;
  }
}
