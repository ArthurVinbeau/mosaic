import 'package:flutter/material.dart';

class ThemeCollection {
  final GameTheme light;
  final GameTheme dark;

  const ThemeCollection({required this.light, required this.dark});

  const ThemeCollection.unique(GameTheme theme)
      : light = theme,
        dark = theme;
}

const ThemeCollection baseTheme = ThemeCollection(
    light: GameTheme(
        primaryColor: Colors.blue,
        menuBackground: Colors.white,
        gameBackground: Colors.grey,
        cellBase: Colors.teal,
        cellEmpty: Colors.white,
        cellFilled: Colors.black,
        cellTextBase: Colors.black,
        cellTextEmpty: Colors.black,
        cellTextFilled: Colors.white,
        cellTextError: Colors.red,
        cellTextComplete: Colors.grey,
        controlsMoveEnabled: Colors.black,
        controlsMoveDisabled: Colors.black26),
    dark: GameTheme(
        primaryColor: Colors.red,
        menuBackground: Color.fromARGB(255, 240, 240, 240),
        gameBackground: Colors.black,
        cellBase: Color.fromARGB(255, 148, 196, 190),
        cellEmpty: Colors.white,
        cellFilled: Color.fromARGB(255, 75, 75, 75),
        cellTextBase: Colors.black,
        cellTextEmpty: Colors.black,
        cellTextFilled: Colors.white,
        cellTextError: Colors.red,
        cellTextComplete: Colors.grey,
        controlsMoveEnabled: Colors.white,
        controlsMoveDisabled: Color.fromARGB(255, 75, 75, 75)));

class GameTheme {
  final MaterialColor primaryColor;
  final Color menuBackground;
  final Color gameBackground;
  final Color cellBase;
  final Color cellEmpty;
  final Color cellFilled;
  final Color cellTextBase;
  final Color cellTextEmpty;
  final Color cellTextFilled;
  final Color cellTextError;
  final Color cellTextComplete;
  final Color controlsMoveEnabled;
  final Color controlsMoveDisabled;

  const GameTheme({
    required this.primaryColor,
    required this.menuBackground,
    required this.gameBackground,
    required this.cellBase,
    required this.cellEmpty,
    required this.cellFilled,
    required this.cellTextBase,
    required this.cellTextEmpty,
    required this.cellTextFilled,
    required this.cellTextError,
    required this.cellTextComplete,
    required this.controlsMoveEnabled,
    required this.controlsMoveDisabled,
  });
}
