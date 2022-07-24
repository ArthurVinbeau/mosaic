import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mosaic/blocs/game/game_bloc.dart';

class NewGameWidget extends StatefulWidget {
  final int height, width;

  const NewGameWidget({Key? key, required this.height, required this.width}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _NewGameWidgetState();
}

class _NewGameWidgetState extends State<NewGameWidget> {
  final _formKey = GlobalKey<FormState>();
  late int height = widget.height, width = widget.width;

  Widget _getInputWidget(
      {required BuildContext context, required String label, required void Function(int? value) onSaved}) {
    return Container(
      width: 120,
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        keyboardType: TextInputType.number,
        initialValue: height.toString(),
        decoration: InputDecoration(label: Text("Board $label"), errorMaxLines: 10),
        onSaved: (String? value) {
          if (value != null) {
            onSaved(int.tryParse(value));
          }
        },
        validator: (String? value) {
          int? val;
          if (value == null || (val = int.tryParse(value)) == null || val! < 8) {
            return "$label must be a valid number and be greater or equal to 8";
          }
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _getInputWidget(context: context, label: "Height", onSaved: (value) => height = value ?? height),
              _getInputWidget(context: context, label: "Width", onSaved: (value) => width = value ?? width),
            ],
          ),
          ElevatedButton(
            child: const Text("New Game"),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                context.read<GameBloc>().add(CreateGameEvent(height, width));
              }
            },
          ),
        ],
      ),
    );
  }
}
