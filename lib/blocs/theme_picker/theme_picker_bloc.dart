import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:mosaic/blocs/theme/theme_cubit.dart';

import '../../entities/theme_collection.dart';

part 'theme_picker_event.dart';

part 'theme_picker_state.dart';

class ThemePickerBloc extends Bloc<ThemePickerEvent, ThemePickerState> {
  final ThemeCubit themeCubit;

  ThemePickerBloc(this.themeCubit)
      : super(ThemePickerInitial(themeCubit.state.collection, themeCubit.combinedLists, themeCubit.preference)) {
    on<PickThemeEvent>(_onTheme);
    on<PickPreferenceEvent>(_onPreference);
  }

  _onTheme(PickThemeEvent event, Emitter emit) {
    themeCubit.setTheme(event.collection);
    emit(ThemePickerInitial(event.collection, themeCubit.combinedLists, themeCubit.preference));
  }

  _onPreference(PickPreferenceEvent event, Emitter emit) {
    themeCubit.updateThemePreference(event.preference);
    emit(ThemePickerInitial(themeCubit.state.collection, themeCubit.combinedLists, event.preference));
  }
}
