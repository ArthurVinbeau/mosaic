import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../game_bloc.dart';

class NewGameWidget extends StatefulWidget {
  final int height, width;

  const NewGameWidget({Key? key, required this.height, required this.width}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _NewGameWidgetState();
}

class _NewGameWidgetState extends State<NewGameWidget> {
  final _formKey = GlobalKey<FormState>();
  late int height = widget.height, width = widget.width;

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
              Container(
                width: 120,
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  initialValue: height.toString(),
                  decoration: const InputDecoration(label: Text("Board Height")),
                  onSaved: (String? value) {
                    if (value != null) {
                      height = int.tryParse(value) ?? height;
                    }
                  },
                  validator: (String? value) {
                    int? val;
                    if (value == null || (val = int.tryParse(value)) == null || val! < 8) {
                      return "Value must be a valid number and be greater or equal to 8";
                    }
                  },
                ),
              ),
              Container(
                width: 120,
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  initialValue: width.toString(),
                  decoration: const InputDecoration(label: Text("Board Width")),
                  onSaved: (String? value) {
                    if (value != null) {
                      width = int.tryParse(value) ?? width;
                    }
                  },
                  validator: (String? value) {
                    int? val;
                    if (value == null || (val = int.tryParse(value)) == null || val! < 8) {
                      return "Value must be a valid number and be greater or equal to 8";
                    }
                  },
                ),
              ),
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
