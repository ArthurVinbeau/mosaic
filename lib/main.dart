import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mosaic/game_bloc.dart';
import 'package:mosaic/presentation/new_game_widget.dart';

import 'game_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GameBloc(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mosaic"),
        centerTitle: true,
      ),
      body: BlocConsumer<GameBloc, GameState>(
        builder: (context, state) {
          state as NotStartedGameState;
          return Center(child: NewGameWidget(height: state.baseHeight, width: state.baseWidth));
        },
        buildWhen: (_, b) => b is NotStartedGameState,
        listenWhen: (_, b) => b is GeneratingBoardGameState,
        listener: (context, state) {
          Navigator.push(context, MaterialPageRoute(builder: (ctx) => const GamePage()));
        },
      ),
      backgroundColor: Colors.grey,
    );
  }
}
