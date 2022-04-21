import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mosaic/game_bloc.dart';
import 'package:mosaic/presentation/board_widget.dart';

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
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Mosaic"),
          centerTitle: true,
        ),
        body: const BoardWidget(),
        backgroundColor: Colors.grey,
        bottomNavigationBar: BlocBuilder<GameBloc, GameState>(
          builder: (context, state) {
            Color a = Colors.black, b = Colors.white;
            if (state is ControlsGameState && state.reversed) {
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
                      ))
                ],
              ),
            );
          },
          buildWhen: (_, b) => b is ControlsGameState,
        ),
      ),
    );
  }
}
