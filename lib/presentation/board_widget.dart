import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mosaic/blocs/game/game_bloc.dart';
import 'package:mosaic/entities/board.dart';
import 'package:mosaic/presentation/tile.dart';
import 'package:mosaic/utils/config.dart';

class BoardWidget extends StatelessWidget {
  const BoardWidget({Key? key}) : super(key: key);

  void _showBlocDialog(BuildContext context, ShowDialogState state) async {
    final theme = Theme.of(context);
    final pop = await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: Text(state.title),
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
          return LayoutBuilder(builder: (context, constraints) {
            const double tileSize = 32.0;
            double? height;
            double? width;
            if (constraints.maxHeight / constraints.maxWidth > state.board.height / state.board.width) {
              height = (tileSize + 4) * state.board.width * constraints.maxHeight / constraints.maxWidth;
            } else {
              width = (tileSize + 4) * state.board.height * constraints.maxWidth / constraints.maxHeight;
            }

            logger.d("height: $height, width: $width");

            return SizedBox.expand(
              child: InteractiveViewer(
                  minScale: 0.00000000001,
                  maxScale: double.infinity,
                  boundaryMargin: const EdgeInsets.all(16),
                  constrained: false,
                  child: Container(
                      height: height,
                      width: width,
                      alignment: Alignment.center,
                      child: Column(mainAxisSize: MainAxisSize.min, children: getTableRows(state.board, tileSize)))),
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
