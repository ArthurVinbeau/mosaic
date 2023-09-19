part of 'theme_picker_bloc.dart';

@immutable
abstract class ThemePickerState {
  final ThemeCollection selected;
  final List<ThemeCollection> themes;
  final Brightness? brightness;

  const ThemePickerState(this.selected, this.themes, this.brightness);
}

class ThemePickerInitial extends ThemePickerState {
  const ThemePickerInitial(ThemeCollection selected, List<ThemeCollection> themes, Brightness? brightness)
      : super(selected, themes, brightness);
}

class OpenThemeCreator extends ThemePickerState {
  final ThemeCollection original;

  const OpenThemeCreator(this.original, ThemeCollection selected, List<ThemeCollection> themes, Brightness? brightness)
      : super(selected, themes, brightness);
}
