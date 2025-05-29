import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mosaic/blocs/theme/theme_cubit.dart';
import 'package:mosaic/blocs/theme_creator/theme_creator_bloc.dart';
import 'package:mosaic/entities/theme_collection.dart';
import 'package:mosaic/presentation/elements/color_picker_dialog.dart';
import 'package:mosaic/presentation/elements/theme_creator_name_field.dart';
import 'package:mosaic/presentation/pages/theme_picker.dart';
import 'package:mosaic/utils/colors_ext.dart';

import '../../l10n/app_localizations.dart';
import '../elements/free_drawing.dart';

class ThemeCreator extends StatelessWidget {
  static final _board = ThemePicker.getDemoBoard();

  const ThemeCreator({Key? key}) : super(key: key);

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
      lightChild: Container(color: light),
      darkChild: Container(color: dark),
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
          color: collection.light.gameBackground,
          alignment: Alignment.center,
          child: Icon(Icons.redo, color: light),
        ),
        darkChild: Container(
          color: collection.dark.gameBackground,
          alignment: Alignment.center,
          child: Icon(Icons.undo, color: dark),
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
                    collection.light.copyWithKey(
                        colorKey,
                        outputMaterialColor
                            ? result.toMaterialColor()
                            : result),
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
                    collection.dark.copyWithKey(
                        colorKey,
                        outputMaterialColor
                            ? result.toMaterialColor()
                            : result),
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
    final brightness = context.read<ThemeCubit>().state.theme.brightness;
    final loc = AppLocalizations.of(context)!;

    return BlocConsumer<ThemeCreatorBloc, ThemeCreatorState>(
      listenWhen: (previous, current) =>
          current is ExitPageState || current is ShowExiConfirmationState,
      listener: (context, state) {
        if (state is ExitPageState) {
          Navigator.pop(context, state.returnValue);
        } else if (state is ShowExiConfirmationState) {
          final bloc = context.read<ThemeCreatorBloc>();
          showDialog(
              context: context,
              builder: (context) => AlertDialog(
                    title: Text(loc.discardChanges),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(loc.loseThemeChanges),
                        Text(loc.cannotBeUndone,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(loc.cancelDialog)),
                      FilledButton(
                          style: FilledButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.error),
                          onPressed: () {
                            bloc.add(const ConfirmExitPageEvent());
                            Navigator.pop(context);
                          },
                          child: Text(loc.confirmDialog))
                    ],
                  ));
        }
      },
      builder: ((context, state) {
        return WillPopScope(
          onWillPop: () async {
            context.read<ThemeCreatorBloc>().add(const ExitPageEvent());
            return false;
          },
          child: Scaffold(
            appBar: AppBar(
              title: const Padding(
                padding: EdgeInsets.only(left: 16.0, right: 48),
                child: ThemeCreatorNameField(),
              ),
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
                                    color:
                                        state.collection.light.gameBackground,
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
                              label: loc.themePrimaryColor,
                              collection: state.collection,
                              colorKey: 'primaryColor',
                              outputMaterialColor: true,
                            ),
                            _getColorRow(
                              context: context,
                              label: loc.themeGameBackground,
                              collection: state.collection,
                              colorKey: 'gameBackground',
                            ),
                            _getColorRow(
                              context: context,
                              label: loc.themeCellBase,
                              collection: state.collection,
                              colorKey: 'cellBase',
                            ),
                            _getColorRow(
                              context: context,
                              label: loc.themeCellTextBase,
                              collection: state.collection,
                              colorKey: 'cellTextBase',
                            ),
                            _getColorRow(
                              context: context,
                              label: loc.themeCellEmpty,
                              collection: state.collection,
                              colorKey: 'cellEmpty',
                            ),
                            _getColorRow(
                              context: context,
                              label: loc.themeCellTextEmpty,
                              collection: state.collection,
                              colorKey: 'cellTextEmpty',
                            ),
                            _getColorRow(
                              context: context,
                              label: loc.themeCellFilled,
                              collection: state.collection,
                              colorKey: 'cellFilled',
                            ),
                            _getColorRow(
                              context: context,
                              label: loc.themeCellTextFilled,
                              collection: state.collection,
                              colorKey: 'cellTextFilled',
                            ),
                            _getColorRow(
                              context: context,
                              label: loc.themeCellTextError,
                              collection: state.collection,
                              colorKey: 'cellTextError',
                            ),
                            _getColorRow(
                              context: context,
                              label: loc.themeCellTextComplete,
                              collection: state.collection,
                              colorKey: 'cellTextComplete',
                            ),
                            _getControlsRow(
                              context: context,
                              label: loc.themeControlsMoveEnabled,
                              collection: state.collection,
                              colorKey: 'controlsMoveEnabled',
                            ),
                            _getControlsRow(
                              context: context,
                              label: loc.themeControlsMoveDisabled,
                              collection: state.collection,
                              colorKey: 'controlsMoveDisabled',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                          backgroundColor: brightness == Brightness.light
                              ? state.collection.light.primaryColor
                              : state.collection.dark.primaryColor),
                      onPressed: () {
                        context
                            .read<ThemeCreatorBloc>()
                            .add(const SaveThemeEvent());
                      },
                      child: Text(loc.saveAndExit),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
