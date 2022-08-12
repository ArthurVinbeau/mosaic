import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:mosaic/utils/themes.dart';

part 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  Brightness? _preference;

  Brightness _platformBrightness;

  ThemeCollection _collection;
  late GameTheme _theme;

  ThemeCubit(this._platformBrightness)
      : _collection = baseTheme,
        super(GameThemeState(baseTheme.light, baseTheme)) {
    _getTheme();
  }

  void updateThemePreference(Brightness? brightness) {
    _preference = brightness;
    _getTheme();
  }

  void setTheme(ThemeCollection collection) {
    _collection = collection;
    _getTheme();
  }

  void updatePlatformBrightness(Brightness brightness) {
    _platformBrightness = brightness;
    _getTheme();
  }

  GameTheme _getTheme() {
    final brightness = _preference ?? _platformBrightness;
    _theme = brightness == Brightness.light ? _collection.light : _collection.dark;
    emit(GameThemeState(_theme, _collection));
    return _theme;
  }
}
