import 'dart:math';
import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:mosaic/blocs/game/game_bloc.dart';

import '../../entities/board.dart';
import '../../entities/cell.dart';

part 'tutorial_event.dart';

part 'tutorial_state.dart';

class TutorialBloc extends Bloc<TutorialEvent, TutorialState> {
  static const _totalSteps = 5;

  int _currentStep = 0;
  late List<_Step> _steps;

  TutorialBloc() : super(const TutorialInitial(_totalSteps)) {
    on<StartTutorialEvent>(_onStart);
    on<NextTutorialStepEvent>(_onNext);
    on<PreviousTutorialStepEvent>(_onPrevious);
    on<TutorialTilePressedEvent>(_onTilePressed);
  }

  void _onStart(StartTutorialEvent event, Emitter emit) {
    _steps = [];
    // Step 0
    var board = Board(height: 3, width: 3);
    board.cells = [
      [
        Cell(clue: 0, shown: true, value: false),
        Cell(clue: 2, shown: false, value: false),
        Cell(clue: 2, shown: true, value: true)
      ],
      [
        Cell(clue: 2, shown: false, value: false),
        Cell(clue: 5, shown: true, value: false),
        Cell(clue: 4, shown: false, value: true)
      ],
      [
        Cell(clue: 2, shown: false, value: true),
        Cell(clue: 4, shown: true, value: true),
        Cell(clue: 3, shown: true, value: true)
      ],
    ];
    _steps.add(_Step(
      board: board,
      overlay: false,
      boardCheck: false,
    ));

    // Step 1
    _steps.add(_Step(
      board: board,
      allowTap: true,
      allowLongTap: true,
      overlay: true,
      overlayExceptions: [const Offset(0, 0), const Offset(1, 0), const Offset(0, 1), const Offset(1, 1)],
    ));

    // Step 2
    board = Board(height: 3, width: 3);
    board.cells = [
      [
        Cell(clue: 0, shown: true, value: false, state: false, complete: true),
        Cell(clue: 2, shown: false, value: false, state: false),
        Cell(clue: 2, shown: true, value: true)
      ],
      [
        Cell(clue: 2, shown: false, value: false, state: false),
        Cell(clue: 5, shown: true, value: false, state: false),
        Cell(clue: 4, shown: false, value: true)
      ],
      [
        Cell(clue: 2, shown: false, value: true),
        Cell(clue: 4, shown: true, value: true),
        Cell(clue: 3, shown: true, value: true)
      ],
    ];
    _steps.add(_Step(
      board: board,
      allowTap: true,
      allowLongTap: true,
      overlay: true,
      overlayExceptions: [const Offset(2, 0), const Offset(2, 1)],
    ));

    // Step 3
    board = Board(height: 3, width: 3);
    board.cells = [
      [
        Cell(clue: 0, shown: true, value: false, state: false, complete: true),
        Cell(clue: 2, shown: false, value: false, state: false, complete: true),
        Cell(clue: 2, shown: true, value: true, state: true, complete: true)
      ],
      [
        Cell(clue: 2, shown: false, value: false, state: false),
        Cell(clue: 5, shown: true, value: false, state: false),
        Cell(clue: 4, shown: false, value: true, state: true)
      ],
      [
        Cell(clue: 2, shown: false, value: true),
        Cell(clue: 4, shown: true, value: true),
        Cell(clue: 3, shown: true, value: true)
      ],
    ];
    _steps.add(_Step(
      board: board,
      allowTap: true,
      isBucket: true,
      showPaintBucket: true,
      overlay: true,
      overlayExceptions: [const Offset(1, 1)],
    ));

    // Step 4
    board = Board(height: 3, width: 3);
    board.cells = [
      [
        Cell(clue: 0, shown: true, value: false, state: false, complete: true),
        Cell(clue: 2, shown: false, value: false, state: false, complete: true),
        Cell(clue: 2, shown: true, value: true, state: true, complete: true)
      ],
      [
        Cell(clue: 2, shown: false, value: false, state: false, complete: true),
        Cell(clue: 5, shown: true, value: false, state: false, complete: true),
        Cell(clue: 4, shown: false, value: true, state: true, complete: true)
      ],
      [
        Cell(clue: 2, shown: false, value: true, state: true, complete: true),
        Cell(clue: 4, shown: true, value: true, state: true, complete: true),
        Cell(clue: 3, shown: true, value: true, state: true, complete: true)
      ],
    ];
    _steps.add(_Step(
      board: board,
      overlay: false,
      allowTap: true,
      allowLongTap: true,
      boardCheck: false,
      canMove: true,
    ));

    _currentStep = 0;

    emit(TutorialBoardState(
        _steps.first.board,
        _currentStep,
        _totalSteps,
        _steps.first.overlay,
        _steps.first.overlayExceptions,
        _steps.first.showPaintBucket,
        _steps.first.allowTap,
        _steps.first.allowLongTap,
        _steps.first.isBucket,
        !_steps.first.boardCheck,
        _steps.first.canMove));
  }

