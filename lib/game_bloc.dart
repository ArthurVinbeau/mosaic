import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:mosaic/entities/board.dart';
import 'package:mosaic/entities/game_controls.dart';

import 'entities/cell.dart';

part 'game_event.dart';

part 'game_state.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  Board board;
  GameStatus status;
  GameControls controls;

  Map<bool?, bool?> order = {true: false, false: null, null: true};
  Map<bool?, bool?> reverseOrder = {true: null, false: true, null: false};
  late Map<bool, Map<bool?, bool?>> usedOrder = {true: reverseOrder, false: order};

  GameBloc()
      : status = GameStatus.notStarted,
        board = Board(),
        controls = GameControls(false, false),
        super(NotStartedGameState()) {
    on<NewBoardButtonPressedGameEvent>(_newGame);
    on<TilePressedGameEvent>(_tilePressed);
    on<ToggleColorsEvent>(_toggleCommands);
    on<ToggleFillEvent>(_toggleFill);
  }

  void _newGame(GameEvent event, Emitter emit) {
    status = GameStatus.generating;
    emit(GeneratingBoardGameState());
    board.newGameDesc();
    status = GameStatus.running;
    emit(BoardGameState(board));
    emit(ControlsGameState(controls));
  }

  void _checkCellError(int i, int j) {
    var count = 0;
    Board.iterateOnSquare(board.cells, i, j, (Cell e, p1, p2) => count += (e.state ?? false) ? 1 : 0);
    board.cells[i][j].error = count > board.cells[i][j].clue;
  }

  void _tilePressed(TilePressedGameEvent event, Emitter emit) {
    if (controls.fill) {
      Board.iterateOnSquare(board.cells, event.i, event.j, (Cell cell, p1, p2) {
        cell.state ??= usedOrder[event.long]![cell.state];
      });
      for (int i = max(0, event.i - 2); i < board.height && i < event.i + 2; i++) {
        for (int j = max(0, event.j - 2); j < board.width && j < event.j + 2; j++) {
          _checkCellError(i, j);
        }
      }
    } else {
      final cell = board.cells[event.i][event.j];

      cell.state = usedOrder[event.long]![cell.state];
      Board.iterateOnSquare(board.cells, event.i, event.j, (Cell cell, p1, p2) {
        _checkCellError(p1, p2);
      });
    }

    emit(BoardGameState(board));
  }

  void _toggleCommands(ToggleColorsEvent event, Emitter emit) {
    controls.reversed = !controls.reversed;
    usedOrder = controls.reversed ? {true: order, false: reverseOrder} : {true: reverseOrder, false: order};
    emit(ControlsGameState(controls));
  }

  void _toggleFill(ToggleFillEvent event, Emitter emit) {
    controls.fill = !controls.fill;
    emit(ControlsGameState(controls));
  }
}

enum GameStatus {
  notStarted,
  generating,
  running,
  win,
}
