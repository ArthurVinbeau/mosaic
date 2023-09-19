import 'package:flutter/material.dart';

import '../../entities/game_theme.dart';
import '../../entities/theme_collection.dart';

final List<ThemeCollection> themeCollections = [baseTheme, redTheme, blueTheme];

const ThemeCollection baseTheme = ThemeCollection(
    name: "Base",
    editable: false,
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
        controlsMoveDisabled: Color.fromARGB(255, 100, 100, 100)),
    dark: GameTheme(
        primaryColor: Colors.orange,
        brightness: Brightness.dark,
        menuBackground: Colors.black,
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

const ThemeCollection redTheme = ThemeCollection(
    name: "Red",
    editable: false,
    light: GameTheme(
        primaryColor: Colors.red,
        brightness: Brightness.light,
        menuBackground: Colors.white,
        gameBackground: Color(0xFFFFB0B0),
        cellBase: Color(0xffff8b8b),
        cellEmpty: Colors.red,
        cellFilled: Color(0xff590606),
        cellTextBase: Colors.black,
        cellTextEmpty: Color(0xfffbf5df),
        cellTextFilled: Colors.white,
        cellTextError: Colors.yellowAccent,
        cellTextComplete: Color(0xFFFFB0B0),
        controlsMoveEnabled: Colors.black,
        controlsMoveDisabled: Color.fromARGB(255, 100, 100, 100)),
    dark: GameTheme(
        primaryColor: Colors.red,
        brightness: Brightness.dark,
        menuBackground: Colors.black,
        gameBackground: Colors.black,
        cellBase: Color(0xffff8b8b),
        cellEmpty: Colors.red,
        cellFilled: Color(0xff772525),
        cellTextBase: Colors.black,
        cellTextEmpty: Color(0xfffbf5df),
        cellTextFilled: Colors.white,
        cellTextError: Colors.yellowAccent,
        cellTextComplete: Color(0xFFFFB0B0),
        controlsMoveEnabled: Colors.white,
        controlsMoveDisabled: Color.fromARGB(255, 75, 75, 75)));

final ThemeCollection blueTheme = ThemeCollection(
    name: "Blue",
    editable: false,
    light: GameTheme(
        primaryColor: Colors.blue,
        brightness: Brightness.light,
        menuBackground: Colors.white,
        gameBackground: Colors.blueGrey.shade200,
        cellBase: Colors.teal,
        cellEmpty: Colors.lightBlueAccent.shade100,
        cellFilled: Colors.blue.shade900,
        cellTextBase: Colors.black,
        cellTextEmpty: Colors.black,
        cellTextFilled: Colors.white,
        cellTextError: Colors.red,
        cellTextComplete: Colors.blueGrey.shade200,
        controlsMoveEnabled: Colors.black,
        controlsMoveDisabled: const Color.fromARGB(255, 100, 100, 100)),
    dark: GameTheme(
        primaryColor: Colors.indigo,
        brightness: Brightness.dark,
        menuBackground: Colors.black,
        gameBackground: Colors.black,
        cellBase: const Color.fromARGB(255, 132, 183, 164),
        cellEmpty: Colors.lightBlueAccent.shade100,
        cellFilled: Colors.blue.shade900,
        cellTextBase: Colors.black,
        cellTextEmpty: Colors.black,
        cellTextFilled: Colors.white,
        cellTextError: Colors.red,
        cellTextComplete: Colors.blueGrey,
        controlsMoveEnabled: Colors.white,
        controlsMoveDisabled: const Color.fromARGB(255, 75, 75, 75)));
