part of 'app_state_bloc.dart';

@immutable
abstract class AppStateEvent {}

class AppLifecycleStateEvent extends AppStateEvent {
  final AppLifecycleState state;

  AppLifecycleStateEvent(this.state);
}

class PopRouteEvent extends AppStateEvent {}

class MetricsChangedEvent extends AppStateEvent {
  final double height;
  final double width;

  MetricsChangedEvent({
    required this.height,
    required this.width,
  });
}
