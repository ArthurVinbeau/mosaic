import 'package:equatable/equatable.dart';

import './game_theme.dart';
import '../utils/config.dart';

class ThemeCollection implements Equatable {
  final int id;
  final GameTheme light;
  final GameTheme dark;
  final String name;
  final bool editable;

  const ThemeCollection(
      {this.id = -1, required this.light, required this.dark, required this.name, required this.editable});

  const ThemeCollection.unique({this.id = -1, required GameTheme theme, required this.name, required this.editable})
      : light = theme,
        dark = theme;

  ThemeCollection copyWith({int? id, GameTheme? light, GameTheme? dark, String? name}) {
    return ThemeCollection(
      light: light ?? this.light.copyWith(),
      dark: dark ?? this.dark.copyWith(),
      name: name ?? this.name,
      id: id ?? this.id,
      editable: true,
    );
  }

  static const String reservedCharacters = "${GameTheme.reservedCharacters}|";

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
      return ThemeCollection(light: light, dark: dark, name: name, editable: true);
    } catch (e, stack) {
      logger.e(
        "Could not deserialize theme collection, make sure it is in the correct format: `$input`",
        error: e,
        stackTrace: stack,
      );
    }
    return null;
  }

  @override
  List<Object?> get props => [id, light, dark, name, editable];

  @override
  bool? get stringify => false;

  @override
  String toString() {
    return '${editable ? "Editable" : "Non-editable"} ThemeCollection $id `$name`: {\n\tlight: $light,\n\rdark: $dark,\n}';
  }
}
