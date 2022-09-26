import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mosaic/blocs/theme/theme_cubit.dart';
import 'package:mosaic/blocs/timer/timer_bloc.dart';
import 'package:mosaic/utils/themes.dart';

import '../../blocs/app_state/app_state_bloc.dart';
import '../../blocs/game/game_bloc.dart';
import '../../entities/game_controls.dart';
import '../elements/board_widget.dart';

class GamePage extends StatefulWidget {
  const GamePage({Key? key}) : super(key: key);

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> with WidgetsBindingObserver {
  late final AppStateBloc _bloc;

  Widget _getControls(BuildContext context, GameTheme theme, bool vertical) {
    return RepaintBoundary(
      child: BlocBuilder<GameBloc, GameState>(
        builder: (context, state) {
          GameControls controls;
          if (state is ControlsGameState) {
            controls = state.controls;
          } else if (state is NewBoardGameState) {
            controls = state.controls;
          } else {
            return const SizedBox();
          }
          Color filled = theme.cellFilled, empty = theme.cellEmpty;

          if (controls.reversed) {
            var tmp = filled;
            filled = empty;
            empty = tmp;
          }
          return Material(
            color: theme.gameBackground,
            child: Container(
              padding: const EdgeInsets.all(8.0),
              width: vertical ? null : double.infinity,
              height: vertical ? double.infinity : null,
              child: Wrap(
                alignment: WrapAlignment.center,
                direction: vertical ? Axis.vertical : Axis.horizontal,
                spacing: 8.0,
                children: [
                  IconButton(
                      onPressed: () => context.read<GameBloc>().add(ToggleColorsEvent()),
                      icon: Stack(
                        children: [Icon(Icons.circle, color: empty), Icon(Icons.contrast, color: filled)],
                      )),
                  Ink(
                    decoration: ShapeDecoration(shape: const CircleBorder(), color: controls.fill ? filled : null),
                    child: IconButton(
                        onPressed: () => context.read<GameBloc>().add(ToggleFillEvent()),
                        icon: Icon(Icons.format_color_fill, color: controls.fill ? empty : filled)),
                  ),
                  IconButton(
                      onPressed: controls.canUndo ? () => context.read<GameBloc>().add(UndoEvent()) : null,
                      icon: const Icon(Icons.undo),
                      color: theme.controlsMoveEnabled,
                      disabledColor: theme.controlsMoveDisabled),
                  IconButton(
                      onPressed: controls.canRedo ? () => context.read<GameBloc>().add(RedoEvent()) : null,
                      icon: const Icon(Icons.redo),
                      color: theme.controlsMoveEnabled,
                      disabledColor: theme.controlsMoveDisabled),
                ],
              ),
            ),
          );
        },
        buildWhen: (_, b) => b is ControlsGameState || b is NewBoardGameState,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(builder: (BuildContext context, ThemeState state) {
      Widget body = const RepaintBoundary(child: BoardWidget());

      final size = MediaQuery.of(context).size;

      final bool vertical = size.height <= size.width;

      if (vertical) {
        body = Row(children: [SizedBox(width: size.width - 64, child: body), _getControls(context, state.theme, true)]);
      }
      return Scaffold(
        appBar: AppBar(
          title: RepaintBoundary(
            child: BlocBuilder<TimerBloc, TimerState>(
              buildWhen: (prev, state) => prev.duration != state.duration,
              builder: (context, state) {
                return Text(state.toString());
              },
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () => context.read<GameBloc>().add(RestartGameButtonEvent()),
              icon: const Icon(Icons.refresh),
              tooltip: AppLocalizations.of(context)!.restartGame,
            )
          ],
        ),
        body: body,
        backgroundColor: state.theme.gameBackground,
        bottomSheet: vertical ? null : _getControls(context, state.theme, false),
      );
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _bloc = context.read<AppStateBloc>();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _bloc.add(PopRouteEvent());
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _bloc.add(AppLifecycleStateEvent(state));
  }

  @override
  void didChangeMetrics() {
    final size = MediaQuery.of(context).size;
    _bloc.add(MetricsChangedEvent(height: size.height, width: size.width));
  }
}
