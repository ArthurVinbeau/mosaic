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
        text:
            "Fill the board by following the clues to win the game.\nEach clue represents the amount of &f;black tiles in a 3x3 square around it, including the clue's own tile.",
        board: board,
        overlay: false));

    // Step 1
    _steps.add(_Step(
      text:
          "According to the clues, this square is comprised of &e;white tiles only.\nTap on a tile to change its color, a long tap will cycle the colors in the reverse order",
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
        Cell(clue: 0, shown: true, value: false, state: false),
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
      text:
          "These two tiles must be filled in &f;black.\nTap on a tile to change its color, a long tap will cycle the colors in the reverse order",
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
        Cell(clue: 0, shown: true, value: false, state: false),
        Cell(clue: 2, shown: false, value: false, state: false),
        Cell(clue: 2, shown: true, value: true, state: true)
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
      text:
          "The ink bucket might come in handy to help you fill the board faster, using it on a tile will color all &u;unfilled tiles in a 3x3 square around your tap.",
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
        Cell(clue: 0, shown: true, value: false, state: false),
        Cell(clue: 2, shown: false, value: false, state: false),
        Cell(clue: 2, shown: true, value: true, state: true)
      ],
      [
        Cell(clue: 2, shown: false, value: false, state: false),
        Cell(clue: 5, shown: true, value: false, state: false),
        Cell(clue: 4, shown: false, value: true, state: true)
      ],
      [
        Cell(clue: 2, shown: false, value: true, state: true),
        Cell(clue: 4, shown: true, value: true, state: true),
        Cell(clue: 3, shown: true, value: true, state: true)
      ],
    ];
    _steps.add(_Step(
      text:
          "Congratulations, you've finished the tutorial!\nOn bigger boards you might want to pinch to zoom in and drag to move the board in order to have a better experience.",
      board: board,
      overlay: false,
    ));

    _currentStep = 0;

    emit(TutorialBoardState(
        _steps.first.board,
        _currentStep,
        _totalSteps,
        _steps.first.overlay,
        _steps.first.overlayExceptions,
        _steps.first.text,
        _steps.first.showPaintBucket,
        _steps.first.allowTap,
        _steps.first.allowLongTap,
        _steps.first.isBucket));
  }

  void _onNext(NextTutorialStepEvent event, Emitter emit) {
    if (_currentStep + 1 < _totalSteps) {
      _currentStep++;
      final step = _steps[_currentStep];
      emit(TutorialBoardState(step.board, _currentStep, _totalSteps, step.overlay, step.overlayExceptions, step.text,
          step.showPaintBucket, step.allowTap, step.allowLongTap, step.isBucket));
    }
  }

  void _onPrevious(PreviousTutorialStepEvent event, Emitter emit) {
    if (_currentStep - 1 >= 0) {
      _currentStep--;
      final step = _steps[_currentStep];
      emit(TutorialBoardState(step.board, _currentStep, _totalSteps, step.overlay, step.overlayExceptions, step.text,
          step.showPaintBucket, step.allowTap, step.allowLongTap, step.isBucket));
    }
  }

  void _onTilePressed(TutorialTilePressedEvent event, Emitter emit) {
    if (state is TutorialBoardState) {
      final state = this.state as TutorialBoardState;
      if ((state.allowTap && !event.long || state.allowLongTap && event.long) && !state.overlay ||
          state.overlayExceptions.contains(Offset(event.j.toDouble(), event.i.toDouble()))) {
        if (state.isBucket) {
          Board.iterateOnSquare(state.board.cells, event.i, event.j, (Cell cell, i, j) {
            if (cell.state == null) {
              if (event.long) {
                cell.state = GameBloc.reverseOrder[cell.state];
              } else {
                cell.state = GameBloc.order[cell.state];
              }
            }
          });
        } else {
          if (event.long) {
            state.board.cells[event.i][event.j].state =
                GameBloc.reverseOrder[state.board.cells[event.i][event.j].state];
          } else {
            state.board.cells[event.i][event.j].state = GameBloc.order[state.board.cells[event.i][event.j].state];
          }
        }
      }
    }
  }
}

class _Step {
  final String text;
  final Board board;
  final bool overlay;
  final List<Offset> overlayExceptions;

  final bool showPaintBucket;
  final bool allowTap;
  final bool allowLongTap;
  final bool isBucket;

  _Step(
      {required this.text,
      required this.board,
      this.overlay = false,
      this.overlayExceptions = const [],
      this.showPaintBucket = false,
      this.allowTap = false,
      this.allowLongTap = false,
      this.isBucket = false});
}
