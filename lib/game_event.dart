part of 'game_bloc.dart';

@immutable
abstract class GameEvent {}

class NewBoardButtonPressedGameEvent extends GameEvent {}

class TilePressedGameEvent extends GameEvent {
  final int i, j;
  final bool long;

  TilePressedGameEvent(this.i, this.j, this.long);
}

class ToggleColorsEvent extends GameEvent {}

class ToggleFillEvent extends GameEvent {}
