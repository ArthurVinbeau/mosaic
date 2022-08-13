import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mosaic/blocs/theme_picker/theme_picker_bloc.dart';
import 'package:mosaic/presentation/free_drawing.dart';
import 'package:mosaic/utils/themes.dart';

import 'entities/board.dart';

class ThemePicker extends StatelessWidget {
  const ThemePicker({Key? key}) : super(key: key);

  static final Board _board = _getBoard();

  static Board _getBoard() {
    final Board board = Board(height: 3, width: 4)..newGameDesc();

    const int hidden = 0, complete = 2, error = 3, filled = 1, empty = 2;

    for (int i = 0; i < board.height; i++) {
      for (int j = 0; j < board.width; j++) {
        final cell = board.cells[i][j];
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

  Widget _getThemeWidget(BuildContext context, double size, ThemeCollection collection, bool selected) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => context.read<ThemePickerBloc>().add(PickThemeEvent(collection)),
      child: Container(
        height: size,
        width: size * 2,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(8.0),
        color: selected
            ? (theme.colorScheme.brightness == Brightness.light ? theme.primaryColor : theme.colorScheme.secondary)
                .withOpacity(0.5)
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              collection.name,
              style: theme.textTheme.headline6,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                Text("Light"),
                Text("Dark"),
              ],
            ),
            LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
              final size = constraints.maxWidth / 2;
              return Row(
                children: [
                  Container(
                    width: size,
                    height: size / 4 * 3.125,
                    padding: const EdgeInsets.all(8.0),
                    color: collection.light.gameBackground,
                    child: FreeDrawing(
                      board: _board,
                      minScale: 1,
                      maxScale: 1,
                      theme: collection.light,
                      onTap: (i, j, long) => context.read<ThemePickerBloc>().add(PickThemeEvent(collection)),
                    ),
                  ),
                  Container(
                    width: size,
                    height: size / 4 * 3.125,
                    padding: const EdgeInsets.all(8.0),
                    color: collection.dark.gameBackground,
                    child: FreeDrawing(
                      board: _board,
                      minScale: 1,
                      maxScale: 1,
                      theme: collection.dark,
                      onTap: (i, j, long) => context.read<ThemePickerBloc>().add(PickThemeEvent(collection)),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  String _getBrightnessLabel(Brightness? brightness) {
    switch (brightness) {
      case Brightness.light:
        return "Light";
      case Brightness.dark:
        return "Dark";
      default:
        return "Use platform theme";
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemePickerBloc, ThemePickerState>(builder: (BuildContext context, ThemePickerState state) {
      final size = min(MediaQuery.of(context).size.width / 2, 250.0);
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text("Theme Picker"),
        ),
        body: GridView.builder(
          itemCount: state.themes.length * 3,
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: size * 2, childAspectRatio: 1.9, crossAxisSpacing: 8.0, mainAxisSpacing: 8.0),
          itemBuilder: (context, index) {
            final collection = state.themes[index % state.themes.length];
            return _getThemeWidget(context, size, collection, collection == state.selected);
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
                const Text("Theme brightness preference :"),
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
                            child: Text(_getBrightnessLabel(value)),
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
