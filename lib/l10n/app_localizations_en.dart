// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'ASConnexion';

  @override
  String get systemLanguage => 'System';

  @override
  String get menu => 'Menu';

  @override
  String get menuNavigation => 'Navigation';

  @override
  String get menuMyProfile => 'My profile';

  @override
  String get menuContact => 'Contact us';

  @override
  String get menuPrivacyPolicy => 'Privacy policy';

  @override
  String get menuVersion => 'Version';

  @override
  String get menuContactSubject => 'Contact via app';

  @override
  String get languageLabel => 'Language';

  @override
  String currentLanguage(String label) {
    return 'Current: $label';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get ok => 'OK';

  @override
  String get logoutTitle => 'Sign out';

  @override
  String get logoutConfirm => 'Are you sure you want to sign out of the app?';

  @override
  String get tabCommunity => 'Connect with the community';

  @override
  String get tabChats => 'My chats';

  @override
  String get tabPoi => 'Points of interest';

  @override
  String get profileUpdated => 'Profile updated ✅';

  @override
  String get loginTitle => 'Sign in';

  @override
  String get loginIntro => 'The ASConnect app is intended only for caregivers who have a child with Angelman syndrome, a rare genetic disorder.';

  @override
  String get emailLabel => 'Email address';

  @override
  String get emailHintRequired => 'Please enter your email';

  @override
  String get emailHintInvalid => 'Invalid email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get show => 'Show';

  @override
  String get hide => 'Hide';

  @override
  String get passwordRequired => 'Please enter your password';

  @override
  String get loginButton => 'Sign in';

  @override
  String get loginLoading => 'Signing in…';

  @override
  String get createAccount => 'Create an account';

  @override
  String get forgotPassword => 'Forgot your password?';

  @override
  String get invalidCredentials => 'Invalid credentials.';

  @override
  String get accessDeniedKey => 'Access denied: missing or invalid app key.';

  @override
  String get badRequest => 'Invalid request (400).';

  @override
  String get tooManyAttempts => 'Too many attempts. Try again in a moment.';

  @override
  String get serviceUnavailable => 'Service unavailable. Please try again later.';

  @override
  String serverErrorWithCode(int code) {
    return 'Server error ($code).';
  }

  @override
  String get unexpectedServerResponse => 'Unexpected server response.';

  @override
  String get cannotConnectServer => 'Unable to connect to the server.';

  @override
  String get timeoutCheckConnection => 'Request timed out. Check your connection.';

  @override
  String errorWithMessage(String message) {
    return 'Error: $message';
  }

  @override
  String get missingAppKeyWarning => '⚠️ App key missing. Run the app with --dart-define=PUBLIC_APP_KEY=your_public_key';

  @override
  String get signupTitle => 'Create an account';

  @override
  String get signupSectionPerson => 'Person with Angelman syndrome';

  @override
  String get signupSectionAuth => 'Authentication';

  @override
  String get consentTitle => 'Consent';

  @override
  String get firstNameLabel => 'First name';

  @override
  String get firstNameRequired => 'First name is required';

  @override
  String get lastNameLabel => 'Last name';

  @override
  String get lastNameRequired => 'Last name is required';

  @override
  String get birthdateLabel => 'Date of birth (dd/mm/yyyy)';

  @override
  String get birthdateRequired => 'Date of birth is required';

  @override
  String get chooseDate => 'Choose a date';

  @override
  String get signupBirthdateHelp => 'Date of birth';

  @override
  String get genotypeLabel => 'Genotype';

  @override
  String get genotypeRequired => 'Genotype is required';

  @override
  String get genotypeDeletion => 'Deletion';

  @override
  String get genotypeMutation => 'Mutation';

  @override
  String get genotypeUpd => 'UPD';

  @override
  String get genotypeIcd => 'ICD';

  @override
  String get genotypeClinical => 'Clinical';

  @override
  String get genotypeMosaic => 'Mosaic';

  @override
  String get signupPhotoHint => 'Child’s photo (required, < 4 MB)';

  @override
  String get importPhoto => 'Import a photo';

  @override
  String get takePhoto => 'Take a photo';

  @override
  String get deletePhoto => 'Delete photo';

  @override
  String get signupPhotoRequired => 'Photo is required';

  @override
  String get signupAddPhotoToContinue => 'Add a photo to continue';

  @override
  String signupPhotoTooLarge(String mb) {
    return 'The photo exceeds 4 MB ($mb MB).';
  }

  @override
  String signupPhotoCannotLoad(String message) {
    return 'Unable to load the photo: $message';
  }

  @override
  String get signupPasswordTooWeak => 'Password is too weak';

  @override
  String get signupPwdRuleMin8 => 'Min. 8 characters';

  @override
  String get signupPwdRuleUpper => '1 uppercase letter';

  @override
  String get signupPwdRuleDigit => '1 digit';

  @override
  String get signupPwdRuleSpecial => '1 special character';

  @override
  String get secretQuestionLabel => 'Security question';

  @override
  String get secretQuestionRequired => 'Security question is required';

  @override
  String get secretQuestion1 => 'Mother’s maiden name?';

  @override
  String get secretQuestion2 => 'Your favorite movie actor’s name?';

  @override
  String get secretQuestion3 => 'Your favorite pet’s name?';

  @override
  String get secretAnswerLabel => 'Answer';

  @override
  String get secretAnswerRequired => 'Answer is required';

  @override
  String get consentCheckbox => 'I accept the terms of use for my data and I give my consent.';

  @override
  String get signupConsentNotGiven => 'You did not give your consent';

  @override
  String get signupCreating => 'Creating…';

  @override
  String get signupCreateBtn => 'Create my account';

  @override
  String get signupSuccess => 'Account created successfully.';

  @override
  String get signupEmailAlreadyExistsRedirect => 'Your email is already in our database. You will be redirected to the login page.';

  @override
  String get signupSelectBirthdate => 'Please select a date of birth';

  @override
  String get signupChooseGenotype => 'Please choose a genotype';

  @override
  String get signupChooseSecretQuestion => 'Please choose a security question';

  @override
  String get signupEnterSecretAnswer => 'Please enter the security answer';

  @override
  String signupApiFailed(int code, String body) {
    return 'API failed ($code): $body';
  }

  @override
  String get forgotPasswordTitle => 'Forgot password';

  @override
  String get forgotEmailLabel => 'Email address';

  @override
  String get forgotFetchQuestionTooltip => 'Fetch the question';

  @override
  String get forgotEnterValidEmail => 'Enter a valid email.';

  @override
  String get forgotUnknownEmail => 'Unknown email.';

  @override
  String forgotErrorCode(int code) {
    return 'Error ($code)';
  }

  @override
  String get forgotTimeoutRetry => 'Timeout. Please try again.';

  @override
  String forgotErrorWithMessage(String message) {
    return 'Error: $message';
  }

  @override
  String get forgotQuestionFallback => 'Security question';

  @override
  String get forgotQuestionLabel => 'Question';

  @override
  String get forgotSecretAnswerLabel => 'Security answer';

  @override
  String get forgotAnswerRequired => 'Answer is required';

  @override
  String get forgotEnterYourAnswer => 'Enter your answer.';

  @override
  String get forgotVerify => 'Verify';

  @override
  String get forgotAnswerCorrectSnack => 'Correct answer 👍';

  @override
  String forgotAnswerIncorrectAttempts(int attempts) {
    return 'Incorrect answer ($attempts/3).';
  }

  @override
  String forgotFailedAttempts(int attempts) {
    return 'Failed attempts: $attempts / 3';
  }

  @override
  String get forgotAnswerOkHint => '✅ Correct answer, you can set a new password.';

  @override
  String get forgotNewPasswordLabel => 'New password';

  @override
  String get forgotPasswordRequired => 'Password is required';

  @override
  String get forgotPasswordTooWeak => 'Password is too weak';

  @override
  String get forgotPwdRuleMin8 => 'At least 8 characters';

  @override
  String get forgotPwdRuleUpper => 'At least 1 uppercase letter';

  @override
  String get forgotPwdRuleSpecial => 'At least 1 special character';

  @override
  String get forgotConfirmPasswordLabel => 'Confirm password';

  @override
  String get forgotEnterNewPasswordFirst => 'Enter the new password first';

  @override
  String get forgotPasswordsDoNotMatch => 'Passwords do not match';

  @override
  String get forgotPasswordsMatch => 'Passwords match';

  @override
  String get forgotResetSuccess => 'Password reset ✅';

  @override
  String forgotResetFailed(int code) {
    return 'Failed ($code).';
  }

  @override
  String get tooManyAttemptsTitle => 'Too many attempts';

  @override
  String get tooManyAttemptsMessage => 'Too many tries.\n\nEmail contact@fastfrance.org to explain your login issue.';

  @override
  String get forgotValidating => 'Submitting…';

  @override
  String get editProfileTitle => 'Edit profile';

  @override
  String get loadingProfile => 'Loading profile…';

  @override
  String get timeoutLoadingProfile => 'Timeout while loading profile.';

  @override
  String errorLoadingProfile(String message) {
    return 'Loading error: $message';
  }

  @override
  String get import => 'Import';

  @override
  String get deleteMyPhoto => 'Delete my photo';

  @override
  String get cancelSelection => 'Cancel selection';

  @override
  String photoTooLarge(String size) {
    return 'The photo exceeds 4 MB ($size MB).';
  }

  @override
  String cannotGetPhoto(String message) {
    return 'Unable to get the photo: $message';
  }

  @override
  String get photoRequired => 'Photo required';

  @override
  String get photoRequiredAddToSave => 'Please add a photo to save';

  @override
  String get photoRequiredAfterDelete => 'Photo required: import or take a new photo.';

  @override
  String get photoDeleted => 'Photo deleted ✅';

  @override
  String get profileInfoSection => 'Profile information';

  @override
  String get firstName => 'First name';

  @override
  String get lastName => 'Last name';

  @override
  String get birthDateLabel => 'Date of birth (dd/mm/yyyy)';

  @override
  String get birthDateRequired => 'Date of birth is required';

  @override
  String get genotype => 'Genotype';

  @override
  String get city => 'City';

  @override
  String get geolocateMe => 'Use my location';

  @override
  String get locationUpdated => 'Location updated';

  @override
  String locationUpdatedWithCity(String city) {
    return 'Location updated ($city)';
  }

  @override
  String get geolocation => 'Geolocation';

  @override
  String get geolocationHint => 'Remember to update your location if it changed since you signed up.';

  @override
  String get secretQuestionSection => 'Security question';

  @override
  String get question => 'Question';

  @override
  String get answer => 'Answer';

  @override
  String get changeMyPassword => 'Change my password';

  @override
  String get changePasswordTitle => 'Change my password';

  @override
  String get newPasswordLabel => 'New password';

  @override
  String get confirmPasswordLabel => 'Confirm password';

  @override
  String get passwordTooWeak => 'Password is too weak';

  @override
  String get enterPassword => 'Enter a password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get passwordsMatch => 'Passwords match';

  @override
  String get pwdRuleMin8 => 'At least 8 characters';

  @override
  String get pwdRuleUpper => 'At least 1 uppercase letter';

  @override
  String get pwdRuleSpecial => 'At least 1 special character';

  @override
  String get passwordChanged => 'Password changed ✅';

  @override
  String get save => 'Save';

  @override
  String get saving => 'Saving…';

  @override
  String get savedChanges => 'Changes saved ✅';

  @override
  String get timeoutTryAgain => 'Timeout. Please try again.';

  @override
  String failedWithCode(int code) {
    return 'Failed ($code)';
  }

  @override
  String get versionMadeByFastFrance => 'This app is developed by Angelman Analytics (www.angelmananalytics.org)';

  @override
  String versionNumber(String version) {
    return 'Version $version';
  }

  @override
  String get privacyTitle => 'Privacy policy';

  @override
  String get privacyRightToBeForgotten => 'Right to be forgotten';

  @override
  String get privacyDeleteTitle => 'Warning';

  @override
  String get privacyDeleteConfirmBody => 'This action is irreversible.\n\nYour profile and associated data will be permanently deleted.\n\nDo you want to continue?';

  @override
  String get privacyDeletedOkTitle => 'Account deleted';

  @override
  String get privacyDeletedOkBody => 'Your account has been deleted.\nYou will be redirected to the login page.';

  @override
  String privacyDeleteFailedWithCode(int code) {
    return 'Unable to delete (code $code).';
  }

  @override
  String get timeoutRetry => 'Request timed out. Please try again.';

  @override
  String get consentText => 'Privacy policy – ASConnect app\n\n1) Data controller\nThe data collected in the ASConnect app is processed by FAST France as the data controller.\nIf you have any questions about your data or how to exercise your rights, contact us at: contact@fastfrance.org.\n\n2) Purposes of processing\nData processing carried out through the app serves the following purposes:\n• Creating and managing your user account to access the ASConnect app;\n• Using geolocation features to display:\n  o points of interest related to Angelman syndrome,\n  o and/or profiles of concerned people, according to various criteria (geographic distance, genotype, age range);\n• Improving the service and personalizing the user experience, including allowing users to choose whether to display a photo, their first name, or last name.\n\n3) Categories of data collected\nThe following data may be collected:\n• Identification data:\n  o last name, first name, email address, password, photo,\n  o secret question and answer (in case of forgotten password);\n• Sensitive data:\n  o genotype, phone location (geolocation).\nThe legal basis for this processing is the user’s explicit and informed consent.\n\n4) Data retention period\nData is kept for the duration of account use, then deleted within a maximum of 12 months after the last activity.\nUsers can exercise their right to be forgotten at any time directly in the app via:\nPrivacy policy → Right to be forgotten.\n\n5) Recipients and data hosting\nData is securely hosted on PythonAnywhere servers.\nData is stored in the European Union.\n(For more information about the host’s privacy policy, see https://www.pythonanywhere.com/privacy/.)\n\n6) Users’ rights\nIn accordance with Regulation (EU) 2016/679 (GDPR), users have the following rights:\n• Right of access, rectification and deletion (“right to be forgotten”) — directly via their profile or via Privacy policy → Right to be forgotten;\n• Right to object, data portability and restriction of processing;\n• Right to withdraw consent at any time.\nTo exercise these rights (other than the in-app right to be forgotten), email: contact@fastfrance.org.\n\n7) Security and confidentiality\nAll data is encrypted during storage and transmission.\nPasswords are hashed according to security best practices, and all communications with the service use HTTPS.\n\n8) Explicit consent\nRegistering for the ASConnect app requires the user’s explicit and informed consent for the processing described in section 2.\nUsers may withdraw consent at any time via account settings or by contacting contact@fastfrance.org.';

  @override
  String get contactPageTitle => 'Contact us';

  @override
  String get contactSendMessageTitle => 'Send a message';

  @override
  String get contactSubjectLabel => 'Title';

  @override
  String get contactSubjectHint => 'Subject of your request';

  @override
  String get contactMessageLabel => 'Message';

  @override
  String get contactMessageHint => 'Describe your request…';

  @override
  String get contactAntiSpamTitle => 'Anti-spam check';

  @override
  String get contactRefresh => 'Refresh';

  @override
  String contactCaptchaQuestion(int a, int b) {
    return 'How much is $a + $b?';
  }

  @override
  String get contactCaptchaAnswerLabel => 'Answer';

  @override
  String get contactCaptchaRequired => 'Captcha required';

  @override
  String get contactCaptchaIncorrect => 'Incorrect captcha.';

  @override
  String get contactSend => 'Send';

  @override
  String get contactSending => 'Sending…';

  @override
  String get contactCancel => 'Cancel';

  @override
  String get contactMessageSent => 'Message sent ✅';

  @override
  String contactSendFailedWithCode(int code) {
    return 'Failed to send ($code)';
  }

  @override
  String get contactAccessDenied => 'Access denied (missing or invalid app key).';

  @override
  String get contactTooManyRequests => 'Too many requests. Try again in a few seconds.';

  @override
  String get contactServiceUnavailable => 'Service temporarily unavailable. Try again later.';

  @override
  String get contactCheckInternet => 'Check your internet connection.';

  @override
  String get contactTimeout => 'Timeout. Please try again later.';

  @override
  String get contactFooterNote => 'Your message is sent via our secure public API. Thank you!';

  @override
  String contactMissingAppKey(String command) {
    return '⚠️ App key missing. Run the app with $command';
  }

  @override
  String fieldRequired(String field) {
    return '$field is required';
  }

  @override
  String unexpectedError(String message) {
    return 'Unexpected error: $message';
  }

  @override
  String get commonOk => 'OK';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get emailRequired => 'Email is required';

  @override
  String get emailInvalid => 'Invalid email';

  @override
  String get editProfileImport => 'Import';

  @override
  String get editProfileTakePhoto => 'Take a photo';

  @override
  String get editProfileDeletePhoto => 'Delete my photo';

  @override
  String get editProfileCancelSelection => 'Cancel selection';

  @override
  String get editProfilePhotoRequired => 'Photo required';

  @override
  String get editProfilePhotoRequiredHint => 'Photo required: import or take a new photo.';

  @override
  String get editProfileAddPhotoToSave => 'Add a photo to save';

  @override
  String get editProfilePhotoDeleted => 'Photo deleted ✅';

  @override
  String editProfilePhotoTooLarge(String size) {
    return 'Photo exceeds 4 MB ($size MB).';
  }

  @override
  String editProfilePhotoPickError(String message) {
    return 'Unable to get the photo: $message';
  }

  @override
  String get editProfileProfileInfoTitle => 'Profile information';

  @override
  String get editProfileFirstNameLabel => 'First name';

  @override
  String get editProfileLastNameLabel => 'Last name';

  @override
  String get editProfileEmailLabel => 'Email address';

  @override
  String get editProfileBirthDateLabel => 'Date of birth (dd/mm/yyyy)';

  @override
  String get editProfileBirthDateHelp => 'Date of birth';

  @override
  String get editProfileBirthDatePickTooltip => 'Pick a date';

  @override
  String get editProfileBirthDateRequired => 'Date of birth is required';

  @override
  String get editProfileGenotypeLabel => 'Genotype';

  @override
  String get editProfileGenotypeRequired => 'Genotype is required';

  @override
  String get editProfileCityLabel => 'City';

  @override
  String get editProfileGeolocate => 'Locate me';

  @override
  String get editProfileGeoTooltip => 'Please update your location if it has changed since you registered.';

  @override
  String get geoTitle => 'Geolocation';

  @override
  String get geoInfoText => 'Please update your location if it has changed since you registered.';

  @override
  String editProfileLocationUpdated(String cityPart) {
    return 'Location updated$cityPart';
  }

  @override
  String get editProfileSecretSectionTitle => 'Secret question';

  @override
  String get editProfileSecretQuestionLabel => 'Question';

  @override
  String get editProfileSecretAnswerLabel => 'Secret answer';

  @override
  String get editProfileChangePassword => 'Change my password';

  @override
  String get passwordEnterFirst => 'Enter a password first';

  @override
  String get passwordMismatch => 'Passwords do not match';

  @override
  String get passwordMatch => 'Passwords match';

  @override
  String get editProfilePasswordChanged => 'Password changed ✅';

  @override
  String get editProfileSave => 'Save';

  @override
  String get editProfileSaving => 'Saving…';

  @override
  String get editProfileChangesSaved => 'Changes saved ✅';

  @override
  String get editProfileTimeoutLoading => 'Timeout while loading the profile.';

  @override
  String editProfileLoadError(String message) {
    return 'Load error: $message';
  }

  @override
  String get editProfileTimeoutGeneric => 'Timeout. Please try again.';

  @override
  String editProfileErrorGeneric(String message) {
    return 'Error: $message';
  }

  @override
  String get genotypeUPD => 'UPD';

  @override
  String get genotypeICD => 'ICD';

  @override
  String get secretQ1 => 'What is your mother\'s birth name?';

  @override
  String get secretQ2 => 'What is your favorite movie actor\'s name?';

  @override
  String get secretQ3 => 'What is your favorite pet\'s name?';

  @override
  String get mapPersonTileIsMeHint => 'This is your profile';

  @override
  String get mapPersonTileSendHint => 'Send a message…';

  @override
  String get mapPersonTileCannotWriteTooltip => 'You can\'t message yourself';

  @override
  String get mapPersonTileSendTooltip => 'Send';

  @override
  String mapPersonTileSendFailed(Object error) {
    return 'Send failed: $error';
  }

  @override
  String mapPersonTileAge(int age) {
    return '$age years old';
  }

  @override
  String get mapFiltersButtonTooltip => 'Filters';

  @override
  String get mapNoFilters => 'No filters';

  @override
  String mapGenotypeCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count genotypes',
      one: '$count genotype',
    );
    return '$_temp0';
  }

  @override
  String mapAgeRangeYears(Object max, Object min) {
    return '$min–$max yrs';
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
      other: '$count people',
      one: '$count person',
    );
    return '$_temp0';
  }

  @override
  String get mapReloadFromNetworkTooltip => 'Reload (network, ignores filters, updates cache)';

  @override
  String get mapTilesBlockedInReleaseMessage => 'OSM tiles are disabled in production.\nConfigure a MapTiler key (or set allowOsmInRelease=true).';

  @override
  String get mapInitializingDataMessage => 'We’re initializing all data…';

  @override
  String mapNetworkUnavailableCacheUsed(Object error) {
    return 'Network unavailable — cache used: $error';
  }

  @override
  String mapLoadGenericError(Object error) {
    return 'Loading error: $error';
  }

  @override
  String mapFilterError(Object error) {
    return 'Filter error: $error';
  }

  @override
  String get mapLocationServiceDisabled => 'Location service disabled';

  @override
  String get mapLocationPermissionDenied => 'Location permission denied';

  @override
  String mapLocationUnavailable(Object error) {
    return 'Location unavailable: $error';
  }

  @override
  String get mapPhotoViewerBarrierLabel => 'Photo';

  @override
  String get mapClose => 'Close';

  @override
  String mapCityPeopleCount(Object city, num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count people',
      one: '$count person',
    );
    return '$city • $_temp0';
  }

  @override
  String mapResultsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count results',
      one: '$count result',
    );
    return '$_temp0';
  }

  @override
  String get mapNoResultsWithTheseFilters => 'No results with these filters (genotype/distance).';

  @override
  String get mapDistanceTitle => 'Distance (from my location)';

  @override
  String get mapEnableDistanceFilter => 'Enable distance filter';

  @override
  String mapOriginDefined(Object lat, Object lon) {
    return 'Origin: $lat, $lon';
  }

  @override
  String get mapOriginUndefined => 'Origin: not set';

  @override
  String get mapMyPosition => 'My location';

  @override
  String mapKmLabel(Object km) {
    return '$km km';
  }

  @override
  String get mapGenotypeTitle => 'Genotype';

  @override
  String get mapAgeTitle => 'Age (years)';

  @override
  String mapMinValue(Object value) {
    return 'Min: $value';
  }

  @override
  String mapMaxValue(Object value) {
    return 'Max: $value';
  }

  @override
  String get mapReset => 'Reset';

  @override
  String get mapCancel => 'Cancel';

  @override
  String get mapApply => 'Apply';

  @override
  String get mapCountryTitle => 'Countries';

  @override
  String get mapAllCountriesSelected => 'All countries';

  @override
  String mapCountriesSelectedCount(int count) {
    return '$count countries selected';
  }

  @override
  String get mapSelectAll => 'Select all';

  @override
  String get mapClear => 'Clear selection';

  @override
  String get mapBack => 'Back';

  @override
  String chatWithName(Object name) {
    return 'Chat with $name';
  }

  @override
  String get conversationsReconnectToSee => 'Please log in again to view your conversations.';

  @override
  String get loading => 'Loading…';

  @override
  String get conversationsEmpty => 'No conversations';

  @override
  String get conversationsNoMessage => 'No messages';

  @override
  String conversationsLoadError(Object error) {
    return 'Loading error: $error';
  }

  @override
  String get conversationsLeaveTitle => 'Leave conversation?';

  @override
  String get conversationsLeaveBody => 'Are you sure you want to leave this conversation?\nAll your messages will be deleted.';

  @override
  String get conversationsLeaveConfirm => 'Leave';

  @override
  String get close => 'Close';

  @override
  String get photo => 'Photo';

  @override
  String get yesterday => 'yesterday';

  @override
  String genericError(Object error) {
    return 'Error: $error';
  }

  @override
  String get today => 'Today';

  @override
  String get chatNoMessagesYet => 'No messages yet.';

  @override
  String chatLoadMessagesError(Object error) {
    return 'Error loading messages: $error';
  }

  @override
  String chatSendError(Object error) {
    return 'Error while sending: $error';
  }

  @override
  String get chatEditMessageTitle => 'Edit message';

  @override
  String get chatYourMessageHint => 'Your message';

  @override
  String chatEditError(Object error) {
    return 'Error while editing: $error';
  }

  @override
  String get chatDeleteMessageTitle => 'Delete message?';

  @override
  String get chatDeleteMessageBody => 'This message will be marked as deleted in this conversation.';

  @override
  String chatDeleteError(Object error) {
    return 'Error while deleting: $error';
  }

  @override
  String chatReactError(Object error) {
    return 'Error while reacting: $error';
  }

  @override
  String get chatLeaveConversationBody => 'Are you sure you want to leave the conversation and delete all your messages?';

  @override
  String chatLeaveError(Object error) {
    return 'Error while leaving: $error';
  }

  @override
  String get message => 'Message';

  @override
  String get send => 'Send';

  @override
  String get edited => 'edited';

  @override
  String get deletedMessage => 'Deleted message';

  @override
  String get edit => 'Edit';

  @override
  String get reply => 'Reply';

  @override
  String get delete => 'Delete';

  @override
  String get languageName => 'English';

  @override
  String get mapConnectionSectionTitle => 'Connection';

  @override
  String get mapConnectedOnlyLabel => 'Show connected people only';

  @override
  String get mapConnectedOnlyHint => 'Hides offline profiles.';

  @override
  String get mapConnectedOnlyChip => 'Connected';

  @override
  String get statusOnline => 'Online';

  @override
  String get statusOffline => 'Offline';

  @override
  String get tableTabular => 'Table';

  @override
  String get tableColumnPseudo => 'Username';

  @override
  String get tableColumnAge => 'Age';

  @override
  String get tableColumnGenotype => 'Genotype';

  @override
  String get tableColumnCountry => 'Country';

  @override
  String get tableColumnCity => 'City';

  @override
  String get tabularColPseudo => 'Username';

  @override
  String get tabularColAge => 'Age';

  @override
  String get tabularColGenotype => 'Genotype';

  @override
  String get tabularColCountry => 'Country';

  @override
  String get tabularColCity => 'City';

  @override
  String get tabularColAction => 'Action';

  @override
  String get tabularSendMessageTooltip => 'Send a message';

  @override
  String get tabularSendMessageErrorNoId => 'Unable to send message: missing identifier.';

  @override
  String get tabularSendMessageActionStub => 'Messaging feature not yet connected.';

  @override
  String tabularSendMessageTitle(Object name) {
    return 'Message to $name';
  }

  @override
  String get tabularSendMessageHint => 'Type a message…';

  @override
  String get tabularSendMessageSend => 'Send';

  @override
  String get tabularSendMessageSentStub => 'Message ready to send (to be wired).';

  @override
  String get tabularSendMessageCancel => 'Cancel';
}
