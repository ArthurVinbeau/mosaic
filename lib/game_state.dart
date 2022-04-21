part of 'game_bloc.dart';

@immutable
abstract class GameState {}

class NotStartedGameState extends GameState {}

class GeneratingBoardGameState extends GameState {
  final double? progress;

  GeneratingBoardGameState({this.progress});
}

class BoardGameState extends GameState {
  final Board board;

  BoardGameState(this.board);
}

class FinishedGameState extends BoardGameState {
  FinishedGameState(Board board) : super(board);
}

class ControlsGameState extends GameState {
  final GameControls controls;

  ControlsGameState(this.controls);
}
