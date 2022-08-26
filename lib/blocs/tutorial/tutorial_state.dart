part of 'tutorial_bloc.dart';

@immutable
abstract class TutorialState {
  final int currentStep;
  final int totalSteps;
  final bool canContinue;

  const TutorialState(this.currentStep, this.totalSteps, this.canContinue);
}

class TutorialInitial extends TutorialState {
  const TutorialInitial(int totalSteps) : super(0, totalSteps, false);
}

class TutorialBoardState extends TutorialState {
  final Board board;
  final bool overlay;
  final List<Offset> overlayExceptions;
  final bool showPaintBucket;
  final bool allowTap;
  final bool allowLongTap;
  final bool isBucket;
  final bool canMove;

  const TutorialBoardState(this.board, int currentStep, int totalSteps, this.overlay, this.overlayExceptions,
      this.showPaintBucket, this.allowTap, this.allowLongTap, this.isBucket, bool canContinue, this.canMove)
      : super(currentStep, totalSteps, canContinue);
}
