import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
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
    Locale('fr'),
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In fr, this message translates to:
  /// **'ASConnexion'**
  String get appTitle;

  /// No description provided for @systemLanguage.
  ///
  /// In fr, this message translates to:
  /// **'Système'**
  String get systemLanguage;

  /// No description provided for @menu.
  ///
  /// In fr, this message translates to:
  /// **'Menu'**
  String get menu;

  /// No description provided for @menuNavigation.
  ///
  /// In fr, this message translates to:
  /// **'Navigation'**
  String get menuNavigation;

  /// No description provided for @menuMyProfile.
  ///
  /// In fr, this message translates to:
  /// **'Mon profil'**
  String get menuMyProfile;

  /// No description provided for @menuContact.
  ///
  /// In fr, this message translates to:
  /// **'Nous contacter'**
  String get menuContact;

  /// No description provided for @menuPrivacyPolicy.
  ///
  /// In fr, this message translates to:
  /// **'Politique de confidentialité'**
  String get menuPrivacyPolicy;

  /// No description provided for @menuVersion.
  ///
  /// In fr, this message translates to:
  /// **'Version'**
  String get menuVersion;

  /// No description provided for @menuContactSubject.
  ///
  /// In fr, this message translates to:
  /// **'Contact via application'**
  String get menuContactSubject;

  /// No description provided for @languageLabel.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get languageLabel;

  /// No description provided for @currentLanguage.
  ///
  /// In fr, this message translates to:
  /// **'Actuelle : {label}'**
  String currentLanguage(String label);

  /// No description provided for @cancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In fr, this message translates to:
  /// **'Valider'**
  String get confirm;

  /// No description provided for @ok.
  ///
  /// In fr, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @logoutTitle.
  ///
  /// In fr, this message translates to:
  /// **'Déconnexion'**
  String get logoutTitle;

  /// No description provided for @logoutConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Êtes-vous certain(e) de vous déconnecter de l’application ?'**
  String get logoutConfirm;

  /// No description provided for @tabCommunity.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter à la communauté'**
  String get tabCommunity;

  /// No description provided for @tabChats.
  ///
  /// In fr, this message translates to:
  /// **'Mes discussions'**
  String get tabChats;

  /// No description provided for @tabPoi.
  ///
  /// In fr, this message translates to:
  /// **'Points d’intérêts'**
  String get tabPoi;

  /// No description provided for @profileUpdated.
  ///
  /// In fr, this message translates to:
  /// **'Profil mis à jour ✅'**
  String get profileUpdated;

  /// No description provided for @loginTitle.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get loginTitle;

  /// No description provided for @loginIntro.
  ///
  /// In fr, this message translates to:
  /// **'L\'application ASConnect est à destination uniquement des aidants ayant un enfant porteur du syndrome d\'Angelman, une maladie génétique rare.'**
  String get loginIntro;

  /// No description provided for @loginButton.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get loginButton;

  /// No description provided for @loginLoading.
  ///
  /// In fr, this message translates to:
  /// **'Connexion…'**
  String get loginLoading;

  /// No description provided for @createAccount.
  ///
  /// In fr, this message translates to:
  /// **'Créer un compte'**
  String get createAccount;

  /// No description provided for @forgotPassword.
  ///
  /// In fr, this message translates to:
  /// **'Vous avez oublié votre mot de passe ?'**
  String get forgotPassword;

  /// No description provided for @emailLabel.
  ///
  /// In fr, this message translates to:
  /// **'Adresse e-mail'**
  String get emailLabel;

  /// No description provided for @emailHintRequired.
  ///
  /// In fr, this message translates to:
  /// **'Renseigne ton e-mail'**
  String get emailHintRequired;

  /// No description provided for @emailHintInvalid.
  ///
  /// In fr, this message translates to:
  /// **'E-mail invalide'**
  String get emailHintInvalid;

  /// No description provided for @passwordLabel.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get passwordLabel;

  /// No description provided for @passwordRequired.
  ///
  /// In fr, this message translates to:
  /// **'Renseigne ton mot de passe'**
  String get passwordRequired;

  /// No description provided for @show.
  ///
  /// In fr, this message translates to:
  /// **'Afficher'**
  String get show;

  /// No description provided for @hide.
  ///
  /// In fr, this message translates to:
  /// **'Masquer'**
  String get hide;

  /// No description provided for @invalidCredentials.
  ///
  /// In fr, this message translates to:
  /// **'Identifiants invalides.'**
  String get invalidCredentials;

  /// No description provided for @accessDeniedKey.
  ///
  /// In fr, this message translates to:
  /// **'Accès refusé: clé d\'application manquante ou invalide.'**
  String get accessDeniedKey;

  /// No description provided for @badRequest.
  ///
  /// In fr, this message translates to:
  /// **'Requête invalide (400).'**
  String get badRequest;

  /// No description provided for @tooManyAttempts.
  ///
  /// In fr, this message translates to:
  /// **'Trop de tentatives. Réessaie dans un instant.'**
  String get tooManyAttempts;

  /// No description provided for @serviceUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Service indisponible. Réessaie plus tard.'**
  String get serviceUnavailable;

  /// No description provided for @serverErrorWithCode.
  ///
  /// In fr, this message translates to:
  /// **'Erreur serveur ({code}).'**
  String serverErrorWithCode(Object code);

  /// No description provided for @unexpectedServerResponse.
  ///
  /// In fr, this message translates to:
  /// **'Réponse inattendue du serveur.'**
  String get unexpectedServerResponse;

  /// No description provided for @cannotConnectServer.
  ///
  /// In fr, this message translates to:
  /// **'Connexion au serveur impossible.'**
  String get cannotConnectServer;

  /// No description provided for @timeoutCheckConnection.
  ///
  /// In fr, this message translates to:
  /// **'Délai dépassé. Vérifie ta connexion.'**
  String get timeoutCheckConnection;

  /// No description provided for @errorWithMessage.
  ///
  /// In fr, this message translates to:
  /// **'Erreur: {message}'**
  String errorWithMessage(Object message);

  /// No description provided for @missingAppKeyWarning.
  ///
  /// In fr, this message translates to:
  /// **'⚠️ Clé d\'application absente. Lance l\'app avec --dart-define=PUBLIC_APP_KEY=ta_cle_publique'**
  String get missingAppKeyWarning;

  /// No description provided for @signupTitle.
  ///
  /// In fr, this message translates to:
  /// **'Créer un compte'**
  String get signupTitle;

  /// No description provided for @signupSectionPerson.
  ///
  /// In fr, this message translates to:
  /// **'Personne porteuse du SA'**
  String get signupSectionPerson;

  /// No description provided for @signupSectionAuth.
  ///
  /// In fr, this message translates to:
  /// **'Authentification'**
  String get signupSectionAuth;

  /// No description provided for @consentTitle.
  ///
  /// In fr, this message translates to:
  /// **'Consentement'**
  String get consentTitle;

  /// No description provided for @firstNameLabel.
  ///
  /// In fr, this message translates to:
  /// **'Prénom'**
  String get firstNameLabel;

  /// No description provided for @firstNameRequired.
  ///
  /// In fr, this message translates to:
  /// **'Prénom requis'**
  String get firstNameRequired;

  /// No description provided for @lastNameLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nom'**
  String get lastNameLabel;

  /// No description provided for @lastNameRequired.
  ///
  /// In fr, this message translates to:
  /// **'Nom requis'**
  String get lastNameRequired;

  /// No description provided for @birthdateLabel.
  ///
  /// In fr, this message translates to:
  /// **'Date de naissance (jj/mm/aaaa)'**
  String get birthdateLabel;

  /// No description provided for @birthdateRequired.
  ///
  /// In fr, this message translates to:
  /// **'Date de naissance requise'**
  String get birthdateRequired;

  /// No description provided for @chooseDate.
  ///
  /// In fr, this message translates to:
  /// **'Choisir une date'**
  String get chooseDate;

  /// No description provided for @signupBirthdateHelp.
  ///
  /// In fr, this message translates to:
  /// **'Date de naissance'**
  String get signupBirthdateHelp;

  /// No description provided for @genotypeLabel.
  ///
  /// In fr, this message translates to:
  /// **'Génotype'**
  String get genotypeLabel;

  /// No description provided for @genotypeRequired.
  ///
  /// In fr, this message translates to:
  /// **'Génotype requis'**
  String get genotypeRequired;

  /// No description provided for @genotypeDeletion.
  ///
  /// In fr, this message translates to:
  /// **'Délétion'**
  String get genotypeDeletion;

  /// No description provided for @genotypeMutation.
  ///
  /// In fr, this message translates to:
  /// **'Mutation'**
  String get genotypeMutation;

  /// No description provided for @genotypeUpd.
  ///
  /// In fr, this message translates to:
  /// **'UPD'**
  String get genotypeUpd;

  /// No description provided for @genotypeIcd.
  ///
  /// In fr, this message translates to:
  /// **'ICD'**
  String get genotypeIcd;

  /// No description provided for @genotypeClinical.
  ///
  /// In fr, this message translates to:
  /// **'Clinique'**
  String get genotypeClinical;

  /// No description provided for @genotypeMosaic.
  ///
  /// In fr, this message translates to:
  /// **'Mosaïque'**
  String get genotypeMosaic;

  /// No description provided for @signupPhotoHint.
  ///
  /// In fr, this message translates to:
  /// **'Photo de l’enfant (obligatoire, < 4 Mo)'**
  String get signupPhotoHint;

  /// No description provided for @importPhoto.
  ///
  /// In fr, this message translates to:
  /// **'Importer une photo'**
  String get importPhoto;

  /// No description provided for @takePhoto.
  ///
  /// In fr, this message translates to:
  /// **'Prendre une photo'**
  String get takePhoto;

  /// No description provided for @deletePhoto.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer la photo'**
  String get deletePhoto;

  /// No description provided for @signupPhotoRequired.
  ///
  /// In fr, this message translates to:
  /// **'Photo obligatoire'**
  String get signupPhotoRequired;

  /// No description provided for @signupAddPhotoToContinue.
  ///
  /// In fr, this message translates to:
  /// **'Ajoute une photo pour continuer'**
  String get signupAddPhotoToContinue;

  /// No description provided for @signupPhotoTooLarge.
  ///
  /// In fr, this message translates to:
  /// **'La photo dépasse 4 Mo ({mb} Mo).'**
  String signupPhotoTooLarge(String mb);

  /// No description provided for @signupPhotoCannotLoad.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de récupérer la photo : {message}'**
  String signupPhotoCannotLoad(String message);

  /// No description provided for @signupPasswordTooWeak.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe trop faible'**
  String get signupPasswordTooWeak;

  /// No description provided for @signupPwdRuleMin8.
  ///
  /// In fr, this message translates to:
  /// **'Min. 8 caractères'**
  String get signupPwdRuleMin8;

  /// No description provided for @signupPwdRuleUpper.
  ///
  /// In fr, this message translates to:
  /// **'1 majuscule'**
  String get signupPwdRuleUpper;

  /// No description provided for @signupPwdRuleDigit.
  ///
  /// In fr, this message translates to:
  /// **'1 chiffre'**
  String get signupPwdRuleDigit;

  /// No description provided for @signupPwdRuleSpecial.
  ///
  /// In fr, this message translates to:
  /// **'1 caractère spécial'**
  String get signupPwdRuleSpecial;

  /// No description provided for @secretQuestionLabel.
  ///
  /// In fr, this message translates to:
  /// **'Question secrète'**
  String get secretQuestionLabel;

  /// No description provided for @secretQuestionRequired.
  ///
  /// In fr, this message translates to:
  /// **'Question secrète requise'**
  String get secretQuestionRequired;

  /// No description provided for @secretQuestion1.
  ///
  /// In fr, this message translates to:
  /// **'Nom de naissance de la maman ?'**
  String get secretQuestion1;

  /// No description provided for @secretQuestion2.
  ///
  /// In fr, this message translates to:
  /// **'Nom de votre acteur de cinéma favori ?'**
  String get secretQuestion2;

  /// No description provided for @secretQuestion3.
  ///
  /// In fr, this message translates to:
  /// **'Nom de votre animal de compagnie favori ?'**
  String get secretQuestion3;

  /// No description provided for @secretAnswerLabel.
  ///
  /// In fr, this message translates to:
  /// **'Réponse'**
  String get secretAnswerLabel;

  /// No description provided for @secretAnswerRequired.
  ///
  /// In fr, this message translates to:
  /// **'Réponse requise'**
  String get secretAnswerRequired;

  /// No description provided for @consentCheckbox.
  ///
  /// In fr, this message translates to:
  /// **'J\'accepte les conditions d\'usage de mes données et je donne mon consentement.'**
  String get consentCheckbox;

  /// No description provided for @signupConsentNotGiven.
  ///
  /// In fr, this message translates to:
  /// **'Vous n\'avez pas donné votre consentement'**
  String get signupConsentNotGiven;

  /// No description provided for @signupCreating.
  ///
  /// In fr, this message translates to:
  /// **'Création…'**
  String get signupCreating;

  /// No description provided for @signupCreateBtn.
  ///
  /// In fr, this message translates to:
  /// **'Créer mon compte'**
  String get signupCreateBtn;

  /// No description provided for @signupSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Compte créé avec succès.'**
  String get signupSuccess;

  /// No description provided for @signupEmailAlreadyExistsRedirect.
  ///
  /// In fr, this message translates to:
  /// **'Votre email est déjà dans notre base. Vous allez être redirigé(e) vers la page de connexion.'**
  String get signupEmailAlreadyExistsRedirect;

  /// No description provided for @signupSelectBirthdate.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionne une date de naissance'**
  String get signupSelectBirthdate;

  /// No description provided for @signupChooseGenotype.
  ///
  /// In fr, this message translates to:
  /// **'Choisis un génotype'**
  String get signupChooseGenotype;

  /// No description provided for @signupChooseSecretQuestion.
  ///
  /// In fr, this message translates to:
  /// **'Choisis une question secrète'**
  String get signupChooseSecretQuestion;

  /// No description provided for @signupEnterSecretAnswer.
  ///
  /// In fr, this message translates to:
  /// **'Renseigne la réponse secrète'**
  String get signupEnterSecretAnswer;

  /// No description provided for @signupApiFailed.
  ///
  /// In fr, this message translates to:
  /// **'Échec API ({code}) : {body}'**
  String signupApiFailed(int code, String body);

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe oublié'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotEmailLabel.
  ///
  /// In fr, this message translates to:
  /// **'Adresse e-mail'**
  String get forgotEmailLabel;

  /// No description provided for @forgotFetchQuestionTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Récupérer la question'**
  String get forgotFetchQuestionTooltip;

  /// No description provided for @forgotEnterValidEmail.
  ///
  /// In fr, this message translates to:
  /// **'Saisis un e-mail valide.'**
  String get forgotEnterValidEmail;

  /// No description provided for @forgotUnknownEmail.
  ///
  /// In fr, this message translates to:
  /// **'E-mail inconnu.'**
  String get forgotUnknownEmail;

  /// No description provided for @forgotErrorCode.
  ///
  /// In fr, this message translates to:
  /// **'Erreur ({code})'**
  String forgotErrorCode(int code);

  /// No description provided for @forgotTimeoutRetry.
  ///
  /// In fr, this message translates to:
  /// **'Délai dépassé. Réessaie.'**
  String get forgotTimeoutRetry;

  /// No description provided for @forgotErrorWithMessage.
  ///
  /// In fr, this message translates to:
  /// **'Erreur: {message}'**
  String forgotErrorWithMessage(String message);

  /// No description provided for @forgotQuestionFallback.
  ///
  /// In fr, this message translates to:
  /// **'Question secrète'**
  String get forgotQuestionFallback;

  /// No description provided for @forgotQuestionLabel.
  ///
  /// In fr, this message translates to:
  /// **'Question'**
  String get forgotQuestionLabel;

  /// No description provided for @forgotSecretAnswerLabel.
  ///
  /// In fr, this message translates to:
  /// **'Réponse secrète'**
  String get forgotSecretAnswerLabel;

  /// No description provided for @forgotAnswerRequired.
  ///
  /// In fr, this message translates to:
  /// **'Réponse requise'**
  String get forgotAnswerRequired;

  /// No description provided for @forgotEnterYourAnswer.
  ///
  /// In fr, this message translates to:
  /// **'Saisis ta réponse.'**
  String get forgotEnterYourAnswer;

  /// No description provided for @forgotVerify.
  ///
  /// In fr, this message translates to:
  /// **'Vérifier'**
  String get forgotVerify;

  /// No description provided for @forgotAnswerCorrectSnack.
  ///
  /// In fr, this message translates to:
  /// **'Réponse correcte 👍'**
  String get forgotAnswerCorrectSnack;

  /// No description provided for @forgotAnswerIncorrectAttempts.
  ///
  /// In fr, this message translates to:
  /// **'Réponse incorrecte ({attempts}/3).'**
  String forgotAnswerIncorrectAttempts(int attempts);

  /// No description provided for @forgotFailedAttempts.
  ///
  /// In fr, this message translates to:
  /// **'Tentatives échouées : {attempts} / 3'**
  String forgotFailedAttempts(int attempts);

  /// No description provided for @forgotAnswerOkHint.
  ///
  /// In fr, this message translates to:
  /// **'✅ Réponse correcte, tu peux saisir un nouveau mot de passe.'**
  String get forgotAnswerOkHint;

  /// No description provided for @forgotNewPasswordLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau mot de passe'**
  String get forgotNewPasswordLabel;

  /// No description provided for @forgotPasswordRequired.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe requis'**
  String get forgotPasswordRequired;

  /// No description provided for @forgotPasswordTooWeak.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe trop faible'**
  String get forgotPasswordTooWeak;

  /// No description provided for @forgotPwdRuleMin8.
  ///
  /// In fr, this message translates to:
  /// **'Au moins 8 caractères'**
  String get forgotPwdRuleMin8;

  /// No description provided for @forgotPwdRuleUpper.
  ///
  /// In fr, this message translates to:
  /// **'Au moins 1 majuscule'**
  String get forgotPwdRuleUpper;

  /// No description provided for @forgotPwdRuleSpecial.
  ///
  /// In fr, this message translates to:
  /// **'Au moins 1 caractère spécial'**
  String get forgotPwdRuleSpecial;

  /// No description provided for @forgotConfirmPasswordLabel.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer le mot de passe'**
  String get forgotConfirmPasswordLabel;

  /// No description provided for @forgotEnterNewPasswordFirst.
  ///
  /// In fr, this message translates to:
  /// **'Saisis le nouveau mot de passe'**
  String get forgotEnterNewPasswordFirst;

  /// No description provided for @forgotPasswordsDoNotMatch.
  ///
  /// In fr, this message translates to:
  /// **'Les mots de passe ne correspondent pas'**
  String get forgotPasswordsDoNotMatch;

  /// No description provided for @forgotPasswordsMatch.
  ///
  /// In fr, this message translates to:
  /// **'Les mots de passe correspondent'**
  String get forgotPasswordsMatch;

  /// No description provided for @forgotResetSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe réinitialisé ✅'**
  String get forgotResetSuccess;

  /// No description provided for @forgotResetFailed.
  ///
  /// In fr, this message translates to:
  /// **'Échec ({code}).'**
  String forgotResetFailed(int code);

  /// No description provided for @tooManyAttemptsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Trop de tentatives'**
  String get tooManyAttemptsTitle;

  /// No description provided for @tooManyAttemptsMessage.
  ///
  /// In fr, this message translates to:
  /// **'Nombre d’essais dépassé.\n\nÉcrire à contact@fastfrance.org pour exposer votre problème de connexion.'**
  String get tooManyAttemptsMessage;

  /// No description provided for @forgotValidating.
  ///
  /// In fr, this message translates to:
  /// **'Validation…'**
  String get forgotValidating;

  /// No description provided for @editProfileTitle.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le profil'**
  String get editProfileTitle;

  /// No description provided for @loadingProfile.
  ///
  /// In fr, this message translates to:
  /// **'Chargement du profil…'**
  String get loadingProfile;

  /// No description provided for @timeoutLoadingProfile.
  ///
  /// In fr, this message translates to:
  /// **'Timeout en chargeant le profil.'**
  String get timeoutLoadingProfile;

  /// No description provided for @errorLoadingProfile.
  ///
  /// In fr, this message translates to:
  /// **'Erreur chargement: {message}'**
  String errorLoadingProfile(String message);

  /// No description provided for @import.
  ///
  /// In fr, this message translates to:
  /// **'Importer'**
  String get import;

  /// No description provided for @deleteMyPhoto.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer ma photo'**
  String get deleteMyPhoto;

  /// No description provided for @cancelSelection.
  ///
  /// In fr, this message translates to:
  /// **'Annuler la sélection'**
  String get cancelSelection;

  /// No description provided for @photoTooLarge.
  ///
  /// In fr, this message translates to:
  /// **'La photo dépasse 4 Mo ({size} Mo).'**
  String photoTooLarge(String size);

  /// No description provided for @cannotGetPhoto.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de récupérer la photo : {message}'**
  String cannotGetPhoto(String message);

  /// No description provided for @photoRequired.
  ///
  /// In fr, this message translates to:
  /// **'Photo obligatoire'**
  String get photoRequired;

  /// No description provided for @photoRequiredAddToSave.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez une photo pour enregistrer'**
  String get photoRequiredAddToSave;

  /// No description provided for @photoRequiredAfterDelete.
  ///
  /// In fr, this message translates to:
  /// **'Photo obligatoire : importez ou prenez une nouvelle photo.'**
  String get photoRequiredAfterDelete;

  /// No description provided for @photoDeleted.
  ///
  /// In fr, this message translates to:
  /// **'Photo supprimée ✅'**
  String get photoDeleted;

  /// No description provided for @profileInfoSection.
  ///
  /// In fr, this message translates to:
  /// **'Informations du profil'**
  String get profileInfoSection;

  /// No description provided for @firstName.
  ///
  /// In fr, this message translates to:
  /// **'Prénom'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In fr, this message translates to:
  /// **'Nom'**
  String get lastName;

  /// No description provided for @birthDateLabel.
  ///
  /// In fr, this message translates to:
  /// **'Date de naissance (jj/mm/aaaa)'**
  String get birthDateLabel;

  /// No description provided for @birthDateRequired.
  ///
  /// In fr, this message translates to:
  /// **'Date de naissance requise'**
  String get birthDateRequired;

  /// No description provided for @genotype.
  ///
  /// In fr, this message translates to:
  /// **'Génotype'**
  String get genotype;

  /// No description provided for @city.
  ///
  /// In fr, this message translates to:
  /// **'Ville'**
  String get city;

  /// No description provided for @geolocateMe.
  ///
  /// In fr, this message translates to:
  /// **'Me géolocaliser'**
  String get geolocateMe;

  /// No description provided for @locationUpdated.
  ///
  /// In fr, this message translates to:
  /// **'Localisation mise à jour'**
  String get locationUpdated;

  /// No description provided for @locationUpdatedWithCity.
  ///
  /// In fr, this message translates to:
  /// **'Localisation mise à jour ({city})'**
  String locationUpdatedWithCity(String city);

  /// No description provided for @geolocation.
  ///
  /// In fr, this message translates to:
  /// **'Géolocalisation'**
  String get geolocation;

  /// No description provided for @geolocationHint.
  ///
  /// In fr, this message translates to:
  /// **'Pensez à changer votre géolocalisation si celle-ci a changé par rapport à votre inscription.'**
  String get geolocationHint;

  /// No description provided for @secretQuestionSection.
  ///
  /// In fr, this message translates to:
  /// **'Question secrète'**
  String get secretQuestionSection;

  /// No description provided for @question.
  ///
  /// In fr, this message translates to:
  /// **'Question'**
  String get question;

  /// No description provided for @answer.
  ///
  /// In fr, this message translates to:
  /// **'Réponse'**
  String get answer;

  /// No description provided for @changeMyPassword.
  ///
  /// In fr, this message translates to:
  /// **'Changer mon mot de passe'**
  String get changeMyPassword;

  /// No description provided for @changePasswordTitle.
  ///
  /// In fr, this message translates to:
  /// **'Changer mon mot de passe'**
  String get changePasswordTitle;

  /// No description provided for @newPasswordLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau mot de passe'**
  String get newPasswordLabel;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer le mot de passe'**
  String get confirmPasswordLabel;

  /// No description provided for @passwordTooWeak.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe trop faible'**
  String get passwordTooWeak;

  /// No description provided for @enterPassword.
  ///
  /// In fr, this message translates to:
  /// **'Saisis un mot de passe'**
  String get enterPassword;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In fr, this message translates to:
  /// **'Les mots de passe ne correspondent pas'**
  String get passwordsDoNotMatch;

  /// No description provided for @passwordsMatch.
  ///
  /// In fr, this message translates to:
  /// **'Les mots de passe correspondent'**
  String get passwordsMatch;

  /// No description provided for @pwdRuleMin8.
  ///
  /// In fr, this message translates to:
  /// **'Au moins 8 caractères'**
  String get pwdRuleMin8;

  /// No description provided for @pwdRuleUpper.
  ///
  /// In fr, this message translates to:
  /// **'Au moins 1 majuscule'**
  String get pwdRuleUpper;

  /// No description provided for @pwdRuleSpecial.
  ///
  /// In fr, this message translates to:
  /// **'Au moins 1 caractère spécial'**
  String get pwdRuleSpecial;

  /// No description provided for @passwordChanged.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe changé ✅'**
  String get passwordChanged;

  /// No description provided for @save.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get save;

  /// No description provided for @saving.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrement…'**
  String get saving;

  /// No description provided for @savedChanges.
  ///
  /// In fr, this message translates to:
  /// **'Modifications enregistrées ✅'**
  String get savedChanges;

  /// No description provided for @timeoutTryAgain.
  ///
  /// In fr, this message translates to:
  /// **'Délai dépassé. Réessaie.'**
  String get timeoutTryAgain;

  /// No description provided for @failedWithCode.
  ///
  /// In fr, this message translates to:
  /// **'Échec ({code})'**
  String failedWithCode(int code);

  /// No description provided for @versionMadeByFastFrance.
  ///
  /// In fr, this message translates to:
  /// **'Cette application est réalisée par FAST France'**
  String get versionMadeByFastFrance;

  /// No description provided for @versionNumber.
  ///
  /// In fr, this message translates to:
  /// **'Version {version}'**
  String versionNumber(String version);

  /// No description provided for @privacyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Politique de confidentialité'**
  String get privacyTitle;

  /// No description provided for @privacyRightToBeForgotten.
  ///
  /// In fr, this message translates to:
  /// **'Droit à l’oubli'**
  String get privacyRightToBeForgotten;

  /// No description provided for @privacyDeleteTitle.
  ///
  /// In fr, this message translates to:
  /// **'Attention'**
  String get privacyDeleteTitle;

  /// No description provided for @privacyDeleteConfirmBody.
  ///
  /// In fr, this message translates to:
  /// **'Cette action est irréversible.\n\nVotre profil et vos données associées seront supprimés définitivement.\n\nVoulez-vous continuer ?'**
  String get privacyDeleteConfirmBody;

  /// No description provided for @privacyDeletedOkTitle.
  ///
  /// In fr, this message translates to:
  /// **'Compte supprimé'**
  String get privacyDeletedOkTitle;

  /// No description provided for @privacyDeletedOkBody.
  ///
  /// In fr, this message translates to:
  /// **'Votre compte a bien été supprimé.\nVous allez être redirigé vers la page de connexion.'**
  String get privacyDeletedOkBody;

  /// No description provided for @privacyDeleteFailedWithCode.
  ///
  /// In fr, this message translates to:
  /// **'Suppression impossible (code {code}).'**
  String privacyDeleteFailedWithCode(int code);

  /// No description provided for @timeoutRetry.
  ///
  /// In fr, this message translates to:
  /// **'Délai dépassé. Réessaie.'**
  String get timeoutRetry;

  /// No description provided for @consentText.
  ///
  /// In fr, this message translates to:
  /// **'Politique de confidentialité – Application ASConnect\n\n1) Identité du responsable de traitement\nLes données collectées dans l’application ASConnect sont traitées par FAST France, en qualité de responsable de traitement.\nPour toute question relative à vos données ou à l’exercice de vos droits, vous pouvez nous contacter à : contact@fastfrance.org.\n\n2) Finalités des traitements\nLes traitements de données réalisés via l’application poursuivent les finalités suivantes :\n• Création et gestion de votre compte utilisateur pour un accès nominatif à l’application ASConnect ;\n• Utilisation des fonctionnalités de géolocalisation afin de visualiser :\n  o des points d’intérêt liés au syndrome d’Angelman,\n  o et/ou des profils de personnes concernées, selon différents critères (distance géographique, génotype, tranche d’âge) ;\n• Amélioration du service et personnalisation de l’expérience utilisateur, incluant la possibilité pour l’utilisateur de choisir s’il souhaite ou non afficher une photo, son nom ou son prénom.\n\n3) Catégories de données collectées\nLes données suivantes peuvent être collectées :\n• Données d’identification :\n  o nom, prénom, adresse e-mail, mot de passe, photo,\n  o question et réponse secrète (en cas d’oubli du mot de passe) ;\n• Données sensibles :\n  o génotype, localisation du téléphone (géolocalisation).\nLa base légale de ces traitements repose sur le consentement explicite et éclairé de l’utilisateur.\n\n4) Durée de conservation des données\nLes données sont conservées pendant toute la durée d’utilisation du compte, puis supprimées dans un délai maximum de 12 mois après la dernière activité.\nL’utilisateur peut à tout moment exercer son droit à l’oubli directement dans l’application, via le menu :\nPolitique de confidentialité → Droit à l’oubli.\n\n5) Destinataires et hébergement des données\nLes données sont hébergées de manière sécurisée sur les serveurs de PythonAnywhere.\nLes données sont stockées dans l’Union européenne.\n(Pour plus d’informations sur la politique de protection des données de l’hébergeur, consultez https://www.pythonanywhere.com/privacy/.)\n\n6) Droits des utilisateurs\nConformément au Règlement (UE) 2016/679 (RGPD), les utilisateurs disposent des droits suivants :\n• Droit d’accès, de rectification et d’effacement (« droit à l’oubli ») — directement via leur profil ou le menu Politique de confidentialité → Droit à l’oubli ;\n• Droit d’opposition, de portabilité et de limitation du traitement ;\n• Droit de retrait du consentement à tout moment.\nPour exercer ces droits (autres que le droit à l’oubli accessible depuis l’application), vous pouvez envoyer un e-mail à contact@fastfrance.org.\n\n7) Sécurité et confidentialité\nToutes les données sont chiffrées lors du stockage et de la transmission.\nLes mots de passe sont hachés selon les bonnes pratiques de sécurité, et toutes les communications avec le service se font via le protocole HTTPS.\n\n8) Consentement explicite\nL’inscription à l’application ASConnect requiert le consentement explicite et éclairé de l’utilisateur pour les traitements décrits à la section 2.\nL’utilisateur peut retirer ce consentement à tout moment via les paramètres de son compte ou par contact direct à contact@fastfrance.org.'**
  String get consentText;
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
      <String>['en', 'es', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
