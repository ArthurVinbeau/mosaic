// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Mosaic';

  @override
  String get resumeGame => 'Resume game';

  @override
  String get restartGame => 'Restart game';

  @override
  String get lightTheme => 'Light';

  @override
  String get darkTheme => 'Dark';

  @override
  String get platformTheme => 'Use platform theme';

  @override
  String get themePickerTitle => 'Theme Picker';

  @override
  String get brightnessPreference => 'Theme brightness preference :';

  @override
  String get tutorialTitle => 'Tutorial';

  @override
  String get previous => 'Previous';

  @override
  String get next => 'Next';

  @override
  String get finish => 'Finish';

  @override
  String get beginnerLevel => 'Beginner';

  @override
  String get easyLevel => 'Easy';

  @override
  String get normalLevel => 'Normal';

  @override
  String get intermediateLevel => 'Intermediate';

  @override
  String get challengerLevel => 'Challenger';

  @override
  String get hardLevel => 'Hard';

  @override
  String get extremeLevel => 'Extreme';

  @override
  String get customLevel => 'Custom';

  @override
  String get boardHeight => 'Board Height';

  @override
  String get boardWidth => 'Board Width';

  @override
  String boardSizeError(String label, int min) {
    return '$label must be a valid number and be greater or equal to $min';
  }

  @override
  String get difficultyPickerHeader => 'Pick a difficulty';

  @override
  String get newGame => 'New Game';

  @override
  String get generatingBoard => 'Generating a new board...';

  @override
  String get tutorialStep0 =>
      'Fill the board by following the clues to win the game.\nEach clue represents the amount of &f;black tiles in a 3x3 square around it, including the clue\'s own tile.';

  @override
  String get tutorialStep1 =>
      'According to the clues, this square is composed of &e;white tiles only.\nTap on a tile to change its color, a long tap will cycle the colors in the reverse order';

  @override
  String get tutorialStep2 =>
      'These two tiles must be filled in &f;black.\nTap on a tile to change its color, a long tap will cycle the colors in the reverse order';

  @override
  String get tutorialStep3 =>
      'The ink bucket might come in handy to help you fill the board faster, using it on a tile will color all &u;unfilled tiles in a 3x3 square around your tap.';

  @override
  String get tutorialStep4 =>
      'Congratulations, you\'ve finished the tutorial!\nOn bigger boards you might want to pinch to zoom in and drag to move the board in order to have a better experience.';

  @override
  String elapsedSeconds(String elapsed) {
    return '$elapsed seconds';
  }

  @override
  String elapsedMinutes(String elapsed, String secondsString) {
    return '$elapsed minutes and $secondsString';
  }

  @override
  String elapsedHours(String elapsed, String minutesAndSecondsString) {
    return '$elapsed hours, $minutesAndSecondsString';
  }

  @override
  String get youWin => 'You win!';

  @override
  String winDescription(String elapsed, int height, int width) {
    return 'You took $elapsed to finish this ${height}x$width board!';
  }

  @override
  String get dismiss => 'Dismiss';

  @override
  String get restartConfirmation => 'Restart the current game?';

  @override
  String get restartConfirmationDescription =>
      'You will lose your current progress';

  @override
  String get confirmDialog => 'yes';

  @override
  String get denyDialog => 'no';

  @override
  String get acceptDialog => 'ok';

  @override
  String get cancelDialog => 'cancel';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get themeSettingsButton => 'Theme settings';

  @override
  String get localePicker => 'Select your locale preference :';

  @override
  String get useSystemLocale => 'Use system locale';

  @override
  String get themePrimaryColor => 'Primary color';

  @override
  String get themeMenuBackground => 'Menu background';

  @override
  String get themeGameBackground => 'Game background';

  @override
  String get themeCellBase => 'Base cell';

  @override
  String get themeCellEmpty => 'Empty cell';

  @override
  String get themeCellFilled => 'Filled cell';

  @override
  String get themeCellTextBase => 'Base cell text';

  @override
  String get themeCellTextEmpty => 'Empty cell text';

  @override
  String get themeCellTextFilled => 'Filled cell text';

  @override
  String get themeCellTextError => 'Cell text error';

  @override
  String get themeCellTextComplete => 'Cell text complete';

  @override
  String get themeControlsMoveEnabled => 'Controls enabled';

  @override
  String get themeControlsMoveDisabled => 'Controls disabled';

  @override
  String get discardChanges => 'Discard changes?';

  @override
  String get cannotBeUndone => 'This action cannot be undone.';

  @override
  String get loseThemeChanges =>
      'You will lose all the modifications you made to this theme.';

  @override
  String get saveAndExit => 'Save and exit';

  @override
  String get deleteTheme => 'Delete theme?';

  @override
  String deleteThemeBody(String name) {
    return 'This will remove $name from your theme list.';
  }

  @override
  String get delete => 'delete';

  @override
  String get importTheme => 'Import theme';

  @override
  String get import => 'import';

  @override
  String forbiddenCharacters(Object characters) {
    return 'You must not use any of the following characters: $characters';
  }

  @override
  String get mustNotBeEmpty => 'This field must not be empty';

  @override
  String get copyGameSeed => 'Copy game seed';

  @override
  String get copiedGameSeed => 'Copied game seed to clipboard';

  @override
  String get importGameSeed => 'Import game seed';

  @override
  String get gameSeed => 'Game seed';

  @override
  String get invalidSeedMessage => 'Could not load invalid seed';

  @override
  String get about => 'About';

  @override
  String get extras => 'Extras';

  @override
  String get loadingAnimation => 'Loading Animation';

  @override
  String get boardSize => 'Board size';

  @override
  String get startAnimation => 'Start animation';

  @override
  String get close => 'Close';
}
