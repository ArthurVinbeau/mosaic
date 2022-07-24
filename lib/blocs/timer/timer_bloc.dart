import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'timer_event.dart';

part 'timer_state.dart';

class TimerBloc extends Bloc<TimerEvent, TimerState> {
  final Stopwatch _stopwatch;

  StreamSubscription<dynamic>? _stopwatchSubscription;

  TimerBloc()
      : _stopwatch = Stopwatch(),
        super(const TimerInitial()) {
    on<TimerStart>(_onStarted);
    on<TimerPause>(_onPaused);
    on<TimerResume>(_onResumed);
    on<TimerReset>(_onReset);
    on<TimerTick>(_onTicked);
  }

  Duration get elapsed => _stopwatch.elapsed;

  @override
  Future<void> close() {
    _stopwatchSubscription?.cancel();
    return super.close();
  }

  void _onStarted(TimerStart event, Emitter<TimerState> emit) {
    _stopwatchSubscription?.cancel();
    _stopwatch.reset();
    emit(TimerRunning(_stopwatch.elapsed));
    _stopwatch.start();
    _stopwatchSubscription =
        Stream.periodic(const Duration(seconds: 1)).listen((_) => add(TimerTick(duration: _stopwatch.elapsed)));
  }

  void _onPaused(TimerPause event, Emitter<TimerState> emit) {
    if (state is TimerRunning) {
      _stopwatch.stop();
      _stopwatchSubscription?.pause();
      emit(TimerPaused(state.duration));
    }
  }

  void _onResumed(TimerResume resume, Emitter<TimerState> emit) {
    if (state is TimerPaused) {
      _stopwatch.start();
      _stopwatchSubscription?.resume();
      emit(TimerRunning(state.duration));
    }
  }

  void _onReset(TimerReset event, Emitter<TimerState> emit) {
    _stopwatchSubscription?.cancel();
    _stopwatch.stop();
    _stopwatch.reset();
    emit(const TimerInitial());
  }

  void _onTicked(TimerTick event, Emitter<TimerState> emit) {
    emit(TimerRunning(event.duration));
  }
}
