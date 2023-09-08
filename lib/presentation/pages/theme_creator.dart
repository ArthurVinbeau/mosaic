import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mosaic/blocs/theme_creator/theme_creator_bloc.dart';
import 'package:mosaic/presentation/pages/color_picker_dialog.dart';
import 'package:mosaic/presentation/pages/theme_picker.dart';

import '../elements/free_drawing.dart';

class ThemeCreator extends StatelessWidget {
  static final _board = ThemePicker.getDemoBoard();

  const ThemeCreator({Key? key}) : super(key: key);

  Widget _getRow(BuildContext context, String label, Color light, Color dark,
      void Function(Brightness brightness, Color color) onColorPick) {
    final loc = AppLocalizations.of(context)!;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          flex: 1,
          child: InkWell(
            onTap: () async {
              final Color? result = await showDialog(
                context: context,
                builder: (context) => ColorPickerDialog(color: light),
              );

              if (result != null) {
                onColorPick(Brightness.light, result);
              }
            },
            child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                color: Colors.black,
                padding: const EdgeInsets.all(4),
                child: Container(color: light),
              ),
            ),
          ),
        ),
        Expanded(
            flex: 2,
            child: Text(
              label,
              textAlign: TextAlign.center,
            )),
        Flexible(
          flex: 1,
          child: InkWell(
            onTap: () async {
              final Color? result = await showDialog(
                context: context,
                builder: (context) => ColorPickerDialog(color: dark),
              );

              if (result != null) {
                onColorPick(Brightness.dark, result);
              }
            },
            child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(4),
                child: Container(color: dark),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCreatorBloc, ThemeCreatorState>(
      builder: ((context, state) {
        final theme = Theme.of(context);
        final loc = AppLocalizations.of(context)!;

        return Scaffold(
          appBar: AppBar(
            title: Text(state.collection.name),
            centerTitle: true,
          ),
          body: Container(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(8.0),
                  child: AspectRatio(
                    aspectRatio: 2,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          flex: 1,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text(loc.lightTheme),
                              Text(loc.darkTheme),
                            ],
                          ),
                        ),
                        Flexible(
                          flex: 4,
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(8.0),
                                  color: state.collection.light.gameBackground,
                                  child: FreeDrawing(
                                    board: _board,
                                    minScale: 1,
                                    maxScale: 1,
                                    theme: state.collection.light,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(8.0),
                                  color: state.collection.dark.gameBackground,
                                  child: FreeDrawing(
                                    board: _board,
                                    minScale: 1,
                                    maxScale: 1,
                                    theme: state.collection.dark,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _getRow(
                              context,
                              "Menu background",
                              state.collection.light.menuBackground,
                              state.collection.dark.menuBackground,
                              (brightness, color) => context.read<ThemeCreatorBloc>().add(SetThemeColorsEvent(
                                  state.collection.light.copyWith(menuBackground: color), brightness))),
                          _getRow(
                              context,
                              "Game background",
                              state.collection.light.gameBackground,
                              state.collection.dark.gameBackground,
                              (brightness, color) => context.read<ThemeCreatorBloc>().add(SetThemeColorsEvent(
                                  state.collection.light.copyWith(gameBackground: color), brightness))),
                          _getRow(
                              context,
                              "Cell base",
                              state.collection.light.cellBase,
                              state.collection.dark.cellBase,
                              (brightness, color) => context.read<ThemeCreatorBloc>().add(
                                  SetThemeColorsEvent(state.collection.light.copyWith(cellBase: color), brightness))),
                          _getRow(
                              context,
                              "Cell text base",
                              state.collection.light.cellTextBase,
                              state.collection.dark.cellTextBase,
                              (brightness, color) => context.read<ThemeCreatorBloc>().add(SetThemeColorsEvent(
                                  state.collection.light.copyWith(cellTextBase: color), brightness))),
                          _getRow(
                              context,
                              "Cell empty",
                              state.collection.light.cellEmpty,
                              state.collection.dark.cellEmpty,
                              (brightness, color) => context.read<ThemeCreatorBloc>().add(
                                  SetThemeColorsEvent(state.collection.light.copyWith(cellEmpty: color), brightness))),
                          _getRow(
                              context,
                              "Cell text empty",
                              state.collection.light.cellTextEmpty,
                              state.collection.dark.cellTextEmpty,
                              (brightness, color) => context.read<ThemeCreatorBloc>().add(SetThemeColorsEvent(
                                  state.collection.light.copyWith(cellTextEmpty: color), brightness))),
                          _getRow(
                              context,
                              "Cell filled",
                              state.collection.light.cellFilled,
                              state.collection.dark.cellFilled,
                              (brightness, color) => context.read<ThemeCreatorBloc>().add(
                                  SetThemeColorsEvent(state.collection.light.copyWith(cellFilled: color), brightness))),
                          _getRow(
                              context,
                              "Cell text filled",
                              state.collection.light.cellTextFilled,
                              state.collection.dark.cellTextFilled,
                              (brightness, color) => context.read<ThemeCreatorBloc>().add(SetThemeColorsEvent(
                                  state.collection.light.copyWith(cellTextFilled: color), brightness))),
                          _getRow(
                              context,
                              "Cell text error",
                              state.collection.light.cellTextError,
                              state.collection.dark.cellTextError,
                              (brightness, color) => context.read<ThemeCreatorBloc>().add(SetThemeColorsEvent(
                                  state.collection.light.copyWith(cellTextError: color), brightness))),
                          _getRow(
                              context,
                              "Cell text complete",
                              state.collection.light.cellTextComplete,
                              state.collection.dark.cellTextComplete,
                              (brightness, color) => context.read<ThemeCreatorBloc>().add(SetThemeColorsEvent(
                                  state.collection.light.copyWith(cellTextComplete: color), brightness))),
                          _getRow(
                              context,
                              "Controls move enabled",
                              state.collection.light.controlsMoveEnabled,
                              state.collection.dark.controlsMoveEnabled,
                              (brightness, color) => context.read<ThemeCreatorBloc>().add(SetThemeColorsEvent(
                                  state.collection.light.copyWith(controlsMoveEnabled: color), brightness))),
                          _getRow(
                              context,
                              "Controls move disabled",
                              state.collection.light.controlsMoveDisabled,
                              state.collection.dark.controlsMoveDisabled,
                              (brightness, color) => context.read<ThemeCreatorBloc>().add(SetThemeColorsEvent(
                                  state.collection.light.copyWith(controlsMoveDisabled: color), brightness))),
                        ],
                      ),
                    ),

                    /*
        primaryColor,
        controlsMoveEnabled,
        controlsMoveDisabled,
         */
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
