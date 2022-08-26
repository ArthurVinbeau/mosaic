part of 'locale_bloc.dart';

@immutable
abstract class LocaleEvent {}

class LoadLocaleEvent extends LocaleEvent {
  final Locale fallbackLocale;

  LoadLocaleEvent(this.fallbackLocale);
}

class LocalePickedEvent extends LocaleEvent {
  final Locale? locale;

  LocalePickedEvent(this.locale);
}
