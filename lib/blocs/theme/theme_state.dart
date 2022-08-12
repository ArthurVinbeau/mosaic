part of 'theme_cubit.dart';

@immutable
abstract class ThemeState {
  final GameTheme theme;
  final ThemeCollection collection;

  const ThemeState(this.theme, this.collection);
}

class GameThemeState extends ThemeState {
  const GameThemeState(GameTheme theme, ThemeCollection collection) : super(theme, collection);
}
