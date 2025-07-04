import 'package:flutter/material.dart';

extension ColorsExt on Color {
  MaterialColor toMaterialColor() {
    final int red = (r * 255).round() & 0xff;
    final int green = (g * 255).round() & 0xff;
    final int blue = (b * 255).round() & 0xff;

    final Map<int, Color> shades = {
      50: Color.fromRGBO(red, green, blue, .1),
      100: Color.fromRGBO(red, green, blue, .2),
      200: Color.fromRGBO(red, green, blue, .3),
      300: Color.fromRGBO(red, green, blue, .4),
      400: Color.fromRGBO(red, green, blue, .5),
      500: Color.fromRGBO(red, green, blue, .6),
      600: Color.fromRGBO(red, green, blue, .7),
      700: Color.fromRGBO(red, green, blue, .8),
      800: Color.fromRGBO(red, green, blue, .9),
      900: Color.fromRGBO(red, green, blue, 1),
    };

    return MaterialColor(toARGB32(), shades);
  }
}
