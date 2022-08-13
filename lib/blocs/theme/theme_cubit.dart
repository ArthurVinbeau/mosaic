import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:mosaic/utils/themes.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  Brightness? _preference;

  Brightness _platformBrightness;

  ThemeCollection _collection;
  late GameTheme _theme;

  ThemeCubit(this._platformBrightness)
      : _collection = baseTheme,
        super(GameThemeState(baseTheme.light, baseTheme)) {
    SharedPreferences.getInstance().then((SharedPreferences prefs) {
      final index = prefs.getInt(ThemeKeys.index) ?? -1;
      if (index >= 0 && index < themeCollections.length) {
        _collection = themeCollections[index];
      }

      final prefIndex = prefs.getInt(ThemeKeys.preference);
      if (prefIndex != null && prefIndex >= 0 && prefIndex < Brightness.values.length) {
        _preference = Brightness.values[prefIndex];
      }

      _getTheme();
    });
  }

  Brightness? get preference => _preference;

  void updateThemePreference(Brightness? brightness) {
    _preference = brightness;
    SharedPreferences.getInstance().then((pref) => pref.setInt(ThemeKeys.preference, brightness?.index ?? -1));
    _getTheme();
  }

  void setTheme(ThemeCollection collection) {
    _collection = collection;
    SharedPreferences.getInstance().then((pref) => pref.setInt(ThemeKeys.index, themeCollections.indexOf(collection)));
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

abstract class ThemeKeys {
  static const String index = "themeIndex";
  static const String custom = "themeCustom";
  static const String preference = "themePreference";
}
