import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';
import 'package:mosaic/blocs/app_state/app_state_bloc.dart';
import 'package:mosaic/blocs/game/game_bloc.dart';
import 'package:mosaic/blocs/locale/locale_bloc.dart';
import 'package:mosaic/blocs/theme/theme_cubit.dart';
import 'package:mosaic/blocs/theme_picker/theme_picker_bloc.dart';
import 'package:mosaic/blocs/timer/timer_bloc.dart';
import 'package:mosaic/blocs/tutorial/tutorial_bloc.dart';
import 'package:mosaic/presentation/new_game_widget.dart';
import 'package:mosaic/settings_page.dart';
import 'package:mosaic/tutorial_page.dart';
import 'package:mosaic/utils/config.dart';

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
        BlocProvider<TimerBloc>(
          create: (context) => TimerBloc(),
        ),
        BlocProvider<GameBloc>(
          create: (context) => GameBloc(BlocProvider.of<TimerBloc>(context)),
        ),
        BlocProvider<AppStateBloc>(
          create: (context) => AppStateBloc(BlocProvider.of<GameBloc>(context)),
        ),
        BlocProvider<ThemeCubit>(
            create: (context) =>
                ThemeCubit(MediaQueryData.fromWindow(WidgetsBinding.instance.window).platformBrightness)),
        BlocProvider<ThemePickerBloc>(create: (context) => ThemePickerBloc(BlocProvider.of<ThemeCubit>(context))),
        BlocProvider<TutorialBloc>(create: (context) => TutorialBloc()),
        BlocProvider<LocaleBloc>(
          create: (context) => LocaleBloc()..add(LoadLocaleEvent(const Locale('en'))),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(builder: (BuildContext context, ThemeState themeState) {
        return BlocBuilder<LocaleBloc, LocaleState>(
          builder: (context, localeState) {
            return MaterialApp(
              onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
              navigatorKey: navigatorKey,
              localizationsDelegates: const [
                LocaleNamesLocalizationsDelegate(),
                ...AppLocalizations.localizationsDelegates
              ],
              locale: localeState.locale,
              supportedLocales: AppLocalizations.supportedLocales,
              theme: ThemeData(
                primarySwatch: themeState.theme.primaryColor,
                brightness: themeState.theme.brightness,
              ),
              home: const MyHomePage(),
            );
          },
        );
      }),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
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
    return BlocBuilder<ThemeCubit, ThemeState>(builder: (BuildContext context, ThemeState state) {
      return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.appTitle),
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
                      NewGameWidget(height: state.baseHeight, width: state.baseWidth),
                      if (state.canResume)
                        Container(
                          padding: const EdgeInsets.all(32.0),
                          width: double.infinity,
                          child: ElevatedButton(
                            child: Text(
                                "${AppLocalizations.of(context)!.resumeGame} (${state.baseHeight}x${state.baseWidth})"),
                            onPressed: () => context.read<GameBloc>().add(ResumeGameEvent()),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            });
          },
          buildWhen: (_, b) => b is NotStartedGameState,
          listenWhen: (_, b) => b is GeneratingBoardGameState,
          listener: (context, state) {
            Navigator.push(context, MaterialPageRoute(builder: (ctx) => const GamePage()));
          },
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: context.read<ThemeCubit>().state.theme.primaryColor,
          child: const Icon(Icons.help),
          onPressed: () {
            context.read<TutorialBloc>().add(StartTutorialEvent());
            Navigator.push(context, MaterialPageRoute(builder: (ctx) => const TutorialPage()));
          },
        ),
        backgroundColor: state.theme.menuBackground,
      );
    });
  }

  @override
  void didChangePlatformBrightness() {
    _cubit.updatePlatformBrightness(MediaQueryData.fromWindow(WidgetsBinding.instance.window).platformBrightness);
  }
}
