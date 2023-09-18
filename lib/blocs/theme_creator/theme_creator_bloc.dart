import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mosaic/blocs/theme/theme_cubit.dart';

import '../../entities/game_theme.dart';
import '../../entities/theme_collection.dart';

part 'theme_creator_event.dart';
part 'theme_creator_state.dart';

class ThemeCreatorBloc extends Bloc<ThemeCreatorEvent, ThemeCreatorState> {
  final ThemeCubit themeCubit;

  ThemeCollection _collection;

  ThemeCreatorBloc({required this.themeCubit, ThemeCollection? original})
      : _collection = original?.copyWith() ?? themeCubit.defaultTheme.copyWith(name: "New Theme"),
        super(ThemeCreatorInitial(original ?? themeCubit.defaultTheme.copyWith(name: "New Theme"))) {
    on<SetThemeColorsEvent>(_setThemeColor);
    on<SetThemeNameEvent>(_setThemeName);
    on<SaveThemeEvent>(_saveTheme);
    on<ExitPageEvent>(_exitPage);
    on<ConfirmExitPageEvent>(_confirmExitPage);
  }

  void _setThemeColor(SetThemeColorsEvent event, Emitter emit) {
    _collection = _collection.copyWith(
      light: event.brightness == Brightness.light ? event.theme : null,
      dark: event.brightness == Brightness.dark ? event.theme : null,
    );
    emit(ThemeCreatorInitial(_collection));
  }

  void _setThemeName(SetThemeNameEvent event, Emitter emit) {
    final name = event.name.trim();
    if (name.isEmpty) {
      emit(ThemeNameErrorState(ThemeCreatorNameError.mustNotBeEmpty, _collection));
    } else if (themeCubit.customThemes.any((element) => element.name == name)) {
      emit(ThemeNameErrorState(ThemeCreatorNameError.alreadyExists, _collection));
    } else {
      _collection = _collection.copyWith(name: name);
      emit(ThemeCreatorInitial(_collection));
    }
  }

  void _saveTheme(SaveThemeEvent event, Emitter emit) {
    themeCubit.saveCustomTheme(_collection);
    emit(ExitPageState(true, _collection));
  }

  void _exitPage(ExitPageEvent event, Emitter emit) {
    emit(ShowExiConfirmationState(_collection));
  }

  void _confirmExitPage(ConfirmExitPageEvent event, Emitter emit) {
    emit(ExitPageState(false, _collection));
  }
}

enum ThemeCreatorNameError {
  alreadyExists,
  mustNotBeEmpty,
}
