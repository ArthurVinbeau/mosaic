part of 'timer_bloc.dart';

abstract class TimerEvent extends Equatable {
  const TimerEvent();

  @override
  List<Object> get props => [];
}

class TimerStart extends TimerEvent {
  const TimerStart();
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

class TimerOffset extends TimerEvent {
  final Duration offset;

  const TimerOffset(this.offset);

  @override
  List<Object> get props => [offset];
}
