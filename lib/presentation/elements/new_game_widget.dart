import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NewGameWidget extends StatefulWidget {
  /// The starting height displayed int the [TextField]
  final int height;

  /// The starting width displayed int the [TextField]
  final int width;

  /// The function called when the user has validated his input
  final void Function(int height, int width) onValidate;

  /// The title displayed above the size selection
  final String title;

  /// The text displayed on the validation button
  final String validateButtonText;

  const NewGameWidget(
      {Key? key,
      required this.height,
      required this.width,
      required this.onValidate,
      required this.title,
      required this.validateButtonText})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _NewGameWidgetState();
}

class _NewGameWidgetState extends State<NewGameWidget> {
  final _formKey = GlobalKey<FormState>();
  late int _height = options[_dropDownValue].height ?? widget.height;
  late int _width = options[_dropDownValue].width ?? widget.width;

  late final TextEditingController _heightController = TextEditingController(text: _height.toString());
  late final TextEditingController _widthController = TextEditingController(text: _width.toString());

  static const List<_GameOpts> options = [
    _GameOpts(name: "Beginner", height: 3, width: 3),
    _GameOpts(name: "Easy", height: 5, width: 5),
    _GameOpts(name: "Normal", height: 8, width: 8),
    _GameOpts(name: "Intermediate", height: 15, width: 15),
    _GameOpts(name: "Challenger", height: 25, width: 25),
    _GameOpts(name: "Hard", height: 50, width: 50),
    _GameOpts(name: "Extreme", height: 100, width: 100),
    _GameOpts(name: "Custom"),
  ];

  int _dropDownValue = 2;

  Widget _getInputWidget(
      {required BuildContext context,
      required String label,
      required String Function(String, int) errorString,
      required void Function(int? value) onSaved,
      required TextEditingController controller}) {
    final enabled = _dropDownValue == options.length - 1;
    final theme = Theme.of(context);
    return Container(
      width: 120,
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        keyboardType: TextInputType.number,
        style: enabled
            ? theme.textTheme.titleMedium
            : theme.textTheme.titleMedium?.copyWith(color: theme.textTheme.titleMedium?.color?.withOpacity(0.35)),
        decoration: InputDecoration(label: Text(label), errorMaxLines: 10),
        onSaved: (String? value) {
          if (value != null) {
            onSaved(int.tryParse(value));
          }
        },
        validator: (String? value) {
          int? val;
          if (value == null || (val = int.tryParse(value)) == null || val! < 3) {
            return errorString(label, 3);
          }
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<DropdownMenuItem<int>> opts = [];
    final loc = AppLocalizations.of(context)!;
    final difficulties = [
      loc.beginnerLevel,
      loc.easyLevel,
      loc.normalLevel,
      loc.intermediateLevel,
      loc.challengerLevel,
      loc.hardLevel,
      loc.extremeLevel,
      loc.customLevel,
    ];

    for (int i = 0; i < options.length; i++) {
      final o = options[i];
      var text = difficulties[i];
      if (o.height != null && o.width != null) {
        text += " (${o.height}x${o.width})";
      }
      opts.add(DropdownMenuItem(value: i, child: Text(text)));
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 24.0),
          child: Text(widget.title, style: Theme.of(context).textTheme.titleLarge),
        ),
        DropdownButton<int>(
          value: _dropDownValue,
          onChanged: (int? newValue) {
            if (newValue != null) {
              setState(() {
                _dropDownValue = newValue;
                _height = options[_dropDownValue].height ?? widget.height;
                _heightController.value = _heightController.value.copyWith(text: _height.toString());
                _width = options[_dropDownValue].width ?? widget.width;
                _widthController.value = _widthController.value.copyWith(text: _width.toString());
              });
            }
          },
          items: opts,
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _getInputWidget(
                  context: context,
                  label: loc.boardHeight,
                  errorString: loc.boardSizeError,
                  onSaved: (value) => _height = value ?? _height,
                  controller: _heightController,
                ),
                _getInputWidget(
                  context: context,
                  label: loc.boardWidth,
                  errorString: loc.boardSizeError,
                  onSaved: (value) => _width = value ?? _width,
                  controller: _widthController,
                ),
              ],
            ),
          ),
        ),
        ElevatedButton(
          child: Text(widget.validateButtonText),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              widget.onValidate(_height, _width);
            }
          },
        ),
      ],
    );
  }
}

class _GameOpts {
  /// Used for indicative purpose only, see l10n for real values
  final String name;
  final int? height;
  final int? width;

  const _GameOpts({
    required this.name,
    this.height,
    this.width,
  });
}
