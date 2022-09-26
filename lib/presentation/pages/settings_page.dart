import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';
import 'package:mosaic/blocs/theme/theme_cubit.dart';
import 'package:mosaic/presentation/pages/theme_picker.dart';

import '../../blocs/locale/locale_bloc.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(loc.settingsTitle),
            centerTitle: true,
          ),
          backgroundColor: state.theme.menuBackground,
          body: BlocBuilder<LocaleBloc, LocaleState>(
            builder: (context, state) {
              return LayoutBuilder(builder: (BuildContext context, BoxConstraints viewportConstraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: viewportConstraints.maxHeight,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: ElevatedButton(
                                onPressed: () =>
                                    Navigator.push(context, MaterialPageRoute(builder: (ctx) => const ThemePicker())),
                                child: Text(loc.themeSettingsButton)),
                          ),
                          const SizedBox(height: 32),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(loc.localePicker),
                          ),
                          DropdownSearch<int>(
                            items: List.generate(AppLocalizations.supportedLocales.length + 1, (index) => index),
                            selectedItem: state.locale == null
                                ? AppLocalizations.supportedLocales.length
                                : AppLocalizations.supportedLocales.indexOf(state.locale!),
                            itemAsString: (index) {
                              if (index < AppLocalizations.supportedLocales.length) {
                                return LocaleNamesLocalizationsDelegate
                                        .nativeLocaleNames[AppLocalizations.supportedLocales[index].toLanguageTag()]
                                    as String;
                              } else {
                                return loc.useSystemLocale;
                              }
                            },
                            popupProps: const PopupProps.dialog(
                              showSearchBox: true,
                              fit: FlexFit.loose,
                            ),
                            onChanged: (int? newValue) {
                              if (newValue != null) {
                                context.read<LocaleBloc>().add(LocalePickedEvent(
                                    newValue < AppLocalizations.supportedLocales.length
                                        ? AppLocalizations.supportedLocales[newValue]
                                        : null));
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              });
            },
          ),
        );
      },
    );
  }
}
