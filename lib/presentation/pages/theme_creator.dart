import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mosaic/blocs/theme_creator/theme_creator_bloc.dart';
import 'package:mosaic/entities/theme_collection.dart';
import 'package:mosaic/presentation/elements/color_picker_dialog.dart';
import 'package:mosaic/presentation/pages/theme_picker.dart';
import 'package:mosaic/utils/colors_ext.dart';

import '../elements/free_drawing.dart';

class ThemeCreator extends StatelessWidget {
  static final _board = ThemePicker.getDemoBoard();

  const ThemeCreator({Key? key}) : super(key: key);

  Color _getBackground(Color color) => color.computeLuminance() > 0.5 ? Colors.black : Colors.white;

  Widget _getColorRow({
    required BuildContext context,
    required String label,
    required ThemeCollection collection,
    required String colorKey,
    bool outputMaterialColor = false,
  }) {
    final light = collection.light[colorKey];
    final dark = collection.dark[colorKey];

    return _getBaseRow(
      context: context,
      label: label,
      collection: collection,
      colorKey: colorKey,
      outputMaterialColor: outputMaterialColor,
      lightChild: Container(
        color: _getBackground(light),
        padding: const EdgeInsets.all(4),
        child: Container(color: light),
      ),
      darkChild: Container(
        color: _getBackground(dark),
        padding: const EdgeInsets.all(4),
        child: Container(color: dark),
      ),
    );
  }

  Widget _getControlsRow({
    required BuildContext context,
    required String label,
    required ThemeCollection collection,
    required String colorKey,
  }) {
    final light = collection.light[colorKey];
    final dark = collection.dark[colorKey];

    return _getBaseRow(
        context: context,
        label: label,
        collection: collection,
        colorKey: colorKey,
        outputMaterialColor: false,
        lightChild: Container(
          color: _getBackground(collection.light.gameBackground),
          padding: const EdgeInsets.all(4),
          child: Container(
            color: collection.light.gameBackground,
            alignment: Alignment.center,
            child: Icon(Icons.redo, color: light),
          ),
        ),
        darkChild: Container(
          color: _getBackground(collection.dark.gameBackground),
          padding: const EdgeInsets.all(4),
          child: Container(
            color: collection.dark.gameBackground,
            alignment: Alignment.center,
            child: Icon(Icons.undo, color: dark),
          ),
        ));
  }

  Widget _getBaseRow({
    required BuildContext context,
    required String label,
    required ThemeCollection collection,
    required String colorKey,
    required bool outputMaterialColor,
    required Widget lightChild,
    required Widget darkChild,
  }) {
    final light = collection.light[colorKey];
    final dark = collection.dark[colorKey];

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

              if (result != null && context.mounted) {
                context.read<ThemeCreatorBloc>().add(SetThemeColorsEvent(
                    collection.light.copyWithKey(colorKey, outputMaterialColor ? result.toMaterialColor() : result),
                    Brightness.light));
              }
            },
            child: AspectRatio(aspectRatio: 1, child: lightChild),
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

              if (result != null && context.mounted) {
                context.read<ThemeCreatorBloc>().add(SetThemeColorsEvent(
                    collection.dark.copyWithKey(colorKey, outputMaterialColor ? result.toMaterialColor() : result),
                    Brightness.dark));
              }
            },
            child: AspectRatio(
              aspectRatio: 1,
              child: darkChild,
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
                          _getColorRow(
                            context: context,
                            label: "Primary color",
                            collection: state.collection,
                            colorKey: 'primaryColor',
                            outputMaterialColor: true,
                          ),
                          _getColorRow(
                            context: context,
                            label: "Menu background",
                            collection: state.collection,
                            colorKey: 'menuBackground',
                          ),
                          _getColorRow(
                            context: context,
                            label: "Game background",
                            collection: state.collection,
                            colorKey: 'gameBackground',
                          ),
                          _getColorRow(
                            context: context,
                            label: "Cell base",
                            collection: state.collection,
                            colorKey: 'cellBase',
                          ),
                          _getColorRow(
                            context: context,
                            label: "Cell text base",
                            collection: state.collection,
                            colorKey: 'cellTextBase',
                          ),
                          _getColorRow(
                            context: context,
                            label: "Cell empty",
                            collection: state.collection,
                            colorKey: 'cellEmpty',
                          ),
                          _getColorRow(
                            context: context,
                            label: "Cell text empty",
                            collection: state.collection,
                            colorKey: 'cellTextEmpty',
                          ),
                          _getColorRow(
                            context: context,
                            label: "Cell filled",
                            collection: state.collection,
                            colorKey: 'cellFilled',
                          ),
                          _getColorRow(
                            context: context,
                            label: "Cell text filled",
                            collection: state.collection,
                            colorKey: 'cellTextFilled',
                          ),
                          _getColorRow(
                            context: context,
                            label: "Cell text error",
                            collection: state.collection,
                            colorKey: 'cellTextError',
                          ),
                          _getColorRow(
                            context: context,
                            label: "Cell text complete",
                            collection: state.collection,
                            colorKey: 'cellTextComplete',
                          ),
                          _getControlsRow(
                            context: context,
                            label: "Controls move enabled",
                            collection: state.collection,
                            colorKey: 'controlsMoveEnabled',
                          ),
                          _getControlsRow(
                            context: context,
                            label: "Controls move disabled",
                            collection: state.collection,
                            colorKey: 'controlsMoveDisabled',
                          ),
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
