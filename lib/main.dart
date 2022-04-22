import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mosaic/game_bloc.dart';
import 'package:mosaic/presentation/board_widget.dart';

import 'entities/game_controls.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const GamePage(),
    );
  }
}

class GamePage extends StatelessWidget {
  const GamePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GameBloc(),
      child: Builder(builder: (context) {
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
              if (state is ControlsGameState) {
                Color a = Colors.black, b = Colors.white;
                GameControls controls = state.controls;
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
              }
              return const SizedBox();
            },
            buildWhen: (_, b) => b is ControlsGameState,
          ),
        );
      }),
    );
  }
}
