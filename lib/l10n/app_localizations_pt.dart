// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'ASConnexion';

  @override
  String get systemLanguage => 'Sistema';

  @override
  String get menu => 'Menu';

  @override
  String get menuNavigation => 'Navegação';

  @override
  String get menuMyProfile => 'Meu perfil';

  @override
  String get menuContact => 'Fale conosco';

  @override
  String get menuPrivacyPolicy => 'Política de privacidade';

  @override
  String get menuVersion => 'Versão';

  @override
  String get menuContactSubject => 'Contato via app';

  @override
  String get languageLabel => 'Idioma';

  @override
  String currentLanguage(String label) {
    return 'Atual: $label';
  }

  @override
  String get cancel => 'Cancelar';

  @override
  String get confirm => 'Confirmar';

  @override
  String get ok => 'OK';

  @override
  String get logoutTitle => 'Sair';

  @override
  String get logoutConfirm => 'Tem certeza de que deseja sair do app?';

  @override
  String get tabCommunity => 'Conecte-se com a comunidade';

  @override
  String get tabChats => 'Minhas conversas';

  @override
  String get tabPoi => 'Pontos de interesse';

  @override
  String get profileUpdated => 'Perfil atualizado ✅';

  @override
  String get loginTitle => 'Entrar';

  @override
  String get loginIntro => 'O app ASConnect é destinado apenas a cuidadores que têm um filho com síndrome de Angelman, uma doença genética rara.';

  @override
  String get emailLabel => 'Endereço de e-mail';

  @override
  String get emailHintRequired => 'Informe seu e-mail';

  @override
  String get emailHintInvalid => 'E-mail inválido';

  @override
  String get passwordLabel => 'Senha';

  @override
  String get show => 'Mostrar';

  @override
  String get hide => 'Ocultar';

  @override
  String get passwordRequired => 'Informe sua senha';

  @override
  String get loginButton => 'Entrar';

  @override
  String get loginLoading => 'Entrando…';

  @override
  String get createAccount => 'Criar uma conta';

  @override
  String get forgotPassword => 'Esqueceu sua senha?';

  @override
  String get invalidCredentials => 'Credenciais inválidas.';

  @override
  String get accessDeniedKey => 'Acesso negado: chave do app ausente ou inválida.';

  @override
  String get badRequest => 'Solicitação inválida (400).';

  @override
  String get tooManyAttempts => 'Muitas tentativas. Tente novamente em instantes.';

  @override
  String get serviceUnavailable => 'Serviço indisponível. Tente novamente mais tarde.';

  @override
  String serverErrorWithCode(int code) {
    return 'Erro do servidor ($code).';
  }

  @override
  String get unexpectedServerResponse => 'Resposta inesperada do servidor.';

  @override
  String get cannotConnectServer => 'Não foi possível conectar ao servidor.';

  @override
  String get timeoutCheckConnection => 'A solicitação expirou. Verifique sua conexão.';

  @override
  String errorWithMessage(String message) {
    return 'Erro: $message';
  }

  @override
  String get missingAppKeyWarning => '⚠️ Chave do app ausente. Execute o app com --dart-define=PUBLIC_APP_KEY=your_public_key';

  @override
  String get signupTitle => 'Criar uma conta';

  @override
  String get signupSectionPerson => 'Pessoa com síndrome de Angelman';

  @override
  String get signupSectionAuth => 'Autenticação';

  @override
  String get consentTitle => 'Consentimento';

  @override
  String get firstNameLabel => 'Nome';

  @override
  String get firstNameRequired => 'O nome é obrigatório';

  @override
  String get lastNameLabel => 'Sobrenome';

  @override
  String get lastNameRequired => 'O sobrenome é obrigatório';

  @override
  String get birthdateLabel => 'Data de nascimento (dd/mm/aaaa)';

  @override
  String get birthdateRequired => 'A data de nascimento é obrigatória';

  @override
  String get chooseDate => 'Escolher uma data';

  @override
  String get signupBirthdateHelp => 'Data de nascimento';

  @override
  String get genotypeLabel => 'Genótipo';

  @override
  String get genotypeRequired => 'O genótipo é obrigatório';

  @override
  String get genotypeDeletion => 'Deleção';

  @override
  String get genotypeMutation => 'Mutação';

  @override
  String get genotypeUpd => 'UPD';

  @override
  String get genotypeIcd => 'ICD';

  @override
  String get genotypeClinical => 'Clínico';

  @override
  String get genotypeMosaic => 'Mosaico';

  @override
  String get signupPhotoHint => 'Foto da criança (obrigatória, < 4 MB)';

  @override
  String get importPhoto => 'Importar uma foto';

  @override
  String get takePhoto => 'Tirar uma foto';

  @override
  String get deletePhoto => 'Excluir foto';

  @override
  String get signupPhotoRequired => 'A foto é obrigatória';

  @override
  String get signupAddPhotoToContinue => 'Adicione uma foto para continuar';

  @override
  String signupPhotoTooLarge(String mb) {
    return 'A foto excede 4 MB ($mb MB).';
  }

  @override
  String signupPhotoCannotLoad(String message) {
    return 'Não foi possível carregar a foto: $message';
  }

  @override
  String get signupPasswordTooWeak => 'A senha é muito fraca';

  @override
  String get signupPwdRuleMin8 => 'Mín. 8 caracteres';

  @override
  String get signupPwdRuleUpper => '1 letra maiúscula';

  @override
  String get signupPwdRuleDigit => '1 número';

  @override
  String get signupPwdRuleSpecial => '1 caractere especial';

  @override
  String get secretQuestionLabel => 'Pergunta de segurança';

  @override
  String get secretQuestionRequired => 'A pergunta de segurança é obrigatória';

  @override
  String get secretQuestion1 => 'Nome de solteira da sua mãe?';

  @override
  String get secretQuestion2 => 'Nome do seu ator de cinema favorito?';

  @override
  String get secretQuestion3 => 'Nome do seu animal de estimação favorito?';

  @override
  String get secretAnswerLabel => 'Resposta';

  @override
  String get secretAnswerRequired => 'A resposta é obrigatória';

  @override
  String get consentCheckbox => 'Aceito os termos de uso dos meus dados e dou meu consentimento.';

  @override
  String get signupConsentNotGiven => 'Você não forneceu seu consentimento';

  @override
  String get signupCreating => 'Criando…';

  @override
  String get signupCreateBtn => 'Criar minha conta';

  @override
  String get signupSuccess => 'Conta criada com sucesso.';

  @override
  String get signupEmailAlreadyExistsRedirect => 'Seu e-mail já está no nosso banco de dados. Você será redirecionado para a página de login.';

  @override
  String get signupSelectBirthdate => 'Selecione uma data de nascimento';

  @override
  String get signupChooseGenotype => 'Escolha um genótipo';

  @override
  String get signupChooseSecretQuestion => 'Escolha uma pergunta de segurança';

  @override
  String get signupEnterSecretAnswer => 'Informe a resposta secreta';

  @override
  String signupApiFailed(int code, String body) {
    return 'Falha na API ($code): $body';
  }

  @override
  String get forgotPasswordTitle => 'Esqueci a senha';

  @override
  String get forgotEmailLabel => 'Endereço de e-mail';

  @override
  String get forgotFetchQuestionTooltip => 'Buscar a pergunta';

  @override
  String get forgotEnterValidEmail => 'Informe um e-mail válido.';

  @override
  String get forgotUnknownEmail => 'E-mail desconhecido.';

  @override
  String forgotErrorCode(int code) {
    return 'Erro ($code)';
  }

  @override
  String get forgotTimeoutRetry => 'Tempo esgotado. Tente novamente.';

  @override
  String forgotErrorWithMessage(String message) {
    return 'Erro: $message';
  }

  @override
  String get forgotQuestionFallback => 'Pergunta de segurança';

  @override
  String get forgotQuestionLabel => 'Pergunta';

  @override
  String get forgotSecretAnswerLabel => 'Resposta de segurança';

  @override
  String get forgotAnswerRequired => 'A resposta é obrigatória';

  @override
  String get forgotEnterYourAnswer => 'Digite sua resposta.';

  @override
  String get forgotVerify => 'Verificar';

  @override
  String get forgotAnswerCorrectSnack => 'Resposta correta 👍';

  @override
  String forgotAnswerIncorrectAttempts(int attempts) {
    return 'Resposta incorreta ($attempts/3).';
  }

  @override
  String forgotFailedAttempts(int attempts) {
    return 'Tentativas falhas: $attempts / 3';
  }

  @override
  String get forgotAnswerOkHint => '✅ Resposta correta, você pode definir uma nova senha.';

  @override
  String get forgotNewPasswordLabel => 'Nova senha';

  @override
  String get forgotPasswordRequired => 'A senha é obrigatória';

  @override
  String get forgotPasswordTooWeak => 'A senha é muito fraca';

  @override
  String get forgotPwdRuleMin8 => 'Pelo menos 8 caracteres';

  @override
  String get forgotPwdRuleUpper => 'Pelo menos 1 letra maiúscula';

  @override
  String get forgotPwdRuleSpecial => 'Pelo menos 1 caractere especial';

  @override
  String get forgotConfirmPasswordLabel => 'Confirmar senha';

  @override
  String get forgotEnterNewPasswordFirst => 'Informe primeiro a nova senha';

  @override
  String get forgotPasswordsDoNotMatch => 'As senhas não coincidem';

  @override
  String get forgotPasswordsMatch => 'As senhas coincidem';

  @override
  String get forgotResetSuccess => 'Senha redefinida ✅';

  @override
  String forgotResetFailed(int code) {
    return 'Falha ($code).';
  }

  @override
  String get tooManyAttemptsTitle => 'Muitas tentativas';

  @override
  String get tooManyAttemptsMessage => 'Muitas tentativas.\n\nEnvie um e-mail para contact@fastfrance.org explicando seu problema de login.';

  @override
  String get forgotValidating => 'Enviando…';

  @override
  String get editProfileTitle => 'Editar perfil';

  @override
  String get loadingProfile => 'Carregando perfil…';

  @override
  String get timeoutLoadingProfile => 'Tempo esgotado ao carregar o perfil.';

  @override
  String errorLoadingProfile(String message) {
    return 'Erro ao carregar: $message';
  }

  @override
  String get import => 'Importar';

  @override
  String get deleteMyPhoto => 'Excluir minha foto';

  @override
  String get cancelSelection => 'Cancelar seleção';

  @override
  String photoTooLarge(String size) {
    return 'A foto excede 4 MB ($size MB).';
  }

  @override
  String cannotGetPhoto(String message) {
    return 'Não foi possível obter a foto: $message';
  }

  @override
  String get photoRequired => 'Foto obrigatória';

  @override
  String get photoRequiredAddToSave => 'Adicione uma foto para salvar';

  @override
  String get photoRequiredAfterDelete => 'Foto obrigatória: importe ou tire uma nova foto.';

  @override
  String get photoDeleted => 'Foto excluída ✅';

  @override
  String get profileInfoSection => 'Informações do perfil';

  @override
  String get firstName => 'Nome';

  @override
  String get lastName => 'Sobrenome';

  @override
  String get birthDateLabel => 'Data de nascimento (dd/mm/aaaa)';

  @override
  String get birthDateRequired => 'A data de nascimento é obrigatória';

  @override
  String get genotype => 'Genótipo';

  @override
  String get city => 'Cidade';

  @override
  String get geolocateMe => 'Usar minha localização';

  @override
  String get locationUpdated => 'Localização atualizada';

  @override
  String locationUpdatedWithCity(String city) {
    return 'Localização atualizada ($city)';
  }

  @override
  String get geolocation => 'Geolocalização';

  @override
  String get geolocationHint => 'Lembre-se de atualizar sua localização se ela mudou desde seu cadastro.';

  @override
  String get secretQuestionSection => 'Pergunta de segurança';

  @override
  String get question => 'Pergunta';

  @override
  String get answer => 'Resposta';

  @override
  String get changeMyPassword => 'Alterar minha senha';

  @override
  String get changePasswordTitle => 'Alterar minha senha';

  @override
  String get newPasswordLabel => 'Nova senha';

  @override
  String get confirmPasswordLabel => 'Confirmar senha';

  @override
  String get passwordTooWeak => 'A senha é muito fraca';

  @override
  String get enterPassword => 'Digite uma senha';

  @override
  String get passwordsDoNotMatch => 'As senhas não coincidem';

  @override
  String get passwordsMatch => 'As senhas coincidem';

  @override
  String get pwdRuleMin8 => 'Pelo menos 8 caracteres';

  @override
  String get pwdRuleUpper => 'Pelo menos 1 letra maiúscula';

  @override
  String get pwdRuleSpecial => 'Pelo menos 1 caractere especial';

  @override
  String get passwordChanged => 'Senha alterada ✅';

  @override
  String get save => 'Salvar';

  @override
  String get saving => 'Salvando…';

  @override
  String get savedChanges => 'Alterações salvas ✅';

  @override
  String get timeoutTryAgain => 'Tempo esgotado. Tente novamente.';

  @override
  String failedWithCode(int code) {
    return 'Falha ($code)';
  }

  @override
  String get versionMadeByFastFrance => 'Este app é desenvolvido pela FAST France';

  @override
  String versionNumber(String version) {
    return 'Versão $version';
  }

  @override
  String get privacyTitle => 'Política de privacidade';

  @override
  String get privacyRightToBeForgotten => 'Direito ao esquecimento';

  @override
  String get privacyDeleteTitle => 'Aviso';

  @override
  String get privacyDeleteConfirmBody => 'Esta ação é irreversível.\n\nSeu perfil e os dados associados serão excluídos permanentemente.\n\nDeseja continuar?';

  @override
  String get privacyDeletedOkTitle => 'Conta excluída';

  @override
  String get privacyDeletedOkBody => 'Sua conta foi excluída.\nVocê será redirecionado para a página de login.';

  @override
  String privacyDeleteFailedWithCode(int code) {
    return 'Não foi possível excluir (código $code).';
  }

  @override
  String get timeoutRetry => 'A solicitação expirou. Tente novamente.';

  @override
  String get consentText => 'Política de privacidade – app ASConnect\n\n1) Controlador de dados\nOs dados coletados no app ASConnect são tratados pela FAST France como controladora de dados.\nSe você tiver dúvidas sobre seus dados ou sobre como exercer seus direitos, entre em contato: contact@fastfrance.org.\n\n2) Finalidades do tratamento\nO tratamento de dados realizado por meio do app serve às seguintes finalidades:\n• Criar e gerenciar sua conta de usuário para acessar o app ASConnect;\n• Usar recursos de geolocalização para exibir:\n  o pontos de interesse relacionados à síndrome de Angelman,\n  o e/ou perfis de pessoas envolvidas, de acordo com critérios diversos (distância geográfica, genótipo, faixa etária);\n• Melhorar o serviço e personalizar a experiência do usuário, incluindo permitir que o usuário escolha se deseja exibir uma foto, seu nome ou sobrenome.\n\n3) Categorias de dados coletados\nOs seguintes dados podem ser coletados:\n• Dados de identificação:\n  o sobrenome, nome, endereço de e-mail, senha, foto,\n  o pergunta e resposta secretas (em caso de senha esquecida);\n• Dados sensíveis:\n  o genótipo, localização do telefone (geolocalização).\nA base legal deste tratamento é o consentimento explícito e informado do usuário.\n\n4) Prazo de retenção dos dados\nOs dados são mantidos durante o uso da conta e, em seguida, excluídos no máximo em 12 meses após a última atividade.\nOs usuários podem exercer seu direito ao esquecimento a qualquer momento diretamente no app via:\nPolítica de privacidade → Direito ao esquecimento.\n\n5) Destinatários e hospedagem de dados\nOs dados são hospedados com segurança nos servidores da PythonAnywhere.\nOs dados são armazenados na União Europeia.\n(Para mais informações sobre a política de privacidade do provedor, consulte https://www.pythonanywhere.com/privacy/.)\n\n6) Direitos dos usuários\nDe acordo com o Regulamento (UE) 2016/679 (GDPR), os usuários têm os seguintes direitos:\n• Direito de acesso, retificação e exclusão (“direito ao esquecimento”) — diretamente via perfil ou via Política de privacidade → Direito ao esquecimento;\n• Direito de oposição, portabilidade de dados e restrição do tratamento;\n• Direito de retirar o consentimento a qualquer momento.\nPara exercer esses direitos (além do direito ao esquecimento no app), envie um e-mail para: contact@fastfrance.org.\n\n7) Segurança e confidencialidade\nTodos os dados são criptografados durante o armazenamento e a transmissão.\nAs senhas são protegidas por hash conforme as melhores práticas de segurança e toda comunicação com o serviço utiliza HTTPS.\n\n8) Consentimento explícito\nO registro no app ASConnect exige o consentimento explícito e informado do usuário para o tratamento descrito na seção 2.\nOs usuários podem retirar o consentimento a qualquer momento nas configurações da conta ou entrando em contato com contact@fastfrance.org.';

  @override
  String get contactPageTitle => 'Fale conosco';

  @override
  String get contactSendMessageTitle => 'Enviar uma mensagem';

  @override
  String get contactSubjectLabel => 'Título';

  @override
  String get contactSubjectHint => 'Assunto da sua solicitação';

  @override
  String get contactMessageLabel => 'Mensagem';

  @override
  String get contactMessageHint => 'Descreva sua solicitação…';

  @override
  String get contactAntiSpamTitle => 'Verificação anti-spam';

  @override
  String get contactRefresh => 'Atualizar';

  @override
  String contactCaptchaQuestion(int a, int b) {
    return 'Quanto é $a + $b?';
  }

  @override
  String get contactCaptchaAnswerLabel => 'Resposta';

  @override
  String get contactCaptchaRequired => 'Captcha obrigatório';

  @override
  String get contactCaptchaIncorrect => 'Captcha incorreto.';

  @override
  String get contactSend => 'Enviar';

  @override
  String get contactSending => 'Enviando…';

  @override
  String get contactCancel => 'Cancelar';

  @override
  String get contactMessageSent => 'Mensagem enviada ✅';

  @override
  String contactSendFailedWithCode(int code) {
    return 'Falha ao enviar ($code)';
  }

  @override
  String get contactAccessDenied => 'Acesso negado (chave do app ausente ou inválida).';

  @override
  String get contactTooManyRequests => 'Muitas solicitações. Tente novamente em alguns segundos.';

  @override
  String get contactServiceUnavailable => 'Serviço temporariamente indisponível. Tente novamente mais tarde.';

  @override
  String get contactCheckInternet => 'Verifique sua conexão com a internet.';

  @override
  String get contactTimeout => 'Tempo esgotado. Tente novamente mais tarde.';

  @override
  String get contactFooterNote => 'Sua mensagem é enviada por meio da nossa API pública segura. Obrigado!';

  @override
  String contactMissingAppKey(String command) {
    return '⚠️ Chave do app ausente. Execute o app com $command';
  }

  @override
  String fieldRequired(String field) {
    return '$field é obrigatório';
  }

  @override
  String unexpectedError(String message) {
    return 'Erro inesperado: $message';
  }

  @override
  String get commonOk => 'OK';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonConfirm => 'Confirmar';

  @override
  String get emailRequired => 'O e-mail é obrigatório';

  @override
  String get emailInvalid => 'E-mail inválido';

  @override
  String get editProfileImport => 'Importar';

  @override
  String get editProfileTakePhoto => 'Tirar uma foto';

  @override
  String get editProfileDeletePhoto => 'Excluir minha foto';

  @override
  String get editProfileCancelSelection => 'Cancelar seleção';

  @override
  String get editProfilePhotoRequired => 'Foto obrigatória';

  @override
  String get editProfilePhotoRequiredHint => 'Foto obrigatória: importe ou tire uma nova foto.';

  @override
  String get editProfileAddPhotoToSave => 'Adicione uma foto para salvar';

  @override
  String get editProfilePhotoDeleted => 'Foto excluída ✅';

  @override
  String editProfilePhotoTooLarge(String size) {
    return 'A foto excede 4 MB ($size MB).';
  }

  @override
  String editProfilePhotoPickError(String message) {
    return 'Não foi possível obter a foto: $message';
  }

  @override
  String get editProfileProfileInfoTitle => 'Informações do perfil';

  @override
  String get editProfileFirstNameLabel => 'Nome';

  @override
  String get editProfileLastNameLabel => 'Sobrenome';

  @override
  String get editProfileEmailLabel => 'Endereço de e-mail';

  @override
  String get editProfileBirthDateLabel => 'Data de nascimento (dd/mm/aaaa)';

  @override
  String get editProfileBirthDateHelp => 'Data de nascimento';

  @override
  String get editProfileBirthDatePickTooltip => 'Escolher uma data';

  @override
  String get editProfileBirthDateRequired => 'A data de nascimento é obrigatória';

  @override
  String get editProfileGenotypeLabel => 'Genótipo';

  @override
  String get editProfileGenotypeRequired => 'O genótipo é obrigatório';

  @override
  String get editProfileCityLabel => 'Cidade';

  @override
  String get editProfileGeolocate => 'Localizar-me';

  @override
  String get editProfileGeoTooltip => 'Atualize sua localização se ela tiver mudado desde o cadastro.';

  @override
  String get geoTitle => 'Geolocalização';

  @override
  String get geoInfoText => 'Atualize sua localização se ela tiver mudado desde o cadastro.';

  @override
  String editProfileLocationUpdated(String cityPart) {
    return 'Localização atualizada$cityPart';
  }

  @override
  String get editProfileSecretSectionTitle => 'Pergunta secreta';

  @override
  String get editProfileSecretQuestionLabel => 'Pergunta';

  @override
  String get editProfileSecretAnswerLabel => 'Resposta secreta';

  @override
  String get editProfileChangePassword => 'Alterar minha senha';

  @override
  String get passwordEnterFirst => 'Informe uma senha primeiro';

  @override
  String get passwordMismatch => 'As senhas não coincidem';

  @override
  String get passwordMatch => 'As senhas coincidem';

  @override
  String get editProfilePasswordChanged => 'Senha alterada ✅';

  @override
  String get editProfileSave => 'Salvar';

  @override
  String get editProfileSaving => 'Salvando…';

  @override
  String get editProfileChangesSaved => 'Alterações salvas ✅';

  @override
  String get editProfileTimeoutLoading => 'Tempo esgotado ao carregar o perfil.';

  @override
  String editProfileLoadError(String message) {
    return 'Erro ao carregar: $message';
  }

  @override
  String get editProfileTimeoutGeneric => 'Tempo esgotado. Tente novamente.';

  @override
  String editProfileErrorGeneric(String message) {
    return 'Erro: $message';
  }

  @override
  String get genotypeUPD => 'UPD';

  @override
  String get genotypeICD => 'ICD';

  @override
  String get secretQ1 => 'Qual é o nome de solteira da sua mãe?';

  @override
  String get secretQ2 => 'Qual é o nome do seu ator de cinema favorito?';

  @override
  String get secretQ3 => 'Qual é o nome do seu animal de estimação favorito?';

  @override
  String get mapPersonTileIsMeHint => 'Este é o seu perfil';

  @override
  String get mapPersonTileSendHint => 'Enviar uma mensagem…';

  @override
  String get mapPersonTileCannotWriteTooltip => 'Você não pode enviar mensagem para si mesmo';

  @override
  String get mapPersonTileSendTooltip => 'Enviar';

  @override
  String mapPersonTileSendFailed(Object error) {
    return 'Falha ao enviar: $error';
  }

  @override
  String mapPersonTileAge(int age) {
    return '$age anos';
  }

  @override
  String get mapFiltersButtonTooltip => 'Filtros';

  @override
  String get mapNoFilters => 'Sem filtros';

  @override
  String mapGenotypeCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count genótipos',
      one: '$count genótipo',
    );
    return '$_temp0';
  }

  @override
  String mapAgeRangeYears(Object max, Object min) {
    return '$min–$max anos';
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
      other: '$count pessoas',
      one: '$count pessoa',
    );
    return '$_temp0';
  }

  @override
  String get mapReloadFromNetworkTooltip => 'Recarregar (rede, ignora filtros, atualiza cache)';

  @override
  String get mapTilesBlockedInReleaseMessage => 'Os tiles OSM estão desativados em produção.\nConfigure uma chave MapTiler (ou defina allowOsmInRelease=true).';

  @override
  String get mapInitializingDataMessage => 'Estamos inicializando todos os dados…';

  @override
  String mapNetworkUnavailableCacheUsed(Object error) {
    return 'Rede indisponível — cache utilizada: $error';
  }

  @override
  String mapLoadGenericError(Object error) {
    return 'Erro ao carregar: $error';
  }

  @override
  String mapFilterError(Object error) {
    return 'Erro de filtro: $error';
  }

  @override
  String get mapLocationServiceDisabled => 'Serviço de localização desativado';

  @override
  String get mapLocationPermissionDenied => 'Permissão de localização negada';

  @override
  String mapLocationUnavailable(Object error) {
    return 'Localização indisponível: $error';
  }

  @override
  String get mapPhotoViewerBarrierLabel => 'Foto';

  @override
  String get mapClose => 'Fechar';

  @override
  String mapCityPeopleCount(Object city, num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pessoas',
      one: '$count pessoa',
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
  String get mapNoResultsWithTheseFilters => 'Nenhum resultado com esses filtros (genótipo/distância).';

  @override
  String get mapDistanceTitle => 'Distância (da minha localização)';

  @override
  String get mapEnableDistanceFilter => 'Ativar filtro de distância';

  @override
  String mapOriginDefined(Object lat, Object lon) {
    return 'Origem: $lat, $lon';
  }

  @override
  String get mapOriginUndefined => 'Origem: não definida';

  @override
  String get mapMyPosition => 'Minha localização';

  @override
  String mapKmLabel(Object km) {
    return '$km km';
  }

  @override
  String get mapGenotypeTitle => 'Genótipo';

  @override
  String get mapAgeTitle => 'Idade (anos)';

  @override
  String mapMinValue(Object value) {
    return 'Mín: $value';
  }

  @override
  String mapMaxValue(Object value) {
    return 'Máx: $value';
  }

  @override
  String get mapReset => 'Redefinir';

  @override
  String get mapCancel => 'Cancelar';

  @override
  String get mapApply => 'Aplicar';

  @override
  String get mapCountryTitle => 'Países';

  @override
  String get mapAllCountriesSelected => 'Todos os países';

  @override
  String mapCountriesSelectedCount(int count) {
    return '$count países selecionados';
  }

  @override
  String get mapSelectAll => 'Selecionar tudo';

  @override
  String get mapClear => 'Limpar seleção';

  @override
  String get mapBack => 'Voltar';

  @override
  String chatWithName(Object name) {
    return 'Chat com $name';
  }

  @override
  String get conversationsReconnectToSee => 'Faça login novamente para ver suas conversas.';

  @override
  String get loading => 'Carregando…';

  @override
  String get conversationsEmpty => 'Sem conversas';

  @override
  String get conversationsNoMessage => 'Sem mensagens';

  @override
  String conversationsLoadError(Object error) {
    return 'Erro ao carregar: $error';
  }

  @override
  String get conversationsLeaveTitle => 'Sair da conversa?';

  @override
  String get conversationsLeaveBody => 'Tem certeza de que deseja sair desta conversa?\nTodas as suas mensagens serão excluídas.';

  @override
  String get conversationsLeaveConfirm => 'Sair';

  @override
  String get close => 'Fechar';

  @override
  String get photo => 'Foto';

  @override
  String get yesterday => 'ontem';

  @override
  String genericError(Object error) {
    return 'Erro: $error';
  }

  @override
  String get today => 'Hoje';

  @override
  String get chatNoMessagesYet => 'Ainda não há mensagens.';

  @override
  String chatLoadMessagesError(Object error) {
    return 'Erro ao carregar mensagens: $error';
  }

  @override
  String chatSendError(Object error) {
    return 'Erro ao enviar: $error';
  }

  @override
  String get chatEditMessageTitle => 'Editar mensagem';

  @override
  String get chatYourMessageHint => 'Sua mensagem';

  @override
  String chatEditError(Object error) {
    return 'Erro ao editar: $error';
  }

  @override
  String get chatDeleteMessageTitle => 'Excluir mensagem?';

  @override
  String get chatDeleteMessageBody => 'Esta mensagem será marcada como excluída nesta conversa.';

  @override
  String chatDeleteError(Object error) {
    return 'Erro ao excluir: $error';
  }

  @override
  String chatReactError(Object error) {
    return 'Erro ao reagir: $error';
  }

  @override
  String get chatLeaveConversationBody => 'Tem certeza de que deseja sair da conversa e excluir todas as suas mensagens?';

  @override
  String chatLeaveError(Object error) {
    return 'Erro ao sair: $error';
  }

  @override
  String get message => 'Mensagem';

  @override
  String get send => 'Enviar';

  @override
  String get edited => 'editado';

  @override
  String get deletedMessage => 'Mensagem excluída';

  @override
  String get edit => 'Editar';

  @override
  String get reply => 'Responder';

  @override
  String get delete => 'Excluir';

  @override
  String get languageName => 'Português';
}
