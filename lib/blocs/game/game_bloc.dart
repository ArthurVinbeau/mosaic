import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:mosaic/blocs/timer/timer_bloc.dart';
import 'package:mosaic/entities/board.dart';
import 'package:mosaic/entities/cell.dart';
import 'package:mosaic/entities/game_controls.dart';
import 'package:mosaic/entities/move.dart';
import 'package:mosaic/entities/move_manager.dart';
import 'package:mosaic/utils/config.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'game_event.dart';
part 'game_state.dart';

Board _generateBoard(Board board) {
  board.newGameDesc();
  return board;
}

class GameBloc extends Bloc<GameEvent, GameState> {
  static const baseHeight = 8, baseWidth = 8;

  final TimerBloc _timerBloc;

  Board? board;
  GameStatus status;
  GameControls controls;
  late MoveManager moveManager;
  int validTiles;

  static const Map<bool?, bool?> order = {true: false, false: null, null: true};
  static const Map<bool?, bool?> reverseOrder = {true: null, false: true, null: false};
  Map<bool, Map<bool?, bool?>> usedOrder = {true: reverseOrder, false: order};

  GameBloc(TimerBloc timerBloc)
      : _timerBloc = timerBloc,
        status = GameStatus.notStarted,
        controls = GameControls(false, false, false, false),
        validTiles = 0,
        super(NotStartedGameState(baseHeight, baseWidth, false)) {
    on<CreateGameEvent>(_createNewGame);
    on<ImportGameEvent>(_importGame);
    on<ShowNewGameOptionsEvent>(_showNewGameWidget);
    on<RestartGameButtonEvent>(_showRestartGameConfirmation);
    on<RestartGameEvent>(_restartGame);
    on<TilePressedGameEvent>(_tilePressed);
    on<ToggleColorsEvent>(_toggleCommands);
    on<ToggleFillEvent>(_toggleFill);
    on<UndoEvent>(_undo);
    on<RedoEvent>(_redo);
    on<GamePausedEvent>(_saveBoard);
    on<AppStartedEvent>(_checkForSave);
    on<ResumeGameEvent>(_resumeGame);
    on<ShouldRebuildEvent>(_rebuildGame);
    on<ExportSeedEvent>(_exportSeed);
  }

  void _rebuildGame(ShouldRebuildEvent event, Emitter emit) {
    if (status == GameStatus.running || status == GameStatus.win) {
      emit(NewBoardGameState(board!, controls));
    } else if (status == GameStatus.generating) {
      emit(GeneratingBoardGameState(height: board?.height, width: board?.width));
    }
  }

  Future<void> _newGame({required Emitter emit, required int height, required int width, int? seed}) async {
    _timerBloc.add(const TimerReset());
    status = GameStatus.generating;
    emit(GeneratingBoardGameState(height: height, width: width));
    board = await compute(_generateBoard, Board(height: height, width: width, seed: seed));
    status = GameStatus.running;
    validTiles = 0;
    moveManager = MoveManager();
    emit(NewBoardGameState(board!, controls));
  }

  void _createNewGame(CreateGameEvent event, Emitter emit) async {
    await _newGame(emit: emit, height: event.height, width: event.width);
  }

  void _importGame(ImportGameEvent event, Emitter emit) async {
    final list = event.seed.split(";");
    if (list.length != 3) {
      emit(ShowInvalidSeedSnackbar());
      return;
    }

    final height = int.tryParse(list[0]);
    final width = int.tryParse(list[1]);
    final seed = int.tryParse(list[2]);
    if (height == null || height < 3 || width == null || width < 3 || seed == null || seed < 0) {
      emit(ShowInvalidSeedSnackbar());
      return;
    }

    await _newGame(emit: emit, height: height, width: width, seed: seed);
  }

  void _showNewGameWidget(ShowNewGameOptionsEvent event, Emitter emit) {
    status = GameStatus.notStarted;
    emit(NotStartedGameState(board!.height, board!.width, false));
  }

  void _showRestartGameConfirmation(RestartGameButtonEvent event, Emitter emit) {
    emit(ShowRestartDialogState(confirmationEvent: RestartGameEvent(), pop: false));
  }

  void _restartGame(RestartGameEvent event, Emitter emit) {
    _timerBloc.add(const TimerReset());
    for (int i = 0; i < board!.height; i++) {
      for (int j = 0; j < board!.height; j++) {
        board!.cells[i][j].state = null;
        board!.cells[i][j].error = board!.cells[i][j].complete = false;
      }
    }
    status = GameStatus.running;
    validTiles = 0;
    moveManager = MoveManager();
    emit(NewBoardGameState(board!, controls));
  }

