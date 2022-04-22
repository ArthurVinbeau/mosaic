part of '../game_bloc.dart';

@immutable
abstract class GameEvent {}

class NewBoardButtonPressedGameEvent extends GameEvent {
  final int height, width;

  NewBoardButtonPressedGameEvent(this.height, this.width);
}

class NewBoardDialogButtonPressedGameEvent extends GameEvent {}

class NewGameButtonEvent extends GameEvent {}

class TilePressedGameEvent extends GameEvent {
  final int i, j;
  final bool long;

  TilePressedGameEvent(this.i, this.j, this.long);
}

class ToggleColorsEvent extends GameEvent {}

class ToggleFillEvent extends GameEvent {}

class UndoEvent extends GameEvent {}

class RedoEvent extends GameEvent {}
