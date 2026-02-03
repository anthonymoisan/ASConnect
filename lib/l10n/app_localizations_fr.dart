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
  String get logoutConfirm => 'Êtes-vous certain(e) de vous déconnecter de l’application ?';

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
  String get loginIntro => 'L\'application ASConnect est à destination uniquement des aidants ayant un enfant porteur du syndrome d\'Angelman, une maladie génétique rare.';

  @override
  String get emailLabel => 'Adresse e-mail';

  @override
  String get emailHintRequired => 'Renseigne ton e-mail';

  @override
  String get emailHintInvalid => 'E-mail invalide';

  @override
  String get passwordLabel => 'Mot de passe';

  @override
  String get show => 'Afficher';

  @override
  String get hide => 'Masquer';

  @override
  String get passwordRequired => 'Renseigne ton mot de passe';

  @override
  String get loginButton => 'Se connecter';

  @override
  String get loginLoading => 'Connexion…';

  @override
  String get createAccount => 'Créer un compte';

  @override
  String get forgotPassword => 'Vous avez oublié votre mot de passe ?';

  @override
  String get invalidCredentials => 'Identifiants invalides.';

  @override
  String get accessDeniedKey => 'Accès refusé: clé d\'application manquante ou invalide.';

  @override
  String get badRequest => 'Requête invalide (400).';

  @override
  String get tooManyAttempts => 'Trop de tentatives. Réessaie dans un instant.';

  @override
  String get serviceUnavailable => 'Service indisponible. Réessaie plus tard.';

  @override
  String serverErrorWithCode(int code) {
    return 'Erreur serveur ($code).';
  }

  @override
  String get unexpectedServerResponse => 'Réponse inattendue du serveur.';

  @override
  String get cannotConnectServer => 'Connexion au serveur impossible.';

  @override
  String get timeoutCheckConnection => 'Délai dépassé. Vérifie ta connexion.';

  @override
  String errorWithMessage(String message) {
    return 'Erreur: $message';
  }

  @override
  String get missingAppKeyWarning => '⚠️ Clé d\'application absente. Lance l\'app avec --dart-define=PUBLIC_APP_KEY=ta_cle_publique';

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
  String get consentCheckbox => 'J\'accepte les conditions d\'usage de mes données et je donne mon consentement.';

  @override
  String get signupConsentNotGiven => 'Vous n\'avez pas donné votre consentement';

  @override
  String get signupCreating => 'Création…';

  @override
  String get signupCreateBtn => 'Créer mon compte';

  @override
  String get signupSuccess => 'Compte créé avec succès.';

  @override
  String get signupEmailAlreadyExistsRedirect => 'Votre email est déjà dans notre base ! Mettre une autre adresse mail ou aller dans la section oubli de mon mot de passe.';

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
  String get forgotAnswerOkHint => '✅ Réponse correcte, tu peux saisir un nouveau mot de passe.';

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
  String get forgotPasswordsDoNotMatch => 'Les mots de passe ne correspondent pas';

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
  String get tooManyAttemptsMessage => 'Nombre d’essais dépassé.\n\nÉcrire à contact@angelmananalytics.org pour exposer votre problème de connexion.';

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
  String get photoRequiredAfterDelete => 'Photo obligatoire : importez ou prenez une nouvelle photo.';

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
  String get geolocationHint => 'Pensez à changer votre géolocalisation si celle-ci a changé par rapport à votre inscription.';

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
  String get versionMadeByFastFrance => 'Cette application est réalisée par Angelman Analytics (www.angelmananalytics.org)';

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
  String get privacyDeleteConfirmBody => 'Cette action est irréversible.\n\nVotre profil et vos données associées seront supprimés définitivement.\n\nVoulez-vous continuer ?';

  @override
  String get privacyDeletedOkTitle => 'Compte supprimé';

  @override
  String get privacyDeletedOkBody => 'Votre compte a bien été supprimé.\nVous allez être redirigé vers la page de connexion.';

  @override
  String privacyDeleteFailedWithCode(int code) {
    return 'Suppression impossible (code $code).';
  }

  @override
  String get timeoutRetry => 'Délai dépassé. Réessaie.';

  @override
  String get consentText => 'Politique de confidentialité – Application ASConnect\n\n1) Identité du responsable de traitement\nLes données collectées dans l’application ASConnect sont traitées par AngelmanAnalytics, en qualité de responsable de traitement.\nPour toute question relative à vos données ou à l’exercice de vos droits, vous pouvez nous contacter à : contact@angelmananalytics.org.\n____________________________________________\n2) Finalités des traitements\nLes traitements de données réalisés via l’application poursuivent les finalités suivantes :\n• Création et gestion de votre compte utilisateur pour un accès nominatif à l’application ASConnect ;\n• Utilisation des fonctionnalités de géolocalisation afin de visualiser :\n  o Des profils de personnes concernées, selon différents critères (distance géographique, génotype, tranche d’âge) ;\n  o Amélioration du service et personnalisation de l’expérience utilisateur, incluant la possibilité pour l’utilisateur.\n• Extraction de données ne permettant pas d\'identifier des personnes à des fins statistiques : nombre de personnes atteintes du syndrome d\'Angelman, répartition par âge...\n____________________________________________\n3) Catégories de données collectées\nLes données suivantes peuvent être collectées :\n• Données d’identification :\n  o le sexe, nom, prénom, adresse e-mail, mot de passe, photo,\n  o question et réponse secrète (en cas d’oubli du mot de passe) ;\n• Données sensibles :\n  o génotype, localisation.\nLa base légale de ces traitements repose sur le consentement explicite et éclairé de l’utilisateur.\n____________________________________________\n4) Durée de conservation des données\nLes données sont conservées pendant toute la durée d’utilisation du compte, puis supprimées dans un délai maximum de 12 mois après la dernière activité.\nL’utilisateur peut à tout moment exercer son droit à l’oubli directement dans l’application, via le menu :\nPolitique de confidentialité → Droit à l’oubli.\n____________________________________________\n5) Destinataires et hébergement des données\nLes données sont hébergées de manière sécurisée sur les serveurs de PythonAnywhere.\nLes données sont stockées dans l’Union européenne.\n(Pour plus d’informations sur la politique de protection des données de l’hébergeur, consultez https://www.pythonanywhere.com/privacy/.)\nL’application Web est hébergée chez O2Switch en France, consultez https://www.o2switch.fr/du-rgpd.pdf.\n____________________________________________\n6) Droits des utilisateurs\nConformément au Règlement (UE) 2016/679 (RGPD), les utilisateurs disposent des droits suivants :\n• Droit d’accès, de rectification et d’effacement (« droit à l’oubli ») — directement via leur profil ou le menu Politique de confidentialité → Droit à l’oubli ;\n• Droit d’opposition, de portabilité et de limitation du traitement ;\n• Droit de retrait du consentement à tout moment.\nPour exercer ces droits (autres que le droit à l’oubli accessible depuis l’application), vous pouvez envoyer un e-mail à contact@angelmananalytics.org.\n____________________________________________\n7) Sécurité et confidentialité\nToutes les données sont chiffrées lors du stockage et de la transmission.\nLes mots de passe sont hachés selon les bonnes pratiques de sécurité, et toutes les communications avec le service se font via le protocole HTTPS.\n____________________________________________\n8) Consentement explicite\nL’inscription à l’application ASConnect requiert le consentement explicite et éclairé de l’utilisateur pour les traitements décrits à la section 2.\nL’utilisateur peut retirer ce consentement à tout moment via les paramètres de son compte ou par contact direct à contact@angelmananalytics.org.';

  @override
  String get contactPageTitle => 'Nous contacter';

  @override
  String get contactSendMessageTitle => 'Envoyer un message';

  @override
  String get contactSubjectLabel => 'Titre';

  @override
  String get contactSubjectHint => 'Sujet de votre demande';

  @override
  String get contactMessageLabel => 'Message';

  @override
  String get contactMessageHint => 'Décrivez votre demande…';

  @override
  String get contactAntiSpamTitle => 'Vérification anti-spam';

  @override
  String get contactRefresh => 'Rafraîchir';

  @override
  String contactCaptchaQuestion(int a, int b) {
    return 'Combien font $a + $b ?';
  }

  @override
  String get contactCaptchaAnswerLabel => 'Réponse';

  @override
  String get contactCaptchaRequired => 'Captcha requis';

  @override
  String get contactCaptchaIncorrect => 'Captcha incorrect.';

  @override
  String get contactSend => 'Envoyer';

  @override
  String get contactSending => 'Envoi…';

  @override
  String get contactCancel => 'Annuler';

  @override
  String get contactMessageSent => 'Message envoyé ✅';

  @override
  String contactSendFailedWithCode(int code) {
    return 'Échec de l’envoi ($code)';
  }

  @override
  String get contactAccessDenied => 'Accès refusé (clé d\'application manquante ou invalide).';

  @override
  String get contactTooManyRequests => 'Trop de requêtes. Réessaie dans quelques secondes.';

  @override
  String get contactServiceUnavailable => 'Service temporairement indisponible. Réessaie plus tard.';

  @override
  String get contactCheckInternet => 'Vérifie ta connexion internet.';

  @override
  String get contactTimeout => 'Délai dépassé. Réessaie plus tard.';

  @override
  String get contactFooterNote => 'Votre message est envoyé via notre API publique sécurisée. Merci !';

  @override
  String contactMissingAppKey(String command) {
    return '⚠️ Clé d\'application absente. Lance l\'app avec $command';
  }

  @override
  String fieldRequired(String field) {
    return '$field requis';
  }

  @override
  String unexpectedError(String message) {
    return 'Erreur inattendue : $message';
  }

  @override
  String get commonOk => 'OK';

  @override
  String get commonCancel => 'Annuler';

  @override
  String get commonConfirm => 'Valider';

  @override
  String get emailRequired => 'Email requis';

  @override
  String get emailInvalid => 'Email invalide';

  @override
  String get editProfileImport => 'Importer';

  @override
  String get editProfileTakePhoto => 'Prendre une photo';

  @override
  String get editProfileDeletePhoto => 'Supprimer ma photo';

  @override
  String get editProfileCancelSelection => 'Annuler la sélection';

  @override
  String get editProfilePhotoRequired => 'Photo obligatoire';

  @override
  String get editProfilePhotoRequiredHint => 'Photo obligatoire : importez ou prenez une nouvelle photo.';

  @override
  String get editProfileAddPhotoToSave => 'Ajoutez une photo pour enregistrer';

  @override
  String get editProfilePhotoDeleted => 'Photo supprimée ✅';

  @override
  String editProfilePhotoTooLarge(String size) {
    return 'La photo dépasse 4 Mo ($size Mo).';
  }

  @override
  String editProfilePhotoPickError(String message) {
    return 'Impossible de récupérer la photo : $message';
  }

  @override
  String get editProfileProfileInfoTitle => 'Informations du profil';

  @override
  String get editProfileFirstNameLabel => 'Prénom';

  @override
  String get editProfileLastNameLabel => 'Nom';

  @override
  String get editProfileEmailLabel => 'Adresse e-mail';

  @override
  String get editProfileBirthDateLabel => 'Date de naissance (jj/mm/aaaa)';

  @override
  String get editProfileBirthDateHelp => 'Date de naissance';

  @override
  String get editProfileBirthDatePickTooltip => 'Choisir une date';

  @override
  String get editProfileBirthDateRequired => 'Date de naissance requise';

  @override
  String get editProfileGenotypeLabel => 'Génotype';

  @override
  String get editProfileGenotypeRequired => 'Génotype requis';

  @override
  String get editProfileCityLabel => 'Ville';

  @override
  String get editProfileGeolocate => 'Me géolocaliser';

  @override
  String get editProfileGeoTooltip => 'Pensez à changer votre géolocalisation si celle-ci a changé par rapport à votre inscription.';

  @override
  String get geoTitle => 'Géolocalisation';

  @override
  String get geoInfoText => 'Pensez à changer votre géolocalisation si celle-ci a changé par rapport à votre inscription.';

  @override
  String editProfileLocationUpdated(String cityPart) {
    return 'Localisation mise à jour$cityPart';
  }

  @override
  String get editProfileSecretSectionTitle => 'Question secrète';

  @override
  String get editProfileSecretQuestionLabel => 'Question';

  @override
  String get editProfileSecretAnswerLabel => 'Réponse secrète';

  @override
  String get editProfileChangePassword => 'Changer mon mot de passe';

  @override
  String get passwordEnterFirst => 'Saisis un mot de passe';

  @override
  String get passwordMismatch => 'Les mots de passe ne correspondent pas';

  @override
  String get passwordMatch => 'Les mots de passe correspondent';

  @override
  String get editProfilePasswordChanged => 'Mot de passe changé ✅';

  @override
  String get editProfileSave => 'Enregistrer';

  @override
  String get editProfileSaving => 'Enregistrement…';

  @override
  String get editProfileChangesSaved => 'Modifications enregistrées ✅';

  @override
  String get editProfileTimeoutLoading => 'Timeout en chargeant le profil.';

  @override
  String editProfileLoadError(String message) {
    return 'Erreur chargement: $message';
  }

  @override
  String get editProfileTimeoutGeneric => 'Délai dépassé. Réessaie.';

  @override
  String editProfileErrorGeneric(String message) {
    return 'Erreur: $message';
  }

  @override
  String get genotypeUPD => 'UPD';

  @override
  String get genotypeICD => 'ICD';

  @override
  String get secretQ1 => 'Nom de naissance de votre maman ?';

  @override
  String get secretQ2 => 'Nom de votre acteur de cinéma favori ?';

  @override
  String get secretQ3 => 'Nom de votre animal de compagnie favori ?';

  @override
  String get mapPersonTileIsMeHint => 'C’est votre profil';

  @override
  String get mapPersonTileSendHint => 'Envoyer un message…';

  @override
  String get mapPersonTileCannotWriteTooltip => 'Impossible de vous écrire';

  @override
  String get mapPersonTileSendTooltip => 'Envoyer';

  @override
  String mapPersonTileSendFailed(Object error) {
    return 'Échec de l’envoi : $error';
  }

  @override
  String mapPersonTileAge(int age) {
    return '$age ans';
  }

  @override
  String get mapFiltersButtonTooltip => 'Filtres';

  @override
  String get mapNoFilters => 'Aucun filtre';

  @override
  String mapGenotypeCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count génotypes',
      one: '$count génotype',
    );
    return '$_temp0';
  }

  @override
  String mapAgeRangeYears(Object max, Object min) {
    return '$min–$max ans';
  }

  @override
  String mapDistanceMaxKm(Object km) {
    return '≤ $km km';
  }

  @override
  String mapPeopleCountBanner(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personnes',
      one: '$count personne',
    );
    return '$_temp0';
  }

  @override
  String get mapReloadFromNetworkTooltip => 'Recharger (réseau, ignore filtres, met à jour le cache)';

  @override
  String get mapTilesBlockedInReleaseMessage => 'Tuiles OSM désactivées en production.\nConfigure une clé MapTiler (ou passe allowOsmInRelease=true).';

  @override
  String get mapInitializingDataMessage => 'Nous initialisons l’ensemble des données…';

  @override
  String mapNetworkUnavailableCacheUsed(Object error) {
    return 'Réseau indisponible — cache utilisé : $error';
  }

  @override
  String mapLoadGenericError(Object error) {
    return 'Erreur chargement : $error';
  }

  @override
  String mapFilterError(Object error) {
    return 'Erreur filtre : $error';
  }

  @override
  String get mapLocationServiceDisabled => 'Service de localisation désactivé';

  @override
  String get mapLocationPermissionDenied => 'Permission localisation refusée';

  @override
  String mapLocationUnavailable(Object error) {
    return 'Localisation indisponible : $error';
  }

  @override
  String get mapPhotoViewerBarrierLabel => 'Photo';

  @override
  String get mapClose => 'Fermer';

  @override
  String mapCityPeopleCount(Object city, num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personnes',
      one: '$count personne',
    );
    return '$city • $_temp0';
  }

  @override
  String mapResultsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count résultats',
      one: '$count résultat',
    );
    return '$_temp0';
  }

  @override
  String get mapNoResultsWithTheseFilters => 'Aucun résultat avec ces filtres (génotype/distance).';

  @override
  String get mapDistanceTitle => 'Distance (depuis ma position)';

  @override
  String get mapEnableDistanceFilter => 'Activer le filtre de distance';

  @override
  String mapOriginDefined(Object lat, Object lon) {
    return 'Origine : $lat, $lon';
  }

  @override
  String get mapOriginUndefined => 'Origine : non définie';

  @override
  String get mapMyPosition => 'Ma position';

  @override
  String mapKmLabel(Object km) {
    return '$km km';
  }

  @override
  String get mapGenotypeTitle => 'Génotype';

  @override
  String get mapAgeTitle => 'Âge (années)';

  @override
  String mapMinValue(Object value) {
    return 'Min : $value';
  }

  @override
  String mapMaxValue(Object value) {
    return 'Max : $value';
  }

  @override
  String get mapReset => 'Réinitialiser';

  @override
  String get mapCancel => 'Annuler';

  @override
  String get mapApply => 'Appliquer';

  @override
  String get mapCountryTitle => 'Pays';

  @override
  String get mapAllCountriesSelected => 'Tous les pays';

  @override
  String mapCountriesSelectedCount(int count) {
    return '$count pays sélectionnés';
  }

  @override
  String get mapSelectAll => 'Tout sélectionner';

  @override
  String get mapClear => 'Tout désélectionner';

  @override
  String get mapBack => 'Retour';

  @override
  String chatWithName(Object name) {
    return 'Chat avec $name';
  }

  @override
  String get conversationsReconnectToSee => 'Veuillez vous reconnecter pour voir vos discussions.';

  @override
  String get loading => 'Chargement…';

  @override
  String get conversationsEmpty => 'Aucune conversation';

  @override
  String get conversationsNoMessage => 'Aucun message';

  @override
  String conversationsLoadError(Object error) {
    return 'Erreur de chargement : $error';
  }

  @override
  String get conversationsLeaveTitle => 'Quitter la conversation ?';

  @override
  String get conversationsLeaveBody => 'Êtes-vous sûr(e) de vouloir quitter la conversation ?\nTous vos messages seront effacés.';

  @override
  String get conversationsLeaveConfirm => 'Quitter';

  @override
  String get close => 'Fermer';

  @override
  String get photo => 'Photo';

  @override
  String get yesterday => 'hier';

  @override
  String genericError(Object error) {
    return 'Erreur : $error';
  }

  @override
  String get today => 'Aujourd’hui';

  @override
  String get chatNoMessagesYet => 'Aucun message pour le moment.';

  @override
  String chatLoadMessagesError(Object error) {
    return 'Erreur chargement messages : $error';
  }

  @override
  String chatSendError(Object error) {
    return 'Erreur lors de l’envoi : $error';
  }

  @override
  String get chatEditMessageTitle => 'Modifier le message';

  @override
  String get chatYourMessageHint => 'Votre message';

  @override
  String chatEditError(Object error) {
    return 'Erreur lors de la modification : $error';
  }

  @override
  String get chatDeleteMessageTitle => 'Supprimer le message ?';

  @override
  String get chatDeleteMessageBody => 'Ce message sera marqué comme supprimé pour cette conversation.';

  @override
  String chatDeleteError(Object error) {
    return 'Erreur lors de la suppression : $error';
  }

  @override
  String chatReactError(Object error) {
    return 'Erreur lors de la réaction : $error';
  }

  @override
  String get chatLeaveConversationBody => 'Êtes-vous sûr(e) de vouloir quitter la conversation et effacer tous vos messages ?';

  @override
  String chatLeaveError(Object error) {
    return 'Erreur pour quitter : $error';
  }

  @override
  String get message => 'Message';

  @override
  String get send => 'Envoyer';

  @override
  String get edited => 'modifié';

  @override
  String get deletedMessage => 'Message supprimé';

  @override
  String get edit => 'Modifier';

  @override
  String get reply => 'Répondre';

  @override
  String get delete => 'Supprimer';

  @override
  String get languageName => 'Français';

  @override
  String get mapConnectionSectionTitle => 'Connexion';

  @override
  String get mapConnectedOnlyLabel => 'Afficher uniquement les personnes connectées';

  @override
  String get mapConnectedOnlyHint => 'Masque les profils hors ligne.';

  @override
  String get mapConnectedOnlyChip => 'Connectés';

  @override
  String get statusOnline => 'En ligne';

  @override
  String get statusOffline => 'Hors ligne';

  @override
  String get tableTabular => 'Table';

  @override
  String get tableColumnPseudo => 'Pseudo';

  @override
  String get tableColumnAge => 'Âge';

  @override
  String get tableColumnGenotype => 'Génotype';

  @override
  String get tableColumnCountry => 'Pays';

  @override
  String get tableColumnCity => 'Ville';

  @override
  String get tabularColPseudo => 'Pseudo';

  @override
  String get tabularColAge => 'Âge';

  @override
  String get tabularColGenotype => 'Génotype';

  @override
  String get tabularColCountry => 'Pays';

  @override
  String get tabularColCity => 'Ville';

  @override
  String get tabularColAction => 'Action';

  @override
  String get tabularSendMessageTooltip => 'Envoyer un message';

  @override
  String get tabularSendMessageErrorNoId => 'Impossible d’envoyer un message : identifiant manquant.';

  @override
  String get tabularSendMessageActionStub => 'Fonctionnalité de messagerie à connecter.';

  @override
  String tabularSendMessageTitle(Object name) {
    return 'Message à $name';
  }

  @override
  String get tabularSendMessageHint => 'Écrire un message…';

  @override
  String get tabularSendMessageSend => 'Envoyer';

  @override
  String get tabularSendMessageSentStub => 'Message prêt à être envoyé (à brancher).';

  @override
  String get tabularSendMessageCancel => 'Annuler';

  @override
  String get genderLabel => 'Sexe';

  @override
  String get genderMale => 'Homme';

  @override
  String get genderFemale => 'Femme';

  @override
  String get genderRequired => 'Veuillez choisir un sexe';

  @override
  String get acceptInfoAngelman => 'J’accepte de recevoir des informations sur le syndrome d’Angelman';

  @override
  String get signupEnableGeolocation => 'Veuillez autoriser la géolocalisation pour continuer.';

  @override
  String get signUpCheckMail => 'Vérification du mail';

  @override
  String get signUpGPS => 'Déduction des coordonnées de votre ville à partir de la position GPS';

  @override
  String get signUpMessageCreate => 'Création profil';

  @override
  String get tabGroup => 'Groupe';

  @override
  String groupMembersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count membres',
      one: '$count membre',
    );
    return '$_temp0';
  }
}
