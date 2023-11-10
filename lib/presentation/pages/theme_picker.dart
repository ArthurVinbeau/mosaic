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
import '../../entities/game_theme.dart';
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

  Widget _getExpandableThemeWidget(BuildContext context, double width, ThemeCollection collection, bool selected,
      AppLocalizations loc, ThemePickerBloc themePickerBloc, GameTheme activeTheme) {
    final theme = Theme.of(context);

    double height = width / 1.7;
    final flexUnit = height / 6;
    if (selected) {
      height += flexUnit * 2;
    } else {
      height = height * 1.1;
    }

    const double iconSize = 32;

    List<Widget> controls = [
      IconButton(
          iconSize: iconSize,
          onPressed: () => themePickerBloc.add(CopyThemeEvent(collection)),
          icon: const Icon(Icons.copy)),
    ];

    if (collection.editable) {
      controls = [
        IconButton(
            iconSize: iconSize,
            onPressed: () async {
              final result = await showDialog(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                        title: Text(loc.deleteTheme),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(loc.deleteThemeBody(collection.name)),
                            Text(loc.cannotBeUndone, style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(loc.cancelDialog)),
                          FilledButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: FilledButton.styleFrom(backgroundColor: theme.colorScheme.error),
                            child: Text(loc.delete),
                          ),
                        ],
                      ));
              if (result ?? false) {
                themePickerBloc.add(DeleteThemeEvent(collection));
              }
            },
            icon: const Icon(Icons.delete)),
        const SizedBox(width: iconSize + 16),
        ...controls,
        IconButton(
            iconSize: iconSize,
            onPressed: () => themePickerBloc.add(EditThemeEvent(collection)),
            icon: const Icon(Icons.edit)),
        IconButton(
            iconSize: iconSize,
            onPressed: () => themePickerBloc.add(ShareThemeEvent(collection)),
            icon: const Icon(Icons.share)),
      ];
    }

    return InkWell(
      onTap: () => context.read<ThemePickerBloc>().add(PickThemeEvent(collection)),
      child: AnimatedContainer(
        width: width,
        height: height,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(8.0),
        duration: const Duration(milliseconds: 500),
        color: selected ? activeTheme.primaryColor : Colors.transparent,
        child: SingleChildScrollView(
          clipBehavior: Clip.hardEdge,
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: flexUnit,
                child: Text(
                  collection.name,
                  style: theme.textTheme.titleLarge,
                ),
              ),
              SizedBox(
                height: flexUnit,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(loc.lightTheme),
                    Text(loc.darkTheme),
                  ],
                ),
              ),
              SizedBox(
                height: flexUnit * 4,
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
                            themePickerBloc.add(PickThemeEvent(collection));
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
                            themePickerBloc.add(PickThemeEvent(collection));
                            return false;
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: flexUnit,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: controls,
                ),
              ),
            ],
          ),
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

    return BlocConsumer<ThemePickerBloc, ThemePickerState>(
        listenWhen: (previous, current) => current is OpenThemeCreator,
        listener: (BuildContext context, ThemePickerState state) {
          if (state is OpenThemeCreator) {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BlocProvider<ThemeCreatorBloc>(
                    create: (context) =>
                        ThemeCreatorBloc(themeCubit: context.read<ThemeCubit>(), original: state.original),
                    child: const ThemeCreator(),
                  ),
                )).then((value) {
              if (value ?? false) {
                context.read<ThemePickerBloc>().add(const ReloadThemesEvent());
              }
            });
          }
        },
        builder: (BuildContext context, ThemePickerState state) {
          final width = MediaQuery.of(context).size.width;
          final size = min(width, 500.0);
          final themeCubit = context.read<ThemeCubit>();
          final theme = themeCubit.state.theme;
          final scrollOffset = size * state.themes.indexOf(state.selected);
          final themePickerBloc = context.read<ThemePickerBloc>();
          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Text(loc.themePickerTitle),
              actions: [
                IconButton(
                    onPressed: () async {
                      String value = "";
                      final result = await showDialog(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                                title: Text(loc.importTheme),
                                content: TextField(
                                  onChanged: (String newVal) {
                                    value = newVal.trim();
                                  },
                                ),
                                actions: [
                                  TextButton(
                                      onPressed: () => Navigator.pop(context, false), child: Text(loc.cancelDialog)),
                                  FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(loc.import)),
                                ],
                              ));
                      if (result ?? false) {
                        themePickerBloc.add(ImportThemeEvent(value));
                      }
                    },
                    icon: const Icon(Icons.file_download_outlined))
              ],
            ),
            body: ListView.builder(
              controller: ScrollController(initialScrollOffset: scrollOffset),
              itemCount: state.themes.length,
              /*gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: size * 2, childAspectRatio: 1.5, crossAxisSpacing: 8.0, mainAxisSpacing: 8.0),*/
              itemBuilder: (context, index) {
                final collection = state.themes[index];
                return _getExpandableThemeWidget(
                    context, size, collection, collection == state.selected, loc, themePickerBloc, theme);
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
                        themePickerBloc.add(PickPreferenceEvent(newValue));
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
