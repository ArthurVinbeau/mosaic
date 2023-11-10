import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mosaic/blocs/game/game_bloc.dart';
import 'package:mosaic/blocs/theme/theme_cubit.dart';
import 'package:mosaic/blocs/tutorial/tutorial_bloc.dart';
import 'package:mosaic/presentation/elements/import_seed_dialog.dart';
import 'package:mosaic/presentation/elements/new_game_widget.dart';
import 'package:mosaic/presentation/pages/settings_page.dart';
import 'package:mosaic/presentation/pages/tutorial_page.dart';

import 'game_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  late final ThemeCubit _cubit;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    context.read<GameBloc>().add(AppStartedEvent());
    _cubit = context.read<ThemeCubit>();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return BlocBuilder<ThemeCubit, ThemeState>(builder: (BuildContext context, ThemeState state) {
      return Scaffold(
        appBar: AppBar(
          title: Text(loc.appTitle),
          centerTitle: true,
          actions: [
            IconButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (ctx) => const SettingsPage())),
                icon: const Icon(Icons.settings))
          ],
        ),
        body: BlocConsumer<GameBloc, GameState>(
          builder: (context, state) {
            state as NotStartedGameState;
            return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                    minWidth: constraints.maxWidth,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      NewGameWidget(
                        height: state.baseHeight,
                        width: state.baseWidth,
                        title: loc.difficultyPickerHeader,
                        validateButtonText: loc.newGame,
                        onValidate: (height, width) => context.read<GameBloc>().add(CreateGameEvent(height, width)),
                      ),
                      if (state.canResume)
                        Container(
                          padding: const EdgeInsets.all(32.0),
                          width: double.infinity,
                          child: ElevatedButton(
                            child: Text("${loc.resumeGame} (${state.baseHeight}x${state.baseWidth})"),
                            onPressed: () => context.read<GameBloc>().add(ResumeGameEvent()),
                          ),
                        ),
                      ElevatedButton(
                          onPressed: () async {
                            final bloc = context.read<GameBloc>();
                            final result = await showDialog(
                                context: context, builder: (BuildContext context) => const ImportSeedDialog());
                            if (result != null) {
                              bloc.add(ImportGameEvent(result));
                            }
                          },
                          child: Text(loc.importGameSeed))
                    ],
                  ),
                ),
              );
            });
          },
          buildWhen: (_, b) => b is NotStartedGameState,
          listenWhen: (_, b) => b is GeneratingBoardGameState || b is ShowInvalidSeedSnackbar,
          listener: (context, state) {
            if (state is GeneratingBoardGameState) {
              Navigator.push(context, MaterialPageRoute(builder: (ctx) => const GamePage()));
            } else if (state is ShowInvalidSeedSnackbar) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.invalidSeedMessage)));
            }
          },
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.help),
          onPressed: () {
            context.read<TutorialBloc>().add(StartTutorialEvent());
            Navigator.push(context, MaterialPageRoute(builder: (ctx) => const TutorialPage()));
          },
        ),
      );
    });
  }

  @override
  void didChangePlatformBrightness() {
    _cubit.updatePlatformBrightness(PlatformDispatcher.instance.platformBrightness);
  }
}
