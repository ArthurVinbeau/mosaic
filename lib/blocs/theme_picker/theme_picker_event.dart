part of 'theme_picker_bloc.dart';

@immutable
abstract class ThemePickerEvent {
  const ThemePickerEvent();
}

class PickThemeEvent extends ThemePickerEvent {
  final ThemeCollection collection;

  const PickThemeEvent(this.collection);
}

class PickPreferenceEvent extends ThemePickerEvent {
  final Brightness? preference;

  const PickPreferenceEvent(this.preference);
}

class ReloadThemesEvent extends ThemePickerEvent {
  const ReloadThemesEvent();
}
