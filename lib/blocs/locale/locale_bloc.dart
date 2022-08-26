import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'locale_event.dart';

part 'locale_state.dart';

class LocaleBloc extends Bloc<LocaleEvent, LocaleState> {
  Locale? _locale;
  Locale? _fallback;

  static const prefsKey = "locale";

  LocaleBloc([Locale? locale])
      : _locale = locale,
        super(LocaleState(locale)) {
    on<LocalePickedEvent>(_onPicked);
    on<LoadLocaleEvent>(_onLoad);
  }

  void _onLoad(LoadLocaleEvent event, Emitter emit) async {
    _fallback = event.fallbackLocale;
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(prefsKey);
    if (str != null) {
      _locale = AppLocalizations.supportedLocales
          .firstWhere((Locale l) => l.toLanguageTag() == str, orElse: () => _fallback!);
    }
    emit(LocaleState(_locale));
  }

  void _onPicked(LocalePickedEvent event, Emitter emit) {
    if (event.locale == null || AppLocalizations.supportedLocales.contains(event.locale)) {
      _locale = event.locale;
    } else {
      _locale = _fallback;
    }
    SharedPreferences.getInstance().then((prefs) {
      if (_locale != null) {
        prefs.setString(prefsKey, _locale!.toLanguageTag());
      } else {
        prefs.remove(prefsKey);
      }
    });
    emit(LocaleState(_locale));
  }
}
