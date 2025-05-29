import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../utils/config.dart';

class GameTheme implements Equatable {
  final MaterialColor primaryColor;
  final Brightness brightness;
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

  GameTheme copyWithKey(String key, Object value) {
    return GameTheme(
      primaryColor:
          key == 'primaryColor' ? value as MaterialColor : primaryColor,
      brightness: key == 'brightness' ? value as Brightness : brightness,
      gameBackground: key == 'gameBackground' ? value as Color : gameBackground,
      cellBase: key == 'cellBase' ? value as Color : cellBase,
      cellEmpty: key == 'cellEmpty' ? value as Color : cellEmpty,
      cellFilled: key == 'cellFilled' ? value as Color : cellFilled,
      cellTextBase: key == 'cellTextBase' ? value as Color : cellTextBase,
      cellTextEmpty: key == 'cellTextEmpty' ? value as Color : cellTextEmpty,
      cellTextFilled: key == 'cellTextFilled' ? value as Color : cellTextFilled,
      cellTextError: key == 'cellTextError' ? value as Color : cellTextError,
      cellTextComplete:
          key == 'cellTextComplete' ? value as Color : cellTextComplete,
      controlsMoveEnabled:
          key == 'controlsMoveEnabled' ? value as Color : controlsMoveEnabled,
      controlsMoveDisabled:
          key == 'controlsMoveDisabled' ? value as Color : controlsMoveDisabled,
    );
  }

  Color operator [](String key) {
    switch (key) {
      case 'primaryColor':
        return primaryColor;
      case 'gameBackground':
        return gameBackground;
      case 'cellBase':
        return cellBase;
      case 'cellEmpty':
        return cellEmpty;
      case 'cellFilled':
        return cellFilled;
      case 'cellTextBase':
        return cellTextBase;
      case 'cellTextEmpty':
        return cellTextEmpty;
      case 'cellTextFilled':
        return cellTextFilled;
      case 'cellTextError':
        return cellTextError;
      case 'cellTextComplete':
        return cellTextComplete;
      case 'controlsMoveEnabled':
        return controlsMoveEnabled;
      case 'controlsMoveDisabled':
        return controlsMoveDisabled;
      default:
        throw ArgumentError('The color `$key` is not a valid key');
    }
  }

  static const String reservedCharacters = ";,";

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
      final primaryColor =
          MaterialColor(_getColorFromHexString(primaryList[0]).toARGB32(), {
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

      final gameBackground = _getColorFromHexString(list[2]);
      final cellBase = _getColorFromHexString(list[3]);
      final cellEmpty = _getColorFromHexString(list[4]);
      final cellFilled = _getColorFromHexString(list[5]);
      final cellTextBase = _getColorFromHexString(list[6]);
      final cellTextEmpty = _getColorFromHexString(list[7]);
      final cellTextFilled = _getColorFromHexString(list[8]);
      final cellTextError = _getColorFromHexString(list[9]);
      final cellTextComplete = _getColorFromHexString(list[10]);
      final controlsMoveEnabled = _getColorFromHexString(list[11]);
      final controlsMoveDisabled = _getColorFromHexString(list[12]);

      return GameTheme(
        primaryColor: primaryColor,
        brightness: brightness,
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

  static String _getColorHexValue(Color color) {
    String alpha = color.a < 1 ? _toHexValue(color.a) : "";
    String red = _toHexValue(color.r);
    String green = _toHexValue(color.g);
    String blue = _toHexValue(color.b);

    // Reduce 0xFF to 0xF if all three values are doubles
    if (red[0] == red[1] && green[0] == green[1] && blue[0] == blue[1]) {
      red = red[0];
      green = green[0];
      blue = blue[0];
    }

    return alpha.isEmpty && red == green && red == blue
        ? alpha + red
        : alpha + red + green + blue;
  }

  static String _toHexValue(double value) {
    final intValue = (value * 255).round() & 0xff;
    return intValue.toRadixString(16).padLeft(2, '0');
  }

  static Color _getColorFromHexString(String input) {
    String alpha, red, green, blue;

    if (input.length == 5 || input.length == 8) {
      alpha = input.substring(0, 2);
      input = input.substring(2);
    } else {
      alpha = "FF";
    }

    if (input.length < 3) {
      red = input;
      green = input;
      blue = input;
    } else {
      final colorSize = input.length == 3 ? 1 : 2;
      red = input.substring(0, colorSize);
      green = input.substring(colorSize, colorSize * 2);
      blue = input.substring(colorSize * 2);
    }

    if (red.length == 1) {
      red = red + red;
      green = green + green;
      blue = blue + blue;
    }

    return Color(int.parse(alpha + red + green + blue, radix: 16));
  }

  @override
  bool? get stringify => true;
}
