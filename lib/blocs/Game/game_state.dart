part of 'game_bloc.dart';

@immutable
abstract class GameState {}

class NotStartedGameState extends GameState {
  final int baseHeight, baseWidth;
  final bool canResume;

  NotStartedGameState(this.baseHeight, this.baseWidth, this.canResume);
}

class GeneratingBoardGameState extends GameState {
  final double? progress;

  GeneratingBoardGameState({this.progress});
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
  final String title;
  final String confirmation;
  final String dismiss;
  final GameEvent confirmationEvent;
  final bool pop;

  ShowDialogState(
      {required this.title,
      this.confirmation = "yes",
      this.dismiss = "no",
      required this.confirmationEvent,
      this.pop = false});
}

class ControlsGameState extends GameState {
  final GameControls controls;

  ControlsGameState(this.controls);
}