  void _onNext(NextTutorialStepEvent event, Emitter emit) {
    if (_currentStep + 1 < _totalSteps) {
      _currentStep++;
      final step = _steps[_currentStep];
      emit(TutorialBoardState(step.board, _currentStep, _totalSteps, step.overlay, step.overlayExceptions,
          step.showPaintBucket, step.allowTap, step.allowLongTap, step.isBucket, !step.boardCheck, step.canMove));
    }
  }

  void _onPrevious(PreviousTutorialStepEvent event, Emitter emit) {
    if (_currentStep - 1 >= 0) {
      _currentStep--;
      final step = _steps[_currentStep];
      emit(TutorialBoardState(step.board, _currentStep, _totalSteps, step.overlay, step.overlayExceptions,
          step.showPaintBucket, step.allowTap, step.allowLongTap, step.isBucket, !step.boardCheck, step.canMove));
    }
  }

  void _onTilePressed(TutorialTilePressedEvent event, Emitter emit) {
    if (state is TutorialBoardState) {
      final state = this.state as TutorialBoardState;
      if ((state.allowTap && !event.long || state.allowLongTap && event.long) &&
          (!state.overlay || state.overlayExceptions.contains(Offset(event.j.toDouble(), event.i.toDouble())))) {
        final board = Board.from(state.board);
        if (state.isBucket) {
          Board.iterateOnSquare(board.cells, event.i, event.j, (Cell cell, i, j) {
            if (cell.state == null) {
              if (event.long) {
                cell.state = GameBloc.reverseOrder[cell.state];
              } else {
                cell.state = GameBloc.order[cell.state];
              }
            }
          });
          for (int i = max(0, event.i - 2); i < board.height && i < event.i + 2; i++) {
            for (int j = max(0, event.j - 2); j < board.width && j < event.j + 2; j++) {
              GameBloc.checkCellError(board, i, j);
            }
          }
        } else {
          if (event.long) {
            board.cells[event.i][event.j].state = GameBloc.reverseOrder[board.cells[event.i][event.j].state];
          } else {
            board.cells[event.i][event.j].state = GameBloc.order[board.cells[event.i][event.j].state];
          }
          Board.iterateOnSquare(board.cells, event.i, event.j, (e, i, j) => GameBloc.checkCellError(board, i, j));
        }
        bool canContinue = true;

        if (_steps[_currentStep].boardCheck && state.overlay && state.overlayExceptions.isNotEmpty) {
          for (var except in state.overlayExceptions) {
            final cell = board.cells[except.dy.floor()][except.dx.floor()];
            canContinue &= cell.state == cell.value;
          }
        }

        emit(TutorialBoardState(board, _currentStep, _totalSteps, state.overlay, state.overlayExceptions,
            state.showPaintBucket, state.allowTap, state.allowLongTap, state.isBucket, canContinue, state.canMove));
      }
    }
  }
}

class _Step {
  final Board board;
  final bool overlay;
  final List<Offset> overlayExceptions;

  final bool showPaintBucket;
  final bool allowTap;
  final bool allowLongTap;
  final bool isBucket;
  final bool boardCheck;
  final bool canMove;

  _Step(
      {required this.board,
      this.overlay = false,
      this.overlayExceptions = const [],
      this.showPaintBucket = false,
      this.allowTap = false,
      this.allowLongTap = false,
      this.isBucket = false,
      this.boardCheck = true,
      this.canMove = false});
}
