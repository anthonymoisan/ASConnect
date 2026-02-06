// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'ASConnexion';

  @override
  String get systemLanguage => 'Sistema';

  @override
  String get menu => 'Menú';

  @override
  String get menuNavigation => 'Navegación';

  @override
  String get menuMyProfile => 'Mi perfil';

  @override
  String get menuContact => 'Contactarnos';

  @override
  String get menuPrivacyPolicy => 'Política de privacidad';

  @override
  String get menuVersion => 'Versión';

  @override
  String get menuContactSubject => 'Contacto desde la app';

  @override
  String get languageLabel => 'Idioma';

  @override
  String currentLanguage(String label) {
    return 'Actual: $label';
  }

  @override
  String get cancel => 'Cancelar';

  @override
  String get confirm => 'Confirmar';

  @override
  String get ok => 'OK';

  @override
  String get logoutTitle => 'Cerrar sesión';

  @override
  String get logoutConfirm => '¿Seguro(a) que deseas cerrar sesión en la aplicación?';

  @override
  String get tabCommunity => 'Conectarse con la comunidad';

  @override
  String get tabChats => 'Mis chats';

  @override
  String get tabPoi => 'Puntos de interés';

  @override
  String get profileUpdated => 'Perfil actualizado ✅';

  @override
  String get loginTitle => 'Iniciar sesión';

  @override
  String get loginIntro => 'La aplicación ASConnect está destinada únicamente a cuidadores que tienen un hijo con el síndrome de Angelman, una enfermedad genética rara.';

  @override
  String get emailLabel => 'Correo electrónico';

  @override
  String get emailHintRequired => 'Introduce tu correo';

  @override
  String get emailHintInvalid => 'Correo no válido';

  @override
  String get passwordLabel => 'Contraseña';

  @override
  String get show => 'Mostrar';

  @override
  String get hide => 'Ocultar';

  @override
  String get passwordRequired => 'Introduce tu contraseña';

  @override
  String get loginButton => 'Iniciar sesión';

  @override
  String get loginLoading => 'Conectando…';

  @override
  String get createAccount => 'Crear una cuenta';

  @override
  String get forgotPassword => '¿Olvidaste tu contraseña?';

  @override
  String get invalidCredentials => 'Credenciales inválidas.';

  @override
  String get accessDeniedKey => 'Acceso denegado: clave de la aplicación ausente o inválida.';

  @override
  String get badRequest => 'Solicitud no válida (400).';

  @override
  String get tooManyAttempts => 'Demasiados intentos. Inténtalo de nuevo en un momento.';

  @override
  String get serviceUnavailable => 'Servicio no disponible. Inténtalo más tarde.';

  @override
  String serverErrorWithCode(int code) {
    return 'Error del servidor ($code).';
  }

  @override
  String get unexpectedServerResponse => 'Respuesta inesperada del servidor.';

  @override
  String get cannotConnectServer => 'No se puede conectar con el servidor.';

  @override
  String get timeoutCheckConnection => 'Tiempo de espera agotado. Verifica tu conexión.';

  @override
  String errorWithMessage(String message) {
    return 'Error: $message';
  }

  @override
  String get missingAppKeyWarning => '⚠️ Falta la clave de la app. Ejecuta la app con --dart-define=PUBLIC_APP_KEY=tu_clave_publica';

  @override
  String get signupTitle => 'Crear una cuenta';

  @override
  String get signupSectionPerson => 'Persona con síndrome de Angelman';

  @override
  String get signupSectionAuth => 'Autenticación';

  @override
  String get consentTitle => 'Consentimiento';

  @override
  String get firstNameLabel => 'Nombre';

  @override
  String get firstNameRequired => 'El nombre es obligatorio';

  @override
  String get lastNameLabel => 'Apellido';

  @override
  String get lastNameRequired => 'El apellido es obligatorio';

  @override
  String get birthdateLabel => 'Fecha de nacimiento (dd/mm/aaaa)';

  @override
  String get birthdateRequired => 'La fecha de nacimiento es obligatoria';

  @override
  String get chooseDate => 'Elegir una fecha';

  @override
  String get signupBirthdateHelp => 'Fecha de nacimiento';

  @override
  String get genotypeLabel => 'Genotipo';

  @override
  String get genotypeRequired => 'El genotipo es obligatorio';

  @override
  String get genotypeDeletion => 'Deleción';

  @override
  String get genotypeMutation => 'Mutación';

  @override
  String get genotypeUpd => 'UPD';

  @override
  String get genotypeIcd => 'ICD';

  @override
  String get genotypeClinical => 'Clínico';

  @override
  String get genotypeMosaic => 'Mosaico';

  @override
  String get signupPhotoHint => 'Foto del niño/a (obligatoria, < 4 MB)';

  @override
  String get importPhoto => 'Importar una foto';

  @override
  String get takePhoto => 'Tomar una foto';

  @override
  String get deletePhoto => 'Eliminar la foto';

  @override
  String get signupPhotoRequired => 'La foto es obligatoria';

  @override
  String get signupAddPhotoToContinue => 'Añade una foto para continuar';

  @override
  String signupPhotoTooLarge(String mb) {
    return 'La foto supera 4 MB ($mb MB).';
  }

  @override
  String signupPhotoCannotLoad(String message) {
    return 'No se pudo cargar la foto: $message';
  }

  @override
  String get signupPasswordTooWeak => 'La contraseña es demasiado débil';

  @override
  String get signupPwdRuleMin8 => 'Mín. 8 caracteres';

  @override
  String get signupPwdRuleUpper => '1 mayúscula';

  @override
  String get signupPwdRuleDigit => '1 número';

  @override
  String get signupPwdRuleSpecial => '1 carácter especial';

  @override
  String get secretQuestionLabel => 'Pregunta secreta';

  @override
  String get secretQuestionRequired => 'La pregunta secreta es obligatoria';

  @override
  String get secretQuestion1 => '¿Apellido de soltera de la madre?';

  @override
  String get secretQuestion2 => '¿Nombre de tu actor de cine favorito?';

  @override
  String get secretQuestion3 => '¿Nombre de tu mascota favorita?';

  @override
  String get secretAnswerLabel => 'Respuesta';

  @override
  String get secretAnswerRequired => 'La respuesta es obligatoria';

  @override
  String get consentCheckbox => 'Acepto las condiciones de uso de mis datos y doy mi consentimiento.';

  @override
  String get signupConsentNotGiven => 'No has dado tu consentimiento';

  @override
  String get signupCreating => 'Creando…';

  @override
  String get signupCreateBtn => 'Crear mi cuenta';

  @override
  String get signupSuccess => 'Cuenta creada con éxito.';

  @override
  String get signupEmailAlreadyExistsRedirect => 'Tu correo ya está en nuestra base de datos! Introduce otra dirección de correo electrónico o ve a la sección “Olvidé mi contraseña”.';

  @override
  String get signupSelectBirthdate => 'Selecciona una fecha de nacimiento';

  @override
  String get signupChooseGenotype => 'Elige un genotipo';

  @override
  String get signupChooseSecretQuestion => 'Elige una pregunta secreta';

  @override
  String get signupEnterSecretAnswer => 'Introduce la respuesta secreta';

  @override
  String signupApiFailed(int code, String body) {
    return 'Fallo de API ($code): $body';
  }

  @override
  String get forgotPasswordTitle => 'Contraseña olvidada';

  @override
  String get forgotEmailLabel => 'Correo electrónico';

  @override
  String get forgotFetchQuestionTooltip => 'Obtener la pregunta';

  @override
  String get forgotEnterValidEmail => 'Introduce un correo válido.';

  @override
  String get forgotUnknownEmail => 'Correo desconocido.';

  @override
  String forgotErrorCode(int code) {
    return 'Error ($code)';
  }

  @override
  String get forgotTimeoutRetry => 'Tiempo agotado. Inténtalo de nuevo.';

  @override
  String forgotErrorWithMessage(String message) {
    return 'Error: $message';
  }

  @override
  String get forgotQuestionFallback => 'Pregunta secreta';

  @override
  String get forgotQuestionLabel => 'Pregunta';

  @override
  String get forgotSecretAnswerLabel => 'Respuesta secreta';

  @override
  String get forgotAnswerRequired => 'La respuesta es obligatoria';

  @override
  String get forgotEnterYourAnswer => 'Introduce tu respuesta.';

  @override
  String get forgotVerify => 'Verificar';

  @override
  String get forgotAnswerCorrectSnack => 'Respuesta correcta 👍';

  @override
  String forgotAnswerIncorrectAttempts(int attempts) {
    return 'Respuesta incorrecta ($attempts/3).';
  }

  @override
  String forgotFailedAttempts(int attempts) {
    return 'Intentos fallidos: $attempts / 3';
  }

  @override
  String get forgotAnswerOkHint => '✅ Respuesta correcta, puedes establecer una nueva contraseña.';

  @override
  String get forgotNewPasswordLabel => 'Nueva contraseña';

  @override
  String get forgotPasswordRequired => 'La contraseña es obligatoria';

  @override
  String get forgotPasswordTooWeak => 'La contraseña es demasiado débil';

  @override
  String get forgotPwdRuleMin8 => 'Al menos 8 caracteres';

  @override
  String get forgotPwdRuleUpper => 'Al menos 1 mayúscula';

  @override
  String get forgotPwdRuleSpecial => 'Al menos 1 carácter especial';

  @override
  String get forgotConfirmPasswordLabel => 'Confirmar contraseña';

  @override
  String get forgotEnterNewPasswordFirst => 'Introduce primero la nueva contraseña';

  @override
  String get forgotPasswordsDoNotMatch => 'Las contraseñas no coinciden';

  @override
  String get forgotPasswordsMatch => 'Las contraseñas coinciden';

  @override
  String get forgotResetSuccess => 'Contraseña restablecida ✅';

  @override
  String forgotResetFailed(int code) {
    return 'Fallo ($code).';
  }

  @override
  String get tooManyAttemptsTitle => 'Demasiados intentos';

  @override
  String get tooManyAttemptsMessage => 'Has superado el número de intentos.\n\nEscribe a contact@angelmananalytics.org para explicar tu problema de inicio de sesión.';

  @override
  String get forgotValidating => 'Enviando…';

  @override
  String get editProfileTitle => 'Editar perfil';

  @override
  String get loadingProfile => 'Cargando perfil…';

  @override
  String get timeoutLoadingProfile => 'Tiempo de espera al cargar el perfil.';

  @override
  String errorLoadingProfile(String message) {
    return 'Error al cargar: $message';
  }

  @override
  String get import => 'Importar';

  @override
  String get deleteMyPhoto => 'Eliminar mi foto';

  @override
  String get cancelSelection => 'Cancelar selección';

  @override
  String photoTooLarge(String size) {
    return 'La foto supera 4 MB ($size MB).';
  }

  @override
  String cannotGetPhoto(String message) {
    return 'No se pudo obtener la foto: $message';
  }

  @override
  String get photoRequired => 'Foto obligatoria';

  @override
  String get photoRequiredAddToSave => 'Añade una foto para guardar';

  @override
  String get photoRequiredAfterDelete => 'Foto obligatoria: importa o toma una nueva foto.';

  @override
  String get photoDeleted => 'Foto eliminada ✅';

  @override
  String get profileInfoSection => 'Información del perfil';

  @override
  String get firstName => 'Nombre';

  @override
  String get lastName => 'Apellido';

  @override
  String get birthDateLabel => 'Fecha de nacimiento (dd/mm/aaaa)';

  @override
  String get birthDateRequired => 'La fecha de nacimiento es obligatoria';

  @override
  String get genotype => 'Genotipo';

  @override
  String get city => 'Ciudad';

  @override
  String get geolocateMe => 'Usar mi ubicación';

  @override
  String get locationUpdated => 'Ubicación actualizada';

  @override
  String locationUpdatedWithCity(String city) {
    return 'Ubicación actualizada ($city)';
  }

  @override
  String get geolocation => 'Geolocalización';

  @override
  String get geolocationHint => 'Recuerda actualizar tu geolocalización si cambió desde tu registro.';

  @override
  String get secretQuestionSection => 'Pregunta secreta';

  @override
  String get question => 'Pregunta';

  @override
  String get answer => 'Respuesta';

  @override
  String get changeMyPassword => 'Cambiar mi contraseña';

  @override
  String get changePasswordTitle => 'Cambiar contraseña';

  @override
  String get newPasswordLabel => 'Nueva contraseña';

  @override
  String get confirmPasswordLabel => 'Confirmar contraseña';

  @override
  String get passwordTooWeak => 'La contraseña es demasiado débil';

  @override
  String get enterPassword => 'Introduce una contraseña';

  @override
  String get passwordsDoNotMatch => 'Las contraseñas no coinciden';

  @override
  String get passwordsMatch => 'Las contraseñas coinciden';

  @override
  String get pwdRuleMin8 => 'Al menos 8 caracteres';

  @override
  String get pwdRuleUpper => 'Al menos 1 mayúscula';

  @override
  String get pwdRuleSpecial => 'Al menos 1 carácter especial';

  @override
  String get passwordChanged => 'Contraseña cambiada ✅';

  @override
  String get save => 'Guardar';

  @override
  String get saving => 'Guardando…';

  @override
  String get savedChanges => 'Cambios guardados ✅';

  @override
  String get timeoutTryAgain => 'Tiempo agotado. Inténtalo de nuevo.';

  @override
  String failedWithCode(int code) {
    return 'Fallo ($code)';
  }

  @override
  String get versionMadeByFastFrance => 'Esta aplicación ha sido desarrollada por Angelman Analytics (www.angelmananalytics.org)';

  @override
  String versionNumber(String version) {
    return 'Versión $version';
  }

  @override
  String get privacyTitle => 'Política de privacidad';

  @override
  String get privacyRightToBeForgotten => 'Derecho al olvido';

  @override
  String get privacyDeleteTitle => 'Atención';

  @override
  String get privacyDeleteConfirmBody => 'Esta acción es irreversible.\n\nTu perfil y los datos asociados se eliminarán definitivamente.\n\n¿Quieres continuar?';

  @override
  String get privacyDeletedOkTitle => 'Cuenta eliminada';

  @override
  String get privacyDeletedOkBody => 'Tu cuenta ha sido eliminada.\nSerás redirigido a la página de inicio de sesión.';

  @override
  String privacyDeleteFailedWithCode(int code) {
    return 'No se pudo eliminar (código $code).';
  }

  @override
  String get timeoutRetry => 'Tiempo de espera agotado. Inténtalo de nuevo.';

  @override
  String get consentText => 'Política de privacidad – Aplicación ASConnect\n\n1) Identidad del responsable del tratamiento\nLos datos recogidos en la aplicación ASConnect son tratados por AngelmanAnalytics en calidad de responsable del tratamiento.\nPara cualquier cuestión relativa a sus datos o al ejercicio de sus derechos, puede contactarnos en: contact@angelmananalytics.org.\n____________________________________________\n2) Finalidades del tratamiento\nLos tratamientos de datos realizados a través de la aplicación persiguen las siguientes finalidades:\n• Creación y gestión de su cuenta de usuario para un acceso nominativo a la aplicación ASConnect;\n• Uso de las funcionalidades de geolocalización para visualizar:\n  o Perfiles de personas afectadas según distintos criterios (distancia geográfica, genotipo, rango de edad);\n  o Mejora del servicio y personalización de la experiencia del usuario.\n• Extracción de datos que no permiten identificar a las personas con fines estadísticos: número de personas afectadas por el síndrome de Angelman, distribución por edad...\n____________________________________________\n3) Categorías de datos recogidos\nSe pueden recoger los siguientes datos:\n• Datos de identificación:\n  o sexo, nombre, apellido, dirección de correo electrónico, contraseña, fotografía,\n  o pregunta y respuesta secreta (en caso de olvido de la contraseña);\n• Datos sensibles:\n  o genotipo, localización.\nLa base legal de estos tratamientos es el consentimiento explícito e informado del usuario.\n____________________________________________\n4) Plazo de conservación de los datos\nLos datos se conservan durante toda la duración del uso de la cuenta y posteriormente se eliminan en un plazo máximo de 12 meses tras la última actividad.\nEl usuario puede ejercer en cualquier momento su derecho al olvido directamente en la aplicación, a través del menú:\nPolítica de privacidad → Derecho al olvido.\n____________________________________________\n5) Destinatarios y alojamiento de los datos\nLos datos se alojan de forma segura en los servidores de PythonAnywhere.\nLos datos se almacenan en la Unión Europea.\n(Para más información sobre la política de protección de datos del proveedor, consulte https://www.pythonanywhere.com/privacy/.)\nLa aplicación web está alojada por O2Switch en Francia, consulte https://www.o2switch.fr/du-rgpd.pdf.\n____________________________________________\n6) Derechos de los usuarios\nDe conformidad con el Reglamento (UE) 2016/679 (RGPD), los usuarios disponen de los siguientes derechos:\n• Derecho de acceso, rectificación y supresión («derecho al olvido») — directamente a través de su perfil o del menú Política de privacidad → Derecho al olvido;\n• Derecho de oposición, portabilidad y limitación del tratamiento;\n• Derecho a retirar el consentimiento en cualquier momento.\nPara ejercer estos derechos (distintos del derecho al olvido accesible desde la aplicación), puede enviar un correo electrónico a contact@angelmananalytics.org.\n____________________________________________\n7) Seguridad y confidencialidad\nTodos los datos se cifran durante el almacenamiento y la transmisión.\nLas contraseñas se almacenan de forma segura conforme a las buenas prácticas de seguridad, y todas las comunicaciones con el servicio se realizan mediante el protocolo HTTPS.\n____________________________________________\n8) Consentimiento explícito\nLa inscripción en la aplicación ASConnect requiere el consentimiento explícito e informado del usuario para los tratamientos descritos en la sección 2.\nEl usuario puede retirar este consentimiento en cualquier momento a través de la configuración de su cuenta o mediante contacto directo en contact@angelmananalytics.org.';

  @override
  String get contactPageTitle => 'Contactar';

  @override
  String get contactSendMessageTitle => 'Enviar un mensaje';

  @override
  String get contactSubjectLabel => 'Título';

  @override
  String get contactSubjectHint => 'Asunto de tu solicitud';

  @override
  String get contactMessageLabel => 'Mensaje';

  @override
  String get contactMessageHint => 'Describe tu solicitud…';

  @override
  String get contactAntiSpamTitle => 'Verificación anti-spam';

  @override
  String get contactRefresh => 'Actualizar';

  @override
  String contactCaptchaQuestion(int a, int b) {
    return '¿Cuánto es $a + $b?';
  }

  @override
  String get contactCaptchaAnswerLabel => 'Respuesta';

  @override
  String get contactCaptchaRequired => 'Captcha obligatorio';

  @override
  String get contactCaptchaIncorrect => 'Captcha incorrecto.';

  @override
  String get contactSend => 'Enviar';

  @override
  String get contactSending => 'Enviando…';

  @override
  String get contactCancel => 'Cancelar';

  @override
  String get contactMessageSent => 'Mensaje enviado ✅';

  @override
  String contactSendFailedWithCode(int code) {
    return 'Error al enviar ($code)';
  }

  @override
  String get contactAccessDenied => 'Acceso denegado (clave de la aplicación ausente o inválida).';

  @override
  String get contactTooManyRequests => 'Demasiadas solicitudes. Inténtalo de nuevo en unos segundos.';

  @override
  String get contactServiceUnavailable => 'Servicio temporalmente no disponible. Inténtalo más tarde.';

  @override
  String get contactCheckInternet => 'Verifica tu conexión a internet.';

  @override
  String get contactTimeout => 'Tiempo de espera agotado. Inténtalo más tarde.';

  @override
  String get contactFooterNote => 'Tu mensaje se envía a través de nuestra API pública segura. ¡Gracias!';

  @override
  String contactMissingAppKey(String command) {
    return '⚠️ Falta la clave de la aplicación. Ejecuta la app con $command';
  }

  @override
  String fieldRequired(String field) {
    return '$field obligatorio';
  }

  @override
  String unexpectedError(String message) {
    return 'Error inesperado: $message';
  }

  @override
  String get commonOk => 'OK';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonConfirm => 'Confirmar';

  @override
  String get emailRequired => 'Email obligatorio';

  @override
  String get emailInvalid => 'Email inválido';

  @override
  String get editProfileImport => 'Importar';

  @override
  String get editProfileTakePhoto => 'Tomar una foto';

  @override
  String get editProfileDeletePhoto => 'Eliminar mi foto';

  @override
  String get editProfileCancelSelection => 'Cancelar selección';

  @override
  String get editProfilePhotoRequired => 'Foto obligatoria';

  @override
  String get editProfilePhotoRequiredHint => 'Foto obligatoria: importa o toma una foto nueva.';

  @override
  String get editProfileAddPhotoToSave => 'Añade una foto para guardar';

  @override
  String get editProfilePhotoDeleted => 'Foto eliminada ✅';

  @override
  String editProfilePhotoTooLarge(String size) {
    return 'La foto supera 4 MB ($size MB).';
  }

  @override
  String editProfilePhotoPickError(String message) {
    return 'No se pudo obtener la foto: $message';
  }

  @override
  String get editProfileProfileInfoTitle => 'Información del perfil';

  @override
  String get editProfileFirstNameLabel => 'Nombre';

  @override
  String get editProfileLastNameLabel => 'Apellidos';

  @override
  String get editProfileEmailLabel => 'Correo electrónico';

  @override
  String get editProfileBirthDateLabel => 'Fecha de nacimiento (dd/mm/aaaa)';

  @override
  String get editProfileBirthDateHelp => 'Fecha de nacimiento';

  @override
  String get editProfileBirthDatePickTooltip => 'Elegir una fecha';

  @override
  String get editProfileBirthDateRequired => 'Fecha de nacimiento obligatoria';

  @override
  String get editProfileGenotypeLabel => 'Genotipo';

  @override
  String get editProfileGenotypeRequired => 'Genotipo obligatorio';

  @override
  String get editProfileCityLabel => 'Ciudad';

  @override
  String get editProfileGeolocate => 'Geolocalizarme';

  @override
  String get editProfileGeoTooltip => 'Actualiza tu geolocalización si ha cambiado desde tu registro.';

  @override
  String get geoTitle => 'Geolocalización';

  @override
  String get geoInfoText => 'Actualiza tu geolocalización si ha cambiado desde tu registro.';

  @override
  String editProfileLocationUpdated(String cityPart) {
    return 'Ubicación actualizada$cityPart';
  }

  @override
  String get editProfileSecretSectionTitle => 'Pregunta secreta';

  @override
  String get editProfileSecretQuestionLabel => 'Pregunta';

  @override
  String get editProfileSecretAnswerLabel => 'Respuesta secreta';

  @override
  String get editProfileChangePassword => 'Cambiar mi contraseña';

  @override
  String get passwordEnterFirst => 'Introduce una contraseña';

  @override
  String get passwordMismatch => 'Las contraseñas no coinciden';

  @override
  String get passwordMatch => 'Las contraseñas coinciden';

  @override
  String get editProfilePasswordChanged => 'Contraseña cambiada ✅';

  @override
  String get editProfileSave => 'Guardar';

  @override
  String get editProfileSaving => 'Guardando…';

  @override
  String get editProfileChangesSaved => 'Cambios guardados ✅';

  @override
  String get editProfileTimeoutLoading => 'Tiempo de espera al cargar el perfil.';

  @override
  String editProfileLoadError(String message) {
    return 'Error al cargar: $message';
  }

  @override
  String get editProfileTimeoutGeneric => 'Tiempo de espera agotado. Inténtalo de nuevo.';

  @override
  String editProfileErrorGeneric(String message) {
    return 'Error: $message';
  }

  @override
  String get genotypeUPD => 'UPD';

  @override
  String get genotypeICD => 'ICD';

  @override
  String get secretQ1 => '¿Cuál es el apellido de soltera de tu madre?';

  @override
  String get secretQ2 => '¿Cuál es el nombre de tu actor de cine favorito?';

  @override
  String get secretQ3 => '¿Cuál es el nombre de tu mascota favorita?';

  @override
  String get mapPersonTileIsMeHint => 'Es tu perfil';

  @override
  String get mapPersonTileSendHint => 'Enviar un mensaje…';

  @override
  String get mapPersonTileCannotWriteTooltip => 'No puedes escribirte a ti mismo';

  @override
  String get mapPersonTileSendTooltip => 'Enviar';

  @override
  String mapPersonTileSendFailed(Object error) {
    return 'Error al enviar: $error';
  }

  @override
  String mapPersonTileAge(int age) {
    return '$age años';
  }

  @override
  String get mapFiltersButtonTooltip => 'Filtros';

  @override
  String get mapNoFilters => 'Sin filtros';

  @override
  String mapGenotypeCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count genotipos',
      one: '$count genotipo',
    );
    return '$_temp0';
  }

  @override
  String mapAgeRangeYears(Object max, Object min) {
    return '$min–$max años';
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
      other: '$count personas',
      one: '$count persona',
    );
    return '$_temp0';
  }

  @override
  String get mapReloadFromNetworkTooltip => 'Recargar (red, ignora filtros, actualiza la caché)';

  @override
  String get mapTilesBlockedInReleaseMessage => 'Los mosaicos de OSM están desactivados en producción.\nConfigura una clave de MapTiler (o activa allowOsmInRelease=true).';

  @override
  String get mapInitializingDataMessage => 'Estamos inicializando todos los datos…';

  @override
  String mapNetworkUnavailableCacheUsed(Object error) {
    return 'Red no disponible — se usó la caché: $error';
  }

  @override
  String mapLoadGenericError(Object error) {
    return 'Error al cargar: $error';
  }

  @override
  String mapFilterError(Object error) {
    return 'Error de filtro: $error';
  }

  @override
  String get mapLocationServiceDisabled => 'Servicio de ubicación desactivado';

  @override
  String get mapLocationPermissionDenied => 'Permiso de ubicación denegado';

  @override
  String mapLocationUnavailable(Object error) {
    return 'Ubicación no disponible: $error';
  }

  @override
  String get mapPhotoViewerBarrierLabel => 'Foto';

  @override
  String get mapClose => 'Cerrar';

  @override
  String mapCityPeopleCount(Object city, num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personas',
      one: '$count persona',
    );
    return '$city • $_temp0';
  }

  @override
  String mapResultsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count resultados',
      one: '$count resultado',
    );
    return '$_temp0';
  }

  @override
  String get mapNoResultsWithTheseFilters => 'No hay resultados con estos filtros (genotipo/distancia).';

  @override
  String get mapDistanceTitle => 'Distancia (desde mi ubicación)';

  @override
  String get mapEnableDistanceFilter => 'Activar filtro de distancia';

  @override
  String mapOriginDefined(Object lat, Object lon) {
    return 'Origen: $lat, $lon';
  }

  @override
  String get mapOriginUndefined => 'Origen: no definido';

  @override
  String get mapMyPosition => 'Mi ubicación';

  @override
  String mapKmLabel(Object km) {
    return '$km km';
  }

  @override
  String get mapGenotypeTitle => 'Genotipo';

  @override
  String get mapAgeTitle => 'Edad (años)';

  @override
  String mapMinValue(Object value) {
    return 'Mín: $value';
  }

  @override
  String mapMaxValue(Object value) {
    return 'Máx: $value';
  }

  @override
  String get mapReset => 'Restablecer';

  @override
  String get mapCancel => 'Cancelar';

  @override
  String get mapApply => 'Aplicar';

  @override
  String get mapCountryTitle => 'Países';

  @override
  String get mapAllCountriesSelected => 'Todos los países';

  @override
  String mapCountriesSelectedCount(int count) {
    return '$count países seleccionados';
  }

  @override
  String get mapSelectAll => 'Seleccionar todo';

  @override
  String get mapClear => 'Deseleccionar todo';

  @override
  String get mapBack => 'Retroceso';

  @override
  String chatWithName(Object name) {
    return 'Chat con $name';
  }

  @override
  String get conversationsReconnectToSee => 'Vuelve a iniciar sesión para ver tus conversaciones.';

  @override
  String get loading => 'Cargando…';

  @override
  String get conversationsEmpty => 'No hay conversaciones';

  @override
  String get conversationsNoMessage => 'Sin mensajes';

  @override
  String conversationsLoadError(Object error) {
    return 'Error al cargar: $error';
  }

  @override
  String get conversationsLeaveTitle => '¿Salir de la conversación?';

  @override
  String get conversationsLeaveBody => '¿Seguro que quieres salir de esta conversación?\nSe borrarán todos tus mensajes.';

  @override
  String get conversationsLeaveConfirm => 'Salir';

  @override
  String get close => 'Cerrar';

  @override
  String get photo => 'Foto';

  @override
  String get yesterday => 'ayer';

  @override
  String genericError(Object error) {
    return 'Error: $error';
  }

  @override
  String get today => 'Hoy';

  @override
  String get chatNoMessagesYet => 'Aún no hay mensajes.';

  @override
  String chatLoadMessagesError(Object error) {
    return 'Error al cargar mensajes: $error';
  }

  @override
  String chatSendError(Object error) {
    return 'Error al enviar: $error';
  }

  @override
  String get chatEditMessageTitle => 'Editar mensaje';

  @override
  String get chatYourMessageHint => 'Tu mensaje';

  @override
  String chatEditError(Object error) {
    return 'Error al editar: $error';
  }

  @override
  String get chatDeleteMessageTitle => '¿Eliminar mensaje?';

  @override
  String get chatDeleteMessageBody => 'Este mensaje se marcará como eliminado en esta conversación.';

  @override
  String chatDeleteError(Object error) {
    return 'Error al eliminar: $error';
  }

  @override
  String chatReactError(Object error) {
    return 'Error al reaccionar: $error';
  }

  @override
  String get chatLeaveConversationBody => '¿Seguro que quieres salir de la conversación y borrar todos tus mensajes?';

  @override
  String chatLeaveError(Object error) {
    return 'Error al salir: $error';
  }

  @override
  String get message => 'Mensaje';

  @override
  String get send => 'Enviar';

  @override
  String get edited => 'editado';

  @override
  String get deletedMessage => 'Mensaje eliminado';

  @override
  String get edit => 'Editar';

  @override
  String get reply => 'Responder';

  @override
  String get delete => 'Eliminar';

  @override
  String get languageName => 'Español';

  @override
  String get mapConnectionSectionTitle => 'Conexión';

  @override
  String get mapConnectedOnlyLabel => 'Mostrar solo personas conectadas';

  @override
  String get mapConnectedOnlyHint => 'Oculta los perfiles sin conexión.';

  @override
  String get mapConnectedOnlyChip => 'Conectados';

  @override
  String get statusOnline => 'En línea';

  @override
  String get statusOffline => 'Desconectado';

  @override
  String get tableTabular => 'Tabla';

  @override
  String get tableColumnPseudo => 'Usuario';

  @override
  String get tableColumnAge => 'Edad';

  @override
  String get tableColumnGenotype => 'Genotipo';

  @override
  String get tableColumnCountry => 'País';

  @override
  String get tableColumnCity => 'Ciudad';

  @override
  String get tabularColPseudo => 'Usuario';

  @override
  String get tabularColAge => 'Edad';

  @override
  String get tabularColGenotype => 'Genotipo';

  @override
  String get tabularColCountry => 'País';

  @override
  String get tabularColCity => 'Ciudad';

  @override
  String get tabularColAction => 'Acción';

  @override
  String get tabularSendMessageTooltip => 'Enviar un mensaje';

  @override
  String get tabularSendMessageErrorNoId => 'No se puede enviar el mensaje: falta el identificador.';

  @override
  String get tabularSendMessageActionStub => 'Función de mensajería pendiente de conexión.';

  @override
  String tabularSendMessageTitle(Object name) {
    return 'Mensaje a $name';
  }

  @override
  String get tabularSendMessageHint => 'Escribe un mensaje…';

  @override
  String get tabularSendMessageSend => 'Enviar';

  @override
  String get tabularSendMessageSentStub => 'Mensaje listo para enviarse (pendiente de conexión).';

  @override
  String get tabularSendMessageCancel => 'Cancelar';

  @override
  String get genderLabel => 'Sexo';

  @override
  String get genderMale => 'Hombre';

  @override
  String get genderFemale => 'Mujer';

  @override
  String get genderRequired => 'Por favor, elige un sexo';

  @override
  String get acceptInfoAngelman => 'Acepto recibir información sobre el síndrome de Angelman';

  @override
  String get signupEnableGeolocation => 'Por favor, autoriza la geolocalización para continuar.';

  @override
  String get signUpCheckMail => 'Verificación del correo';

  @override
  String get signUpGPS => 'Determinación de las coordenadas de tu ciudad a partir de la ubicación GPS';

  @override
  String get signUpMessageCreate => 'Creación del perfil';

  @override
  String get tabGroup => 'Grupo';

  @override
  String groupMembersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count miembros',
      one: '$count miembro',
    );
    return '$_temp0';
  }

  @override
  String get groupCreateTooltip => 'Crear un grupo';

  @override
  String get groupCreateTitle => 'Crear un grupo';

  @override
  String get groupCreateIntro => 'Estás a punto de crear un grupo. Elige un título significativo, escribe el primer mensaje y define la audiencia mediante los filtros.';

  @override
  String get groupTitleLabel => 'Título del grupo';

  @override
  String get groupFirstMessageLabel => 'Primer mensaje';

  @override
  String get groupCreateButton => 'Crear';

  @override
  String get groupTitleRequired => 'El título es obligatorio';

  @override
  String get groupCreateNoMembers => 'No se puede crear un grupo sin miembros';

  @override
  String get audience => 'Audiencia';
}
