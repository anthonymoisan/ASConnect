// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'ASConnexion';

  @override
  String get systemLanguage => 'System';

  @override
  String get menu => 'Menü';

  @override
  String get menuNavigation => 'Navigation';

  @override
  String get menuMyProfile => 'Mein Profil';

  @override
  String get menuContact => 'Kontakt';

  @override
  String get menuPrivacyPolicy => 'Datenschutzrichtlinie';

  @override
  String get menuVersion => 'Version';

  @override
  String get menuContactSubject => 'Kontakt über die App';

  @override
  String get languageLabel => 'Sprache';

  @override
  String currentLanguage(String label) {
    return 'Aktuell: $label';
  }

  @override
  String get cancel => 'Abbrechen';

  @override
  String get confirm => 'Bestätigen';

  @override
  String get ok => 'OK';

  @override
  String get logoutTitle => 'Abmelden';

  @override
  String get logoutConfirm => 'Möchtest du dich wirklich von der App abmelden?';

  @override
  String get tabCommunity => 'Mit der Community verbinden';

  @override
  String get tabChats => 'Meine Chats';

  @override
  String get tabPoi => 'Sehenswürdigkeiten';

  @override
  String get profileUpdated => 'Profil aktualisiert ✅';

  @override
  String get loginTitle => 'Anmelden';

  @override
  String get loginIntro => 'Die ASConnect-App ist ausschließlich für Betreuungspersonen gedacht, die ein Kind mit dem Angelman-Syndrom haben, einer seltenen genetischen Erkrankung.';

  @override
  String get emailLabel => 'E-Mail-Adresse';

  @override
  String get emailHintRequired => 'Bitte gib deine E-Mail-Adresse ein';

  @override
  String get emailHintInvalid => 'Ungültige E-Mail-Adresse';

  @override
  String get passwordLabel => 'Passwort';

  @override
  String get show => 'Anzeigen';

  @override
  String get hide => 'Ausblenden';

  @override
  String get passwordRequired => 'Bitte gib dein Passwort ein';

  @override
  String get loginButton => 'Anmelden';

  @override
  String get loginLoading => 'Anmeldung…';

  @override
  String get createAccount => 'Konto erstellen';

  @override
  String get forgotPassword => 'Passwort vergessen?';

  @override
  String get invalidCredentials => 'Ungültige Zugangsdaten.';

  @override
  String get accessDeniedKey => 'Zugriff verweigert: fehlender oder ungültiger App-Schlüssel.';

  @override
  String get badRequest => 'Ungültige Anfrage (400).';

  @override
  String get tooManyAttempts => 'Zu viele Versuche. Bitte versuche es gleich noch einmal.';

  @override
  String get serviceUnavailable => 'Dienst nicht verfügbar. Bitte versuche es später erneut.';

  @override
  String serverErrorWithCode(int code) {
    return 'Serverfehler ($code).';
  }

  @override
  String get unexpectedServerResponse => 'Unerwartete Serverantwort.';

  @override
  String get cannotConnectServer => 'Verbindung zum Server nicht möglich.';

  @override
  String get timeoutCheckConnection => 'Zeitüberschreitung der Anfrage. Bitte überprüfe deine Verbindung.';

  @override
  String errorWithMessage(String message) {
    return 'Fehler: $message';
  }

  @override
  String get missingAppKeyWarning => '⚠️ App-Schlüssel fehlt. Starte die App mit --dart-define=PUBLIC_APP_KEY=your_public_key';

  @override
  String get signupTitle => 'Konto erstellen';

  @override
  String get signupSectionPerson => 'Person mit Angelman-Syndrom';

  @override
  String get signupSectionAuth => 'Authentifizierung';

  @override
  String get consentTitle => 'Einwilligung';

  @override
  String get firstNameLabel => 'Vorname';

  @override
  String get firstNameRequired => 'Vorname ist erforderlich';

  @override
  String get lastNameLabel => 'Nachname';

  @override
  String get lastNameRequired => 'Nachname ist erforderlich';

  @override
  String get birthdateLabel => 'Geburtsdatum (tt/mm/jjjj)';

  @override
  String get birthdateRequired => 'Geburtsdatum ist erforderlich';

  @override
  String get chooseDate => 'Datum auswählen';

  @override
  String get signupBirthdateHelp => 'Geburtsdatum';

  @override
  String get genotypeLabel => 'Genotyp';

  @override
  String get genotypeRequired => 'Genotyp ist erforderlich';

  @override
  String get genotypeDeletion => 'Deletion';

  @override
  String get genotypeMutation => 'Mutation';

  @override
  String get genotypeUpd => 'UPD';

  @override
  String get genotypeIcd => 'ICD';

  @override
  String get genotypeClinical => 'Klinisch';

  @override
  String get genotypeMosaic => 'Mosaik';

  @override
  String get signupPhotoHint => 'Foto des Kindes (erforderlich, < 4 MB)';

  @override
  String get importPhoto => 'Foto importieren';

  @override
  String get takePhoto => 'Foto aufnehmen';

  @override
  String get deletePhoto => 'Foto löschen';

  @override
  String get signupPhotoRequired => 'Foto ist erforderlich';

  @override
  String get signupAddPhotoToContinue => 'Füge ein Foto hinzu, um fortzufahren';

  @override
  String signupPhotoTooLarge(String mb) {
    return 'Das Foto überschreitet 4 MB ($mb MB).';
  }

  @override
  String signupPhotoCannotLoad(String message) {
    return 'Foto kann nicht geladen werden: $message';
  }

  @override
  String get signupPasswordTooWeak => 'Passwort ist zu schwach';

  @override
  String get signupPwdRuleMin8 => 'Mind. 8 Zeichen';

  @override
  String get signupPwdRuleUpper => '1 Großbuchstabe';

  @override
  String get signupPwdRuleDigit => '1 Ziffer';

  @override
  String get signupPwdRuleSpecial => '1 Sonderzeichen';

  @override
  String get secretQuestionLabel => 'Sicherheitsfrage';

  @override
  String get secretQuestionRequired => 'Sicherheitsfrage ist erforderlich';

  @override
  String get secretQuestion1 => 'Mädchenname der Mutter?';

  @override
  String get secretQuestion2 => 'Name deines Lieblingsfilmstars?';

  @override
  String get secretQuestion3 => 'Name deines Lieblingstiers?';

  @override
  String get secretAnswerLabel => 'Antwort';

  @override
  String get secretAnswerRequired => 'Antwort ist erforderlich';

  @override
  String get consentCheckbox => 'Ich akzeptiere die Nutzungsbedingungen für meine Daten und erteile meine Einwilligung.';

  @override
  String get signupConsentNotGiven => 'Du hast keine Einwilligung erteilt';

  @override
  String get signupCreating => 'Wird erstellt…';

  @override
  String get signupCreateBtn => 'Mein Konto erstellen';

  @override
  String get signupSuccess => 'Konto erfolgreich erstellt.';

  @override
  String get signupEmailAlreadyExistsRedirect => 'Deine E-Mail-Adresse ist bereits in unserer Datenbank. Du wirst zur Login-Seite weitergeleitet.';

  @override
  String get signupSelectBirthdate => 'Bitte wähle ein Geburtsdatum aus';

  @override
  String get signupChooseGenotype => 'Bitte wähle einen Genotyp aus';

  @override
  String get signupChooseSecretQuestion => 'Bitte wähle eine Sicherheitsfrage aus';

  @override
  String get signupEnterSecretAnswer => 'Bitte gib die Antwort auf die Sicherheitsfrage ein';

  @override
  String signupApiFailed(int code, String body) {
    return 'API-Fehler ($code): $body';
  }

  @override
  String get forgotPasswordTitle => 'Passwort vergessen';

  @override
  String get forgotEmailLabel => 'E-Mail-Adresse';

  @override
  String get forgotFetchQuestionTooltip => 'Frage abrufen';

  @override
  String get forgotEnterValidEmail => 'Bitte eine gültige E-Mail-Adresse eingeben.';

  @override
  String get forgotUnknownEmail => 'Unbekannte E-Mail-Adresse.';

  @override
  String forgotErrorCode(int code) {
    return 'Fehler ($code)';
  }

  @override
  String get forgotTimeoutRetry => 'Zeitüberschreitung. Bitte erneut versuchen.';

  @override
  String forgotErrorWithMessage(String message) {
    return 'Fehler: $message';
  }

  @override
  String get forgotQuestionFallback => 'Sicherheitsfrage';

  @override
  String get forgotQuestionLabel => 'Frage';

  @override
  String get forgotSecretAnswerLabel => 'Sicherheitsantwort';

  @override
  String get forgotAnswerRequired => 'Antwort ist erforderlich';

  @override
  String get forgotEnterYourAnswer => 'Gib deine Antwort ein.';

  @override
  String get forgotVerify => 'Überprüfen';

  @override
  String get forgotAnswerCorrectSnack => 'Richtige Antwort 👍';

  @override
  String forgotAnswerIncorrectAttempts(int attempts) {
    return 'Falsche Antwort ($attempts/3).';
  }

  @override
  String forgotFailedAttempts(int attempts) {
    return 'Fehlversuche: $attempts / 3';
  }

  @override
  String get forgotAnswerOkHint => '✅ Richtige Antwort, du kannst ein neues Passwort festlegen.';

  @override
  String get forgotNewPasswordLabel => 'Neues Passwort';

  @override
  String get forgotPasswordRequired => 'Passwort ist erforderlich';

  @override
  String get forgotPasswordTooWeak => 'Passwort ist zu schwach';

  @override
  String get forgotPwdRuleMin8 => 'Mindestens 8 Zeichen';

  @override
  String get forgotPwdRuleUpper => 'Mindestens 1 Großbuchstabe';

  @override
  String get forgotPwdRuleSpecial => 'Mindestens 1 Sonderzeichen';

  @override
  String get forgotConfirmPasswordLabel => 'Passwort bestätigen';

  @override
  String get forgotEnterNewPasswordFirst => 'Gib zuerst das neue Passwort ein';

  @override
  String get forgotPasswordsDoNotMatch => 'Passwörter stimmen nicht überein';

  @override
  String get forgotPasswordsMatch => 'Passwörter stimmen überein';

  @override
  String get forgotResetSuccess => 'Passwort zurückgesetzt ✅';

  @override
  String forgotResetFailed(int code) {
    return 'Fehlgeschlagen ($code).';
  }

  @override
  String get tooManyAttemptsTitle => 'Zu viele Versuche';

  @override
  String get tooManyAttemptsMessage => 'Zu viele Versuche.\n\nSende eine E-Mail an contact@fastfrance.org und schildere dein Login-Problem.';

  @override
  String get forgotValidating => 'Wird gesendet…';

  @override
  String get editProfileTitle => 'Profil bearbeiten';

  @override
  String get loadingProfile => 'Profil wird geladen…';

  @override
  String get timeoutLoadingProfile => 'Zeitüberschreitung beim Laden des Profils.';

  @override
  String errorLoadingProfile(String message) {
    return 'Ladefehler: $message';
  }

  @override
  String get import => 'Importieren';

  @override
  String get deleteMyPhoto => 'Mein Foto löschen';

  @override
  String get cancelSelection => 'Auswahl abbrechen';

  @override
  String photoTooLarge(String size) {
    return 'Das Foto überschreitet 4 MB ($size MB).';
  }

  @override
  String cannotGetPhoto(String message) {
    return 'Foto kann nicht abgerufen werden: $message';
  }

  @override
  String get photoRequired => 'Foto erforderlich';

  @override
  String get photoRequiredAddToSave => 'Bitte füge ein Foto hinzu, um zu speichern';

  @override
  String get photoRequiredAfterDelete => 'Foto erforderlich: importiere oder nimm ein neues Foto auf.';

  @override
  String get photoDeleted => 'Foto gelöscht ✅';

  @override
  String get profileInfoSection => 'Profilinformationen';

  @override
  String get firstName => 'Vorname';

  @override
  String get lastName => 'Nachname';

  @override
  String get birthDateLabel => 'Geburtsdatum (tt/mm/jjjj)';

  @override
  String get birthDateRequired => 'Geburtsdatum ist erforderlich';

  @override
  String get genotype => 'Genotyp';

  @override
  String get city => 'Stadt';

  @override
  String get geolocateMe => 'Meinen Standort verwenden';

  @override
  String get locationUpdated => 'Standort aktualisiert';

  @override
  String locationUpdatedWithCity(String city) {
    return 'Standort aktualisiert ($city)';
  }

  @override
  String get geolocation => 'Geolokalisierung';

  @override
  String get geolocationHint => 'Bitte aktualisiere deinen Standort, wenn er sich seit der Registrierung geändert hat.';

  @override
  String get secretQuestionSection => 'Sicherheitsfrage';

  @override
  String get question => 'Frage';

  @override
  String get answer => 'Antwort';

  @override
  String get changeMyPassword => 'Mein Passwort ändern';

  @override
  String get changePasswordTitle => 'Mein Passwort ändern';

  @override
  String get newPasswordLabel => 'Neues Passwort';

  @override
  String get confirmPasswordLabel => 'Passwort bestätigen';

  @override
  String get passwordTooWeak => 'Passwort ist zu schwach';

  @override
  String get enterPassword => 'Passwort eingeben';

  @override
  String get passwordsDoNotMatch => 'Passwörter stimmen nicht überein';

  @override
  String get passwordsMatch => 'Passwörter stimmen überein';

  @override
  String get pwdRuleMin8 => 'Mindestens 8 Zeichen';

  @override
  String get pwdRuleUpper => 'Mindestens 1 Großbuchstabe';

  @override
  String get pwdRuleSpecial => 'Mindestens 1 Sonderzeichen';

  @override
  String get passwordChanged => 'Passwort geändert ✅';

  @override
  String get save => 'Speichern';

  @override
  String get saving => 'Wird gespeichert…';

  @override
  String get savedChanges => 'Änderungen gespeichert ✅';

  @override
  String get timeoutTryAgain => 'Zeitüberschreitung. Bitte erneut versuchen.';

  @override
  String failedWithCode(int code) {
    return 'Fehlgeschlagen ($code)';
  }

  @override
  String get versionMadeByFastFrance => 'Diese App wird von Angelman Analytics (www.angelmananalytics.org) entwickelt';

  @override
  String versionNumber(String version) {
    return 'Version $version';
  }

  @override
  String get privacyTitle => 'Datenschutzrichtlinie';

  @override
  String get privacyRightToBeForgotten => 'Recht auf Vergessenwerden';

  @override
  String get privacyDeleteTitle => 'Warnung';

  @override
  String get privacyDeleteConfirmBody => 'Diese Aktion ist unwiderruflich.\n\nDein Profil und die zugehörigen Daten werden dauerhaft gelöscht.\n\nMöchtest du fortfahren?';

  @override
  String get privacyDeletedOkTitle => 'Konto gelöscht';

  @override
  String get privacyDeletedOkBody => 'Dein Konto wurde gelöscht.\nDu wirst zur Login-Seite weitergeleitet.';

  @override
  String privacyDeleteFailedWithCode(int code) {
    return 'Löschen nicht möglich (Code $code).';
  }

  @override
  String get timeoutRetry => 'Zeitüberschreitung der Anfrage. Bitte erneut versuchen.';

  @override
  String get consentText => 'Informativa sulla privacy – Applicazione ASConnect\n\n1) Titolare del trattamento\nI dati raccolti nell’applicazione ASConnect sono trattati da AngelmanAnalytics, in qualità di titolare del trattamento.\nPer qualsiasi domanda relativa ai dati personali o all’esercizio dei diritti, è possibile contattarci all’indirizzo: contact@angelmananalytics.org.\n\n____________________________________________\n2) Finalità del trattamento\nI trattamenti dei dati effettuati tramite l’applicazione hanno le seguenti finalità:\n• Creazione e gestione dell’account utente per l’accesso nominativo all’applicazione ASConnect;\n• Utilizzo delle funzionalità di geolocalizzazione per visualizzare:\n  o Profili delle persone interessate secondo diversi criteri (distanza geografica, genotipo, fascia di età);\n  o Miglioramento del servizio e personalizzazione dell’esperienza utente.\n• Estrazione di dati non identificativi a fini statistici: numero di persone affette dalla sindrome di Angelman, distribuzione per età, ecc.\n\n____________________________________________\n3) Categorie di dati raccolti\nPossono essere raccolti i seguenti dati:\n• Dati identificativi:\n  o nome, cognome, indirizzo email, password, foto,\n  o domanda e risposta di sicurezza (in caso di password dimenticata);\n• Dati sensibili:\n  o genotipo, localizzazione.\nLa base giuridica del trattamento è il consenso esplicito e informato dell’utente.\n\n____________________________________________\n4) Periodo di conservazione\nI dati sono conservati per tutta la durata dell’utilizzo dell’account e cancellati entro un massimo di 12 mesi dall’ultima attività.\nL’utente può esercitare in qualsiasi momento il diritto all’oblio direttamente nell’applicazione tramite:\nInformativa sulla privacy → Diritto all’oblio.\n\n____________________________________________\n5) Destinatari e hosting dei dati\nI dati sono ospitati in modo sicuro sui server di PythonAnywhere.\nI dati sono conservati all’interno dell’Unione Europea.\n(Per maggiori informazioni: https://www.pythonanywhere.com/privacy/.)\n\n____________________________________________\n6) Diritti degli utenti\nAi sensi del Regolamento (UE) 2016/679 (GDPR), gli utenti hanno i seguenti diritti:\n• Diritto di accesso, rettifica e cancellazione («diritto all’oblio»);\n• Diritto di opposizione, portabilità e limitazione del trattamento;\n• Diritto di revocare il consenso in qualsiasi momento.\nPer esercitare tali diritti (diversi dal diritto all’oblio disponibile nell’app), è possibile scrivere a: contact@angelmananalytics.org.\n\n____________________________________________\n7) Sicurezza e riservatezza\nTutti i dati sono cifrati durante la memorizzazione e la trasmissione.\nLe password sono protette tramite hashing e tutte le comunicazioni avvengono tramite protocollo HTTPS.\n\n____________________________________________\n8) Consenso esplicito\nLa registrazione all’applicazione ASConnect richiede il consenso esplicito e informato dell’utente per i trattamenti descritti nella sezione 2.\nIl consenso può essere revocato in qualsiasi momento tramite le impostazioni dell’account o scrivendo a contact@angelmananalytics.org.';

  @override
  String get contactPageTitle => 'Kontakt';

  @override
  String get contactSendMessageTitle => 'Nachricht senden';

  @override
  String get contactSubjectLabel => 'Titel';

  @override
  String get contactSubjectHint => 'Betreff deiner Anfrage';

  @override
  String get contactMessageLabel => 'Nachricht';

  @override
  String get contactMessageHint => 'Beschreibe deine Anfrage…';

  @override
  String get contactAntiSpamTitle => 'Anti-Spam-Prüfung';

  @override
  String get contactRefresh => 'Aktualisieren';

  @override
  String contactCaptchaQuestion(int a, int b) {
    return 'Wie viel ist $a + $b?';
  }

  @override
  String get contactCaptchaAnswerLabel => 'Antwort';

  @override
  String get contactCaptchaRequired => 'Captcha erforderlich';

  @override
  String get contactCaptchaIncorrect => 'Falsches Captcha.';

  @override
  String get contactSend => 'Senden';

  @override
  String get contactSending => 'Wird gesendet…';

  @override
  String get contactCancel => 'Abbrechen';

  @override
  String get contactMessageSent => 'Nachricht gesendet ✅';

  @override
  String contactSendFailedWithCode(int code) {
    return 'Senden fehlgeschlagen ($code)';
  }

  @override
  String get contactAccessDenied => 'Zugriff verweigert (fehlender oder ungültiger App-Schlüssel).';

  @override
  String get contactTooManyRequests => 'Zu viele Anfragen. Bitte in ein paar Sekunden erneut versuchen.';

  @override
  String get contactServiceUnavailable => 'Dienst vorübergehend nicht verfügbar. Bitte später erneut versuchen.';

  @override
  String get contactCheckInternet => 'Bitte überprüfe deine Internetverbindung.';

  @override
  String get contactTimeout => 'Zeitüberschreitung. Bitte später erneut versuchen.';

  @override
  String get contactFooterNote => 'Deine Nachricht wird über unsere sichere öffentliche API gesendet. Danke!';

  @override
  String contactMissingAppKey(String command) {
    return '⚠️ App-Schlüssel fehlt. Starte die App mit $command';
  }

  @override
  String fieldRequired(String field) {
    return '$field ist erforderlich';
  }

  @override
  String unexpectedError(String message) {
    return 'Unerwarteter Fehler: $message';
  }

  @override
  String get commonOk => 'OK';

  @override
  String get commonCancel => 'Abbrechen';

  @override
  String get commonConfirm => 'Bestätigen';

  @override
  String get emailRequired => 'E-Mail ist erforderlich';

  @override
  String get emailInvalid => 'Ungültige E-Mail';

  @override
  String get editProfileImport => 'Importieren';

  @override
  String get editProfileTakePhoto => 'Foto aufnehmen';

  @override
  String get editProfileDeletePhoto => 'Mein Foto löschen';

  @override
  String get editProfileCancelSelection => 'Auswahl abbrechen';

  @override
  String get editProfilePhotoRequired => 'Foto erforderlich';

  @override
  String get editProfilePhotoRequiredHint => 'Foto erforderlich: importieren oder ein neues Foto aufnehmen.';

  @override
  String get editProfileAddPhotoToSave => 'Bitte füge ein Foto hinzu, um zu speichern';

  @override
  String get editProfilePhotoDeleted => 'Foto gelöscht ✅';

  @override
  String editProfilePhotoTooLarge(String size) {
    return 'Foto überschreitet 4 MB ($size MB).';
  }

  @override
  String editProfilePhotoPickError(String message) {
    return 'Foto kann nicht abgerufen werden: $message';
  }

  @override
  String get editProfileProfileInfoTitle => 'Profilinformationen';

  @override
  String get editProfileFirstNameLabel => 'Vorname';

  @override
  String get editProfileLastNameLabel => 'Nachname';

  @override
  String get editProfileEmailLabel => 'E-Mail-Adresse';

  @override
  String get editProfileBirthDateLabel => 'Geburtsdatum (tt/mm/jjjj)';

  @override
  String get editProfileBirthDateHelp => 'Geburtsdatum';

  @override
  String get editProfileBirthDatePickTooltip => 'Datum auswählen';

  @override
  String get editProfileBirthDateRequired => 'Geburtsdatum ist erforderlich';

  @override
  String get editProfileGenotypeLabel => 'Genotyp';

  @override
  String get editProfileGenotypeRequired => 'Genotyp ist erforderlich';

  @override
  String get editProfileCityLabel => 'Stadt';

  @override
  String get editProfileGeolocate => 'Mich lokalisieren';

  @override
  String get editProfileGeoTooltip => 'Bitte aktualisiere deinen Standort, wenn er sich seit der Registrierung geändert hat.';

  @override
  String get geoTitle => 'Geolokalisierung';

  @override
  String get geoInfoText => 'Bitte aktualisiere deinen Standort, wenn er sich seit der Registrierung geändert hat.';

  @override
  String editProfileLocationUpdated(String cityPart) {
    return 'Standort aktualisiert$cityPart';
  }

  @override
  String get editProfileSecretSectionTitle => 'Sicherheitsfrage';

  @override
  String get editProfileSecretQuestionLabel => 'Frage';

  @override
  String get editProfileSecretAnswerLabel => 'Sicherheitsantwort';

  @override
  String get editProfileChangePassword => 'Mein Passwort ändern';

  @override
  String get passwordEnterFirst => 'Bitte zuerst ein Passwort eingeben';

  @override
  String get passwordMismatch => 'Passwörter stimmen nicht überein';

  @override
  String get passwordMatch => 'Passwörter stimmen überein';

  @override
  String get editProfilePasswordChanged => 'Passwort geändert ✅';

  @override
  String get editProfileSave => 'Speichern';

  @override
  String get editProfileSaving => 'Wird gespeichert…';

  @override
  String get editProfileChangesSaved => 'Änderungen gespeichert ✅';

  @override
  String get editProfileTimeoutLoading => 'Zeitüberschreitung beim Laden des Profils.';

  @override
  String editProfileLoadError(String message) {
    return 'Ladefehler: $message';
  }

  @override
  String get editProfileTimeoutGeneric => 'Zeitüberschreitung. Bitte erneut versuchen.';

  @override
  String editProfileErrorGeneric(String message) {
    return 'Fehler: $message';
  }

  @override
  String get genotypeUPD => 'UPD';

  @override
  String get genotypeICD => 'ICD';

  @override
  String get secretQ1 => 'Wie lautet der Geburtsname deiner Mutter?';

  @override
  String get secretQ2 => 'Wie heißt dein Lieblingsfilmstar?';

  @override
  String get secretQ3 => 'Wie heißt dein Lieblingstier?';

  @override
  String get mapPersonTileIsMeHint => 'Das ist dein Profil';

  @override
  String get mapPersonTileSendHint => 'Nachricht senden…';

  @override
  String get mapPersonTileCannotWriteTooltip => 'Du kannst dir selbst keine Nachricht senden';

  @override
  String get mapPersonTileSendTooltip => 'Senden';

  @override
  String mapPersonTileSendFailed(Object error) {
    return 'Senden fehlgeschlagen: $error';
  }

  @override
  String mapPersonTileAge(int age) {
    return '$age Jahre alt';
  }

  @override
  String get mapFiltersButtonTooltip => 'Filter';

  @override
  String get mapNoFilters => 'Keine Filter';

  @override
  String mapGenotypeCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Genotypen',
      one: '$count Genotyp',
    );
    return '$_temp0';
  }

  @override
  String mapAgeRangeYears(Object max, Object min) {
    return '$min–$max J.';
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
      other: '$count Personen',
      one: '$count Person',
    );
    return '$_temp0';
  }

  @override
  String get mapReloadFromNetworkTooltip => 'Neu laden (Netzwerk, ignoriert Filter, aktualisiert Cache)';

  @override
  String get mapTilesBlockedInReleaseMessage => 'OSM-Kacheln sind in der Produktion deaktiviert.\nKonfiguriere einen MapTiler-Schlüssel (oder setze allowOsmInRelease=true).';

  @override
  String get mapInitializingDataMessage => 'Wir initialisieren alle Daten…';

  @override
  String mapNetworkUnavailableCacheUsed(Object error) {
    return 'Netzwerk nicht verfügbar — Cache verwendet: $error';
  }

  @override
  String mapLoadGenericError(Object error) {
    return 'Ladefehler: $error';
  }

  @override
  String mapFilterError(Object error) {
    return 'Filterfehler: $error';
  }

  @override
  String get mapLocationServiceDisabled => 'Standortdienst deaktiviert';

  @override
  String get mapLocationPermissionDenied => 'Standortberechtigung verweigert';

  @override
  String mapLocationUnavailable(Object error) {
    return 'Standort nicht verfügbar: $error';
  }

  @override
  String get mapPhotoViewerBarrierLabel => 'Foto';

  @override
  String get mapClose => 'Schließen';

  @override
  String mapCityPeopleCount(Object city, num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Personen',
      one: '$count Person',
    );
    return '$city • $_temp0';
  }

  @override
  String mapResultsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Ergebnisse',
      one: '$count Ergebnis',
    );
    return '$_temp0';
  }

  @override
  String get mapNoResultsWithTheseFilters => 'Keine Ergebnisse mit diesen Filtern (Genotyp/Distanz).';

  @override
  String get mapDistanceTitle => 'Entfernung (von meinem Standort)';

  @override
  String get mapEnableDistanceFilter => 'Entfernungsfilter aktivieren';

  @override
  String mapOriginDefined(Object lat, Object lon) {
    return 'Ursprung: $lat, $lon';
  }

  @override
  String get mapOriginUndefined => 'Ursprung: nicht gesetzt';

  @override
  String get mapMyPosition => 'Mein Standort';

  @override
  String mapKmLabel(Object km) {
    return '$km km';
  }

  @override
  String get mapGenotypeTitle => 'Genotyp';

  @override
  String get mapAgeTitle => 'Alter (Jahre)';

  @override
  String mapMinValue(Object value) {
    return 'Min: $value';
  }

  @override
  String mapMaxValue(Object value) {
    return 'Max: $value';
  }

  @override
  String get mapReset => 'Zurücksetzen';

  @override
  String get mapCancel => 'Abbrechen';

  @override
  String get mapApply => 'Anwenden';

  @override
  String get mapCountryTitle => 'Länder';

  @override
  String get mapAllCountriesSelected => 'Alle Länder';

  @override
  String mapCountriesSelectedCount(int count) {
    return '$count Länder ausgewählt';
  }

  @override
  String get mapSelectAll => 'Alle auswählen';

  @override
  String get mapClear => 'Auswahl löschen';

  @override
  String get mapBack => 'Zurück';

  @override
  String chatWithName(Object name) {
    return 'Chat mit $name';
  }

  @override
  String get conversationsReconnectToSee => 'Bitte melde dich erneut an, um deine Gespräche zu sehen.';

  @override
  String get loading => 'Wird geladen…';

  @override
  String get conversationsEmpty => 'Keine Gespräche';

  @override
  String get conversationsNoMessage => 'Keine Nachrichten';

  @override
  String conversationsLoadError(Object error) {
    return 'Ladefehler: $error';
  }

  @override
  String get conversationsLeaveTitle => 'Gespräch verlassen?';

  @override
  String get conversationsLeaveBody => 'Möchtest du dieses Gespräch wirklich verlassen?\nAlle deine Nachrichten werden gelöscht.';

  @override
  String get conversationsLeaveConfirm => 'Verlassen';

  @override
  String get close => 'Schließen';

  @override
  String get photo => 'Foto';

  @override
  String get yesterday => 'gestern';

  @override
  String genericError(Object error) {
    return 'Fehler: $error';
  }

  @override
  String get today => 'Heute';

  @override
  String get chatNoMessagesYet => 'Noch keine Nachrichten.';

  @override
  String chatLoadMessagesError(Object error) {
    return 'Fehler beim Laden der Nachrichten: $error';
  }

  @override
  String chatSendError(Object error) {
    return 'Fehler beim Senden: $error';
  }

  @override
  String get chatEditMessageTitle => 'Nachricht bearbeiten';

  @override
  String get chatYourMessageHint => 'Deine Nachricht';

  @override
  String chatEditError(Object error) {
    return 'Fehler beim Bearbeiten: $error';
  }

  @override
  String get chatDeleteMessageTitle => 'Nachricht löschen?';

  @override
  String get chatDeleteMessageBody => 'Diese Nachricht wird in diesem Gespräch als gelöscht markiert.';

  @override
  String chatDeleteError(Object error) {
    return 'Fehler beim Löschen: $error';
  }

  @override
  String chatReactError(Object error) {
    return 'Fehler bei der Reaktion: $error';
  }

  @override
  String get chatLeaveConversationBody => 'Möchtest du das Gespräch wirklich verlassen und alle deine Nachrichten löschen?';

  @override
  String chatLeaveError(Object error) {
    return 'Fehler beim Verlassen: $error';
  }

  @override
  String get message => 'Nachricht';

  @override
  String get send => 'Senden';

  @override
  String get edited => 'bearbeitet';

  @override
  String get deletedMessage => 'Gelöschte Nachricht';

  @override
  String get edit => 'Bearbeiten';

  @override
  String get reply => 'Antworten';

  @override
  String get delete => 'Löschen';

  @override
  String get languageName => 'Deutsch';

  @override
  String get mapConnectionSectionTitle => 'Verbindung';

  @override
  String get mapConnectedOnlyLabel => 'Nur verbundene Personen anzeigen';

  @override
  String get mapConnectedOnlyHint => 'Blendet Offline-Profile aus.';

  @override
  String get mapConnectedOnlyChip => 'Verbunden';

  @override
  String get statusOnline => 'Online';

  @override
  String get statusOffline => 'Offline';

  @override
  String get tableTabular => 'Tabelle';

  @override
  String get tableColumnPseudo => 'Benutzername';

  @override
  String get tableColumnAge => 'Alter';

  @override
  String get tableColumnGenotype => 'Genotyp';

  @override
  String get tableColumnCountry => 'Land';

  @override
  String get tableColumnCity => 'Stadt';

  @override
  String get tabularColPseudo => 'Benutzername';

  @override
  String get tabularColAge => 'Alter';

  @override
  String get tabularColGenotype => 'Genotyp';

  @override
  String get tabularColCountry => 'Land';

  @override
  String get tabularColCity => 'Stadt';

  @override
  String get tabularColAction => 'Aktion';

  @override
  String get tabularSendMessageTooltip => 'Nachricht senden';

  @override
  String get tabularSendMessageErrorNoId => 'Nachricht kann nicht gesendet werden: Kennung fehlt.';

  @override
  String get tabularSendMessageActionStub => 'Nachrichtenfunktion noch nicht verbunden.';

  @override
  String tabularSendMessageTitle(Object name) {
    return 'Nachricht an $name';
  }

  @override
  String get tabularSendMessageHint => 'Nachricht eingeben…';

  @override
  String get tabularSendMessageSend => 'Senden';

  @override
  String get tabularSendMessageSentStub => 'Nachricht bereit zum Senden (noch nicht verbunden).';

  @override
  String get tabularSendMessageCancel => 'Abbrechen';

  @override
  String get genderLabel => 'Geschlecht';

  @override
  String get genderMale => 'Männlich';

  @override
  String get genderFemale => 'Weiblich';

  @override
  String get genderRequired => 'Bitte wähle ein Geschlecht';

  @override
  String get acceptInfoAngelman => 'Ich stimme zu, Informationen über das Angelman-Syndrom zu erhalten';
}
