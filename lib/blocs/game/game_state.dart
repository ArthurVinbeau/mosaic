part of 'game_bloc.dart';

@immutable
abstract class GameState {}

class NotStartedGameState extends GameState {
  final int baseHeight, baseWidth;
  final bool canResume;

  NotStartedGameState(this.baseHeight, this.baseWidth, this.canResume);
}

class GeneratingBoardGameState extends GameState {
  final int height;
  final int width;

  GeneratingBoardGameState({int? height, int? width})
      : height = height ?? 5,
        width = width ?? 5;
}

class CheckingForSavesState extends GameState {}

class BoardGameState extends GameState {
  final Board board;

  BoardGameState(this.board);
}

class NewBoardGameState extends BoardGameState {
  final GameControls controls;

  NewBoardGameState(Board board, this.controls) : super(board);
}

class ShowDialogState extends GameState {
  final GameEvent confirmationEvent;
  final bool pop;

  ShowDialogState({required this.confirmationEvent, this.pop = false});
}

class ShowWinDialogState extends ShowDialogState {
  final String elapsedTime;
  final int height;
  final int width;

  ShowWinDialogState(
      {required GameEvent confirmationEvent,
      bool pop = false,
      required this.elapsedTime,
      required this.height,
      required this.width})
      : super(confirmationEvent: confirmationEvent, pop: pop);
}

class ShowRestartDialogState extends ShowDialogState {
  ShowRestartDialogState({required GameEvent confirmationEvent, bool pop = false})
      : super(confirmationEvent: confirmationEvent, pop: pop);
}

class ControlsGameState extends GameState {
  final GameControls controls;

  ControlsGameState(this.controls);
}
