import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:mosaic/entities/board.dart';
import 'package:mosaic/entities/game_controls.dart';
import 'package:mosaic/entities/move_manager.dart';
import 'package:mosaic/utils/config.dart';

import 'entities/cell.dart';
import 'entities/move.dart';

part 'game_event.dart';

part 'game_state.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  static const baseHeight = 8, baseWidth = 8;

  late Board board;
  GameStatus status;
  GameControls controls;
  late MoveManager moveManager;
  int validTiles;

  Map<bool?, bool?> order = {true: false, false: null, null: true};
  Map<bool?, bool?> reverseOrder = {true: null, false: true, null: false};
  late Map<bool, Map<bool?, bool?>> usedOrder = {true: reverseOrder, false: order};

  GameBloc()
      : status = GameStatus.notStarted,
        controls = GameControls(false, false, false, false),
        validTiles = 0,
        super(NotStartedGameState(baseHeight, baseWidth)) {
    on<NewBoardButtonPressedGameEvent>(_newGame);
    on<NewBoardDialogButtonPressedGameEvent>(_showNewGameWidget);
    on<TilePressedGameEvent>(_tilePressed);
    on<ToggleColorsEvent>(_toggleCommands);
    on<ToggleFillEvent>(_toggleFill);
    on<UndoEvent>(_undo);
    on<RedoEvent>(_redo);
  }

  void _newGame(NewBoardButtonPressedGameEvent event, Emitter emit) {
    status = GameStatus.generating;
    emit(GeneratingBoardGameState());
    board = Board(height: event.height, width: event.width);
    board.newGameDesc();
    status = GameStatus.running;
    validTiles = 0;
    moveManager = MoveManager();
    emit(BoardGameState(board));
    emit(ControlsGameState(controls));
  }

  void _showNewGameWidget(NewBoardDialogButtonPressedGameEvent event, Emitter emit) {
    emit(NotStartedGameState(board.height, board.width));
  }

  void _checkCellError(int i, int j) {
    var count = 0, empty = 0;
    Board.iterateOnSquare(board.cells, i, j, (Cell e, p1, p2) {
      count += (e.state ?? false) ? 1 : 0;
      empty += e.state == null ? 1 : 0;
    });
    board.cells[i][j].error = count > board.cells[i][j].clue || count < board.cells[i][j].clue && empty == 0;
    board.cells[i][j].complete = empty == 0;
  }

  void _cellPressed(Cell cell, bool? newState) {
    var oldState = cell.state;
    cell.state = newState;
    validTiles += (oldState == cell.value
            ? -1
            : newState == cell.value
                ? 1
                : 0) *
        (oldState != newState ? 1 : 0);
  }

  void _tilePressed(TilePressedGameEvent event, Emitter emit) {
    if (controls.fill) {
      List<Move> moves = [];
      Board.iterateOnSquare(board.cells, event.i, event.j, (Cell cell, p1, p2) {
        if (cell.state == null) {
          final newState = usedOrder[event.long]![cell.state];
          moves.add(Move(p1, p2, cell.state, newState));
          _cellPressed(cell, newState);
        }
      });
      if (moves.isNotEmpty) {
        moveManager.add(moves);
        for (int i = max(0, event.i - 2); i < board.height && i < event.i + 2; i++) {
          for (int j = max(0, event.j - 2); j < board.width && j < event.j + 2; j++) {
            _checkCellError(i, j);
          }
        }
      }
    } else {
      final cell = board.cells[event.i][event.j];
      final newState = usedOrder[event.long]![cell.state];
      moveManager.add([Move(event.i, event.j, cell.state, newState)]);
      _cellPressed(cell, newState);
      Board.iterateOnSquare(board.cells, event.i, event.j, (Cell cell, p1, p2) {
        _checkCellError(p1, p2);
      });
    }

    if (validTiles == board.height * board.width) {
      logger.i("You win!");
      status = GameStatus.win;
      emit(FinishedGameState(board));
    } else {
      emit(BoardGameState(board));
    }

    _updateMoveControls(emit);
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

  void _updateMoveControls(Emitter emit) {
    bool change = false;
    if (moveManager.canUndo != controls.canUndo) {
      controls.canUndo = moveManager.canUndo;
      change = true;
    }
    if (moveManager.canRedo != controls.canRedo) {
      controls.canRedo = moveManager.canRedo;
      change = true;
    }

    if (change) {
      emit(ControlsGameState(controls));
    }
  }

  void _undo(UndoEvent event, Emitter emit) {
    if (moveManager.canUndo) {
      moveManager.undo().forEach((Move move) {
        _cellPressed(board.cells[move.i][move.j], move.oldState);
        Board.iterateOnSquare(board.cells, move.i, move.j, (Cell cell, p1, p2) {
          _checkCellError(p1, p2);
        });
      });
      emit(BoardGameState(board));
      _updateMoveControls(emit);
    }
  }

  void _redo(RedoEvent event, Emitter emit) {
    if (moveManager.canRedo) {
      moveManager.redo().forEach((Move move) {
        _cellPressed(board.cells[move.i][move.j], move.newState);
        Board.iterateOnSquare(board.cells, move.i, move.j, (Cell cell, p1, p2) {
          _checkCellError(p1, p2);
        });
      });
      emit(BoardGameState(board));
      _updateMoveControls(emit);
    }
  }
}

enum GameStatus {
  notStarted,
  generating,
  running,
  win,
}
