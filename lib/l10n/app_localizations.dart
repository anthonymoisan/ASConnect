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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('fr')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'ASConnexion'**
  String get appTitle;

  /// No description provided for @systemLanguage.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get systemLanguage;

  /// No description provided for @menu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// No description provided for @menuNavigation.
  ///
  /// In en, this message translates to:
  /// **'Navigation'**
  String get menuNavigation;

  /// No description provided for @menuMyProfile.
  ///
  /// In en, this message translates to:
  /// **'My profile'**
  String get menuMyProfile;

  /// No description provided for @menuContact.
  ///
  /// In en, this message translates to:
  /// **'Contact us'**
  String get menuContact;

  /// No description provided for @menuPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get menuPrivacyPolicy;

  /// No description provided for @menuVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get menuVersion;

  /// No description provided for @menuContactSubject.
  ///
  /// In en, this message translates to:
  /// **'Contact via app'**
  String get menuContactSubject;

  /// No description provided for @languageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageLabel;

  /// No description provided for @currentLanguage.
  ///
  /// In en, this message translates to:
  /// **'Current: {label}'**
  String currentLanguage(String label);

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @logoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get logoutTitle;

  /// No description provided for @logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out of the app?'**
  String get logoutConfirm;

  /// No description provided for @tabCommunity.
  ///
  /// In en, this message translates to:
  /// **'Connect with the community'**
  String get tabCommunity;

  /// No description provided for @tabChats.
  ///
  /// In en, this message translates to:
  /// **'My chats'**
  String get tabChats;

  /// No description provided for @tabPoi.
  ///
  /// In en, this message translates to:
  /// **'Points of interest'**
  String get tabPoi;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated ✅'**
  String get profileUpdated;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginTitle;

  /// No description provided for @loginIntro.
  ///
  /// In en, this message translates to:
  /// **'The ASConnect app is intended only for caregivers who have a child with Angelman syndrome, a rare genetic disorder.'**
  String get loginIntro;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get emailLabel;

  /// No description provided for @emailHintRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get emailHintRequired;

  /// No description provided for @emailHintInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid email'**
  String get emailHintInvalid;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @show.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get show;

  /// No description provided for @hide.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get hide;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get passwordRequired;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginButton;

  /// No description provided for @loginLoading.
  ///
  /// In en, this message translates to:
  /// **'Signing in…'**
  String get loginLoading;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get createAccount;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot your password?'**
  String get forgotPassword;

  /// No description provided for @invalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid credentials.'**
  String get invalidCredentials;

  /// No description provided for @accessDeniedKey.
  ///
  /// In en, this message translates to:
  /// **'Access denied: missing or invalid app key.'**
  String get accessDeniedKey;

  /// No description provided for @badRequest.
  ///
  /// In en, this message translates to:
  /// **'Invalid request (400).'**
  String get badRequest;

  /// No description provided for @tooManyAttempts.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Try again in a moment.'**
  String get tooManyAttempts;

  /// No description provided for @serviceUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Service unavailable. Please try again later.'**
  String get serviceUnavailable;

  /// No description provided for @serverErrorWithCode.
  ///
  /// In en, this message translates to:
  /// **'Server error ({code}).'**
  String serverErrorWithCode(Object code);

  /// No description provided for @unexpectedServerResponse.
  ///
  /// In en, this message translates to:
  /// **'Unexpected server response.'**
  String get unexpectedServerResponse;

  /// No description provided for @cannotConnectServer.
  ///
  /// In en, this message translates to:
  /// **'Unable to connect to the server.'**
  String get cannotConnectServer;

  /// No description provided for @timeoutCheckConnection.
  ///
  /// In en, this message translates to:
  /// **'Request timed out. Check your connection.'**
  String get timeoutCheckConnection;

  /// No description provided for @errorWithMessage.
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String errorWithMessage(Object message);

  /// No description provided for @missingAppKeyWarning.
  ///
  /// In en, this message translates to:
  /// **'⚠️ App key missing. Run the app with --dart-define=PUBLIC_APP_KEY=your_public_key'**
  String get missingAppKeyWarning;

  /// No description provided for @signupTitle.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get signupTitle;

  /// No description provided for @signupSectionPerson.
  ///
  /// In en, this message translates to:
  /// **'Person with Angelman syndrome'**
  String get signupSectionPerson;

  /// No description provided for @signupSectionAuth.
  ///
  /// In en, this message translates to:
  /// **'Authentication'**
  String get signupSectionAuth;

  /// No description provided for @consentTitle.
  ///
  /// In en, this message translates to:
  /// **'Consent'**
  String get consentTitle;

  /// No description provided for @firstNameLabel.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get firstNameLabel;

  /// No description provided for @firstNameRequired.
  ///
  /// In en, this message translates to:
  /// **'First name is required'**
  String get firstNameRequired;

  /// No description provided for @lastNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get lastNameLabel;

  /// No description provided for @lastNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Last name is required'**
  String get lastNameRequired;

  /// No description provided for @birthdateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date of birth (dd/mm/yyyy)'**
  String get birthdateLabel;

  /// No description provided for @birthdateRequired.
  ///
  /// In en, this message translates to:
  /// **'Date of birth is required'**
  String get birthdateRequired;

  /// No description provided for @chooseDate.
  ///
  /// In en, this message translates to:
  /// **'Choose a date'**
  String get chooseDate;

  /// No description provided for @signupBirthdateHelp.
  ///
  /// In en, this message translates to:
  /// **'Date of birth'**
  String get signupBirthdateHelp;

  /// No description provided for @genotypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Genotype'**
  String get genotypeLabel;

  /// No description provided for @genotypeRequired.
  ///
  /// In en, this message translates to:
  /// **'Genotype is required'**
  String get genotypeRequired;

  /// No description provided for @genotypeDeletion.
  ///
  /// In en, this message translates to:
  /// **'Deletion'**
  String get genotypeDeletion;

  /// No description provided for @genotypeMutation.
  ///
  /// In en, this message translates to:
  /// **'Mutation'**
  String get genotypeMutation;

  /// No description provided for @genotypeUpd.
  ///
  /// In en, this message translates to:
  /// **'UPD'**
  String get genotypeUpd;

  /// No description provided for @genotypeIcd.
  ///
  /// In en, this message translates to:
  /// **'ICD'**
  String get genotypeIcd;

  /// No description provided for @genotypeClinical.
  ///
  /// In en, this message translates to:
  /// **'Clinical'**
  String get genotypeClinical;

  /// No description provided for @genotypeMosaic.
  ///
  /// In en, this message translates to:
  /// **'Mosaic'**
  String get genotypeMosaic;

  /// No description provided for @signupPhotoHint.
  ///
  /// In en, this message translates to:
  /// **'Child’s photo (required, < 4 MB)'**
  String get signupPhotoHint;

  /// No description provided for @importPhoto.
  ///
  /// In en, this message translates to:
  /// **'Import a photo'**
  String get importPhoto;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get takePhoto;

  /// No description provided for @deletePhoto.
  ///
  /// In en, this message translates to:
  /// **'Delete photo'**
  String get deletePhoto;

  /// No description provided for @signupPhotoRequired.
  ///
  /// In en, this message translates to:
  /// **'Photo is required'**
  String get signupPhotoRequired;

  /// No description provided for @signupAddPhotoToContinue.
  ///
  /// In en, this message translates to:
  /// **'Add a photo to continue'**
  String get signupAddPhotoToContinue;

  /// No description provided for @signupPhotoTooLarge.
  ///
  /// In en, this message translates to:
  /// **'The photo exceeds 4 MB ({mb} MB).'**
  String signupPhotoTooLarge(String mb);

  /// No description provided for @signupPhotoCannotLoad.
  ///
  /// In en, this message translates to:
  /// **'Unable to load the photo: {message}'**
  String signupPhotoCannotLoad(String message);

  /// No description provided for @signupPasswordTooWeak.
  ///
  /// In en, this message translates to:
  /// **'Password is too weak'**
  String get signupPasswordTooWeak;

  /// No description provided for @signupPwdRuleMin8.
  ///
  /// In en, this message translates to:
  /// **'Min. 8 characters'**
  String get signupPwdRuleMin8;

  /// No description provided for @signupPwdRuleUpper.
  ///
  /// In en, this message translates to:
  /// **'1 uppercase letter'**
  String get signupPwdRuleUpper;

  /// No description provided for @signupPwdRuleDigit.
  ///
  /// In en, this message translates to:
  /// **'1 digit'**
  String get signupPwdRuleDigit;

  /// No description provided for @signupPwdRuleSpecial.
  ///
  /// In en, this message translates to:
  /// **'1 special character'**
  String get signupPwdRuleSpecial;

  /// No description provided for @secretQuestionLabel.
  ///
  /// In en, this message translates to:
  /// **'Security question'**
  String get secretQuestionLabel;

  /// No description provided for @secretQuestionRequired.
  ///
  /// In en, this message translates to:
  /// **'Security question is required'**
  String get secretQuestionRequired;

  /// No description provided for @secretQuestion1.
  ///
  /// In en, this message translates to:
  /// **'Mother’s maiden name?'**
  String get secretQuestion1;

  /// No description provided for @secretQuestion2.
  ///
  /// In en, this message translates to:
  /// **'Your favorite movie actor’s name?'**
  String get secretQuestion2;

  /// No description provided for @secretQuestion3.
  ///
  /// In en, this message translates to:
  /// **'Your favorite pet’s name?'**
  String get secretQuestion3;

  /// No description provided for @secretAnswerLabel.
  ///
  /// In en, this message translates to:
  /// **'Answer'**
  String get secretAnswerLabel;

  /// No description provided for @secretAnswerRequired.
  ///
  /// In en, this message translates to:
  /// **'Answer is required'**
  String get secretAnswerRequired;

  /// No description provided for @consentCheckbox.
  ///
  /// In en, this message translates to:
  /// **'I accept the terms of use for my data and I give my consent.'**
  String get consentCheckbox;

  /// No description provided for @signupConsentNotGiven.
  ///
  /// In en, this message translates to:
  /// **'You did not give your consent'**
  String get signupConsentNotGiven;

  /// No description provided for @signupCreating.
  ///
  /// In en, this message translates to:
  /// **'Creating…'**
  String get signupCreating;

  /// No description provided for @signupCreateBtn.
  ///
  /// In en, this message translates to:
  /// **'Create my account'**
  String get signupCreateBtn;

  /// No description provided for @signupSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account created successfully.'**
  String get signupSuccess;

  /// No description provided for @signupEmailAlreadyExistsRedirect.
  ///
  /// In en, this message translates to:
  /// **'Your email is already in our database. You will be redirected to the login page.'**
  String get signupEmailAlreadyExistsRedirect;

  /// No description provided for @signupSelectBirthdate.
  ///
  /// In en, this message translates to:
  /// **'Please select a date of birth'**
  String get signupSelectBirthdate;

  /// No description provided for @signupChooseGenotype.
  ///
  /// In en, this message translates to:
  /// **'Please choose a genotype'**
  String get signupChooseGenotype;

  /// No description provided for @signupChooseSecretQuestion.
  ///
  /// In en, this message translates to:
  /// **'Please choose a security question'**
  String get signupChooseSecretQuestion;

  /// No description provided for @signupEnterSecretAnswer.
  ///
  /// In en, this message translates to:
  /// **'Please enter the security answer'**
  String get signupEnterSecretAnswer;

  /// No description provided for @signupApiFailed.
  ///
  /// In en, this message translates to:
  /// **'API failed ({code}): {body}'**
  String signupApiFailed(int code, String body);

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot password'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get forgotEmailLabel;

  /// No description provided for @forgotFetchQuestionTooltip.
  ///
  /// In en, this message translates to:
  /// **'Fetch the question'**
  String get forgotFetchQuestionTooltip;

  /// No description provided for @forgotEnterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email.'**
  String get forgotEnterValidEmail;

  /// No description provided for @forgotUnknownEmail.
  ///
  /// In en, this message translates to:
  /// **'Unknown email.'**
  String get forgotUnknownEmail;

  /// No description provided for @forgotErrorCode.
  ///
  /// In en, this message translates to:
  /// **'Error ({code})'**
  String forgotErrorCode(int code);

  /// No description provided for @forgotTimeoutRetry.
  ///
  /// In en, this message translates to:
  /// **'Timeout. Please try again.'**
  String get forgotTimeoutRetry;

  /// No description provided for @forgotErrorWithMessage.
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String forgotErrorWithMessage(String message);

  /// No description provided for @forgotQuestionFallback.
  ///
  /// In en, this message translates to:
  /// **'Security question'**
  String get forgotQuestionFallback;

  /// No description provided for @forgotQuestionLabel.
  ///
  /// In en, this message translates to:
  /// **'Question'**
  String get forgotQuestionLabel;

  /// No description provided for @forgotSecretAnswerLabel.
  ///
  /// In en, this message translates to:
  /// **'Security answer'**
  String get forgotSecretAnswerLabel;

  /// No description provided for @forgotAnswerRequired.
  ///
  /// In en, this message translates to:
  /// **'Answer is required'**
  String get forgotAnswerRequired;

  /// No description provided for @forgotEnterYourAnswer.
  ///
  /// In en, this message translates to:
  /// **'Enter your answer.'**
  String get forgotEnterYourAnswer;

  /// No description provided for @forgotVerify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get forgotVerify;

  /// No description provided for @forgotAnswerCorrectSnack.
  ///
  /// In en, this message translates to:
  /// **'Correct answer 👍'**
  String get forgotAnswerCorrectSnack;

  /// No description provided for @forgotAnswerIncorrectAttempts.
  ///
  /// In en, this message translates to:
  /// **'Incorrect answer ({attempts}/3).'**
  String forgotAnswerIncorrectAttempts(int attempts);

  /// No description provided for @forgotFailedAttempts.
  ///
  /// In en, this message translates to:
  /// **'Failed attempts: {attempts} / 3'**
  String forgotFailedAttempts(int attempts);

  /// No description provided for @forgotAnswerOkHint.
  ///
  /// In en, this message translates to:
  /// **'✅ Correct answer, you can set a new password.'**
  String get forgotAnswerOkHint;

  /// No description provided for @forgotNewPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get forgotNewPasswordLabel;

  /// No description provided for @forgotPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get forgotPasswordRequired;

  /// No description provided for @forgotPasswordTooWeak.
  ///
  /// In en, this message translates to:
  /// **'Password is too weak'**
  String get forgotPasswordTooWeak;

  /// No description provided for @forgotPwdRuleMin8.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get forgotPwdRuleMin8;

  /// No description provided for @forgotPwdRuleUpper.
  ///
  /// In en, this message translates to:
  /// **'At least 1 uppercase letter'**
  String get forgotPwdRuleUpper;

  /// No description provided for @forgotPwdRuleSpecial.
  ///
  /// In en, this message translates to:
  /// **'At least 1 special character'**
  String get forgotPwdRuleSpecial;

  /// No description provided for @forgotConfirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get forgotConfirmPasswordLabel;

  /// No description provided for @forgotEnterNewPasswordFirst.
  ///
  /// In en, this message translates to:
  /// **'Enter the new password first'**
  String get forgotEnterNewPasswordFirst;

  /// No description provided for @forgotPasswordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get forgotPasswordsDoNotMatch;

  /// No description provided for @forgotPasswordsMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords match'**
  String get forgotPasswordsMatch;

  /// No description provided for @forgotResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password reset ✅'**
  String get forgotResetSuccess;

  /// No description provided for @forgotResetFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed ({code}).'**
  String forgotResetFailed(int code);

  /// No description provided for @tooManyAttemptsTitle.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts'**
  String get tooManyAttemptsTitle;

  /// No description provided for @tooManyAttemptsMessage.
  ///
  /// In en, this message translates to:
  /// **'Too many tries.\n\nEmail contact@fastfrance.org to explain your login issue.'**
  String get tooManyAttemptsMessage;

  /// No description provided for @forgotValidating.
  ///
  /// In en, this message translates to:
  /// **'Submitting…'**
  String get forgotValidating;

  /// No description provided for @editProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfileTitle;

  /// No description provided for @loadingProfile.
  ///
  /// In en, this message translates to:
  /// **'Loading profile…'**
  String get loadingProfile;

  /// No description provided for @timeoutLoadingProfile.
  ///
  /// In en, this message translates to:
  /// **'Timeout while loading profile.'**
  String get timeoutLoadingProfile;

  /// No description provided for @errorLoadingProfile.
  ///
  /// In en, this message translates to:
  /// **'Loading error: {message}'**
  String errorLoadingProfile(String message);

  /// No description provided for @import.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get import;

  /// No description provided for @deleteMyPhoto.
  ///
  /// In en, this message translates to:
  /// **'Delete my photo'**
  String get deleteMyPhoto;

  /// No description provided for @cancelSelection.
  ///
  /// In en, this message translates to:
  /// **'Cancel selection'**
  String get cancelSelection;

  /// No description provided for @photoTooLarge.
  ///
  /// In en, this message translates to:
  /// **'The photo exceeds 4 MB ({size} MB).'**
  String photoTooLarge(String size);

  /// No description provided for @cannotGetPhoto.
  ///
  /// In en, this message translates to:
  /// **'Unable to get the photo: {message}'**
  String cannotGetPhoto(String message);

  /// No description provided for @photoRequired.
  ///
  /// In en, this message translates to:
  /// **'Photo required'**
  String get photoRequired;

  /// No description provided for @photoRequiredAddToSave.
  ///
  /// In en, this message translates to:
  /// **'Please add a photo to save'**
  String get photoRequiredAddToSave;

  /// No description provided for @photoRequiredAfterDelete.
  ///
  /// In en, this message translates to:
  /// **'Photo required: import or take a new photo.'**
  String get photoRequiredAfterDelete;

  /// No description provided for @photoDeleted.
  ///
  /// In en, this message translates to:
  /// **'Photo deleted ✅'**
  String get photoDeleted;

  /// No description provided for @profileInfoSection.
  ///
  /// In en, this message translates to:
  /// **'Profile information'**
  String get profileInfoSection;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get lastName;

  /// No description provided for @birthDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date of birth (dd/mm/yyyy)'**
  String get birthDateLabel;

  /// No description provided for @birthDateRequired.
  ///
  /// In en, this message translates to:
  /// **'Date of birth is required'**
  String get birthDateRequired;

  /// No description provided for @genotype.
  ///
  /// In en, this message translates to:
  /// **'Genotype'**
  String get genotype;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @geolocateMe.
  ///
  /// In en, this message translates to:
  /// **'Use my location'**
  String get geolocateMe;

  /// No description provided for @locationUpdated.
  ///
  /// In en, this message translates to:
  /// **'Location updated'**
  String get locationUpdated;

  /// No description provided for @locationUpdatedWithCity.
  ///
  /// In en, this message translates to:
  /// **'Location updated ({city})'**
  String locationUpdatedWithCity(String city);

  /// No description provided for @geolocation.
  ///
  /// In en, this message translates to:
  /// **'Geolocation'**
  String get geolocation;

  /// No description provided for @geolocationHint.
  ///
  /// In en, this message translates to:
  /// **'Remember to update your location if it changed since you signed up.'**
  String get geolocationHint;

  /// No description provided for @secretQuestionSection.
  ///
  /// In en, this message translates to:
  /// **'Security question'**
  String get secretQuestionSection;

  /// No description provided for @question.
  ///
  /// In en, this message translates to:
  /// **'Question'**
  String get question;

  /// No description provided for @answer.
  ///
  /// In en, this message translates to:
  /// **'Answer'**
  String get answer;

  /// No description provided for @changeMyPassword.
  ///
  /// In en, this message translates to:
  /// **'Change my password'**
  String get changeMyPassword;

  /// No description provided for @changePasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Change my password'**
  String get changePasswordTitle;

  /// No description provided for @newPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPasswordLabel;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPasswordLabel;

  /// No description provided for @passwordTooWeak.
  ///
  /// In en, this message translates to:
  /// **'Password is too weak'**
  String get passwordTooWeak;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter a password'**
  String get enterPassword;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @passwordsMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords match'**
  String get passwordsMatch;

  /// No description provided for @pwdRuleMin8.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get pwdRuleMin8;

  /// No description provided for @pwdRuleUpper.
  ///
  /// In en, this message translates to:
  /// **'At least 1 uppercase letter'**
  String get pwdRuleUpper;

  /// No description provided for @pwdRuleSpecial.
  ///
  /// In en, this message translates to:
  /// **'At least 1 special character'**
  String get pwdRuleSpecial;

  /// No description provided for @passwordChanged.
  ///
  /// In en, this message translates to:
  /// **'Password changed ✅'**
  String get passwordChanged;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get saving;

  /// No description provided for @savedChanges.
  ///
  /// In en, this message translates to:
  /// **'Changes saved ✅'**
  String get savedChanges;

  /// No description provided for @timeoutTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Timeout. Please try again.'**
  String get timeoutTryAgain;

  /// No description provided for @failedWithCode.
  ///
  /// In en, this message translates to:
  /// **'Failed ({code})'**
  String failedWithCode(int code);

  /// No description provided for @versionMadeByFastFrance.
  ///
  /// In en, this message translates to:
  /// **'This app is developed by FAST France'**
  String get versionMadeByFastFrance;

  /// No description provided for @versionNumber.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String versionNumber(String version);

  /// No description provided for @privacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacyTitle;

  /// No description provided for @privacyRightToBeForgotten.
  ///
  /// In en, this message translates to:
  /// **'Right to be forgotten'**
  String get privacyRightToBeForgotten;

  /// No description provided for @privacyDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get privacyDeleteTitle;

  /// No description provided for @privacyDeleteConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This action is irreversible.\n\nYour profile and associated data will be permanently deleted.\n\nDo you want to continue?'**
  String get privacyDeleteConfirmBody;

  /// No description provided for @privacyDeletedOkTitle.
  ///
  /// In en, this message translates to:
  /// **'Account deleted'**
  String get privacyDeletedOkTitle;

  /// No description provided for @privacyDeletedOkBody.
  ///
  /// In en, this message translates to:
  /// **'Your account has been deleted.\nYou will be redirected to the login page.'**
  String get privacyDeletedOkBody;

  /// No description provided for @privacyDeleteFailedWithCode.
  ///
  /// In en, this message translates to:
  /// **'Unable to delete (code {code}).'**
  String privacyDeleteFailedWithCode(int code);

  /// No description provided for @timeoutRetry.
  ///
  /// In en, this message translates to:
  /// **'Request timed out. Please try again.'**
  String get timeoutRetry;

  /// No description provided for @consentText.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy – ASConnect app\n\n1) Data controller\nThe data collected in the ASConnect app is processed by FAST France as the data controller.\nIf you have any questions about your data or how to exercise your rights, contact us at: contact@fastfrance.org.\n\n2) Purposes of processing\nData processing carried out through the app serves the following purposes:\n• Creating and managing your user account to access the ASConnect app;\n• Using geolocation features to display:\n  o points of interest related to Angelman syndrome,\n  o and/or profiles of concerned people, according to various criteria (geographic distance, genotype, age range);\n• Improving the service and personalizing the user experience, including allowing users to choose whether to display a photo, their first name, or last name.\n\n3) Categories of data collected\nThe following data may be collected:\n• Identification data:\n  o last name, first name, email address, password, photo,\n  o secret question and answer (in case of forgotten password);\n• Sensitive data:\n  o genotype, phone location (geolocation).\nThe legal basis for this processing is the user’s explicit and informed consent.\n\n4) Data retention period\nData is kept for the duration of account use, then deleted within a maximum of 12 months after the last activity.\nUsers can exercise their right to be forgotten at any time directly in the app via:\nPrivacy policy → Right to be forgotten.\n\n5) Recipients and data hosting\nData is securely hosted on PythonAnywhere servers.\nData is stored in the European Union.\n(For more information about the host’s privacy policy, see https://www.pythonanywhere.com/privacy/.)\n\n6) Users’ rights\nIn accordance with Regulation (EU) 2016/679 (GDPR), users have the following rights:\n• Right of access, rectification and deletion (“right to be forgotten”) — directly via their profile or via Privacy policy → Right to be forgotten;\n• Right to object, data portability and restriction of processing;\n• Right to withdraw consent at any time.\nTo exercise these rights (other than the in-app right to be forgotten), email: contact@fastfrance.org.\n\n7) Security and confidentiality\nAll data is encrypted during storage and transmission.\nPasswords are hashed according to security best practices, and all communications with the service use HTTPS.\n\n8) Explicit consent\nRegistering for the ASConnect app requires the user’s explicit and informed consent for the processing described in section 2.\nUsers may withdraw consent at any time via account settings or by contacting contact@fastfrance.org.'**
  String get consentText;

  /// No description provided for @contactPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact us'**
  String get contactPageTitle;

  /// No description provided for @contactSendMessageTitle.
  ///
  /// In en, this message translates to:
  /// **'Send a message'**
  String get contactSendMessageTitle;

  /// No description provided for @contactSubjectLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get contactSubjectLabel;

  /// No description provided for @contactSubjectHint.
  ///
  /// In en, this message translates to:
  /// **'Subject of your request'**
  String get contactSubjectHint;

  /// No description provided for @contactMessageLabel.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get contactMessageLabel;

  /// No description provided for @contactMessageHint.
  ///
  /// In en, this message translates to:
  /// **'Describe your request…'**
  String get contactMessageHint;

  /// No description provided for @contactAntiSpamTitle.
  ///
  /// In en, this message translates to:
  /// **'Anti-spam check'**
  String get contactAntiSpamTitle;

  /// No description provided for @contactRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get contactRefresh;

  /// No description provided for @contactCaptchaQuestion.
  ///
  /// In en, this message translates to:
  /// **'How much is {a} + {b}?'**
  String contactCaptchaQuestion(int a, int b);

  /// No description provided for @contactCaptchaAnswerLabel.
  ///
  /// In en, this message translates to:
  /// **'Answer'**
  String get contactCaptchaAnswerLabel;

  /// No description provided for @contactCaptchaRequired.
  ///
  /// In en, this message translates to:
  /// **'Captcha required'**
  String get contactCaptchaRequired;

  /// No description provided for @contactCaptchaIncorrect.
  ///
  /// In en, this message translates to:
  /// **'Incorrect captcha.'**
  String get contactCaptchaIncorrect;

  /// No description provided for @contactSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get contactSend;

  /// No description provided for @contactSending.
  ///
  /// In en, this message translates to:
  /// **'Sending…'**
  String get contactSending;

  /// No description provided for @contactCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get contactCancel;

  /// No description provided for @contactMessageSent.
  ///
  /// In en, this message translates to:
  /// **'Message sent ✅'**
  String get contactMessageSent;

  /// No description provided for @contactSendFailedWithCode.
  ///
  /// In en, this message translates to:
  /// **'Failed to send ({code})'**
  String contactSendFailedWithCode(int code);

  /// No description provided for @contactAccessDenied.
  ///
  /// In en, this message translates to:
  /// **'Access denied (missing or invalid app key).'**
  String get contactAccessDenied;

  /// No description provided for @contactTooManyRequests.
  ///
  /// In en, this message translates to:
  /// **'Too many requests. Try again in a few seconds.'**
  String get contactTooManyRequests;

  /// No description provided for @contactServiceUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Service temporarily unavailable. Try again later.'**
  String get contactServiceUnavailable;

  /// No description provided for @contactCheckInternet.
  ///
  /// In en, this message translates to:
  /// **'Check your internet connection.'**
  String get contactCheckInternet;

  /// No description provided for @contactTimeout.
  ///
  /// In en, this message translates to:
  /// **'Timeout. Please try again later.'**
  String get contactTimeout;

  /// No description provided for @contactFooterNote.
  ///
  /// In en, this message translates to:
  /// **'Your message is sent via our secure public API. Thank you!'**
  String get contactFooterNote;

  /// No description provided for @contactMissingAppKey.
  ///
  /// In en, this message translates to:
  /// **'⚠️ App key missing. Run the app with {command}'**
  String contactMissingAppKey(String command);

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'{field} is required'**
  String fieldRequired(String field);

  /// No description provided for @unexpectedError.
  ///
  /// In en, this message translates to:
  /// **'Unexpected error: {message}'**
  String unexpectedError(String message);
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'es', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
    case 'fr': return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
