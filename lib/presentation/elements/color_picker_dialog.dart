import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import '../../l10n/app_localizations.dart';

class ColorPickerDialog extends StatefulWidget {
  final Color color;

  const ColorPickerDialog({required this.color, Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<ColorPickerDialog> {
  late Color _color;

  @override
  void initState() {
    _color = widget.color;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return AlertDialog(
      title: const Text('Pick a color!'),
      content: SingleChildScrollView(
        child: ColorPicker(
          pickerColor: _color,
          enableAlpha: false,
          onColorChanged: (value) => setState(() {
            _color = value;
          }),
        ),
        // Use Material color picker:
        //
        // child: MaterialPicker(
        //   pickerColor: pickerColor,
        //   onColorChanged: changeColor,
        //   showLabel: true, // only on portrait mode
        // ),
        //
        // Use Block color picker:
        //
        // child: BlockPicker(
        //   pickerColor: currentColor,
        //   onColorChanged: changeColor,
        // ),
      ),
      actions: <Widget>[
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.cancelDialog)),
        ElevatedButton(
          child: Text(loc.acceptDialog),
          onPressed: () {
            Navigator.pop(context, _color);
          },
        ),
      ],
    );
  }
}
