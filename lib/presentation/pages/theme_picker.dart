import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mosaic/blocs/theme_creator/theme_creator_bloc.dart';
import 'package:mosaic/blocs/theme_picker/theme_picker_bloc.dart';
import 'package:mosaic/presentation/elements/free_drawing.dart';
import 'package:mosaic/presentation/pages/theme_creator.dart';

import '../../blocs/theme/theme_cubit.dart';
import '../../entities/board.dart';
import '../../entities/theme_collection.dart';

class ThemePicker extends StatelessWidget {
  const ThemePicker({Key? key}) : super(key: key);

  static final Board _board = getDemoBoard();

  static Board getDemoBoard() {
    final Board board = Board(height: 3, width: 4)..newGameDesc();

    const int hidden = 0, complete = 2, error = 3, filled = 1, empty = 2;

    for (int i = 0; i < board.height; i++) {
      for (int j = 0; j < board.width; j++) {
        final cell = board.cells[i][j];
        cell.clue = j - 1 + i * 3;
        cell.shown = j != hidden;
        cell.complete = j == complete;
        cell.error = j == error;
        cell.state = i == filled
            ? true
            : i == empty
                ? false
                : null;
      }
    }

    return board;
  }

  Widget _getThemeWidget(
      BuildContext context, double size, ThemeCollection collection, bool selected, AppLocalizations loc) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => context.read<ThemePickerBloc>().add(PickThemeEvent(collection)),
      child: Container(
        width: size * 2,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(8.0),
        color: selected ? context.read<ThemeCubit>().state.theme.primaryColor : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              flex: 1,
              child: Text(
                collection.name,
                style: theme.textTheme.titleLarge,
              ),
            ),
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
                      color: collection.light.gameBackground,
                      child: FreeDrawing(
                        board: _board,
                        minScale: 1,
                        maxScale: 1,
                        theme: collection.light,
                        onTap: (i, j, long) {
                          context.read<ThemePickerBloc>().add(PickThemeEvent(collection));
                          return false;
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      color: collection.dark.gameBackground,
                      child: FreeDrawing(
                        board: _board,
                        minScale: 1,
                        maxScale: 1,
                        theme: collection.dark,
                        onTap: (i, j, long) {
                          context.read<ThemePickerBloc>().add(PickThemeEvent(collection));
                          return false;
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getBrightnessLabel(Brightness? brightness, AppLocalizations loc) {
    switch (brightness) {
      case Brightness.light:
        return loc.lightTheme;
      case Brightness.dark:
        return loc.darkTheme;
      default:
        return loc.platformTheme;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return BlocBuilder<ThemePickerBloc, ThemePickerState>(builder: (BuildContext context, ThemePickerState state) {
      final size = min(MediaQuery.of(context).size.width / 2, 250.0);
      final themeCubit = context.read<ThemeCubit>();
      final theme = themeCubit.state.theme;
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(loc.themePickerTitle),
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BlocProvider<ThemeCreatorBloc>(
                          create: (context) => ThemeCreatorBloc(themeCubit: themeCubit),
                          child: const ThemeCreator(),
                        ),
                      ));
                },
                icon: const Icon(Icons.add))
          ],
        ),
        backgroundColor: theme.menuBackground,
        body: GridView.builder(
          itemCount: state.themes.length,
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: size * 2, childAspectRatio: 1.9, crossAxisSpacing: 8.0, mainAxisSpacing: 8.0),
          itemBuilder: (context, index) {
            final collection = state.themes[index];
            return _getThemeWidget(context, size, collection, collection == state.selected, loc);
          },
        ),
        bottomNavigationBar: Material(
          elevation: 8,
          child: Container(
            height: 100,
            width: double.infinity,
            padding: const EdgeInsets.all(8.0),
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(loc.brightnessPreference),
                DropdownButton<Brightness?>(
                  value: state.brightness,
                  onChanged: (Brightness? newValue) {
                    context.read<ThemePickerBloc>().add(PickPreferenceEvent(newValue));
                  },
                  alignment: Alignment.center,
                  items: <Brightness?>[null, Brightness.light, Brightness.dark]
                      .map<DropdownMenuItem<Brightness?>>((Brightness? value) => DropdownMenuItem<Brightness?>(
                            value: value,
                            alignment: Alignment.center,
                            child: Text(_getBrightnessLabel(value, loc)),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
