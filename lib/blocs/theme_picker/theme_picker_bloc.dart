import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:mosaic/blocs/theme/theme_cubit.dart';
import 'package:mosaic/utils/themes.dart';

part 'theme_picker_event.dart';

part 'theme_picker_state.dart';

class ThemePickerBloc extends Bloc<ThemePickerEvent, ThemePickerState> {
  final ThemeCubit themeCubit;

  ThemePickerBloc(this.themeCubit)
      : super(ThemePickerInitial(themeCubit.state.collection, themeCollections, themeCubit.preference)) {
    on<PickThemeEvent>(_onTheme);
    on<PickPreferenceEvent>(_onPreference);
  }

  _onTheme(PickThemeEvent event, Emitter emit) {
    themeCubit.setTheme(event.collection);
    emit(ThemePickerInitial(event.collection, themeCollections, themeCubit.preference));
  }

  _onPreference(PickPreferenceEvent event, Emitter emit) {
    themeCubit.updateThemePreference(event.preference);
    emit(ThemePickerInitial(themeCubit.state.collection, themeCollections, event.preference));
  }
}
