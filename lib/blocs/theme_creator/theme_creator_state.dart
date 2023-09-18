part of 'theme_creator_bloc.dart';

abstract class ThemeCreatorState extends Equatable {
  final ThemeCollection collection;

  const ThemeCreatorState(this.collection);

  @override
  List<Object> get props => [collection];
}

class ThemeCreatorInitial extends ThemeCreatorState {
  const ThemeCreatorInitial(ThemeCollection collection) : super(collection);
}

class ThemeNameErrorState extends ThemeCreatorState {
  final ThemeCreatorNameError error;

  const ThemeNameErrorState(this.error, ThemeCollection collection) : super(collection);

  @override
  List<Object> get props => [collection, error];
}

class ShowExiConfirmationState extends ThemeCreatorState {
  const ShowExiConfirmationState(ThemeCollection collection) : super(collection);
}

class ExitPageState extends ThemeCreatorState {
  final bool returnValue;

  const ExitPageState(this.returnValue, ThemeCollection collection) : super(collection);

  @override
  List<Object> get props => [collection, returnValue];
}
