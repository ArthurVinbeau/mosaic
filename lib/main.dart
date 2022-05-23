import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mosaic/blocs/AppState/app_state_bloc.dart';
import 'package:mosaic/blocs/Game/game_bloc.dart';
import 'package:mosaic/blocs/theme/theme_cubit.dart';
import 'package:mosaic/presentation/new_game_widget.dart';
import 'package:mosaic/utils/config.dart';
import 'package:mosaic/utils/theme/theme_container.dart';
import 'package:mosaic/utils/theme/themes.dart';

import 'game_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<GameBloc>(
          create: (context) => GameBloc(),
        ),
        BlocProvider<AppStateBloc>(
          create: (context) => AppStateBloc(BlocProvider.of<GameBloc>(context)),
        ),
        BlocProvider<ThemeCubit>(create: (context) => ThemeCubit()),
      ],
      child: GameThemeContainer(
        child: Builder(builder: (context) {
          return MaterialApp(
            title: 'Flutter Demo',
            navigatorKey: navigatorKey,
            theme: ThemeData(
              primarySwatch: GameThemeContainer.of(context).primaryColor,
            ),
            home: const MyHomePage(),
          );
        }),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    context.read<GameBloc>().add(AppStartedEvent());
  }

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
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                NewGameWidget(height: state.baseHeight, width: state.baseWidth),
                if (state.canResume)
                  Container(
                    padding: const EdgeInsets.all(32.0),
                    width: double.infinity,
                    child: ElevatedButton(
                      child: const Text("Resume Game"),
                      onPressed: () => context.read<GameBloc>().add(ResumeGameEvent()),
                    ),
                  ),
              ],
            ),
          );
        },
        buildWhen: (_, b) => b is NotStartedGameState,
        listenWhen: (_, b) => b is GeneratingBoardGameState,
        listener: (context, state) {
          Navigator.push(context, MaterialPageRoute(builder: (ctx) => const GamePage()));
        },
      ),
      backgroundColor: GameThemeContainer.of(context).menuBackground,
    );
  }
}
