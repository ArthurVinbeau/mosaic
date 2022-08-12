import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:mosaic/blocs/theme/theme_cubit.dart';
import 'package:mosaic/utils/themes.dart';

part 'theme_picker_event.dart';

part 'theme_picker_state.dart';

class ThemePickerBloc extends Bloc<ThemePickerEvent, ThemePickerState> {
  final ThemeCubit themeCubit;

  ThemePickerBloc(this.themeCubit) : super(ThemePickerInitial(themeCubit.state.collection, themeCollections)) {
    on<PickThemeEvent>(_onPick);
  }

  _onPick(PickThemeEvent event, Emitter emit) {
    themeCubit.setTheme(event.collection);
    emit(ThemePickerInitial(event.collection, themeCollections));
  }
}
