part of 'theme_picker_bloc.dart';

@immutable
abstract class ThemePickerState {
  final ThemeCollection selected;
  final List<ThemeCollection> themes;

  const ThemePickerState(this.selected, this.themes);
}

class ThemePickerInitial extends ThemePickerState {
  const ThemePickerInitial(ThemeCollection selected, List<ThemeCollection> themes) : super(selected, themes);
}
