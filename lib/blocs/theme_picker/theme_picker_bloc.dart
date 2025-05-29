import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:mosaic/blocs/theme/theme_cubit.dart';
import 'package:mosaic/utils/config.dart';
import 'package:share_plus/share_plus.dart';

import '../../entities/theme_collection.dart';

part 'theme_picker_event.dart';
part 'theme_picker_state.dart';

class ThemePickerBloc extends Bloc<ThemePickerEvent, ThemePickerState> {
  final ThemeCubit themeCubit;

  ThemePickerBloc(this.themeCubit)
      : super(ThemePickerInitial(themeCubit.state.collection,
            themeCubit.combinedLists, themeCubit.preference)) {
    on<PickThemeEvent>(_onTheme);
    on<PickPreferenceEvent>(_onPreference);
    on<ReloadThemesEvent>(_onReload);
    on<DeleteThemeEvent>(_onDelete);
    on<CopyThemeEvent>(_onCopyTheme);
    on<EditThemeEvent>(_onEditTheme);
    on<ShareThemeEvent>(_onShare);
    on<ImportThemeEvent>(_onImport);
  }

  void _onTheme(PickThemeEvent event, Emitter emit) {
    themeCubit.setTheme(event.collection);
    emit(ThemePickerInitial(
        event.collection, themeCubit.combinedLists, themeCubit.preference));
  }

  void _onPreference(PickPreferenceEvent event, Emitter emit) {
    themeCubit.updateThemePreference(event.preference);
    emit(ThemePickerInitial(themeCubit.state.collection,
        themeCubit.combinedLists, event.preference));
  }

  void _onReload(ReloadThemesEvent event, Emitter emit) {
    emit(ThemePickerInitial(themeCubit.state.collection,
        themeCubit.combinedLists, themeCubit.preference));
  }

  Future<void> _onDelete(DeleteThemeEvent event, Emitter emit) async {
    if (await themeCubit.deleteTheme(event.collection)) {
      emit(ThemePickerInitial(themeCubit.state.collection,
          themeCubit.combinedLists, themeCubit.preference));
    } else {
      // FIXME: snackbar
    }
  }

  void _onCopyTheme(CopyThemeEvent event, Emitter emit) {
    emit(OpenThemeCreator(
        event.collection
            .copyWith(name: "Copy of ${event.collection.name}", id: -1),
        themeCubit.state.collection,
        themeCubit.combinedLists,
        themeCubit.preference));
  }

  void _onEditTheme(EditThemeEvent event, Emitter emit) {
    emit(OpenThemeCreator(event.collection, themeCubit.state.collection,
        themeCubit.combinedLists, themeCubit.preference));
  }

  void _onShare(ShareThemeEvent event, Emitter emit) {
    final serialized = event.collection.serialize();
    logger.d("Sharing $serialized");
    SharePlus.instance.share(ShareParams(
      text: serialized,
      subject: "Mosaic Theme: ${event.collection.name}",
    ));
  }

  void _onImport(ImportThemeEvent event, Emitter emit) {
    if (themeCubit.importCustomTheme(event.serializedCollection) != null) {
      emit(ThemePickerInitial(themeCubit.state.collection,
          themeCubit.combinedLists, themeCubit.preference));
    } else {
      // FIXME: snackbar
    }
  }
}
