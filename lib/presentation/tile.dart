import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mosaic/blocs/game/game_bloc.dart';

import '../utils/theme/theme_container.dart';

class Tile extends StatelessWidget {
  final int i, j;

  final String? label;
  final bool? state;
  final double size;
  final bool error;
  final bool complete;

  const Tile(
      {Key? key,
      required this.i,
      required this.j,
      this.label,
      this.state,
      this.size = 50,
      this.error = false,
      this.complete = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = GameThemeContainer.of(context);
    return InkWell(
      onTap: () => context.read<GameBloc>().add(TilePressedGameEvent(i, j, false)),
      onLongPress: () => context.read<GameBloc>().add(TilePressedGameEvent(i, j, true)),
      child: Container(
        height: size,
        width: size,
        // alignment: Alignment.center,
        padding: const EdgeInsets.all(2.0),
        color: state == null
            ? theme.cellBase
            : state!
                ? theme.cellFilled
                : theme.cellEmpty,
        child: label != null
            ? Text(label!,
                style: TextStyle(
                    fontSize: 24,
                    color: error
                        ? theme.cellTextError
                        : complete
                            ? theme.cellTextComplete
                            : state == null
                                ? theme.cellTextBase
                                : state!
                                    ? theme.cellTextFilled
                                    : theme.cellTextEmpty),
                textAlign: TextAlign.center)
            : null,
      ),
    );
  }
}
