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
  final String errorMessage;

  const ThemeNameErrorState(this.errorMessage, ThemeCollection collection) : super(collection);

  @override
  List<Object> get props => [collection, errorMessage];
}
