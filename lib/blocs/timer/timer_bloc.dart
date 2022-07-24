import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'timer_event.dart';

part 'timer_state.dart';

class TimerBloc extends Bloc<TimerEvent, TimerState> {
  final Stopwatch _stopwatch;
  Duration _offset;

  StreamSubscription<Duration>? _stopwatchSubscription;

  TimerBloc()
      : _stopwatch = Stopwatch(),
        _offset = Duration.zero,
        super(const TimerInitial()) {
    on<TimerStart>(_onStarted);
    on<TimerPause>(_onPaused);
    on<TimerResume>(_onResumed);
    on<TimerReset>(_onReset);
    on<TimerTick>(_onTicked);
    on<TimerOffset>(_onOffset);
  }

  Duration get elapsed => _stopwatch.elapsed + _offset;

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
    _stopwatchSubscription = Stream.periodic(const Duration(seconds: 1), (_) => _offset + _stopwatch.elapsed)
        .listen((duration) => add(TimerTick(duration: duration)));
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
    _offset = Duration.zero;
    emit(const TimerInitial());
  }

  void _onTicked(TimerTick event, Emitter<TimerState> emit) {
    emit(TimerRunning(event.duration));
  }

  void _onOffset(TimerOffset event, Emitter<TimerState> emit) {
    _offset = event.offset;
    if (state is TimerInitial) {
      emit(TimerInitial(duration: _offset));
    }
  }
}
