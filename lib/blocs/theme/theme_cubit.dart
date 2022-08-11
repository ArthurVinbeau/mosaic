import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:mosaic/utils/themes.dart';

part 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  bool? preference;

  ThemeCollection collection;
  late GameTheme theme;

  ThemeCubit()
      : collection = baseTheme,
        super(GameThemeState(baseTheme.light)) {
    _getTheme();
  }

  void updateThemePreference(bool? light) {
    preference = light;
    _getTheme();
  }

  void setTheme(ThemeCollection collection) {
    this.collection = collection;
    _getTheme();
  }

  GameTheme _getTheme() {
    theme = collection.dark; // FIXME
    emit(GameThemeState(theme));
    return theme;
  }
}
