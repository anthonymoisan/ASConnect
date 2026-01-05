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
  String get loginIntro =>
      'The ASConnect app is intended only for caregivers who have a child with Angelman syndrome, a rare genetic disorder.';

  @override
  String get loginButton => 'Sign in';

  @override
  String get loginLoading => 'Signing in…';

  @override
  String get createAccount => 'Create an account';

  @override
  String get forgotPassword => 'Forgot your password?';

  @override
  String get emailLabel => 'Email address';

  @override
  String get emailHintRequired => 'Please enter your email';

  @override
  String get emailHintInvalid => 'Invalid email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get passwordRequired => 'Please enter your password';

  @override
  String get show => 'Show';

  @override
  String get hide => 'Hide';

  @override
  String get invalidCredentials => 'Invalid credentials.';

  @override
  String get accessDeniedKey => 'Access denied: missing or invalid app key.';

  @override
  String get badRequest => 'Invalid request (400).';

  @override
  String get tooManyAttempts => 'Too many attempts. Try again in a moment.';

  @override
  String get serviceUnavailable =>
      'Service unavailable. Please try again later.';

  @override
  String serverErrorWithCode(Object code) {
    return 'Server error ($code).';
  }

  @override
  String get unexpectedServerResponse => 'Unexpected server response.';

  @override
  String get cannotConnectServer => 'Unable to connect to the server.';

  @override
  String get timeoutCheckConnection =>
      'Request timed out. Check your connection.';

  @override
  String errorWithMessage(Object message) {
    return 'Error: $message';
  }

  @override
  String get missingAppKeyWarning =>
      '⚠️ App key missing. Run the app with --dart-define=PUBLIC_APP_KEY=your_public_key';

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
  String get consentCheckbox =>
      'I accept the terms of use for my data and I give my consent.';

  @override
  String get signupConsentNotGiven => 'You did not give your consent';

  @override
  String get signupCreating => 'Creating…';

  @override
  String get signupCreateBtn => 'Create my account';

  @override
  String get signupSuccess => 'Account created successfully.';

  @override
  String get signupEmailAlreadyExistsRedirect =>
      'Your email is already in our database. You will be redirected to the login page.';

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
  String get forgotAnswerOkHint =>
      '✅ Correct answer, you can set a new password.';

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
  String get tooManyAttemptsMessage =>
      'Too many tries.\n\nEmail contact@fastfrance.org to explain your login issue.';

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
  String get photoRequiredAfterDelete =>
      'Photo required: import or take a new photo.';

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
  String get geolocationHint =>
      'Remember to update your location if it changed since you signed up.';

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
  String get versionMadeByFastFrance => 'This app is developed by FAST France';

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
  String get privacyDeleteConfirmBody =>
      'This action is irreversible.\n\nYour profile and associated data will be permanently deleted.\n\nDo you want to continue?';

  @override
  String get privacyDeletedOkTitle => 'Account deleted';

  @override
  String get privacyDeletedOkBody =>
      'Your account has been deleted.\nYou will be redirected to the login page.';

  @override
  String privacyDeleteFailedWithCode(int code) {
    return 'Unable to delete (code $code).';
  }

  @override
  String get timeoutRetry => 'Request timed out. Please try again.';

  @override
  String get consentText =>
      'Privacy policy – ASConnect app\n\n1) Data controller\nThe data collected in the ASConnect app is processed by FAST France as the data controller.\nIf you have any questions about your data or how to exercise your rights, contact us at: contact@fastfrance.org.\n\n2) Purposes of processing\nData processing carried out through the app serves the following purposes:\n• Creating and managing your user account to access the ASConnect app;\n• Using geolocation features to display:\n  o points of interest related to Angelman syndrome,\n  o and/or profiles of concerned people, according to various criteria (geographic distance, genotype, age range);\n• Improving the service and personalizing the user experience, including allowing users to choose whether to display a photo, their first name, or last name.\n\n3) Categories of data collected\nThe following data may be collected:\n• Identification data:\n  o last name, first name, email address, password, photo,\n  o secret question and answer (in case of forgotten password);\n• Sensitive data:\n  o genotype, phone location (geolocation).\nThe legal basis for this processing is the user’s explicit and informed consent.\n\n4) Data retention period\nData is kept for the duration of account use, then deleted within a maximum of 12 months after the last activity.\nUsers can exercise their right to be forgotten at any time directly in the app via:\nPrivacy policy → Right to be forgotten.\n\n5) Recipients and data hosting\nData is securely hosted on PythonAnywhere servers.\nData is stored in the European Union.\n(For more information about the host’s privacy policy, see https://www.pythonanywhere.com/privacy/.)\n\n6) Users’ rights\nIn accordance with Regulation (EU) 2016/679 (GDPR), users have the following rights:\n• Right of access, rectification and deletion (“right to be forgotten”) — directly via their profile or via Privacy policy → Right to be forgotten;\n• Right to object, data portability and restriction of processing;\n• Right to withdraw consent at any time.\nTo exercise these rights (other than the in-app right to be forgotten), email: contact@fastfrance.org.\n\n7) Security and confidentiality\nAll data is encrypted during storage and transmission.\nPasswords are hashed according to security best practices, and all communications with the service use HTTPS.\n\n8) Explicit consent\nRegistering for the ASConnect app requires the user’s explicit and informed consent for the processing described in section 2.\nUsers may withdraw consent at any time via account settings or by contacting contact@fastfrance.org.';
}
