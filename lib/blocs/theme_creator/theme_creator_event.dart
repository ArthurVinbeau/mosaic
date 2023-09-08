part of 'theme_creator_bloc.dart';

abstract class ThemeCreatorEvent extends Equatable {
  const ThemeCreatorEvent();
}

class SetThemeColorsEvent extends ThemeCreatorEvent {
  final GameTheme theme;
  final Brightness brightness;

  const SetThemeColorsEvent(this.theme, this.brightness);

  @override
  List<Object?> get props => [theme, brightness];
}

class SaveThemeEvent extends ThemeCreatorEvent {
  const SaveThemeEvent();

  @override
  List<Object?> get props => [];
}

class SetThemeName extends ThemeCreatorEvent {
  final String name;

  const SetThemeName(this.name);

  @override
  List<Object?> get props => [name];
}