  static void checkCellError(Board board, int i, int j) {
    if (board.cells[i][j].clue >= 0) {
      var countF = 0, countE = 0, empty = 0;
      final countC = Board.iterateOnSquare(board.cells, i, j, (Cell e, p1, p2) {
        countF += (e.state ?? false) ? 1 : 0;
        countE += (e.state ?? true) ? 0 : 1;
        empty += e.state == null ? 1 : 0;
      });
      board.cells[i][j].error = countF > board.cells[i][j].clue || countC - countE < board.cells[i][j].clue;
      board.cells[i][j].complete = empty == 0;
    }
  }

  void _cellPressed(Cell cell, bool? newState) {
    var oldState = cell.state;
    if (oldState != newState) {
      cell.state = newState;
      validTiles += oldState == cell.value
          ? -1
          : newState == cell.value
              ? 1
              : 0;
    }
  }

  void _tilePressed(TilePressedGameEvent event, Emitter emit) {
    if (_timerBloc.state is TimerInitial) {
      _timerBloc.add(const TimerStart());
    } else if (_timerBloc.state is TimerPaused) {
      _timerBloc.add(const TimerResume());
    }

    if (controls.fill) {
      List<Move> moves = [];
      Board.iterateOnSquare(board!.cells, event.i, event.j, (Cell cell, p1, p2) {
        if (cell.state == null) {
          final newState = usedOrder[event.long]![cell.state];
          moves.add(Move(p1, p2, cell.state, newState));
          _cellPressed(cell, newState);
        }
      });
      if (moves.isNotEmpty) {
        moveManager.add(moves);
        for (int i = max(0, event.i - 2); i < board!.height && i <= event.i + 2; i++) {
          for (int j = max(0, event.j - 2); j < board!.width && j <= event.j + 2; j++) {
            checkCellError(board!, i, j);
          }
        }
      }
    } else {
      final cell = board!.cells[event.i][event.j];
      final newState = usedOrder[event.long]![cell.state];
      moveManager.add([Move(event.i, event.j, cell.state, newState)]);
      _cellPressed(cell, newState);
      Board.iterateOnSquare(board!.cells, event.i, event.j, (Cell cell, p1, p2) {
        checkCellError(board!, p1, p2);
      });
    }

    logger.i(validTiles);

    emit(BoardGameState(board!));
    if (validTiles == board!.height * board!.width) {
      _timerBloc.add(const TimerPause());
      logger.i("You win!");
      status = GameStatus.win;
      _removeSave();
      emit(ShowWinDialogState(
          elapsedTime: _timerBloc.state.toString(),
          height: board!.height,
          width: board!.width,
          confirmationEvent: ShowNewGameOptionsEvent(),
          pop: true));
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
        _cellPressed(board!.cells[move.i][move.j], move.oldState);
        Board.iterateOnSquare(board!.cells, move.i, move.j, (Cell cell, p1, p2) {
          checkCellError(board!, p1, p2);
        });
      });
      emit(BoardGameState(board!));
      _updateMoveControls(emit);
    }
  }

  void _redo(RedoEvent event, Emitter emit) {
    if (moveManager.canRedo) {
      moveManager.redo().forEach((Move move) {
        _cellPressed(board!.cells[move.i][move.j], move.newState);
        Board.iterateOnSquare(board!.cells, move.i, move.j, (Cell cell, p1, p2) {
          checkCellError(board!, p1, p2);
        });
      });
      emit(BoardGameState(board!));
      _updateMoveControls(emit);
    }
  }

  void _saveBoard(GamePausedEvent event, Emitter emit) async {
    _timerBloc.add(const TimerPause());
    if (!event.saveOnly) {
      emit(NotStartedGameState(board!.height, board!.width, true));
    }
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString("board", board.toString());
    await prefs.setString("timer", _timerBloc.elapsed.inMilliseconds.toString());
  }

  void _removeSave() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString("board", "");
    await prefs.setString("timer", "");
  }

  void _checkForSave(AppStartedEvent event, Emitter emit) async {
    emit(CheckingForSavesState());
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString("board");
    if (str != null) {
      board = Board.fromString(str);
      validTiles = 0;
      for (final row in board!.cells) {
        for (final cell in row) {
          validTiles += cell.state == cell.value ? 1 : 0;
        }
      }
      emit(NotStartedGameState(board!.height, board!.width, true));

      final timer = int.tryParse(prefs.getString("timer") ?? "");
      if (timer != null) {
        _timerBloc.add(TimerOffset(Duration(milliseconds: timer)));
      }
    } else {
      emit(NotStartedGameState(baseHeight, baseWidth, false));
    }
  }

  void _resumeGame(ResumeGameEvent event, Emitter emit) {
    status = GameStatus.running;
    moveManager = MoveManager();
    emit(GeneratingBoardGameState());
    emit(NewBoardGameState(board!, controls));
  }

  void _exportSeed(ExportSeedEvent event, Emitter emit) async {
    await Clipboard.setData(ClipboardData(text: "${board?.height};${board?.width};${board?.seed}"));
    emit(ShowCopySnackbar());
  }
}

enum GameStatus {
  notStarted,
  generating,
  running,
  win,
}
