part of 'theme_picker_bloc.dart';

@immutable
abstract class ThemePickerEvent {}

class PickThemeEvent extends ThemePickerEvent {
  final ThemeCollection collection;

  PickThemeEvent(this.collection);
}