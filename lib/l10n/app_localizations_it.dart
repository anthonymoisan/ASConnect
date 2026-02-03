// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'ASConnexion';

  @override
  String get systemLanguage => 'Sistema';

  @override
  String get menu => 'Menu';

  @override
  String get menuNavigation => 'Navigazione';

  @override
  String get menuMyProfile => 'Il mio profilo';

  @override
  String get menuContact => 'Contattaci';

  @override
  String get menuPrivacyPolicy => 'Informativa sulla privacy';

  @override
  String get menuVersion => 'Versione';

  @override
  String get menuContactSubject => 'Contatto tramite app';

  @override
  String get languageLabel => 'Lingua';

  @override
  String currentLanguage(String label) {
    return 'Attuale: $label';
  }

  @override
  String get cancel => 'Annulla';

  @override
  String get confirm => 'Conferma';

  @override
  String get ok => 'OK';

  @override
  String get logoutTitle => 'Disconnettersi';

  @override
  String get logoutConfirm => 'Sei sicuro di voler uscire dall\'app?';

  @override
  String get tabCommunity => 'Connettiti con la comunità';

  @override
  String get tabChats => 'Le mie chat';

  @override
  String get tabPoi => 'Punti di interesse';

  @override
  String get profileUpdated => 'Profilo aggiornato ✅';

  @override
  String get loginTitle => 'Accedi';

  @override
  String get loginIntro => 'L\'app ASConnect è destinata esclusivamente ai caregiver che hanno un figlio con la sindrome di Angelman, una rara malattia genetica.';

  @override
  String get emailLabel => 'Indirizzo email';

  @override
  String get emailHintRequired => 'Inserisci la tua email';

  @override
  String get emailHintInvalid => 'Email non valida';

  @override
  String get passwordLabel => 'Password';

  @override
  String get show => 'Mostra';

  @override
  String get hide => 'Nascondi';

  @override
  String get passwordRequired => 'Inserisci la password';

  @override
  String get loginButton => 'Accedi';

  @override
  String get loginLoading => 'Accesso in corso…';

  @override
  String get createAccount => 'Crea un account';

  @override
  String get forgotPassword => 'Hai dimenticato la password?';

  @override
  String get invalidCredentials => 'Credenziali non valide.';

  @override
  String get accessDeniedKey => 'Accesso negato: chiave app mancante o non valida.';

  @override
  String get badRequest => 'Richiesta non valida (400).';

  @override
  String get tooManyAttempts => 'Troppi tentativi. Riprova tra poco.';

  @override
  String get serviceUnavailable => 'Servizio non disponibile. Riprova più tardi.';

  @override
  String serverErrorWithCode(int code) {
    return 'Errore del server ($code).';
  }

  @override
  String get unexpectedServerResponse => 'Risposta inattesa dal server.';

  @override
  String get cannotConnectServer => 'Impossibile connettersi al server.';

  @override
  String get timeoutCheckConnection => 'Richiesta scaduta. Controlla la connessione.';

  @override
  String errorWithMessage(String message) {
    return 'Errore: $message';
  }

  @override
  String get missingAppKeyWarning => '⚠️ Chiave app mancante. Avvia l\'app con --dart-define=PUBLIC_APP_KEY=your_public_key';

  @override
  String get signupTitle => 'Crea un account';

  @override
  String get signupSectionPerson => 'Persona con sindrome di Angelman';

  @override
  String get signupSectionAuth => 'Autenticazione';

  @override
  String get consentTitle => 'Consenso';

  @override
  String get firstNameLabel => 'Nome';

  @override
  String get firstNameRequired => 'Il nome è obbligatorio';

  @override
  String get lastNameLabel => 'Cognome';

  @override
  String get lastNameRequired => 'Il cognome è obbligatorio';

  @override
  String get birthdateLabel => 'Data di nascita (gg/mm/aaaa)';

  @override
  String get birthdateRequired => 'La data di nascita è obbligatoria';

  @override
  String get chooseDate => 'Scegli una data';

  @override
  String get signupBirthdateHelp => 'Data di nascita';

  @override
  String get genotypeLabel => 'Genotipo';

  @override
  String get genotypeRequired => 'Il genotipo è obbligatorio';

  @override
  String get genotypeDeletion => 'Delezione';

  @override
  String get genotypeMutation => 'Mutazione';

  @override
  String get genotypeUpd => 'UPD';

  @override
  String get genotypeIcd => 'ICD';

  @override
  String get genotypeClinical => 'Clinico';

  @override
  String get genotypeMosaic => 'Mosaico';

  @override
  String get signupPhotoHint => 'Foto del bambino (obbligatoria, < 4 MB)';

  @override
  String get importPhoto => 'Importa una foto';

  @override
  String get takePhoto => 'Scatta una foto';

  @override
  String get deletePhoto => 'Elimina foto';

  @override
  String get signupPhotoRequired => 'La foto è obbligatoria';

  @override
  String get signupAddPhotoToContinue => 'Aggiungi una foto per continuare';

  @override
  String signupPhotoTooLarge(String mb) {
    return 'La foto supera i 4 MB ($mb MB).';
  }

  @override
  String signupPhotoCannotLoad(String message) {
    return 'Impossibile caricare la foto: $message';
  }

  @override
  String get signupPasswordTooWeak => 'La password è troppo debole';

  @override
  String get signupPwdRuleMin8 => 'Min. 8 caratteri';

  @override
  String get signupPwdRuleUpper => '1 lettera maiuscola';

  @override
  String get signupPwdRuleDigit => '1 numero';

  @override
  String get signupPwdRuleSpecial => '1 carattere speciale';

  @override
  String get secretQuestionLabel => 'Domanda di sicurezza';

  @override
  String get secretQuestionRequired => 'La domanda di sicurezza è obbligatoria';

  @override
  String get secretQuestion1 => 'Cognome da nubile di tua madre?';

  @override
  String get secretQuestion2 => 'Nome del tuo attore preferito?';

  @override
  String get secretQuestion3 => 'Nome del tuo animale preferito?';

  @override
  String get secretAnswerLabel => 'Risposta';

  @override
  String get secretAnswerRequired => 'La risposta è obbligatoria';

  @override
  String get consentCheckbox => 'Accetto le condizioni d’uso dei miei dati e do il mio consenso.';

  @override
  String get signupConsentNotGiven => 'Non hai dato il consenso';

  @override
  String get signupCreating => 'Creazione in corso…';

  @override
  String get signupCreateBtn => 'Crea il mio account';

  @override
  String get signupSuccess => 'Account creato con successo.';

  @override
  String get signupEmailAlreadyExistsRedirect => 'La tua email è già nel nostro database! Inserisci un altro indirizzo e-mail oppure vai alla sezione “Password dimenticata”.';

  @override
  String get signupSelectBirthdate => 'Seleziona una data di nascita';

  @override
  String get signupChooseGenotype => 'Scegli un genotipo';

  @override
  String get signupChooseSecretQuestion => 'Scegli una domanda di sicurezza';

  @override
  String get signupEnterSecretAnswer => 'Inserisci la risposta segreta';

  @override
  String signupApiFailed(int code, String body) {
    return 'Errore API ($code): $body';
  }

  @override
  String get forgotPasswordTitle => 'Password dimenticata';

  @override
  String get forgotEmailLabel => 'Indirizzo email';

  @override
  String get forgotFetchQuestionTooltip => 'Recupera la domanda';

  @override
  String get forgotEnterValidEmail => 'Inserisci un\'email valida.';

  @override
  String get forgotUnknownEmail => 'Email sconosciuta.';

  @override
  String forgotErrorCode(int code) {
    return 'Errore ($code)';
  }

  @override
  String get forgotTimeoutRetry => 'Tempo scaduto. Riprova.';

  @override
  String forgotErrorWithMessage(String message) {
    return 'Errore: $message';
  }

  @override
  String get forgotQuestionFallback => 'Domanda di sicurezza';

  @override
  String get forgotQuestionLabel => 'Domanda';

  @override
  String get forgotSecretAnswerLabel => 'Risposta segreta';

  @override
  String get forgotAnswerRequired => 'La risposta è obbligatoria';

  @override
  String get forgotEnterYourAnswer => 'Inserisci la tua risposta.';

  @override
  String get forgotVerify => 'Verifica';

  @override
  String get forgotAnswerCorrectSnack => 'Risposta corretta 👍';

  @override
  String forgotAnswerIncorrectAttempts(int attempts) {
    return 'Risposta errata ($attempts/3).';
  }

  @override
  String forgotFailedAttempts(int attempts) {
    return 'Tentativi falliti: $attempts / 3';
  }

  @override
  String get forgotAnswerOkHint => '✅ Risposta corretta, puoi impostare una nuova password.';

  @override
  String get forgotNewPasswordLabel => 'Nuova password';

  @override
  String get forgotPasswordRequired => 'La password è obbligatoria';

  @override
  String get forgotPasswordTooWeak => 'La password è troppo debole';

  @override
  String get forgotPwdRuleMin8 => 'Almeno 8 caratteri';

  @override
  String get forgotPwdRuleUpper => 'Almeno 1 lettera maiuscola';

  @override
  String get forgotPwdRuleSpecial => 'Almeno 1 carattere speciale';

  @override
  String get forgotConfirmPasswordLabel => 'Conferma password';

  @override
  String get forgotEnterNewPasswordFirst => 'Inserisci prima la nuova password';

  @override
  String get forgotPasswordsDoNotMatch => 'Le password non coincidono';

  @override
  String get forgotPasswordsMatch => 'Le password coincidono';

  @override
  String get forgotResetSuccess => 'Password reimpostata ✅';

  @override
  String forgotResetFailed(int code) {
    return 'Operazione fallita ($code).';
  }

  @override
  String get tooManyAttemptsTitle => 'Troppi tentativi';

  @override
  String get tooManyAttemptsMessage => 'Troppi tentativi.\n\nScrivi a contact@angelmananalytics.org per spiegare il tuo problema di accesso.';

  @override
  String get forgotValidating => 'Invio in corso…';

  @override
  String get editProfileTitle => 'Modifica profilo';

  @override
  String get loadingProfile => 'Caricamento profilo…';

  @override
  String get timeoutLoadingProfile => 'Tempo scaduto durante il caricamento del profilo.';

  @override
  String errorLoadingProfile(String message) {
    return 'Errore di caricamento: $message';
  }

  @override
  String get import => 'Importa';

  @override
  String get deleteMyPhoto => 'Elimina la mia foto';

  @override
  String get cancelSelection => 'Annulla selezione';

  @override
  String photoTooLarge(String size) {
    return 'La foto supera i 4 MB ($size MB).';
  }

  @override
  String cannotGetPhoto(String message) {
    return 'Impossibile ottenere la foto: $message';
  }

  @override
  String get photoRequired => 'Foto obbligatoria';

  @override
  String get photoRequiredAddToSave => 'Aggiungi una foto per salvare';

  @override
  String get photoRequiredAfterDelete => 'Foto obbligatoria: importa o scatta una nuova foto.';

  @override
  String get photoDeleted => 'Foto eliminata ✅';

  @override
  String get profileInfoSection => 'Informazioni del profilo';

  @override
  String get firstName => 'Nome';

  @override
  String get lastName => 'Cognome';

  @override
  String get birthDateLabel => 'Data di nascita (gg/mm/aaaa)';

  @override
  String get birthDateRequired => 'La data di nascita è obbligatoria';

  @override
  String get genotype => 'Genotipo';

  @override
  String get city => 'Città';

  @override
  String get geolocateMe => 'Usa la mia posizione';

  @override
  String get locationUpdated => 'Posizione aggiornata';

  @override
  String locationUpdatedWithCity(String city) {
    return 'Posizione aggiornata ($city)';
  }

  @override
  String get geolocation => 'Geolocalizzazione';

  @override
  String get geolocationHint => 'Ricorda di aggiornare la tua posizione se è cambiata dopo la registrazione.';

  @override
  String get secretQuestionSection => 'Domanda di sicurezza';

  @override
  String get question => 'Domanda';

  @override
  String get answer => 'Risposta';

  @override
  String get changeMyPassword => 'Cambia la mia password';

  @override
  String get changePasswordTitle => 'Cambia la mia password';

  @override
  String get newPasswordLabel => 'Nuova password';

  @override
  String get confirmPasswordLabel => 'Conferma password';

  @override
  String get passwordTooWeak => 'La password è troppo debole';

  @override
  String get enterPassword => 'Inserisci una password';

  @override
  String get passwordsDoNotMatch => 'Le password non coincidono';

  @override
  String get passwordsMatch => 'Le password coincidono';

  @override
  String get pwdRuleMin8 => 'Almeno 8 caratteri';

  @override
  String get pwdRuleUpper => 'Almeno 1 lettera maiuscola';

  @override
  String get pwdRuleSpecial => 'Almeno 1 carattere speciale';

  @override
  String get passwordChanged => 'Password cambiata ✅';

  @override
  String get save => 'Salva';

  @override
  String get saving => 'Salvataggio…';

  @override
  String get savedChanges => 'Modifiche salvate ✅';

  @override
  String get timeoutTryAgain => 'Tempo scaduto. Riprova.';

  @override
  String failedWithCode(int code) {
    return 'Operazione fallita ($code)';
  }

  @override
  String get versionMadeByFastFrance => 'Questa app è sviluppata da Angelman Analytics (www.angelmananalytics.org)';

  @override
  String versionNumber(String version) {
    return 'Versione $version';
  }

  @override
  String get privacyTitle => 'Informativa sulla privacy';

  @override
  String get privacyRightToBeForgotten => 'Diritto all\'oblio';

  @override
  String get privacyDeleteTitle => 'Avviso';

  @override
  String get privacyDeleteConfirmBody => 'Questa azione è irreversibile.\n\nIl tuo profilo e i dati associati verranno eliminati definitivamente.\n\nVuoi continuare?';

  @override
  String get privacyDeletedOkTitle => 'Account eliminato';

  @override
  String get privacyDeletedOkBody => 'Il tuo account è stato eliminato.\nVerrai reindirizzato alla pagina di accesso.';

  @override
  String privacyDeleteFailedWithCode(int code) {
    return 'Impossibile eliminare (codice $code).';
  }

  @override
  String get timeoutRetry => 'Richiesta scaduta. Riprova.';

  @override
  String get consentText => 'Informativa sulla privacy – Applicazione ASConnect\n\n1) Identità del titolare del trattamento\nI dati raccolti nell’applicazione ASConnect sono trattati da AngelmanAnalytics in qualità di titolare del trattamento.\nPer qualsiasi domanda relativa ai dati o all’esercizio dei diritti, è possibile contattarci all’indirizzo: contact@angelmananalytics.org.\n____________________________________________\n2) Finalità del trattamento\nI trattamenti dei dati effettuati tramite l’applicazione perseguono le seguenti finalità:\n• Creazione e gestione dell’account utente per un accesso nominativo all’applicazione ASConnect;\n• Utilizzo delle funzionalità di geolocalizzazione per visualizzare:\n  o Profili di persone interessate secondo diversi criteri (distanza geografica, genotipo, fascia di età);\n  o Miglioramento del servizio e personalizzazione dell’esperienza utente.\n• Estrazione di dati che non consentono l’identificazione delle persone a fini statistici: numero di persone affette dalla sindrome di Angelman, distribuzione per età...\n____________________________________________\n3) Categorie di dati raccolti\nPossono essere raccolti i seguenti dati:\n• Dati identificativi:\n  o sesso, nome, cognome, indirizzo email, password, fotografia,\n  o domanda e risposta segreta (in caso di smarrimento della password);\n• Dati sensibili:\n  o genotipo, localizzazione.\nLa base giuridica di tali trattamenti è il consenso esplicito e informato dell’utente.\n____________________________________________\n4) Periodo di conservazione dei dati\nI dati sono conservati per tutta la durata dell’utilizzo dell’account e successivamente cancellati entro un periodo massimo di 12 mesi dall’ultima attività.\nL’utente può esercitare in qualsiasi momento il diritto all’oblio direttamente nell’applicazione tramite il menu:\nInformativa sulla privacy → Diritto all’oblio.\n____________________________________________\n5) Destinatari e hosting dei dati\nI dati sono ospitati in modo sicuro sui server di PythonAnywhere.\nI dati sono archiviati all’interno dell’Unione Europea.\n(Per maggiori informazioni sulla politica di protezione dei dati del fornitore, consultare https://www.pythonanywhere.com/privacy/.)\nL’applicazione web è ospitata da O2Switch in Francia, consultare https://www.o2switch.fr/du-rgpd.pdf.\n____________________________________________\n6) Diritti degli utenti\nAi sensi del Regolamento (UE) 2016/679 (GDPR), gli utenti dispongono dei seguenti diritti:\n• Diritto di accesso, rettifica e cancellazione («diritto all’oblio») — direttamente tramite il profilo o il menu Informativa sulla privacy → Diritto all’oblio;\n• Diritto di opposizione, portabilità e limitazione del trattamento;\n• Diritto di revocare il consenso in qualsiasi momento.\nPer esercitare tali diritti (diversi dal diritto all’oblio accessibile dall’applicazione), è possibile inviare un’email a contact@angelmananalytics.org.\n____________________________________________\n7) Sicurezza e riservatezza\nTutti i dati sono cifrati durante l’archiviazione e la trasmissione.\nLe password sono trattate secondo le migliori pratiche di sicurezza e tutte le comunicazioni con il servizio avvengono tramite il protocollo HTTPS.\n____________________________________________\n8) Consenso esplicito\nLa registrazione all’applicazione ASConnect richiede il consenso esplicito e informato dell’utente per i trattamenti descritti nella sezione 2.\nL’utente può revocare tale consenso in qualsiasi momento tramite le impostazioni del proprio account o contattando direttamente contact@angelmananalytics.org.';

  @override
  String get contactPageTitle => 'Contattaci';

  @override
  String get contactSendMessageTitle => 'Invia un messaggio';

  @override
  String get contactSubjectLabel => 'Titolo';

  @override
  String get contactSubjectHint => 'Oggetto della tua richiesta';

  @override
  String get contactMessageLabel => 'Messaggio';

  @override
  String get contactMessageHint => 'Descrivi la tua richiesta…';

  @override
  String get contactAntiSpamTitle => 'Verifica anti-spam';

  @override
  String get contactRefresh => 'Aggiorna';

  @override
  String contactCaptchaQuestion(int a, int b) {
    return 'Quanto fa $a + $b?';
  }

  @override
  String get contactCaptchaAnswerLabel => 'Risposta';

  @override
  String get contactCaptchaRequired => 'Captcha obbligatorio';

  @override
  String get contactCaptchaIncorrect => 'Captcha non corretto.';

  @override
  String get contactSend => 'Invia';

  @override
  String get contactSending => 'Invio in corso…';

  @override
  String get contactCancel => 'Annulla';

  @override
  String get contactMessageSent => 'Messaggio inviato ✅';

  @override
  String contactSendFailedWithCode(int code) {
    return 'Invio non riuscito ($code)';
  }

  @override
  String get contactAccessDenied => 'Accesso negato (chiave app mancante o non valida).';

  @override
  String get contactTooManyRequests => 'Troppe richieste. Riprova tra qualche secondo.';

  @override
  String get contactServiceUnavailable => 'Servizio temporaneamente non disponibile. Riprova più tardi.';

  @override
  String get contactCheckInternet => 'Controlla la connessione internet.';

  @override
  String get contactTimeout => 'Tempo scaduto. Riprova più tardi.';

  @override
  String get contactFooterNote => 'Il tuo messaggio viene inviato tramite la nostra API pubblica sicura. Grazie!';

  @override
  String contactMissingAppKey(String command) {
    return '⚠️ Chiave app mancante. Avvia l\'app con $command';
  }

  @override
  String fieldRequired(String field) {
    return '$field è obbligatorio';
  }

  @override
  String unexpectedError(String message) {
    return 'Errore imprevisto: $message';
  }

  @override
  String get commonOk => 'OK';

  @override
  String get commonCancel => 'Annulla';

  @override
  String get commonConfirm => 'Conferma';

  @override
  String get emailRequired => 'L\'email è obbligatoria';

  @override
  String get emailInvalid => 'Email non valida';

  @override
  String get editProfileImport => 'Importa';

  @override
  String get editProfileTakePhoto => 'Scatta una foto';

  @override
  String get editProfileDeletePhoto => 'Elimina la mia foto';

  @override
  String get editProfileCancelSelection => 'Annulla selezione';

  @override
  String get editProfilePhotoRequired => 'Foto obbligatoria';

  @override
  String get editProfilePhotoRequiredHint => 'Foto obbligatoria: importa o scatta una nuova foto.';

  @override
  String get editProfileAddPhotoToSave => 'Aggiungi una foto per salvare';

  @override
  String get editProfilePhotoDeleted => 'Foto eliminata ✅';

  @override
  String editProfilePhotoTooLarge(String size) {
    return 'La foto supera i 4 MB ($size MB).';
  }

  @override
  String editProfilePhotoPickError(String message) {
    return 'Impossibile ottenere la foto: $message';
  }

  @override
  String get editProfileProfileInfoTitle => 'Informazioni del profilo';

  @override
  String get editProfileFirstNameLabel => 'Nome';

  @override
  String get editProfileLastNameLabel => 'Cognome';

  @override
  String get editProfileEmailLabel => 'Indirizzo email';

  @override
  String get editProfileBirthDateLabel => 'Data di nascita (gg/mm/aaaa)';

  @override
  String get editProfileBirthDateHelp => 'Data di nascita';

  @override
  String get editProfileBirthDatePickTooltip => 'Scegli una data';

  @override
  String get editProfileBirthDateRequired => 'La data di nascita è obbligatoria';

  @override
  String get editProfileGenotypeLabel => 'Genotipo';

  @override
  String get editProfileGenotypeRequired => 'Il genotipo è obbligatorio';

  @override
  String get editProfileCityLabel => 'Città';

  @override
  String get editProfileGeolocate => 'Localizzami';

  @override
  String get editProfileGeoTooltip => 'Aggiorna la tua posizione se è cambiata dopo la registrazione.';

  @override
  String get geoTitle => 'Geolocalizzazione';

  @override
  String get geoInfoText => 'Aggiorna la tua posizione se è cambiata dopo la registrazione.';

  @override
  String editProfileLocationUpdated(String cityPart) {
    return 'Posizione aggiornata$cityPart';
  }

  @override
  String get editProfileSecretSectionTitle => 'Domanda segreta';

  @override
  String get editProfileSecretQuestionLabel => 'Domanda';

  @override
  String get editProfileSecretAnswerLabel => 'Risposta segreta';

  @override
  String get editProfileChangePassword => 'Cambia la mia password';

  @override
  String get passwordEnterFirst => 'Inserisci prima una password';

  @override
  String get passwordMismatch => 'Le password non coincidono';

  @override
  String get passwordMatch => 'Le password coincidono';

  @override
  String get editProfilePasswordChanged => 'Password cambiata ✅';

  @override
  String get editProfileSave => 'Salva';

  @override
  String get editProfileSaving => 'Salvataggio…';

  @override
  String get editProfileChangesSaved => 'Modifiche salvate ✅';

  @override
  String get editProfileTimeoutLoading => 'Tempo scaduto durante il caricamento del profilo.';

  @override
  String editProfileLoadError(String message) {
    return 'Errore di caricamento: $message';
  }

  @override
  String get editProfileTimeoutGeneric => 'Tempo scaduto. Riprova.';

  @override
  String editProfileErrorGeneric(String message) {
    return 'Errore: $message';
  }

  @override
  String get genotypeUPD => 'UPD';

  @override
  String get genotypeICD => 'ICD';

  @override
  String get secretQ1 => 'Qual è il cognome da nubile di tua madre?';

  @override
  String get secretQ2 => 'Qual è il nome del tuo attore preferito?';

  @override
  String get secretQ3 => 'Qual è il nome del tuo animale preferito?';

  @override
  String get mapPersonTileIsMeHint => 'Questo è il tuo profilo';

  @override
  String get mapPersonTileSendHint => 'Invia un messaggio…';

  @override
  String get mapPersonTileCannotWriteTooltip => 'Non puoi scrivere a te stesso';

  @override
  String get mapPersonTileSendTooltip => 'Invia';

  @override
  String mapPersonTileSendFailed(Object error) {
    return 'Invio non riuscito: $error';
  }

  @override
  String mapPersonTileAge(int age) {
    return '$age anni';
  }

  @override
  String get mapFiltersButtonTooltip => 'Filtri';

  @override
  String get mapNoFilters => 'Nessun filtro';

  @override
  String mapGenotypeCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count genotipi',
      one: '$count genotipo',
    );
    return '$_temp0';
  }

  @override
  String mapAgeRangeYears(Object max, Object min) {
    return '$min–$max anni';
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
      other: '$count persone',
      one: '$count persona',
    );
    return '$_temp0';
  }

  @override
  String get mapReloadFromNetworkTooltip => 'Ricarica (rete, ignora filtri, aggiorna cache)';

  @override
  String get mapTilesBlockedInReleaseMessage => 'Le tile OSM sono disabilitate in produzione.\nConfigura una chiave MapTiler (o imposta allowOsmInRelease=true).';

  @override
  String get mapInitializingDataMessage => 'Stiamo inizializzando tutti i dati…';

  @override
  String mapNetworkUnavailableCacheUsed(Object error) {
    return 'Rete non disponibile — cache utilizzata: $error';
  }

  @override
  String mapLoadGenericError(Object error) {
    return 'Errore di caricamento: $error';
  }

  @override
  String mapFilterError(Object error) {
    return 'Errore filtro: $error';
  }

  @override
  String get mapLocationServiceDisabled => 'Servizio di localizzazione disattivato';

  @override
  String get mapLocationPermissionDenied => 'Permesso di localizzazione negato';

  @override
  String mapLocationUnavailable(Object error) {
    return 'Posizione non disponibile: $error';
  }

  @override
  String get mapPhotoViewerBarrierLabel => 'Foto';

  @override
  String get mapClose => 'Chiudi';

  @override
  String mapCityPeopleCount(Object city, num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count persone',
      one: '$count persona',
    );
    return '$city • $_temp0';
  }

  @override
  String mapResultsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count risultati',
      one: '$count risultato',
    );
    return '$_temp0';
  }

  @override
  String get mapNoResultsWithTheseFilters => 'Nessun risultato con questi filtri (genotipo/distanza).';

  @override
  String get mapDistanceTitle => 'Distanza (dalla mia posizione)';

  @override
  String get mapEnableDistanceFilter => 'Abilita filtro distanza';

  @override
  String mapOriginDefined(Object lat, Object lon) {
    return 'Origine: $lat, $lon';
  }

  @override
  String get mapOriginUndefined => 'Origine: non impostata';

  @override
  String get mapMyPosition => 'La mia posizione';

  @override
  String mapKmLabel(Object km) {
    return '$km km';
  }

  @override
  String get mapGenotypeTitle => 'Genotipo';

  @override
  String get mapAgeTitle => 'Età (anni)';

  @override
  String mapMinValue(Object value) {
    return 'Min: $value';
  }

  @override
  String mapMaxValue(Object value) {
    return 'Max: $value';
  }

  @override
  String get mapReset => 'Reimposta';

  @override
  String get mapCancel => 'Annulla';

  @override
  String get mapApply => 'Applica';

  @override
  String get mapCountryTitle => 'Paesi';

  @override
  String get mapAllCountriesSelected => 'Tutti i paesi';

  @override
  String mapCountriesSelectedCount(int count) {
    return '$count paesi selezionati';
  }

  @override
  String get mapSelectAll => 'Seleziona tutto';

  @override
  String get mapClear => 'Cancella selezione';

  @override
  String get mapBack => 'Indietro';

  @override
  String chatWithName(Object name) {
    return 'Chat con $name';
  }

  @override
  String get conversationsReconnectToSee => 'Accedi di nuovo per visualizzare le tue conversazioni.';

  @override
  String get loading => 'Caricamento…';

  @override
  String get conversationsEmpty => 'Nessuna conversazione';

  @override
  String get conversationsNoMessage => 'Nessun messaggio';

  @override
  String conversationsLoadError(Object error) {
    return 'Errore di caricamento: $error';
  }

  @override
  String get conversationsLeaveTitle => 'Uscire dalla conversazione?';

  @override
  String get conversationsLeaveBody => 'Sei sicuro di voler uscire da questa conversazione?\nTutti i tuoi messaggi verranno eliminati.';

  @override
  String get conversationsLeaveConfirm => 'Esci';

  @override
  String get close => 'Chiudi';

  @override
  String get photo => 'Foto';

  @override
  String get yesterday => 'ieri';

  @override
  String genericError(Object error) {
    return 'Errore: $error';
  }

  @override
  String get today => 'Oggi';

  @override
  String get chatNoMessagesYet => 'Nessun messaggio ancora.';

  @override
  String chatLoadMessagesError(Object error) {
    return 'Errore nel caricamento dei messaggi: $error';
  }

  @override
  String chatSendError(Object error) {
    return 'Errore durante l\'invio: $error';
  }

  @override
  String get chatEditMessageTitle => 'Modifica messaggio';

  @override
  String get chatYourMessageHint => 'Il tuo messaggio';

  @override
  String chatEditError(Object error) {
    return 'Errore durante la modifica: $error';
  }

  @override
  String get chatDeleteMessageTitle => 'Eliminare il messaggio?';

  @override
  String get chatDeleteMessageBody => 'Questo messaggio verrà contrassegnato come eliminato in questa conversazione.';

  @override
  String chatDeleteError(Object error) {
    return 'Errore durante l\'eliminazione: $error';
  }

  @override
  String chatReactError(Object error) {
    return 'Errore durante la reazione: $error';
  }

  @override
  String get chatLeaveConversationBody => 'Sei sicuro di voler uscire dalla conversazione ed eliminare tutti i tuoi messaggi?';

  @override
  String chatLeaveError(Object error) {
    return 'Errore durante l\'uscita: $error';
  }

  @override
  String get message => 'Messaggio';

  @override
  String get send => 'Invia';

  @override
  String get edited => 'modificato';

  @override
  String get deletedMessage => 'Messaggio eliminato';

  @override
  String get edit => 'Modifica';

  @override
  String get reply => 'Rispondi';

  @override
  String get delete => 'Elimina';

  @override
  String get languageName => 'Italiano';

  @override
  String get mapConnectionSectionTitle => 'Connessione';

  @override
  String get mapConnectedOnlyLabel => 'Mostra solo le persone connesse';

  @override
  String get mapConnectedOnlyHint => 'Nasconde i profili offline.';

  @override
  String get mapConnectedOnlyChip => 'Connessi';

  @override
  String get statusOnline => 'Disponibile';

  @override
  String get statusOffline => 'Non disponibile';

  @override
  String get tableTabular => 'Tabella';

  @override
  String get tableColumnPseudo => 'Nome utente';

  @override
  String get tableColumnAge => 'Età';

  @override
  String get tableColumnGenotype => 'Genotipo';

  @override
  String get tableColumnCountry => 'Paese';

  @override
  String get tableColumnCity => 'Città';

  @override
  String get tabularColPseudo => 'Nome utente';

  @override
  String get tabularColAge => 'Età';

  @override
  String get tabularColGenotype => 'Genotipo';

  @override
  String get tabularColCountry => 'Paese';

  @override
  String get tabularColCity => 'Città';

  @override
  String get tabularColAction => 'Azione';

  @override
  String get tabularSendMessageTooltip => 'Invia un messaggio';

  @override
  String get tabularSendMessageErrorNoId => 'Impossibile inviare il messaggio: identificatore mancante.';

  @override
  String get tabularSendMessageActionStub => 'Funzionalità di messaggistica da collegare.';

  @override
  String tabularSendMessageTitle(Object name) {
    return 'Messaggio a $name';
  }

  @override
  String get tabularSendMessageHint => 'Scrivi un messaggio…';

  @override
  String get tabularSendMessageSend => 'Invia';

  @override
  String get tabularSendMessageSentStub => 'Messaggio pronto per l’invio (da collegare).';

  @override
  String get tabularSendMessageCancel => 'Annulla';

  @override
  String get genderLabel => 'Sesso';

  @override
  String get genderMale => 'Uomo';

  @override
  String get genderFemale => 'Donna';

  @override
  String get genderRequired => 'Seleziona un sesso';

  @override
  String get acceptInfoAngelman => 'Accetto di ricevere informazioni sulla sindrome di Angelman';

  @override
  String get signupEnableGeolocation => 'Per favore, autorizza la geolocalizzazione per continuare.';

  @override
  String get signUpCheckMail => 'Verifica dell’email';

  @override
  String get signUpGPS => 'Determinazione delle coordinate della tua città dalla posizione GPS';

  @override
  String get signUpMessageCreate => 'Creazione del profilo';

  @override
  String get tabGroup => 'Gruppo';

  @override
  String groupMembersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count membri',
      one: '$count membro',
    );
    return '$_temp0';
  }
}
