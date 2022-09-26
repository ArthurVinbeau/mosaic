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
import 'package:mosaic/presentation/pages/home_page.dart';
import 'package:mosaic/utils/config.dart';

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
              home: const HomePage(),
            );
          },
        );
      }),
    );
  }
}
