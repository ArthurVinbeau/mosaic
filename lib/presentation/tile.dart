import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mosaic/game_bloc.dart';

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
    return InkWell(
      onTap: () => context.read<GameBloc>().add(TilePressedGameEvent(i, j, false)),
      onLongPress: () => context.read<GameBloc>().add(TilePressedGameEvent(i, j, true)),
      child: Container(
        height: size,
        width: size,
        // alignment: Alignment.center,
        padding: const EdgeInsets.all(2.0),
        color: state == null
            ? Colors.teal
            : state!
                ? Colors.black
                : Colors.white,
        child: label != null
            ? Text(label!,
                style: TextStyle(
                    fontSize: 24,
                    color: error
                        ? Colors.red
                        : complete
                            ? Colors.grey
                            : ((state ?? false) ? Colors.white : Colors.black)),
                textAlign: TextAlign.center)
            : null,
      ),
    );
  }
}
