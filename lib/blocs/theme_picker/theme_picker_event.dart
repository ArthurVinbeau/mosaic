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

class DeleteThemeEvent extends ThemePickerEvent {
  final ThemeCollection collection;

  const DeleteThemeEvent(this.collection);
}

class CopyThemeEvent extends ThemePickerEvent {
  final ThemeCollection collection;

  const CopyThemeEvent(this.collection);
}

class EditThemeEvent extends ThemePickerEvent {
  final ThemeCollection collection;

  const EditThemeEvent(this.collection);
}

class ShareThemeEvent extends ThemePickerEvent {
  final ThemeCollection collection;

  const ShareThemeEvent(this.collection);
}

class ImportThemeEvent extends ThemePickerEvent {
  final String serializedCollection;

  const ImportThemeEvent(this.serializedCollection);
}
