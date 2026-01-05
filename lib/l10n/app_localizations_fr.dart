// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'ASConnexion';

  @override
  String get systemLanguage => 'Système';

  @override
  String get menu => 'Menu';

  @override
  String get menuNavigation => 'Navigation';

  @override
  String get menuMyProfile => 'Mon profil';

  @override
  String get menuContact => 'Nous contacter';

  @override
  String get menuPrivacyPolicy => 'Politique de confidentialité';

  @override
  String get menuVersion => 'Version';

  @override
  String get menuContactSubject => 'Contact via application';

  @override
  String get languageLabel => 'Langue';

  @override
  String currentLanguage(String label) {
    return 'Actuelle : $label';
  }

  @override
  String get cancel => 'Annuler';

  @override
  String get confirm => 'Valider';

  @override
  String get ok => 'OK';

  @override
  String get logoutTitle => 'Déconnexion';

  @override
  String get logoutConfirm =>
      'Êtes-vous certain(e) de vous déconnecter de l’application ?';

  @override
  String get tabCommunity => 'Se connecter à la communauté';

  @override
  String get tabChats => 'Mes discussions';

  @override
  String get tabPoi => 'Points d’intérêts';

  @override
  String get profileUpdated => 'Profil mis à jour ✅';

  @override
  String get loginTitle => 'Se connecter';

  @override
  String get loginIntro =>
      'L\'application ASConnect est à destination uniquement des aidants ayant un enfant porteur du syndrome d\'Angelman, une maladie génétique rare.';

  @override
  String get loginButton => 'Se connecter';

  @override
  String get loginLoading => 'Connexion…';

  @override
  String get createAccount => 'Créer un compte';

  @override
  String get forgotPassword => 'Vous avez oublié votre mot de passe ?';

  @override
  String get emailLabel => 'Adresse e-mail';

  @override
  String get emailHintRequired => 'Renseigne ton e-mail';

  @override
  String get emailHintInvalid => 'E-mail invalide';

  @override
  String get passwordLabel => 'Mot de passe';

  @override
  String get passwordRequired => 'Renseigne ton mot de passe';

  @override
  String get show => 'Afficher';

  @override
  String get hide => 'Masquer';

  @override
  String get invalidCredentials => 'Identifiants invalides.';

  @override
  String get accessDeniedKey =>
      'Accès refusé: clé d\'application manquante ou invalide.';

  @override
  String get badRequest => 'Requête invalide (400).';

  @override
  String get tooManyAttempts => 'Trop de tentatives. Réessaie dans un instant.';

  @override
  String get serviceUnavailable => 'Service indisponible. Réessaie plus tard.';

  @override
  String serverErrorWithCode(Object code) {
    return 'Erreur serveur ($code).';
  }

  @override
  String get unexpectedServerResponse => 'Réponse inattendue du serveur.';

  @override
  String get cannotConnectServer => 'Connexion au serveur impossible.';

  @override
  String get timeoutCheckConnection => 'Délai dépassé. Vérifie ta connexion.';

  @override
  String errorWithMessage(Object message) {
    return 'Erreur: $message';
  }

  @override
  String get missingAppKeyWarning =>
      '⚠️ Clé d\'application absente. Lance l\'app avec --dart-define=PUBLIC_APP_KEY=ta_cle_publique';

  @override
  String get signupTitle => 'Créer un compte';

  @override
  String get signupSectionPerson => 'Personne porteuse du SA';

  @override
  String get signupSectionAuth => 'Authentification';

  @override
  String get consentTitle => 'Consentement';

  @override
  String get firstNameLabel => 'Prénom';

  @override
  String get firstNameRequired => 'Prénom requis';

  @override
  String get lastNameLabel => 'Nom';

  @override
  String get lastNameRequired => 'Nom requis';

  @override
  String get birthdateLabel => 'Date de naissance (jj/mm/aaaa)';

  @override
  String get birthdateRequired => 'Date de naissance requise';

  @override
  String get chooseDate => 'Choisir une date';

  @override
  String get signupBirthdateHelp => 'Date de naissance';

  @override
  String get genotypeLabel => 'Génotype';

  @override
  String get genotypeRequired => 'Génotype requis';

  @override
  String get genotypeDeletion => 'Délétion';

  @override
  String get genotypeMutation => 'Mutation';

  @override
  String get genotypeUpd => 'UPD';

  @override
  String get genotypeIcd => 'ICD';

  @override
  String get genotypeClinical => 'Clinique';

  @override
  String get genotypeMosaic => 'Mosaïque';

  @override
  String get signupPhotoHint => 'Photo de l’enfant (obligatoire, < 4 Mo)';

  @override
  String get importPhoto => 'Importer une photo';

  @override
  String get takePhoto => 'Prendre une photo';

  @override
  String get deletePhoto => 'Supprimer la photo';

  @override
  String get signupPhotoRequired => 'Photo obligatoire';

  @override
  String get signupAddPhotoToContinue => 'Ajoute une photo pour continuer';

  @override
  String signupPhotoTooLarge(String mb) {
    return 'La photo dépasse 4 Mo ($mb Mo).';
  }

  @override
  String signupPhotoCannotLoad(String message) {
    return 'Impossible de récupérer la photo : $message';
  }

  @override
  String get signupPasswordTooWeak => 'Mot de passe trop faible';

  @override
  String get signupPwdRuleMin8 => 'Min. 8 caractères';

  @override
  String get signupPwdRuleUpper => '1 majuscule';

  @override
  String get signupPwdRuleDigit => '1 chiffre';

  @override
  String get signupPwdRuleSpecial => '1 caractère spécial';

  @override
  String get secretQuestionLabel => 'Question secrète';

  @override
  String get secretQuestionRequired => 'Question secrète requise';

  @override
  String get secretQuestion1 => 'Nom de naissance de la maman ?';

  @override
  String get secretQuestion2 => 'Nom de votre acteur de cinéma favori ?';

  @override
  String get secretQuestion3 => 'Nom de votre animal de compagnie favori ?';

  @override
  String get secretAnswerLabel => 'Réponse';

  @override
  String get secretAnswerRequired => 'Réponse requise';

  @override
  String get consentCheckbox =>
      'J\'accepte les conditions d\'usage de mes données et je donne mon consentement.';

  @override
  String get signupConsentNotGiven =>
      'Vous n\'avez pas donné votre consentement';

  @override
  String get signupCreating => 'Création…';

  @override
  String get signupCreateBtn => 'Créer mon compte';

  @override
  String get signupSuccess => 'Compte créé avec succès.';

  @override
  String get signupEmailAlreadyExistsRedirect =>
      'Votre email est déjà dans notre base. Vous allez être redirigé(e) vers la page de connexion.';

  @override
  String get signupSelectBirthdate => 'Sélectionne une date de naissance';

  @override
  String get signupChooseGenotype => 'Choisis un génotype';

  @override
  String get signupChooseSecretQuestion => 'Choisis une question secrète';

  @override
  String get signupEnterSecretAnswer => 'Renseigne la réponse secrète';

  @override
  String signupApiFailed(int code, String body) {
    return 'Échec API ($code) : $body';
  }

  @override
  String get forgotPasswordTitle => 'Mot de passe oublié';

  @override
  String get forgotEmailLabel => 'Adresse e-mail';

  @override
  String get forgotFetchQuestionTooltip => 'Récupérer la question';

  @override
  String get forgotEnterValidEmail => 'Saisis un e-mail valide.';

  @override
  String get forgotUnknownEmail => 'E-mail inconnu.';

  @override
  String forgotErrorCode(int code) {
    return 'Erreur ($code)';
  }

  @override
  String get forgotTimeoutRetry => 'Délai dépassé. Réessaie.';

  @override
  String forgotErrorWithMessage(String message) {
    return 'Erreur: $message';
  }

  @override
  String get forgotQuestionFallback => 'Question secrète';

  @override
  String get forgotQuestionLabel => 'Question';

  @override
  String get forgotSecretAnswerLabel => 'Réponse secrète';

  @override
  String get forgotAnswerRequired => 'Réponse requise';

  @override
  String get forgotEnterYourAnswer => 'Saisis ta réponse.';

  @override
  String get forgotVerify => 'Vérifier';

  @override
  String get forgotAnswerCorrectSnack => 'Réponse correcte 👍';

  @override
  String forgotAnswerIncorrectAttempts(int attempts) {
    return 'Réponse incorrecte ($attempts/3).';
  }

  @override
  String forgotFailedAttempts(int attempts) {
    return 'Tentatives échouées : $attempts / 3';
  }

  @override
  String get forgotAnswerOkHint =>
      '✅ Réponse correcte, tu peux saisir un nouveau mot de passe.';

  @override
  String get forgotNewPasswordLabel => 'Nouveau mot de passe';

  @override
  String get forgotPasswordRequired => 'Mot de passe requis';

  @override
  String get forgotPasswordTooWeak => 'Mot de passe trop faible';

  @override
  String get forgotPwdRuleMin8 => 'Au moins 8 caractères';

  @override
  String get forgotPwdRuleUpper => 'Au moins 1 majuscule';

  @override
  String get forgotPwdRuleSpecial => 'Au moins 1 caractère spécial';

  @override
  String get forgotConfirmPasswordLabel => 'Confirmer le mot de passe';

  @override
  String get forgotEnterNewPasswordFirst => 'Saisis le nouveau mot de passe';

  @override
  String get forgotPasswordsDoNotMatch =>
      'Les mots de passe ne correspondent pas';

  @override
  String get forgotPasswordsMatch => 'Les mots de passe correspondent';

  @override
  String get forgotResetSuccess => 'Mot de passe réinitialisé ✅';

  @override
  String forgotResetFailed(int code) {
    return 'Échec ($code).';
  }

  @override
  String get tooManyAttemptsTitle => 'Trop de tentatives';

  @override
  String get tooManyAttemptsMessage =>
      'Nombre d’essais dépassé.\n\nÉcrire à contact@fastfrance.org pour exposer votre problème de connexion.';

  @override
  String get forgotValidating => 'Validation…';

  @override
  String get editProfileTitle => 'Modifier le profil';

  @override
  String get loadingProfile => 'Chargement du profil…';

  @override
  String get timeoutLoadingProfile => 'Timeout en chargeant le profil.';

  @override
  String errorLoadingProfile(String message) {
    return 'Erreur chargement: $message';
  }

  @override
  String get import => 'Importer';

  @override
  String get deleteMyPhoto => 'Supprimer ma photo';

  @override
  String get cancelSelection => 'Annuler la sélection';

  @override
  String photoTooLarge(String size) {
    return 'La photo dépasse 4 Mo ($size Mo).';
  }

  @override
  String cannotGetPhoto(String message) {
    return 'Impossible de récupérer la photo : $message';
  }

  @override
  String get photoRequired => 'Photo obligatoire';

  @override
  String get photoRequiredAddToSave => 'Ajoutez une photo pour enregistrer';

  @override
  String get photoRequiredAfterDelete =>
      'Photo obligatoire : importez ou prenez une nouvelle photo.';

  @override
  String get photoDeleted => 'Photo supprimée ✅';

  @override
  String get profileInfoSection => 'Informations du profil';

  @override
  String get firstName => 'Prénom';

  @override
  String get lastName => 'Nom';

  @override
  String get birthDateLabel => 'Date de naissance (jj/mm/aaaa)';

  @override
  String get birthDateRequired => 'Date de naissance requise';

  @override
  String get genotype => 'Génotype';

  @override
  String get city => 'Ville';

  @override
  String get geolocateMe => 'Me géolocaliser';

  @override
  String get locationUpdated => 'Localisation mise à jour';

  @override
  String locationUpdatedWithCity(String city) {
    return 'Localisation mise à jour ($city)';
  }

  @override
  String get geolocation => 'Géolocalisation';

  @override
  String get geolocationHint =>
      'Pensez à changer votre géolocalisation si celle-ci a changé par rapport à votre inscription.';

  @override
  String get secretQuestionSection => 'Question secrète';

  @override
  String get question => 'Question';

  @override
  String get answer => 'Réponse';

  @override
  String get changeMyPassword => 'Changer mon mot de passe';

  @override
  String get changePasswordTitle => 'Changer mon mot de passe';

  @override
  String get newPasswordLabel => 'Nouveau mot de passe';

  @override
  String get confirmPasswordLabel => 'Confirmer le mot de passe';

  @override
  String get passwordTooWeak => 'Mot de passe trop faible';

  @override
  String get enterPassword => 'Saisis un mot de passe';

  @override
  String get passwordsDoNotMatch => 'Les mots de passe ne correspondent pas';

  @override
  String get passwordsMatch => 'Les mots de passe correspondent';

  @override
  String get pwdRuleMin8 => 'Au moins 8 caractères';

  @override
  String get pwdRuleUpper => 'Au moins 1 majuscule';

  @override
  String get pwdRuleSpecial => 'Au moins 1 caractère spécial';

  @override
  String get passwordChanged => 'Mot de passe changé ✅';

  @override
  String get save => 'Enregistrer';

  @override
  String get saving => 'Enregistrement…';

  @override
  String get savedChanges => 'Modifications enregistrées ✅';

  @override
  String get timeoutTryAgain => 'Délai dépassé. Réessaie.';

  @override
  String failedWithCode(int code) {
    return 'Échec ($code)';
  }

  @override
  String get versionMadeByFastFrance =>
      'Cette application est réalisée par FAST France';

  @override
  String versionNumber(String version) {
    return 'Version $version';
  }

  @override
  String get privacyTitle => 'Politique de confidentialité';

  @override
  String get privacyRightToBeForgotten => 'Droit à l’oubli';

  @override
  String get privacyDeleteTitle => 'Attention';

  @override
  String get privacyDeleteConfirmBody =>
      'Cette action est irréversible.\n\nVotre profil et vos données associées seront supprimés définitivement.\n\nVoulez-vous continuer ?';

  @override
  String get privacyDeletedOkTitle => 'Compte supprimé';

  @override
  String get privacyDeletedOkBody =>
      'Votre compte a bien été supprimé.\nVous allez être redirigé vers la page de connexion.';

  @override
  String privacyDeleteFailedWithCode(int code) {
    return 'Suppression impossible (code $code).';
  }

  @override
  String get timeoutRetry => 'Délai dépassé. Réessaie.';

  @override
  String get consentText =>
      'Politique de confidentialité – Application ASConnect\n\n1) Identité du responsable de traitement\nLes données collectées dans l’application ASConnect sont traitées par FAST France, en qualité de responsable de traitement.\nPour toute question relative à vos données ou à l’exercice de vos droits, vous pouvez nous contacter à : contact@fastfrance.org.\n\n2) Finalités des traitements\nLes traitements de données réalisés via l’application poursuivent les finalités suivantes :\n• Création et gestion de votre compte utilisateur pour un accès nominatif à l’application ASConnect ;\n• Utilisation des fonctionnalités de géolocalisation afin de visualiser :\n  o des points d’intérêt liés au syndrome d’Angelman,\n  o et/ou des profils de personnes concernées, selon différents critères (distance géographique, génotype, tranche d’âge) ;\n• Amélioration du service et personnalisation de l’expérience utilisateur, incluant la possibilité pour l’utilisateur de choisir s’il souhaite ou non afficher une photo, son nom ou son prénom.\n\n3) Catégories de données collectées\nLes données suivantes peuvent être collectées :\n• Données d’identification :\n  o nom, prénom, adresse e-mail, mot de passe, photo,\n  o question et réponse secrète (en cas d’oubli du mot de passe) ;\n• Données sensibles :\n  o génotype, localisation du téléphone (géolocalisation).\nLa base légale de ces traitements repose sur le consentement explicite et éclairé de l’utilisateur.\n\n4) Durée de conservation des données\nLes données sont conservées pendant toute la durée d’utilisation du compte, puis supprimées dans un délai maximum de 12 mois après la dernière activité.\nL’utilisateur peut à tout moment exercer son droit à l’oubli directement dans l’application, via le menu :\nPolitique de confidentialité → Droit à l’oubli.\n\n5) Destinataires et hébergement des données\nLes données sont hébergées de manière sécurisée sur les serveurs de PythonAnywhere.\nLes données sont stockées dans l’Union européenne.\n(Pour plus d’informations sur la politique de protection des données de l’hébergeur, consultez https://www.pythonanywhere.com/privacy/.)\n\n6) Droits des utilisateurs\nConformément au Règlement (UE) 2016/679 (RGPD), les utilisateurs disposent des droits suivants :\n• Droit d’accès, de rectification et d’effacement (« droit à l’oubli ») — directement via leur profil ou le menu Politique de confidentialité → Droit à l’oubli ;\n• Droit d’opposition, de portabilité et de limitation du traitement ;\n• Droit de retrait du consentement à tout moment.\nPour exercer ces droits (autres que le droit à l’oubli accessible depuis l’application), vous pouvez envoyer un e-mail à contact@fastfrance.org.\n\n7) Sécurité et confidentialité\nToutes les données sont chiffrées lors du stockage et de la transmission.\nLes mots de passe sont hachés selon les bonnes pratiques de sécurité, et toutes les communications avec le service se font via le protocole HTTPS.\n\n8) Consentement explicite\nL’inscription à l’application ASConnect requiert le consentement explicite et éclairé de l’utilisateur pour les traitements décrits à la section 2.\nL’utilisateur peut retirer ce consentement à tout moment via les paramètres de son compte ou par contact direct à contact@fastfrance.org.';
}
