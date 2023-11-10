import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mosaic/blocs/theme/theme_cubit.dart';
import 'package:mosaic/presentation/elements/loading_board_indicator.dart';

import '../elements/new_game_widget.dart';

class ExtrasPage extends StatelessWidget {
  const ExtrasPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return BlocBuilder<ThemeCubit, ThemeState>(builder: (BuildContext context, ThemeState state) {
      return Scaffold(
        appBar: AppBar(
          title: Text(loc.extras),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(loc.loadingAnimation, style: Theme.of(context).textTheme.headlineMedium),
              ),
              NewGameWidget(
                height: 8,
                width: 8,
                title: loc.boardSize,
                validateButtonText: loc.startAnimation,
                onValidate: (height, width) {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) => Dialog.fullscreen(
                            backgroundColor: state.theme.gameBackground,
                            child: LayoutBuilder(builder: (context, constraints) {
                              return Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: constraints.maxHeight * 0.8,
                                    width: constraints.maxWidth,
                                    child: LoadingBoardIndicator(
                                      height: height,
                                      width: width,
                                      showLoadingText: false,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: ElevatedButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text(loc.close),
                                    ),
                                  )
                                ],
                              );
                            }),
                          ));
                },
              ),
            ],
          ),
        ),
      );
    });
  }
}
