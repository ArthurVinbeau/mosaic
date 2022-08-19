part of 'tutorial_bloc.dart';

@immutable
abstract class TutorialState {
  final int currentStep;
  final int totalSteps;

  const TutorialState(this.currentStep, this.totalSteps);
}

class TutorialInitial extends TutorialState {
  const TutorialInitial(int totalSteps) : super(0, totalSteps);
}

class TutorialBoardState extends TutorialState {
  final Board board;
  final bool overlay;
  final List<Offset> overlayExceptions;
  final String text;
  final bool showPaintBucket;
  final bool allowTap;
  final bool allowLongTap;
  final bool isBucket;

  const TutorialBoardState(this.board, int currentStep, int totalSteps, this.overlay, this.overlayExceptions, this.text,
      this.showPaintBucket, this.allowTap, this.allowLongTap, this.isBucket)
      : super(currentStep, totalSteps);
}
