import 'package:equatable/equatable.dart';

import './game_theme.dart';
import '../utils/config.dart';

class ThemeCollection implements Equatable {
  final GameTheme light;
  final GameTheme dark;
  final String name;

  const ThemeCollection({required this.light, required this.dark, required this.name});

  const ThemeCollection.unique({required GameTheme theme, required this.name})
      : light = theme,
        dark = theme;

  ThemeCollection copyWith({GameTheme? light, GameTheme? dark, String? name}) {
    return ThemeCollection(
      light: light ?? this.light.copyWith(),
      dark: dark ?? this.dark.copyWith(),
      name: name ?? this.name,
    );
  }

  String serialize() {
    String result = name;
    result += "|${light.serialize()}";
    result += "|${dark.serialize()}";
    return result;
  }

  static ThemeCollection? deserialize(String input) {
    try {
      final list = input.split('|');

      final name = list[0];
      final light = GameTheme.deserialize(list[1])!;
      final dark = GameTheme.deserialize(list[2])!;
      return ThemeCollection(light: light, dark: dark, name: name);
    } catch (e, stack) {
      logger.e(
        "Could not deserialize theme collection, make sure it is in the correct format: `$input`",
        error: e,
        stackTrace: stack,
      );
    }
  }

  @override
  List<Object?> get props => [light, dark, name];

  @override
  bool? get stringify => false;

  @override
  String toString() {
    return 'ThemeCollection `$name`: {\n\tlight: $light,\n\rdark: $dark,\n}';
  }
}
