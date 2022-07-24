part of 'timer_bloc.dart';

@immutable
abstract class TimerState extends Equatable {
  final Duration duration;

  const TimerState(this.duration);

  @override
  List<Object> get props => [duration];

  @override
  String toString() {
    return duration.toString().split(".").first.padLeft(8, "0");
  }
}

class TimerInitial extends TimerState {
  const TimerInitial({Duration duration = Duration.zero}) : super(duration);
}

class TimerRunning extends TimerState {
  const TimerRunning(Duration duration) : super(duration);
}

class TimerPaused extends TimerState {
  const TimerPaused(Duration duration) : super(duration);
}
