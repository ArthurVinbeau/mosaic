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
        super(ThemeCreatorInitial(original ?? themeCubit.defaultTheme)) {
    on<SetThemeColorsEvent>((event, emit) {
      _collection = _collection.copyWith(
        light: event.brightness == Brightness.light ? event.theme : null,
        dark: event.brightness == Brightness.dark ? event.theme : null,
      );
      emit(ThemeCreatorInitial(_collection));
    });
    on<SetThemeName>((event, emit) {
      if (event.name.trim().isNotEmpty) {
        _collection = _collection.copyWith(name: event.name.trim());
        emit(ThemeCreatorInitial(_collection));
      } else {
        emit(ThemeNameErrorState('Name must not be empty', _collection));
      }
    });
    on<SaveThemeEvent>((event, emit) {});
  }
}
