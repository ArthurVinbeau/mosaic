part of 'theme_cubit.dart';

@immutable
abstract class ThemeState {
  final GameTheme theme;

  const ThemeState(this.theme);
}

class GameThemeState extends ThemeState {
  const GameThemeState(GameTheme theme) : super(theme);
}
