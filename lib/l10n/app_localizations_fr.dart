// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Mosaïque';

  @override
  String get resumeGame => 'Reprendre la partie';

  @override
  String get restartGame => 'Redémarrer la partie';

  @override
  String get lightTheme => 'Clair';

  @override
  String get darkTheme => 'Sombre';

  @override
  String get platformTheme => 'Utiliser le thème de l\'appareil';

  @override
  String get themePickerTitle => 'Choix du thème';

  @override
  String get brightnessPreference => 'Préférence de luminosité du thème :';

  @override
  String get tutorialTitle => 'Tutoriel';

  @override
  String get previous => 'Précédent';

  @override
  String get next => 'Suivant';

  @override
  String get finish => 'Terminer';

  @override
  String get beginnerLevel => 'Débutant';

  @override
  String get easyLevel => 'Facile';

  @override
  String get normalLevel => 'Normal';

  @override
  String get intermediateLevel => 'Intermédiaire';

  @override
  String get challengerLevel => 'Difficile';

  @override
  String get hardLevel => 'Très difficile';

  @override
  String get extremeLevel => 'Extrême';

  @override
  String get customLevel => 'Personnalisé';

  @override
  String get boardHeight => 'Hauteur';

  @override
  String get boardWidth => 'Largeur';

  @override
  String boardSizeError(String label, int min) {
    return 'La $label doit être un nombre valide et être supérieur ou égal à $min';
  }

  @override
  String get difficultyPickerHeader => 'Choix de la difficulté';

  @override
  String get newGame => 'Nouvelle partie';

  @override
  String get generatingBoard => 'Génération du nouveau plateau...';

  @override
  String get tutorialStep0 =>
      'Remplissez le plateau en suivant les indices pour remporter la partie.\nChaque indice représente le nombre de cases &f;noires dans un carré de 3x3 l\'entourant, y-compris la case de l\'indice.';

  @override
  String get tutorialStep1 =>
      'D\'après les indices, ce carré est uniquement composé de cases &e;blanches.\nTouchez une case pour changer sa couleur, restez appuyé utiliser un cycle inverse de couleurs.';

  @override
  String get tutorialStep2 =>
      'Ces deux cases doivent être remplies de &f;noir.\nTouchez une case pour changer sa couleur, restez appuyé utiliser un cycle inverse de couleurs.';

  @override
  String get tutorialStep3 =>
      'Le pot de peinture est pratique pour remplir le plateau plus rapidement, l\'utiliser sur une case va remplir toutes les cases &u;vides dans un carré de 3x3 autour du point d\'impact.';

  @override
  String get tutorialStep4 =>
      'Félicitations, vous avez terminé le tutoriel !\nVous pouvez pincer et pousser le plateau pour zoomer et vous déplacer ce qui peut vous aider sur de plus grands plateaux.';

  @override
  String elapsedSeconds(String elapsed) {
    return '$elapsed secondes';
  }

  @override
  String elapsedMinutes(String elapsed, String secondsString) {
    return '$elapsed minutes et $secondsString';
  }

  @override
  String elapsedHours(String elapsed, String minutesAndSecondsString) {
    return '$elapsed heures, $minutesAndSecondsString';
  }

  @override
  String get youWin => 'Vous avez gagné !';

  @override
  String winDescription(String elapsed, int height, int width) {
    return 'Vous avez pris $elapsed pour remplir ce plateau de ${height}x$width!';
  }

  @override
  String get dismiss => 'Fermer';

  @override
  String get restartConfirmation => 'Redémarrer la partie actuelle ?';

  @override
  String get restartConfirmationDescription =>
      'Vous perdrez votre progression actuelle';

  @override
  String get confirmDialog => 'oui';

  @override
  String get denyDialog => 'non';

  @override
  String get acceptDialog => 'ok';

  @override
  String get cancelDialog => 'annuler';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get themeSettingsButton => 'Paramètres des thèmes';

  @override
  String get localePicker => 'Préférence de langue :';

  @override
  String get useSystemLocale => 'Utiliser la langue de l\'appareil';

  @override
  String get themePrimaryColor => 'Couleur principale';

  @override
  String get themeMenuBackground => 'Fond du menu';

  @override
  String get themeGameBackground => 'Fond du plateau';

  @override
  String get themeCellBase => 'Case de base';

  @override
  String get themeCellEmpty => 'Case vide';

  @override
  String get themeCellFilled => 'Case remplie';

  @override
  String get themeCellTextBase => 'Texte de case de base';

  @override
  String get themeCellTextEmpty => 'Texte de case vide';

  @override
  String get themeCellTextFilled => 'Texte de case remplie';

  @override
  String get themeCellTextError => 'Texte d\'erreur';

  @override
  String get themeCellTextComplete => 'Texte de case terminée';

  @override
  String get themeControlsMoveEnabled => 'Contrôle activé';

  @override
  String get themeControlsMoveDisabled => 'Contrôle désactivé';

  @override
  String get discardChanges => 'Annuler les changements ?';

  @override
  String get cannotBeUndone => 'Cette action est définitive.';

  @override
  String get loseThemeChanges =>
      'Vous perdrez toutes les modifications apportées à ce thème';

  @override
  String get saveAndExit => 'Sauvegarder et fermer';

  @override
  String get deleteTheme => 'Supprimer le thème ?';

  @override
  String deleteThemeBody(String name) {
    return 'Cela supprimera $name de votre liste de thèmes.';
  }

  @override
  String get delete => 'supprimer';

  @override
  String get importTheme => 'Importer le thème';

  @override
  String get import => 'importer';

  @override
  String forbiddenCharacters(Object characters) {
    return 'Vous ne devez pas utiliser lez caractères suivants : $characters';
  }

  @override
  String get mustNotBeEmpty => 'Ce champ ne doit pas être vide.';

  @override
  String get copyGameSeed => 'Copier la seed';

  @override
  String get copiedGameSeed => 'La seed a été copiée dans le presse-papier.';

  @override
  String get importGameSeed => 'Importer une seed';

  @override
  String get gameSeed => 'Seed';

  @override
  String get invalidSeedMessage => 'Chargement impossible, seed invalide.';

  @override
  String get about => 'À propos';

  @override
  String get extras => 'Extras';

  @override
  String get loadingAnimation => 'Animation de chargement';

  @override
  String get boardSize => 'Taille du plateau';

  @override
  String get startAnimation => 'Lancer l\'animation';

  @override
  String get close => 'Fermer';
}
