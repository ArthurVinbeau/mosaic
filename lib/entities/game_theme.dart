import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../utils/config.dart';

class GameTheme implements Equatable {
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

  @override
  List<Object?> get props => [
        primaryColor,
        brightness,
        menuBackground,
        gameBackground,
        cellBase,
        cellEmpty,
        cellFilled,
        cellTextBase,
        cellTextEmpty,
        cellTextFilled,
        cellTextError,
        cellTextComplete,
        controlsMoveEnabled,
        controlsMoveDisabled,
      ];

  GameTheme copyWith({
    MaterialColor? primaryColor,
    Brightness? brightness,
    Color? menuBackground,
    Color? gameBackground,
    Color? cellBase,
    Color? cellEmpty,
    Color? cellFilled,
    Color? cellTextBase,
    Color? cellTextEmpty,
    Color? cellTextFilled,
    Color? cellTextError,
    Color? cellTextComplete,
    Color? controlsMoveEnabled,
    Color? controlsMoveDisabled,
  }) {
    return GameTheme(
      primaryColor: primaryColor ?? this.primaryColor,
      brightness: brightness ?? this.brightness,
      menuBackground: menuBackground ?? this.menuBackground,
      gameBackground: gameBackground ?? this.gameBackground,
      cellBase: cellBase ?? this.cellBase,
      cellEmpty: cellEmpty ?? this.cellEmpty,
      cellFilled: cellFilled ?? this.cellFilled,
      cellTextBase: cellTextBase ?? this.cellTextBase,
      cellTextEmpty: cellTextEmpty ?? this.cellTextEmpty,
      cellTextFilled: cellTextFilled ?? this.cellTextFilled,
      cellTextError: cellTextError ?? this.cellTextError,
      cellTextComplete: cellTextComplete ?? this.cellTextComplete,
      controlsMoveEnabled: controlsMoveEnabled ?? this.controlsMoveEnabled,
      controlsMoveDisabled: controlsMoveDisabled ?? this.controlsMoveDisabled,
    );
  }

  String serialize() {
    String result = brightness == Brightness.light ? '1' : '0';
    result += ';${_getColorHexValue(primaryColor)},'
        '${_getColorHexValue(primaryColor.shade50)},'
        '${_getColorHexValue(primaryColor.shade100)},'
        '${_getColorHexValue(primaryColor.shade200)},'
        '${_getColorHexValue(primaryColor.shade300)},'
        '${_getColorHexValue(primaryColor.shade400)},'
        '${_getColorHexValue(primaryColor.shade500)},'
        '${_getColorHexValue(primaryColor.shade600)},'
        '${_getColorHexValue(primaryColor.shade700)},'
        '${_getColorHexValue(primaryColor.shade800)},'
        '${_getColorHexValue(primaryColor.shade900)}';
    result += ";${_getColorHexValue(menuBackground)}";
    result += ";${_getColorHexValue(gameBackground)}";
    result += ";${_getColorHexValue(cellBase)}";
    result += ";${_getColorHexValue(cellEmpty)}";
    result += ";${_getColorHexValue(cellFilled)}";
    result += ";${_getColorHexValue(cellTextBase)}";
    result += ";${_getColorHexValue(cellTextEmpty)}";
    result += ";${_getColorHexValue(cellTextFilled)}";
    result += ";${_getColorHexValue(cellTextError)}";
    result += ";${_getColorHexValue(cellTextComplete)}";
    result += ";${_getColorHexValue(controlsMoveEnabled)}";
    result += ";${_getColorHexValue(controlsMoveDisabled)}";

    return result;
  }

  static GameTheme? deserialize(String input) {
    try {
      final list = input.split(';');

      final brightness = list[0] == '1' ? Brightness.light : Brightness.dark;

      final primaryList = list[1].split(',');
      final primaryColor = MaterialColor(_getColorFromHexString(primaryList[0]).value, {
        50: _getColorFromHexString(primaryList[1]),
        100: _getColorFromHexString(primaryList[2]),
        200: _getColorFromHexString(primaryList[3]),
        300: _getColorFromHexString(primaryList[4]),
        400: _getColorFromHexString(primaryList[5]),
        500: _getColorFromHexString(primaryList[6]),
        600: _getColorFromHexString(primaryList[7]),
        700: _getColorFromHexString(primaryList[8]),
        800: _getColorFromHexString(primaryList[9]),
        900: _getColorFromHexString(primaryList[10]),
      });

      final menuBackground = _getColorFromHexString(list[2]);
      final gameBackground = _getColorFromHexString(list[3]);
      final cellBase = _getColorFromHexString(list[4]);
      final cellEmpty = _getColorFromHexString(list[5]);
      final cellFilled = _getColorFromHexString(list[6]);
      final cellTextBase = _getColorFromHexString(list[7]);
      final cellTextEmpty = _getColorFromHexString(list[8]);
      final cellTextFilled = _getColorFromHexString(list[9]);
      final cellTextError = _getColorFromHexString(list[10]);
      final cellTextComplete = _getColorFromHexString(list[11]);
      final controlsMoveEnabled = _getColorFromHexString(list[12]);
      final controlsMoveDisabled = _getColorFromHexString(list[13]);

      return GameTheme(
        primaryColor: primaryColor,
        brightness: brightness,
        menuBackground: menuBackground,
        gameBackground: gameBackground,
        cellBase: cellBase,
        cellEmpty: cellEmpty,
        cellFilled: cellFilled,
        cellTextBase: cellTextBase,
        cellTextEmpty: cellTextEmpty,
        cellTextFilled: cellTextFilled,
        cellTextError: cellTextError,
        cellTextComplete: cellTextComplete,
        controlsMoveEnabled: controlsMoveEnabled,
        controlsMoveDisabled: controlsMoveDisabled,
      );
    } catch (e, stack) {
      logger.e(
        "Could not deserialize game theme, make sure it is in the correct format: `$input`",
        error: e,
        stackTrace: stack,
      );
      return null;
    }
  }

  static String _getColorHexValue(Color color) => color.value.toRadixString(16);

  static Color _getColorFromHexString(String input) => Color(int.parse(input, radix: 16));

  @override
  bool? get stringify => true;
}
