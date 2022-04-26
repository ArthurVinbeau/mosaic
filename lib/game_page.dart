import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'entities/game_controls.dart';
import 'game_bloc.dart';
import 'presentation/board_widget.dart';

class GamePage extends StatelessWidget {
  const GamePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mosaic"),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => context.read<GameBloc>().add(NewGameButtonEvent()),
            icon: const Icon(Icons.refresh),
            tooltip: "New game",
          )
        ],
      ),
      body: const BoardWidget(),
      backgroundColor: Colors.grey,
      bottomNavigationBar: BlocBuilder<GameBloc, GameState>(
        builder: (context, state) {
          GameControls controls;
          if (state is ControlsGameState) {
            controls = state.controls;
          } else if (state is NewBoardGameState) {
            controls = state.controls;
          } else {
            return const SizedBox();
          }
          Color a = Colors.black, b = Colors.white;

          if (controls.reversed) {
            var tmp = a;
            a = b;
            b = tmp;
          }
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 8.0,
              children: [
                IconButton(
                    onPressed: () => context.read<GameBloc>().add(ToggleColorsEvent()),
                    icon: Stack(
                      children: [Icon(Icons.circle, color: b), Icon(Icons.contrast, color: a)],
                    )),
                Ink(
                  decoration: ShapeDecoration(shape: const CircleBorder(), color: controls.fill ? a : null),
                  child: IconButton(
                      onPressed: () => context.read<GameBloc>().add(ToggleFillEvent()),
                      icon: Icon(Icons.format_color_fill, color: controls.fill ? b : a)),
                ),
                IconButton(
                    onPressed: controls.canUndo ? () => context.read<GameBloc>().add(UndoEvent()) : null,
                    icon: const Icon(Icons.undo)),
                IconButton(
                    onPressed: controls.canRedo ? () => context.read<GameBloc>().add(RedoEvent()) : null,
                    icon: const Icon(Icons.redo)),
              ],
            ),
          );
        },
        buildWhen: (_, b) => b is ControlsGameState || b is NewBoardGameState,
      ),
    );
  }
}