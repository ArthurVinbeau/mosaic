# mosaic `1.5.0+9`

A flutter implementation of Mosaic
from [Simon Tatham's Portable Puzzle Collection](https://www.chiark.greenend.org.uk/~sgtatham/puzzles/)

- Flutter version `3.0.5`

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