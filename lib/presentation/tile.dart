import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mosaic/game_bloc.dart';

class Tile extends StatelessWidget {
  final int i, j;

  final String? label;
  final bool? state;
  final double size;

  const Tile({Key? key, required this.i, required this.j, this.label, this.state, this.size = 50}) : super(key: key);

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
            ? AutoSizeText(label!,
                minFontSize: 1,
                style: TextStyle(fontSize: 200, color: (state ?? false) ? Colors.white : Colors.black),
                textAlign: TextAlign.center)
            : null,
      ),
    );
  }
}
