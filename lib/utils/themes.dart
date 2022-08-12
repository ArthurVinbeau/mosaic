import 'package:flutter/material.dart';

class ThemeCollection {
  final GameTheme light;
  final GameTheme dark;
  final String name;

  const ThemeCollection({required this.light, required this.dark, required this.name});

  const ThemeCollection.unique({required GameTheme theme, required this.name})
      : light = theme,
        dark = theme;
}

final List<ThemeCollection> themeCollections = [baseTheme, redTheme, blueTheme];

const ThemeCollection baseTheme = ThemeCollection(
    name: "Base",
    light: GameTheme(
        primaryColor: Colors.blue,
        brightness: Brightness.light,
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
        primaryColor: Colors.orange,
        brightness: Brightness.dark,
        menuBackground: Colors.black54,
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

final ThemeCollection redTheme = ThemeCollection(
    name: "Red",
    light: GameTheme(
        primaryColor: Colors.blue,
        brightness: Brightness.light,
        menuBackground: Colors.white,
        gameBackground: const Color(0xFFFFB0B0),
        cellBase: Colors.redAccent.withOpacity(0.50),
        cellEmpty: Colors.red,
        cellFilled: const Color(0xff590606),
        cellTextBase: Colors.black,
        cellTextEmpty: const Color(0xfffbf5df),
        cellTextFilled: Colors.white,
        cellTextError: Colors.yellowAccent,
        cellTextComplete: const Color(0xffd39fc2),
        controlsMoveEnabled: Colors.black,
        controlsMoveDisabled: Colors.black26),
    dark: GameTheme(
        primaryColor: Colors.red,
        brightness: Brightness.dark,
        menuBackground: Colors.black,
        gameBackground: Colors.black,
        cellBase: Colors.redAccent.withOpacity(0.30),
        cellEmpty: const Color(0xfffeb3ab),
        cellFilled: Colors.redAccent.withOpacity(0.75),
        cellTextBase: const Color(0xfffbf5df),
        cellTextEmpty: Colors.black,
        cellTextFilled: const Color(0xfffbf5df),
        cellTextError: Colors.yellowAccent,
        cellTextComplete: const Color(0xff787583),
        controlsMoveEnabled: Colors.white,
        controlsMoveDisabled: const Color.fromARGB(255, 75, 75, 75)));

const ThemeCollection blueTheme = ThemeCollection(
    name: "Blue",
    light: GameTheme(
        primaryColor: Colors.blue,
        brightness: Brightness.light,
        menuBackground: Colors.white,
        gameBackground: Colors.blueGrey,
        cellBase: Colors.blueAccent,
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
        brightness: Brightness.dark,
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
  final Brightness brightness;
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
    required this.brightness,
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
