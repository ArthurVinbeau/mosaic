import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr')
  ];

  /// The app's title
  ///
  /// In en, this message translates to:
  /// **'Mosaic'**
  String get appTitle;

  /// The text used on the Resume Game button
  ///
  /// In en, this message translates to:
  /// **'Resume game'**
  String get resumeGame;

  /// The tooltip for the restart game button
  ///
  /// In en, this message translates to:
  /// **'Restart game'**
  String get restartGame;

  /// The 'light' type of theme
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get lightTheme;

  /// The 'dart' type of theme
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get darkTheme;

  /// Use the platform theme
  ///
  /// In en, this message translates to:
  /// **'Use platform theme'**
  String get platformTheme;

  /// The title of the theme picker page
  ///
  /// In en, this message translates to:
  /// **'Theme Picker'**
  String get themePickerTitle;

  /// The theme brightness preference label
  ///
  /// In en, this message translates to:
  /// **'Theme brightness preference :'**
  String get brightnessPreference;

  /// The tutorial page's title
  ///
  /// In en, this message translates to:
  /// **'Tutorial'**
  String get tutorialTitle;

  /// Previous button
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// Next button
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// Beginner game level
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get beginnerLevel;

  /// Easy game level
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get easyLevel;

  /// Normal game level
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get normalLevel;

  /// Intermediate game level
  ///
  /// In en, this message translates to:
  /// **'Intermediate'**
  String get intermediateLevel;

  /// Challenger game level
  ///
  /// In en, this message translates to:
  /// **'Challenger'**
  String get challengerLevel;

  /// Hard game level
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get hardLevel;

  /// Extreme game level
  ///
  /// In en, this message translates to:
  /// **'Extreme'**
  String get extremeLevel;

  /// Custom game level
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get customLevel;

  /// The Board Height
  ///
  /// In en, this message translates to:
  /// **'Board Height'**
  String get boardHeight;

  /// The Board Width
  ///
  /// In en, this message translates to:
  /// **'Board Width'**
  String get boardWidth;

  /// The error message displayed when the input size is invalid
  ///
  /// In en, this message translates to:
  /// **'{label} must be a valid number and be greater or equal to {min}'**
  String boardSizeError(String label, int min);

  /// The header displayed above the difficulty picker
  ///
  /// In en, this message translates to:
  /// **'Pick a difficulty'**
  String get difficultyPickerHeader;

  /// The new game button label
  ///
  /// In en, this message translates to:
  /// **'New Game'**
  String get newGame;

  /// The text displayed when generating a new board
  ///
  /// In en, this message translates to:
  /// **'Generating a new board...'**
  String get generatingBoard;

  /// The first tutorial step
  ///
  /// In en, this message translates to:
  /// **'Fill the board by following the clues to win the game.\nEach clue represents the amount of &f;black tiles in a 3x3 square around it, including the clue\'s own tile.'**
  String get tutorialStep0;

  /// The second tutorial step
  ///
  /// In en, this message translates to:
  /// **'According to the clues, this square is composed of &e;white tiles only.\nTap on a tile to change its color, a long tap will cycle the colors in the reverse order'**
  String get tutorialStep1;

  /// The third tutorial step
  ///
  /// In en, this message translates to:
  /// **'These two tiles must be filled in &f;black.\nTap on a tile to change its color, a long tap will cycle the colors in the reverse order'**
  String get tutorialStep2;

  /// The last tutorial step
  ///
  /// In en, this message translates to:
  /// **'The ink bucket might come in handy to help you fill the board faster, using it on a tile will color all &u;unfilled tiles in a 3x3 square around your tap.'**
  String get tutorialStep3;

  /// The last tutorial step
  ///
  /// In en, this message translates to:
  /// **'Congratulations, you\'ve finished the tutorial!\nOn bigger boards you might want to pinch to zoom in and drag to move the board in order to have a better experience.'**
  String get tutorialStep4;

  /// A string to display the seconds spent in a game
  ///
  /// In en, this message translates to:
  /// **'{elapsed} seconds'**
  String elapsedSeconds(String elapsed);

  /// A string to display the minutes spent in a game, will always be paired with the elapsedSeconds string
  ///
  /// In en, this message translates to:
  /// **'{elapsed} minutes and {secondsString}'**
  String elapsedMinutes(String elapsed, String secondsString);

  /// A string to display the hours spent in a game, will always be paired with the elapsedMinutes & elapsedSeconds strings
  ///
  /// In en, this message translates to:
  /// **'{elapsed} hours, {minutesAndSecondsString}'**
  String elapsedHours(String elapsed, String minutesAndSecondsString);

  /// The statement displayed when the player wins
  ///
  /// In en, this message translates to:
  /// **'You win!'**
  String get youWin;

  /// Shows the amount of time spent and the size of the board
  ///
  /// In en, this message translates to:
  /// **'You took {elapsed} to finish this {height}x{width} board!'**
  String winDescription(String elapsed, int height, int width);

  /// Dismiss button
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismiss;

  /// Ask for a confirmation about restarting the game
  ///
  /// In en, this message translates to:
  /// **'Restart the current game?'**
  String get restartConfirmation;

  /// Additional restart information (loss of the progress)
  ///
  /// In en, this message translates to:
  /// **'You will lose your current progress'**
  String get restartConfirmationDescription;

  /// Confirm dialog option
  ///
  /// In en, this message translates to:
  /// **'yes'**
  String get confirmDialog;

  /// Deny dialog action
  ///
  /// In en, this message translates to:
  /// **'no'**
  String get denyDialog;

  /// Accept dialog option
  ///
  /// In en, this message translates to:
  /// **'ok'**
  String get acceptDialog;

  /// Cancel dialog action
  ///
  /// In en, this message translates to:
  /// **'cancel'**
  String get cancelDialog;

  /// Settings page title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// The button that leads to the theme settings
  ///
  /// In en, this message translates to:
  /// **'Theme settings'**
  String get themeSettingsButton;

  /// Locale preference picker label
  ///
  /// In en, this message translates to:
  /// **'Select your locale preference :'**
  String get localePicker;

  /// use system locale
  ///
  /// In en, this message translates to:
  /// **'Use system locale'**
  String get useSystemLocale;

  /// Game theme primary color
  ///
  /// In en, this message translates to:
  /// **'Primary color'**
  String get themePrimaryColor;

  /// Game theme Menu background color
  ///
  /// In en, this message translates to:
  /// **'Menu background'**
  String get themeMenuBackground;

  /// Game theme game background color
  ///
  /// In en, this message translates to:
  /// **'Game background'**
  String get themeGameBackground;

  /// Game theme base cell color
  ///
  /// In en, this message translates to:
  /// **'Base cell'**
  String get themeCellBase;

  /// Game theme empty cell color
  ///
  /// In en, this message translates to:
  /// **'Empty cell'**
  String get themeCellEmpty;

  /// Game theme filled cell color
  ///
  /// In en, this message translates to:
  /// **'Filled cell'**
  String get themeCellFilled;

  /// Game theme base cell text color
  ///
  /// In en, this message translates to:
  /// **'Base cell text'**
  String get themeCellTextBase;

  /// Game theme empty cell text color
  ///
  /// In en, this message translates to:
  /// **'Empty cell text'**
  String get themeCellTextEmpty;

  /// Game theme filled cell text color
  ///
  /// In en, this message translates to:
  /// **'Filled cell text'**
  String get themeCellTextFilled;

  /// Game theme cell text error color
  ///
  /// In en, this message translates to:
  /// **'Cell text error'**
  String get themeCellTextError;

  /// Game theme cell text complete color
  ///
  /// In en, this message translates to:
  /// **'Cell text complete'**
  String get themeCellTextComplete;

  /// Game theme move controls enabled color
  ///
  /// In en, this message translates to:
  /// **'Controls enabled'**
  String get themeControlsMoveEnabled;

  /// Game theme move controls disabled color
  ///
  /// In en, this message translates to:
  /// **'Controls disabled'**
  String get themeControlsMoveDisabled;

  /// Ask the user if he wants to discard all the changes made
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get discardChanges;

  /// Warn the user that the action cannot be undone
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get cannotBeUndone;

  /// Warn the user that he will lose all modifications made to the theme
  ///
  /// In en, this message translates to:
  /// **'You will lose all the modifications you made to this theme.'**
  String get loseThemeChanges;

  /// Save and exit the page
  ///
  /// In en, this message translates to:
  /// **'Save and exit'**
  String get saveAndExit;

  /// Ask the user if he wants to delete the theme
  ///
  /// In en, this message translates to:
  /// **'Delete theme?'**
  String get deleteTheme;

  /// Warn the user that he will lose all modifications made to the theme
  ///
  /// In en, this message translates to:
  /// **'This will remove {name} from your theme list.'**
  String deleteThemeBody(String name);

  /// delete button action
  ///
  /// In en, this message translates to:
  /// **'delete'**
  String get delete;

  /// Import theme dialog title
  ///
  /// In en, this message translates to:
  /// **'Import theme'**
  String get importTheme;

  /// import button action
  ///
  /// In en, this message translates to:
  /// **'import'**
  String get import;

  /// Warn the user about forbidden characters
  ///
  /// In en, this message translates to:
  /// **'You must not use any of the following characters: {characters}'**
  String forbiddenCharacters(Object characters);

  /// Warn the user when a field must not be empty
  ///
  /// In en, this message translates to:
  /// **'This field must not be empty'**
  String get mustNotBeEmpty;

  /// Copy the game seed for sharing & debugging
  ///
  /// In en, this message translates to:
  /// **'Copy game seed'**
  String get copyGameSeed;

  /// Informs the user the game seed was copied to the clipboard
  ///
  /// In en, this message translates to:
  /// **'Copied game seed to clipboard'**
  String get copiedGameSeed;

  /// import game seed button & title
  ///
  /// In en, this message translates to:
  /// **'Import game seed'**
  String get importGameSeed;

  /// game seed label
  ///
  /// In en, this message translates to:
  /// **'Game seed'**
  String get gameSeed;

  /// Informs the user the provided seed is invalid
  ///
  /// In en, this message translates to:
  /// **'Could not load invalid seed'**
  String get invalidSeedMessage;

  /// About page button
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// Extras page button
  ///
  /// In en, this message translates to:
  /// **'Extras'**
  String get extras;

  /// Loading animation picker title
  ///
  /// In en, this message translates to:
  /// **'Loading Animation'**
  String get loadingAnimation;

  /// Board size picker title
  ///
  /// In en, this message translates to:
  /// **'Board size'**
  String get boardSize;

  /// Start animation button
  ///
  /// In en, this message translates to:
  /// **'Start animation'**
  String get startAnimation;

  /// Close button
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
