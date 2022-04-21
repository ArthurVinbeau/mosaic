import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:mosaic/entities/board.dart';

part 'game_event.dart';

part 'game_state.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  GameBloc() : super(NotStartedGameState()) {
    on<GameEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
