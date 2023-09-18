import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mosaic/blocs/theme_creator/theme_creator_bloc.dart';

class ThemeCreatorNameField extends StatefulWidget {
  const ThemeCreatorNameField({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ThemeCreatorNameFieldState();
}

class _ThemeCreatorNameFieldState extends State<ThemeCreatorNameField> {
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCreatorBloc, ThemeCreatorState>(
        builder: (BuildContext context, ThemeCreatorState state) {
          controller.value = controller.value.copyWith(text: state.collection.name);
          return TextField(
            controller: controller,
            onChanged: (String value) {
              if (value.trim().isNotEmpty) {
                context.read<ThemeCreatorBloc>().add(SetThemeNameEvent(value.trim()));
              }
            },
          );
        },
        buildWhen: (previous, current) => previous.collection.name != current.collection.name);
  }
}
