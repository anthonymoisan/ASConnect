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
  String get signupEmailAlreadyExistsRedirect => 'Tu correo ya está en nuestra base de datos. Serás redirigido/a a la página de inicio de sesión.';

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
  String get tooManyAttemptsMessage => 'Has superado el número de intentos.\n\nEscribe a contact@fastfrance.org para explicar tu problema de inicio de sesión.';

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
  String get versionMadeByFastFrance => 'Esta aplicación ha sido desarrollada por FAST France';

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
  String get consentText => 'Política de privacidad – Aplicación ASConnect\n\n1) Responsable del tratamiento\nLos datos recopilados en la aplicación ASConnect son tratados por FAST France como responsable del tratamiento.\nPara cualquier pregunta relativa a sus datos o al ejercicio de sus derechos, puede contactarnos en: contact@fastfrance.org.\n\n2) Finalidades del tratamiento\nLos tratamientos de datos realizados a través de la aplicación persiguen las siguientes finalidades:\n• Crear y gestionar su cuenta de usuario para acceder a la aplicación ASConnect;\n• Utilizar funciones de geolocalización para visualizar:\n  o puntos de interés relacionados con el síndrome de Angelman,\n  o y/o perfiles de personas afectadas, según distintos criterios (distancia geográfica, genotipo, rango de edad);\n• Mejorar el servicio y personalizar la experiencia del usuario, incluyendo la posibilidad de elegir si desea mostrar una foto, su nombre o su apellido.\n\n3) Categorías de datos recopilados\nSe pueden recopilar los siguientes datos:\n• Datos de identificación:\n  o apellido, nombre, correo electrónico, contraseña, foto,\n  o pregunta y respuesta secretas (en caso de olvido de la contraseña);\n• Datos sensibles:\n  o genotipo, ubicación del teléfono (geolocalización).\nLa base legal de estos tratamientos se basa en el consentimiento explícito e informado del usuario.\n\n4) Plazo de conservación\nLos datos se conservan durante todo el tiempo de uso de la cuenta y luego se eliminan en un plazo máximo de 12 meses tras la última actividad.\nEl usuario puede ejercer su derecho al olvido en cualquier momento directamente en la aplicación, a través de:\nPolítica de privacidad → Derecho al olvido.\n\n5) Destinatarios y alojamiento\nLos datos se alojan de forma segura en los servidores de PythonAnywhere.\nLos datos se almacenan en la Unión Europea.\n(Para más información sobre la política de privacidad del proveedor, consulte https://www.pythonanywhere.com/privacy/.)\n\n6) Derechos de los usuarios\nDe conformidad con el Reglamento (UE) 2016/679 (RGPD), los usuarios disponen de los siguientes derechos:\n• Derecho de acceso, rectificación y supresión (“derecho al olvido”) — directamente desde su perfil o desde Política de privacidad → Derecho al olvido;\n• Derecho de oposición, portabilidad y limitación del tratamiento;\n• Derecho a retirar el consentimiento en cualquier momento.\nPara ejercer estos derechos (distintos del derecho al olvido dentro de la aplicación), puede enviar un correo a: contact@fastfrance.org.\n\n7) Seguridad y confidencialidad\nTodos los datos se cifran durante el almacenamiento y la transmisión.\nLas contraseñas se almacenan mediante hash siguiendo buenas prácticas de seguridad y toda la comunicación con el servicio se realiza mediante HTTPS.\n\n8) Consentimiento explícito\nEl registro en la aplicación ASConnect requiere el consentimiento explícito e informado del usuario para los tratamientos descritos en la sección 2.\nEl usuario puede retirar su consentimiento en cualquier momento desde la configuración de su cuenta o contactando con contact@fastfrance.org.';

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
}
