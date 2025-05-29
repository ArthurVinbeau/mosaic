import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

class ImportSeedDialog extends StatefulWidget {
  const ImportSeedDialog({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ImportSeedDialogState();
}

class _ImportSeedDialogState extends State<ImportSeedDialog> {
  String value = "";

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(loc.importGameSeed),
      content: TextField(
        onSubmitted: (value) {
          Navigator.pop(context, value.trim());
        },
        onChanged: (value) {
          setState(() {
            this.value = value.trim();
          });
        },
        decoration: InputDecoration(
            border: const OutlineInputBorder(), labelText: loc.gameSeed),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.cancelDialog)),
        ElevatedButton(
            onPressed:
                value.isEmpty ? null : () => Navigator.pop(context, value),
            child: Text(loc.import))
      ],
    );
  }
}
