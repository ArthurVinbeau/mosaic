part of 'timer_bloc.dart';

abstract class TimerEvent extends Equatable {
  const TimerEvent();

  @override
  List<Object> get props => [];
}

class TimerStart extends TimerEvent {
  final Duration duration;

  const TimerStart({required this.duration});
}

class TimerPause extends TimerEvent {
  const TimerPause();
}

class TimerResume extends TimerEvent {
  const TimerResume();
}

class TimerReset extends TimerEvent {
  const TimerReset();
}

class TimerTick extends TimerEvent {
  final Duration duration;

  const TimerTick({required this.duration});

  @override
  List<Object> get props => [duration];
}
