part of 'tutorial_bloc.dart';

@immutable
abstract class TutorialEvent {}

class StartTutorialEvent extends TutorialEvent {}

class NextTutorialStepEvent extends TutorialEvent {}

class PreviousTutorialStepEvent extends TutorialEvent {}

class TutorialTilePressedEvent extends TutorialEvent {
  final int i;
  final int j;
  final bool long;

  TutorialTilePressedEvent(this.i, this.j, this.long);
}
