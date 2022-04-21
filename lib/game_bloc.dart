import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:mosaic/entities/board.dart';

part 'game_event.dart';

part 'game_state.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  Board? board;
  GameStatus status;

  Map<bool?, bool?> order = {true: false, false: null, null: true};
  Map<bool?, bool?> reverseOrder = {true: null, false: true, null: false};

  GameBloc()
      : status = GameStatus.notStarted,
        super(NotStartedGameState()) {
    on<NewBoardButtonPressedGameEvent>(_newGame);
    on<TilePressedGameEvent>(_tilePressed);
  }

  void _newGame(GameEvent event, Emitter emit) {
    status = GameStatus.generating;
    emit(GeneratingBoardGameState());
    board = Board(height: 15, width: 15);
    status = GameStatus.running;
    emit(BoardGameState(board!));
  }

  void _tilePressed(TilePressedGameEvent event, Emitter emit) {
    final cell = board!.cells[event.i][event.j];

    cell.state = event.long ? reverseOrder[cell.state] : order[cell.state];
    emit(BoardGameState(board!));
  }
}

enum GameStatus {
  notStarted,
  generating,
  running,
  win,
}
