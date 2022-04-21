import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:mosaic/entities/board.dart';

import 'entities/cell.dart';

part 'game_event.dart';

part 'game_state.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  Board board;
  GameStatus status;

  bool reversed = false;

  Map<bool?, bool?> order = {true: false, false: null, null: true};
  Map<bool?, bool?> reverseOrder = {true: null, false: true, null: false};
  late Map<bool, Map<bool?, bool?>> usedOrder = {true: reverseOrder, false: order};

  GameBloc()
      : status = GameStatus.notStarted,
        board = Board(),
        super(NotStartedGameState()) {
    on<NewBoardButtonPressedGameEvent>(_newGame);
    on<TilePressedGameEvent>(_tilePressed);
    on<ToggleColorsEvent>(_toggleCommands);
  }

  void _newGame(GameEvent event, Emitter emit) {
    status = GameStatus.generating;
    emit(GeneratingBoardGameState());
    board.newGameDesc();
    status = GameStatus.running;
    emit(BoardGameState(board));
  }

  void _tilePressed(TilePressedGameEvent event, Emitter emit) {
    final cell = board.cells[event.i][event.j];

    cell.state = usedOrder[event.long]![cell.state];
    Board.iterateOnSquare(board.cells, event.i, event.j, (Cell cell, p1, p2) {
      var count = 0;
      Board.iterateOnSquare(board.cells, p1, p2, (Cell e, p1, p2) => count += (e.state ?? false) ? 1 : 0);
      cell.error = count > cell.clue;
    });

    emit(BoardGameState(board));
  }

  void _toggleCommands(ToggleColorsEvent event, Emitter emit) {
    reversed = !reversed;
    usedOrder = reversed ? {true: order, false: reverseOrder} : {true: reverseOrder, false: order};
    emit(ControlsGameState(reversed));
  }
}

enum GameStatus {
  notStarted,
  generating,
  running,
  win,
}
