# mosaic `1.6.1+13`

A flutter implementation of Mosaic
from [Simon Tatham's Portable Puzzle Collection](https://www.chiark.greenend.org.uk/~sgtatham/puzzles/)

- Flutter version `3.30.0`

# First steps

## Flutter

Follow the [Flutter installation instructions](https://docs.flutter.dev/get-started/install) based
on your OS.

All flutter versions are available [here](https://docs.flutter.dev/development/tools/sdk/releases)

## IDE

[Android Studio](https://developer.android.com/studio) is recommended for Android development
and [XCode](https://developer.apple.com/xcode/) for iOS, the latter one is required to compile on
iOS, but I recommend sticking to Android Studio or VSCode as your dev IDE.

## Android Studio plugins

You need to install the [Flutter plugin](https://plugins.jetbrains.com/plugin/9212-flutter)
(which will also install the [Dart plugin](https://plugins.jetbrains.com/plugin/6351-dart))

I recommend using the following plugins:

- [Rainbow Brackets](https://plugins.jetbrains.com/plugin/10080-rainbow-brackets): in flutter we
  have a lot of nesting so some coloration will help a lot!
- [Flutter Snippets](https://plugins.jetbrains.com/plugin/12348-flutter-snippets): flutter snippets,
  always nice to have.
- [Grazie](https://plugins.jetbrains.com/plugin/12175-grazie): great syntax analysis for English and
  other languages.
- [Save Actions](https://plugins.jetbrains.com/plugin/7642-save-actions): allows you to set actions
  when saving your files like code formatting or `import` optimization.
- [Bloc](https://plugins.jetbrains.com/plugin/12129-bloc): we use
  the [BLoC](https://www.didierboelens.com/2018/08/reactive-programming-streams-bloc/) design
  pattern so snippets and shortcuts come in handy.

## Project

Once Flutter installed and the project cloned, use `flutter pub get` to download and install all the
dependencies.
(This command is also available in Android Studio in the `pubspec.yaml` file)

## Run the application

Either use the builtin run function in your IDE or use `flutter run`

# App localization

> See the [official flutter doc](https://docs.flutter.dev/ui/accessibility-and-localization/internationalization) for more information

## Add a new localized message

In `${FLUTTER_PROJECT}/lib/l10n`, add a new message to the `app_en.arb` template file. For example:
```json
{
  "helloWorld": "Hello World!",
  "@helloWorld": {
    "description": "The conventional newborn programmer greeting"
  }
}
```

Then edit the other language files to provide a translation like this in the `app_fr.arb` template file:
```json
{
  "helloWorld": "Bonjour le monde!"
}
```

Finally, run this command to generate the corresponding dart files in `${FLUTTER_PROJECT}/.dart_tool/flutter_gen/gen_l10n` and use it in your code:
```sh
flutter gen-l10n
```

## Usage example

```dart
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
//  ...

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Localizations Sample App',
      localizationsDelegates: [
        AppLocalizations.delegate, // Add this line
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('en'), // English
        Locale('fr'), // French
      ],
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final AppLocalizations loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: loc.helloWorld)
    );
  }
}

```
