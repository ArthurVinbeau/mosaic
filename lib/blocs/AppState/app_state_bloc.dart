import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:mosaic/blocs/Game/game_bloc.dart';
import 'package:mosaic/utils/config.dart';

part 'app_state_event.dart';

part 'app_state_state.dart';

class AppStateBloc extends Bloc<AppStateEvent, AppStateState> {
  final GameBloc _gameBloc;
  bool _paused = false;

  AppStateBloc(this._gameBloc) : super(AppStateInitial()) {
    on<PopRouteEvent>((event, emit) {
      logger.d("route pop");
      _gameBloc.add(GamePausedEvent(false));
    });
    on<AppLifecycleStateEvent>((event, emit) {
      logger.d(event.state);
      if (event.state == AppLifecycleState.resumed) {
        _paused = false;
      } else if (!_paused) {
        _paused = true;
        _gameBloc.add(GamePausedEvent(true));
      }
    });
  }
}
