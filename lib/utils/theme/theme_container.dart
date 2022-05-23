import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mosaic/blocs/theme/theme_cubit.dart';
import 'package:mosaic/utils/theme/themes.dart';

class _InheritedThemeContainer extends InheritedWidget {
  final _GameThemeContainerState data;

  const _InheritedThemeContainer({
    Key? key,
    required this.data,
    required Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(_InheritedThemeContainer old) => old.data.theme != data.theme;
}

class GameThemeContainer extends StatefulWidget {
  final Widget child;

  const GameThemeContainer({
    Key? key,
    required this.child,
  }) : super(key: key);

  static GameTheme of(BuildContext context) {
    return (context.dependOnInheritedWidgetOfExactType<_InheritedThemeContainer>() as _InheritedThemeContainer)
        .data
        .theme;
  }

  @override
  State<GameThemeContainer> createState() => _GameThemeContainerState();
}

class _GameThemeContainerState extends State<GameThemeContainer> {
  late GameTheme theme;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        theme = state.theme;
        return _InheritedThemeContainer(data: this, child: widget.child);
      },
    );
  }
}
