part of 'app_state_bloc.dart';

@immutable
abstract class AppStateEvent {}

class AppLifecycleStateEvent extends AppStateEvent {
  final AppLifecycleState state;

  AppLifecycleStateEvent(this.state);
}

class PopRouteEvent extends AppStateEvent {}
