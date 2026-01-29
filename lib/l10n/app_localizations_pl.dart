// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get appTitle => 'ASConnexion';

  @override
  String get systemLanguage => 'System';

  @override
  String get menu => 'Menu';

  @override
  String get menuNavigation => 'Nawigacja';

  @override
  String get menuMyProfile => 'Mój profil';

  @override
  String get menuContact => 'Skontaktuj się z nami';

  @override
  String get menuPrivacyPolicy => 'Polityka prywatności';

  @override
  String get menuVersion => 'Wersja';

  @override
  String get menuContactSubject => 'Kontakt przez aplikację';

  @override
  String get languageLabel => 'Język';

  @override
  String currentLanguage(String label) {
    return 'Aktualnie: $label';
  }

  @override
  String get cancel => 'Anuluj';

  @override
  String get confirm => 'Potwierdź';

  @override
  String get ok => 'OK';

  @override
  String get logoutTitle => 'Wyloguj się';

  @override
  String get logoutConfirm => 'Czy na pewno chcesz się wylogować z aplikacji?';

  @override
  String get tabCommunity => 'Połącz się ze społecznością';

  @override
  String get tabChats => 'Moje czaty';

  @override
  String get tabPoi => 'Punkty zainteresowania';

  @override
  String get profileUpdated => 'Profil zaktualizowany ✅';

  @override
  String get loginTitle => 'Zaloguj się';

  @override
  String get loginIntro => 'Aplikacja ASConnect jest przeznaczona wyłącznie dla opiekunów, którzy mają dziecko z zespołem Angelmana, rzadką chorobą genetyczną.';

  @override
  String get emailLabel => 'Adres e-mail';

  @override
  String get emailHintRequired => 'Wpisz swój e-mail';

  @override
  String get emailHintInvalid => 'Nieprawidłowy e-mail';

  @override
  String get passwordLabel => 'Hasło';

  @override
  String get show => 'Pokaż';

  @override
  String get hide => 'Ukryj';

  @override
  String get passwordRequired => 'Wpisz swoje hasło';

  @override
  String get loginButton => 'Zaloguj się';

  @override
  String get loginLoading => 'Logowanie…';

  @override
  String get createAccount => 'Utwórz konto';

  @override
  String get forgotPassword => 'Nie pamiętasz hasła?';

  @override
  String get invalidCredentials => 'Nieprawidłowe dane logowania.';

  @override
  String get accessDeniedKey => 'Odmowa dostępu: brak lub nieprawidłowy klucz aplikacji.';

  @override
  String get badRequest => 'Nieprawidłowe żądanie (400).';

  @override
  String get tooManyAttempts => 'Zbyt wiele prób. Spróbuj ponownie za chwilę.';

  @override
  String get serviceUnavailable => 'Usługa niedostępna. Spróbuj ponownie później.';

  @override
  String serverErrorWithCode(int code) {
    return 'Błąd serwera ($code).';
  }

  @override
  String get unexpectedServerResponse => 'Nieoczekiwana odpowiedź serwera.';

  @override
  String get cannotConnectServer => 'Nie można połączyć się z serwerem.';

  @override
  String get timeoutCheckConnection => 'Przekroczono limit czasu. Sprawdź połączenie.';

  @override
  String errorWithMessage(String message) {
    return 'Błąd: $message';
  }

  @override
  String get missingAppKeyWarning => '⚠️ Brak klucza aplikacji. Uruchom aplikację z --dart-define=PUBLIC_APP_KEY=your_public_key';

  @override
  String get signupTitle => 'Utwórz konto';

  @override
  String get signupSectionPerson => 'Osoba z zespołem Angelmana';

  @override
  String get signupSectionAuth => 'Uwierzytelnianie';

  @override
  String get consentTitle => 'Zgoda';

  @override
  String get firstNameLabel => 'Imię';

  @override
  String get firstNameRequired => 'Imię jest wymagane';

  @override
  String get lastNameLabel => 'Nazwisko';

  @override
  String get lastNameRequired => 'Nazwisko jest wymagane';

  @override
  String get birthdateLabel => 'Data urodzenia (dd/mm/rrrr)';

  @override
  String get birthdateRequired => 'Data urodzenia jest wymagana';

  @override
  String get chooseDate => 'Wybierz datę';

  @override
  String get signupBirthdateHelp => 'Data urodzenia';

  @override
  String get genotypeLabel => 'Genotyp';

  @override
  String get genotypeRequired => 'Genotyp jest wymagany';

  @override
  String get genotypeDeletion => 'Delecja';

  @override
  String get genotypeMutation => 'Mutacja';

  @override
  String get genotypeUpd => 'UPD';

  @override
  String get genotypeIcd => 'ICD';

  @override
  String get genotypeClinical => 'Kliniczny';

  @override
  String get genotypeMosaic => 'Mozaikowy';

  @override
  String get signupPhotoHint => 'Zdjęcie dziecka (wymagane, < 4 MB)';

  @override
  String get importPhoto => 'Importuj zdjęcie';

  @override
  String get takePhoto => 'Zrób zdjęcie';

  @override
  String get deletePhoto => 'Usuń zdjęcie';

  @override
  String get signupPhotoRequired => 'Zdjęcie jest wymagane';

  @override
  String get signupAddPhotoToContinue => 'Dodaj zdjęcie, aby kontynuować';

  @override
  String signupPhotoTooLarge(String mb) {
    return 'Zdjęcie przekracza 4 MB ($mb MB).';
  }

  @override
  String signupPhotoCannotLoad(String message) {
    return 'Nie można wczytać zdjęcia: $message';
  }

  @override
  String get signupPasswordTooWeak => 'Hasło jest zbyt słabe';

  @override
  String get signupPwdRuleMin8 => 'Min. 8 znaków';

  @override
  String get signupPwdRuleUpper => '1 wielka litera';

  @override
  String get signupPwdRuleDigit => '1 cyfra';

  @override
  String get signupPwdRuleSpecial => '1 znak specjalny';

  @override
  String get secretQuestionLabel => 'Pytanie zabezpieczające';

  @override
  String get secretQuestionRequired => 'Pytanie zabezpieczające jest wymagane';

  @override
  String get secretQuestion1 => 'Nazwisko panieńskie matki?';

  @override
  String get secretQuestion2 => 'Imię i nazwisko ulubionego aktora filmowego?';

  @override
  String get secretQuestion3 => 'Imię ulubionego zwierzaka?';

  @override
  String get secretAnswerLabel => 'Odpowiedź';

  @override
  String get secretAnswerRequired => 'Odpowiedź jest wymagana';

  @override
  String get consentCheckbox => 'Akceptuję warunki korzystania z moich danych i wyrażam zgodę.';

  @override
  String get signupConsentNotGiven => 'Nie wyrażono zgody';

  @override
  String get signupCreating => 'Tworzenie…';

  @override
  String get signupCreateBtn => 'Utwórz moje konto';

  @override
  String get signupSuccess => 'Konto utworzone pomyślnie.';

  @override
  String get signupEmailAlreadyExistsRedirect => 'Twój e-mail jest już w naszej bazie danych! Wpisz inny adres e-mail lub przejdź do sekcji „Nie pamiętam hasła”.';

  @override
  String get signupSelectBirthdate => 'Wybierz datę urodzenia';

  @override
  String get signupChooseGenotype => 'Wybierz genotyp';

  @override
  String get signupChooseSecretQuestion => 'Wybierz pytanie zabezpieczające';

  @override
  String get signupEnterSecretAnswer => 'Wpisz odpowiedź zabezpieczającą';

  @override
  String signupApiFailed(int code, String body) {
    return 'Błąd API ($code): $body';
  }

  @override
  String get forgotPasswordTitle => 'Nie pamiętasz hasła';

  @override
  String get forgotEmailLabel => 'Adres e-mail';

  @override
  String get forgotFetchQuestionTooltip => 'Pobierz pytanie';

  @override
  String get forgotEnterValidEmail => 'Wpisz prawidłowy e-mail.';

  @override
  String get forgotUnknownEmail => 'Nieznany e-mail.';

  @override
  String forgotErrorCode(int code) {
    return 'Błąd ($code)';
  }

  @override
  String get forgotTimeoutRetry => 'Przekroczono limit czasu. Spróbuj ponownie.';

  @override
  String forgotErrorWithMessage(String message) {
    return 'Błąd: $message';
  }

  @override
  String get forgotQuestionFallback => 'Pytanie zabezpieczające';

  @override
  String get forgotQuestionLabel => 'Pytanie';

  @override
  String get forgotSecretAnswerLabel => 'Odpowiedź zabezpieczająca';

  @override
  String get forgotAnswerRequired => 'Odpowiedź jest wymagana';

  @override
  String get forgotEnterYourAnswer => 'Wpisz swoją odpowiedź.';

  @override
  String get forgotVerify => 'Zweryfikuj';

  @override
  String get forgotAnswerCorrectSnack => 'Poprawna odpowiedź 👍';

  @override
  String forgotAnswerIncorrectAttempts(int attempts) {
    return 'Niepoprawna odpowiedź ($attempts/3).';
  }

  @override
  String forgotFailedAttempts(int attempts) {
    return 'Nieudane próby: $attempts / 3';
  }

  @override
  String get forgotAnswerOkHint => '✅ Poprawna odpowiedź, możesz ustawić nowe hasło.';

  @override
  String get forgotNewPasswordLabel => 'Nowe hasło';

  @override
  String get forgotPasswordRequired => 'Hasło jest wymagane';

  @override
  String get forgotPasswordTooWeak => 'Hasło jest zbyt słabe';

  @override
  String get forgotPwdRuleMin8 => 'Co najmniej 8 znaków';

  @override
  String get forgotPwdRuleUpper => 'Co najmniej 1 wielka litera';

  @override
  String get forgotPwdRuleSpecial => 'Co najmniej 1 znak specjalny';

  @override
  String get forgotConfirmPasswordLabel => 'Potwierdź hasło';

  @override
  String get forgotEnterNewPasswordFirst => 'Najpierw wpisz nowe hasło';

  @override
  String get forgotPasswordsDoNotMatch => 'Hasła nie są takie same';

  @override
  String get forgotPasswordsMatch => 'Hasła są takie same';

  @override
  String get forgotResetSuccess => 'Hasło zresetowane ✅';

  @override
  String forgotResetFailed(int code) {
    return 'Niepowodzenie ($code).';
  }

  @override
  String get tooManyAttemptsTitle => 'Zbyt wiele prób';

  @override
  String get tooManyAttemptsMessage => 'Zbyt wiele prób.\n\nWyślij e-mail na contact@fastfrance.org i opisz problem z logowaniem.';

  @override
  String get forgotValidating => 'Wysyłanie…';

  @override
  String get editProfileTitle => 'Edytuj profil';

  @override
  String get loadingProfile => 'Ładowanie profilu…';

  @override
  String get timeoutLoadingProfile => 'Przekroczono limit czasu podczas ładowania profilu.';

  @override
  String errorLoadingProfile(String message) {
    return 'Błąd ładowania: $message';
  }

  @override
  String get import => 'Importuj';

  @override
  String get deleteMyPhoto => 'Usuń moje zdjęcie';

  @override
  String get cancelSelection => 'Anuluj wybór';

  @override
  String photoTooLarge(String size) {
    return 'Zdjęcie przekracza 4 MB ($size MB).';
  }

  @override
  String cannotGetPhoto(String message) {
    return 'Nie można pobrać zdjęcia: $message';
  }

  @override
  String get photoRequired => 'Wymagane zdjęcie';

  @override
  String get photoRequiredAddToSave => 'Dodaj zdjęcie, aby zapisać';

  @override
  String get photoRequiredAfterDelete => 'Wymagane zdjęcie: zaimportuj lub zrób nowe.';

  @override
  String get photoDeleted => 'Zdjęcie usunięte ✅';

  @override
  String get profileInfoSection => 'Informacje o profilu';

  @override
  String get firstName => 'Imię';

  @override
  String get lastName => 'Nazwisko';

  @override
  String get birthDateLabel => 'Data urodzenia (dd/mm/rrrr)';

  @override
  String get birthDateRequired => 'Data urodzenia jest wymagana';

  @override
  String get genotype => 'Genotyp';

  @override
  String get city => 'Miasto';

  @override
  String get geolocateMe => 'Użyj mojej lokalizacji';

  @override
  String get locationUpdated => 'Lokalizacja zaktualizowana';

  @override
  String locationUpdatedWithCity(String city) {
    return 'Lokalizacja zaktualizowana ($city)';
  }

  @override
  String get geolocation => 'Geolokalizacja';

  @override
  String get geolocationHint => 'Pamiętaj, aby zaktualizować lokalizację, jeśli zmieniła się od czasu rejestracji.';

  @override
  String get secretQuestionSection => 'Pytanie zabezpieczające';

  @override
  String get question => 'Pytanie';

  @override
  String get answer => 'Odpowiedź';

  @override
  String get changeMyPassword => 'Zmień moje hasło';

  @override
  String get changePasswordTitle => 'Zmień moje hasło';

  @override
  String get newPasswordLabel => 'Nowe hasło';

  @override
  String get confirmPasswordLabel => 'Potwierdź hasło';

  @override
  String get passwordTooWeak => 'Hasło jest zbyt słabe';

  @override
  String get enterPassword => 'Wpisz hasło';

  @override
  String get passwordsDoNotMatch => 'Hasła nie są takie same';

  @override
  String get passwordsMatch => 'Hasła są takie same';

  @override
  String get pwdRuleMin8 => 'Co najmniej 8 znaków';

  @override
  String get pwdRuleUpper => 'Co najmniej 1 wielka litera';

  @override
  String get pwdRuleSpecial => 'Co najmniej 1 znak specjalny';

  @override
  String get passwordChanged => 'Hasło zmienione ✅';

  @override
  String get save => 'Zapisz';

  @override
  String get saving => 'Zapisywanie…';

  @override
  String get savedChanges => 'Zmiany zapisane ✅';

  @override
  String get timeoutTryAgain => 'Przekroczono limit czasu. Spróbuj ponownie.';

  @override
  String failedWithCode(int code) {
    return 'Niepowodzenie ($code)';
  }

  @override
  String get versionMadeByFastFrance => 'Ta aplikacja została opracowana przez Angelman Analytics (www.angelmananalytics.org)';

  @override
  String versionNumber(String version) {
    return 'Wersja $version';
  }

  @override
  String get privacyTitle => 'Polityka prywatności';

  @override
  String get privacyRightToBeForgotten => 'Prawo do bycia zapomnianym';

  @override
  String get privacyDeleteTitle => 'Ostrzeżenie';

  @override
  String get privacyDeleteConfirmBody => 'To działanie jest nieodwracalne.\n\nTwój profil i powiązane dane zostaną trwale usunięte.\n\nCzy chcesz kontynuować?';

  @override
  String get privacyDeletedOkTitle => 'Konto usunięte';

  @override
  String get privacyDeletedOkBody => 'Twoje konto zostało usunięte.\nZostaniesz przekierowany(-a) na stronę logowania.';

  @override
  String privacyDeleteFailedWithCode(int code) {
    return 'Nie można usunąć (kod $code).';
  }

  @override
  String get timeoutRetry => 'Przekroczono limit czasu. Spróbuj ponownie.';

  @override
  String get consentText => 'Polityka prywatności – Aplikacja ASConnect\n\n1) Tożsamość administratora danych\nDane zbierane w aplikacji ASConnect są przetwarzane przez AngelmanAnalytics jako administratora danych.\nW przypadku pytań dotyczących danych lub wykonywania praw można skontaktować się z nami pod adresem: contact@angelmananalytics.org.\n____________________________________________\n2) Cele przetwarzania\nPrzetwarzanie danych realizowane za pośrednictwem aplikacji ma następujące cele:\n• Tworzenie i zarządzanie kontem użytkownika w celu imiennego dostępu do aplikacji ASConnect;\n• Korzystanie z funkcji geolokalizacji w celu wyświetlania:\n  o Profili osób zainteresowanych według różnych kryteriów (odległość geograficzna, genotyp, przedział wiekowy);\n  o Poprawy usługi i personalizacji doświadczenia użytkownika.\n• Pozyskiwanie danych, które nie pozwalają na identyfikację osób, do celów statystycznych: liczba osób dotkniętych zespołem Angelmana, rozkład wiekowy...\n____________________________________________\n3) Kategorie zbieranych danych\nMogą być zbierane następujące dane:\n• Dane identyfikacyjne:\n  o płeć, imię, nazwisko, adres e-mail, hasło, zdjęcie,\n  o pytanie i odpowiedź tajna (w przypadku utraty hasła);\n• Dane wrażliwe:\n  o genotyp, lokalizacja.\nPodstawą prawną przetwarzania jest wyraźna i świadoma zgoda użytkownika.\n____________________________________________\n4) Okres przechowywania danych\nDane są przechowywane przez cały okres korzystania z konta, a następnie usuwane w terminie nie dłuższym niż 12 miesięcy od ostatniej aktywności.\nUżytkownik może w każdej chwili skorzystać z prawa do bycia zapomnianym bezpośrednio w aplikacji poprzez menu:\nPolityka prywatności → Prawo do bycia zapomnianym.\n____________________________________________\n5) Odbiorcy i hosting danych\nDane są bezpiecznie przechowywane na serwerach PythonAnywhere.\nDane są przechowywane na terenie Unii Europejskiej.\n(Więcej informacji na temat polityki ochrony danych dostawcy znajduje się na stronie https://www.pythonanywhere.com/privacy/.)\nAplikacja internetowa jest hostowana przez O2Switch we Francji, zob. https://www.o2switch.fr/du-rgpd.pdf.\n____________________________________________\n6) Prawa użytkowników\nZgodnie z rozporządzeniem (UE) 2016/679 (RODO) użytkownikom przysługują następujące prawa:\n• Prawo dostępu, sprostowania i usunięcia danych („prawo do bycia zapomnianym”) — bezpośrednio poprzez profil lub menu Polityka prywatności → Prawo do bycia zapomnianym;\n• Prawo sprzeciwu, przenoszenia danych i ograniczenia przetwarzania;\n• Prawo do cofnięcia zgody w dowolnym momencie.\nW celu skorzystania z tych praw (z wyjątkiem prawa do bycia zapomnianym dostępnego w aplikacji) można wysłać wiadomość e-mail na adres contact@angelmananalytics.org.\n____________________________________________\n7) Bezpieczeństwo i poufność\nWszystkie dane są szyfrowane podczas przechowywania i transmisji.\nHasła są haszowane zgodnie z najlepszymi praktykami bezpieczeństwa, a cała komunikacja z usługą odbywa się za pośrednictwem protokołu HTTPS.\n____________________________________________\n8) Wyraźna zgoda\nRejestracja w aplikacji ASConnect wymaga wyraźnej i świadomej zgody użytkownika na przetwarzanie opisane w sekcji 2.\nUżytkownik może wycofać tę zgodę w dowolnym momencie poprzez ustawienia konta lub kontaktując się bezpośrednio pod adresem contact@angelmananalytics.org.';

  @override
  String get contactPageTitle => 'Skontaktuj się z nami';

  @override
  String get contactSendMessageTitle => 'Wyślij wiadomość';

  @override
  String get contactSubjectLabel => 'Tytuł';

  @override
  String get contactSubjectHint => 'Temat Twojego zgłoszenia';

  @override
  String get contactMessageLabel => 'Wiadomość';

  @override
  String get contactMessageHint => 'Opisz swoje zgłoszenie…';

  @override
  String get contactAntiSpamTitle => 'Kontrola anty-spam';

  @override
  String get contactRefresh => 'Odśwież';

  @override
  String contactCaptchaQuestion(int a, int b) {
    return 'Ile to jest $a + $b?';
  }

  @override
  String get contactCaptchaAnswerLabel => 'Odpowiedź';

  @override
  String get contactCaptchaRequired => 'Captcha jest wymagana';

  @override
  String get contactCaptchaIncorrect => 'Nieprawidłowa captcha.';

  @override
  String get contactSend => 'Wyślij';

  @override
  String get contactSending => 'Wysyłanie…';

  @override
  String get contactCancel => 'Anuluj';

  @override
  String get contactMessageSent => 'Wiadomość wysłana ✅';

  @override
  String contactSendFailedWithCode(int code) {
    return 'Nie udało się wysłać ($code)';
  }

  @override
  String get contactAccessDenied => 'Odmowa dostępu (brak lub nieprawidłowy klucz aplikacji).';

  @override
  String get contactTooManyRequests => 'Zbyt wiele żądań. Spróbuj ponownie za kilka sekund.';

  @override
  String get contactServiceUnavailable => 'Usługa tymczasowo niedostępna. Spróbuj ponownie później.';

  @override
  String get contactCheckInternet => 'Sprawdź połączenie z internetem.';

  @override
  String get contactTimeout => 'Przekroczono limit czasu. Spróbuj ponownie później.';

  @override
  String get contactFooterNote => 'Twoja wiadomość jest wysyłana przez naszą bezpieczną publiczną API. Dziękujemy!';

  @override
  String contactMissingAppKey(String command) {
    return '⚠️ Brak klucza aplikacji. Uruchom aplikację z $command';
  }

  @override
  String fieldRequired(String field) {
    return '$field jest wymagane';
  }

  @override
  String unexpectedError(String message) {
    return 'Nieoczekiwany błąd: $message';
  }

  @override
  String get commonOk => 'OK';

  @override
  String get commonCancel => 'Anuluj';

  @override
  String get commonConfirm => 'Potwierdź';

  @override
  String get emailRequired => 'E-mail jest wymagany';

  @override
  String get emailInvalid => 'Nieprawidłowy e-mail';

  @override
  String get editProfileImport => 'Importuj';

  @override
  String get editProfileTakePhoto => 'Zrób zdjęcie';

  @override
  String get editProfileDeletePhoto => 'Usuń moje zdjęcie';

  @override
  String get editProfileCancelSelection => 'Anuluj wybór';

  @override
  String get editProfilePhotoRequired => 'Wymagane zdjęcie';

  @override
  String get editProfilePhotoRequiredHint => 'Wymagane zdjęcie: zaimportuj lub zrób nowe.';

  @override
  String get editProfileAddPhotoToSave => 'Dodaj zdjęcie, aby zapisać';

  @override
  String get editProfilePhotoDeleted => 'Zdjęcie usunięte ✅';

  @override
  String editProfilePhotoTooLarge(String size) {
    return 'Zdjęcie przekracza 4 MB ($size MB).';
  }

  @override
  String editProfilePhotoPickError(String message) {
    return 'Nie można pobrać zdjęcia: $message';
  }

  @override
  String get editProfileProfileInfoTitle => 'Informacje o profilu';

  @override
  String get editProfileFirstNameLabel => 'Imię';

  @override
  String get editProfileLastNameLabel => 'Nazwisko';

  @override
  String get editProfileEmailLabel => 'Adres e-mail';

  @override
  String get editProfileBirthDateLabel => 'Data urodzenia (dd/mm/rrrr)';

  @override
  String get editProfileBirthDateHelp => 'Data urodzenia';

  @override
  String get editProfileBirthDatePickTooltip => 'Wybierz datę';

  @override
  String get editProfileBirthDateRequired => 'Data urodzenia jest wymagana';

  @override
  String get editProfileGenotypeLabel => 'Genotyp';

  @override
  String get editProfileGenotypeRequired => 'Genotyp jest wymagany';

  @override
  String get editProfileCityLabel => 'Miasto';

  @override
  String get editProfileGeolocate => 'Ustal moją lokalizację';

  @override
  String get editProfileGeoTooltip => 'Zaktualizuj lokalizację, jeśli zmieniła się od rejestracji.';

  @override
  String get geoTitle => 'Geolokalizacja';

  @override
  String get geoInfoText => 'Zaktualizuj lokalizację, jeśli zmieniła się od rejestracji.';

  @override
  String editProfileLocationUpdated(String cityPart) {
    return 'Lokalizacja zaktualizowana$cityPart';
  }

  @override
  String get editProfileSecretSectionTitle => 'Pytanie zabezpieczające';

  @override
  String get editProfileSecretQuestionLabel => 'Pytanie';

  @override
  String get editProfileSecretAnswerLabel => 'Odpowiedź zabezpieczająca';

  @override
  String get editProfileChangePassword => 'Zmień moje hasło';

  @override
  String get passwordEnterFirst => 'Najpierw wpisz hasło';

  @override
  String get passwordMismatch => 'Hasła nie są takie same';

  @override
  String get passwordMatch => 'Hasła są takie same';

  @override
  String get editProfilePasswordChanged => 'Hasło zmienione ✅';

  @override
  String get editProfileSave => 'Zapisz';

  @override
  String get editProfileSaving => 'Zapisywanie…';

  @override
  String get editProfileChangesSaved => 'Zmiany zapisane ✅';

  @override
  String get editProfileTimeoutLoading => 'Przekroczono limit czasu podczas ładowania profilu.';

  @override
  String editProfileLoadError(String message) {
    return 'Błąd ładowania: $message';
  }

  @override
  String get editProfileTimeoutGeneric => 'Przekroczono limit czasu. Spróbuj ponownie.';

  @override
  String editProfileErrorGeneric(String message) {
    return 'Błąd: $message';
  }

  @override
  String get genotypeUPD => 'UPD';

  @override
  String get genotypeICD => 'ICD';

  @override
  String get secretQ1 => 'Jakie jest nazwisko panieńskie Twojej mamy?';

  @override
  String get secretQ2 => 'Jak nazywa się Twój ulubiony aktor filmowy?';

  @override
  String get secretQ3 => 'Jak ma na imię Twoje ulubione zwierzę?';

  @override
  String get mapPersonTileIsMeHint => 'To jest Twój profil';

  @override
  String get mapPersonTileSendHint => 'Wyślij wiadomość…';

  @override
  String get mapPersonTileCannotWriteTooltip => 'Nie możesz wysłać wiadomości do siebie';

  @override
  String get mapPersonTileSendTooltip => 'Wyślij';

  @override
  String mapPersonTileSendFailed(Object error) {
    return 'Nie udało się wysłać: $error';
  }

  @override
  String mapPersonTileAge(int age) {
    return '$age lat';
  }

  @override
  String get mapFiltersButtonTooltip => 'Filtry';

  @override
  String get mapNoFilters => 'Brak filtrów';

  @override
  String mapGenotypeCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count genotypów',
      one: '$count genotyp',
    );
    return '$_temp0';
  }

  @override
  String mapAgeRangeYears(Object max, Object min) {
    return '$min–$max lat';
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
      other: '$count osób',
      one: '$count osoba',
    );
    return '$_temp0';
  }

  @override
  String get mapReloadFromNetworkTooltip => 'Odśwież (sieć, ignoruje filtry, aktualizuje cache)';

  @override
  String get mapTilesBlockedInReleaseMessage => 'Warstwy OSM są wyłączone w produkcji.\nSkonfiguruj klucz MapTiler (lub ustaw allowOsmInRelease=true).';

  @override
  String get mapInitializingDataMessage => 'Inicjalizujemy wszystkie dane…';

  @override
  String mapNetworkUnavailableCacheUsed(Object error) {
    return 'Sieć niedostępna — użyto cache: $error';
  }

  @override
  String mapLoadGenericError(Object error) {
    return 'Błąd ładowania: $error';
  }

  @override
  String mapFilterError(Object error) {
    return 'Błąd filtra: $error';
  }

  @override
  String get mapLocationServiceDisabled => 'Usługa lokalizacji wyłączona';

  @override
  String get mapLocationPermissionDenied => 'Odmowa uprawnień lokalizacji';

  @override
  String mapLocationUnavailable(Object error) {
    return 'Lokalizacja niedostępna: $error';
  }

  @override
  String get mapPhotoViewerBarrierLabel => 'Zdjęcie';

  @override
  String get mapClose => 'Zamknij';

  @override
  String mapCityPeopleCount(Object city, num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count osób',
      one: '$count osoba',
    );
    return '$city • $_temp0';
  }

  @override
  String mapResultsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count wyników',
      one: '$count wynik',
    );
    return '$_temp0';
  }

  @override
  String get mapNoResultsWithTheseFilters => 'Brak wyników dla tych filtrów (genotyp/odległość).';

  @override
  String get mapDistanceTitle => 'Odległość (od mojej lokalizacji)';

  @override
  String get mapEnableDistanceFilter => 'Włącz filtr odległości';

  @override
  String mapOriginDefined(Object lat, Object lon) {
    return 'Punkt odniesienia: $lat, $lon';
  }

  @override
  String get mapOriginUndefined => 'Punkt odniesienia: nie ustawiono';

  @override
  String get mapMyPosition => 'Moja lokalizacja';

  @override
  String mapKmLabel(Object km) {
    return '$km km';
  }

  @override
  String get mapGenotypeTitle => 'Genotyp';

  @override
  String get mapAgeTitle => 'Wiek (lata)';

  @override
  String mapMinValue(Object value) {
    return 'Min: $value';
  }

  @override
  String mapMaxValue(Object value) {
    return 'Maks: $value';
  }

  @override
  String get mapReset => 'Resetuj';

  @override
  String get mapCancel => 'Anuluj';

  @override
  String get mapApply => 'Zastosuj';

  @override
  String get mapCountryTitle => 'Kraje';

  @override
  String get mapAllCountriesSelected => 'Wszystkie kraje';

  @override
  String mapCountriesSelectedCount(int count) {
    return 'Wybrano krajów: $count';
  }

  @override
  String get mapSelectAll => 'Zaznacz wszystko';

  @override
  String get mapClear => 'Wyczyść wybór';

  @override
  String get mapBack => 'Wstecz';

  @override
  String chatWithName(Object name) {
    return 'Czat z $name';
  }

  @override
  String get conversationsReconnectToSee => 'Zaloguj się ponownie, aby zobaczyć swoje rozmowy.';

  @override
  String get loading => 'Ładowanie…';

  @override
  String get conversationsEmpty => 'Brak rozmów';

  @override
  String get conversationsNoMessage => 'Brak wiadomości';

  @override
  String conversationsLoadError(Object error) {
    return 'Błąd ładowania: $error';
  }

  @override
  String get conversationsLeaveTitle => 'Opuścić rozmowę?';

  @override
  String get conversationsLeaveBody => 'Czy na pewno chcesz opuścić tę rozmowę?\nWszystkie Twoje wiadomości zostaną usunięte.';

  @override
  String get conversationsLeaveConfirm => 'Opuść';

  @override
  String get close => 'Zamknij';

  @override
  String get photo => 'Zdjęcie';

  @override
  String get yesterday => 'wczoraj';

  @override
  String genericError(Object error) {
    return 'Błąd: $error';
  }

  @override
  String get today => 'Dzisiaj';

  @override
  String get chatNoMessagesYet => 'Brak wiadomości.';

  @override
  String chatLoadMessagesError(Object error) {
    return 'Błąd ładowania wiadomości: $error';
  }

  @override
  String chatSendError(Object error) {
    return 'Błąd podczas wysyłania: $error';
  }

  @override
  String get chatEditMessageTitle => 'Edytuj wiadomość';

  @override
  String get chatYourMessageHint => 'Twoja wiadomość';

  @override
  String chatEditError(Object error) {
    return 'Błąd podczas edycji: $error';
  }

  @override
  String get chatDeleteMessageTitle => 'Usunąć wiadomość?';

  @override
  String get chatDeleteMessageBody => 'Ta wiadomość zostanie oznaczona jako usunięta w tej rozmowie.';

  @override
  String chatDeleteError(Object error) {
    return 'Błąd podczas usuwania: $error';
  }

  @override
  String chatReactError(Object error) {
    return 'Błąd podczas reakcji: $error';
  }

  @override
  String get chatLeaveConversationBody => 'Czy na pewno chcesz opuścić rozmowę i usunąć wszystkie swoje wiadomości?';

  @override
  String chatLeaveError(Object error) {
    return 'Błąd podczas opuszczania: $error';
  }

  @override
  String get message => 'Wiadomość';

  @override
  String get send => 'Wyślij';

  @override
  String get edited => 'edytowano';

  @override
  String get deletedMessage => 'Usunięta wiadomość';

  @override
  String get edit => 'Edytuj';

  @override
  String get reply => 'Odpowiedz';

  @override
  String get delete => 'Usuń';

  @override
  String get languageName => 'Polski';

  @override
  String get mapConnectionSectionTitle => 'Połączenie';

  @override
  String get mapConnectedOnlyLabel => 'Pokaż tylko osoby połączone';

  @override
  String get mapConnectedOnlyHint => 'Ukrywa profile offline.';

  @override
  String get mapConnectedOnlyChip => 'Połączeni';

  @override
  String get statusOnline => 'Online';

  @override
  String get statusOffline => 'Offline';

  @override
  String get tableTabular => 'Tabela';

  @override
  String get tableColumnPseudo => 'Pseudonim';

  @override
  String get tableColumnAge => 'Wiek';

  @override
  String get tableColumnGenotype => 'Genotyp';

  @override
  String get tableColumnCountry => 'Kraj';

  @override
  String get tableColumnCity => 'Miasto';

  @override
  String get tabularColPseudo => 'Pseudonim';

  @override
  String get tabularColAge => 'Wiek';

  @override
  String get tabularColGenotype => 'Genotyp';

  @override
  String get tabularColCountry => 'Kraj';

  @override
  String get tabularColCity => 'Miasto';

  @override
  String get tabularColAction => 'Akcja';

  @override
  String get tabularSendMessageTooltip => 'Wyślij wiadomość';

  @override
  String get tabularSendMessageErrorNoId => 'Nie można wysłać wiadomości: brak identyfikatora.';

  @override
  String get tabularSendMessageActionStub => 'Funkcja wiadomości nie jest jeszcze podłączona.';

  @override
  String tabularSendMessageTitle(Object name) {
    return 'Wiadomość do $name';
  }

  @override
  String get tabularSendMessageHint => 'Napisz wiadomość…';

  @override
  String get tabularSendMessageSend => 'Wyślij';

  @override
  String get tabularSendMessageSentStub => 'Wiadomość gotowa do wysłania (do podłączenia).';

  @override
  String get tabularSendMessageCancel => 'Anuluj';

  @override
  String get genderLabel => 'Płeć';

  @override
  String get genderMale => 'Mężczyzna';

  @override
  String get genderFemale => 'Kobieta';

  @override
  String get genderRequired => 'Wybierz płeć';

  @override
  String get acceptInfoAngelman => 'Wyrażam zgodę na otrzymywanie informacji o zespole Angelmana';

  @override
  String get signupEnableGeolocation => 'Proszę zezwolić na dostęp do lokalizacji, aby kontynuować.';

  @override
  String get signUpCheckMail => 'Weryfikacja adresu e-mail';

  @override
  String get signUpGPS => 'Ustalanie współrzędnych Twojego miasta na podstawie lokalizacji GPS';

  @override
  String get signUpMessageCreate => 'Tworzenie profilu';
}
