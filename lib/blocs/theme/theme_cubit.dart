import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../entities/game_theme.dart';
import '../../entities/theme_collection.dart';
import 'base_themes.dart';

part 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  Brightness? _preference;

  Brightness _platformBrightness;

  ThemeCollection _collection;
  late GameTheme _theme;

  late List<ThemeCollection> customThemes;

  List<ThemeCollection> get combinedLists => themeCollections + customThemes;

  ThemeCollection get defaultTheme => baseTheme;

  ThemeCubit(this._platformBrightness)
      : _collection = baseTheme,
        super(GameThemeState(baseTheme.light, baseTheme)) {
    SharedPreferences.getInstance().then((SharedPreferences prefs) {
      customThemes = prefs
          .getStringList(ThemeKeys.custom)
          ?.map((e) => ThemeCollection.deserialize(e))
          .whereType<ThemeCollection>()
          .toList() ??
          [];

      final index = prefs.getInt(ThemeKeys.index) ?? -1;
      if (index >= 0 && index < combinedLists.length) {
        _collection = combinedLists[index];
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
    SharedPreferences.getInstance().then((pref) => pref.setInt(ThemeKeys.index, combinedLists.indexOf(collection)));
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

  void saveCustomTheme(ThemeCollection collection) {
    final index = customThemes.indexWhere((element) => element.name == collection.name);

    if (index > -1) {
      customThemes[index] = collection;
    } else {
      customThemes.add(collection);
    }

    SharedPreferences.getInstance().then((pref) {
      pref.setStringList(ThemeKeys.custom, customThemes.map((e) => e.serialize()).toList());
    });

    setTheme(collection);
  }

  Future<bool> deleteTheme(ThemeCollection collection) async {
    final index = customThemes.indexWhere((element) => element.name == collection.name);

    if (index == -1 || !customThemes.remove(collection)) {
      return false;
    }

    final selected = combinedLists[themeCollections.length + index - 1];
    setTheme(selected);

    final pref = await SharedPreferences.getInstance();
    pref.setStringList(ThemeKeys.custom, customThemes.map((e) => e.serialize()).toList());

    return true;
  }

  ThemeCollection? importCustomTheme(String serializedCollection) {
    ThemeCollection? collection = ThemeCollection.deserialize(serializedCollection.trim());

    if (collection != null) {
      if (customThemes.indexWhere((element) => element.name == collection!.name) > -1) {
        collection = collection.copyWith(name: "Imported ${collection.name}");
      }

      saveCustomTheme(collection);
      return collection;
    }

    return null;
  }
}

abstract class ThemeKeys {
  static const String index = "themeIndex";
  static const String custom = "themeCustom";
  static const String preference = "themePreference";
}
