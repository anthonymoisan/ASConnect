import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ionicons/ionicons.dart';

// ✅ AppLocalizations
import '../l10n/app_localizations.dart';

// =====================
//   CONFIG PUBLIQUE
// =====================

// Clé d'application publique : passer via --dart-define=PUBLIC_APP_KEY=xxx
const String _publicAppKey = String.fromEnvironment(
  'PUBLIC_APP_KEY',
  defaultValue: '',
);

// Base API publique
const String kPublicApiBase =
    'https://anthonymoisan.pythonanywhere.com/api/public';

// Helpers d'URL
String _secretQuestionUrl(String email) =>
    '$kPublicApiBase/people/secret-question?email=$email';
String _secretAnswerVerifyUrl() =>
    '$kPublicApiBase/people/secret-answer/verify';
String _resetPasswordUrl() => '$kPublicApiBase/auth/reset-password';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _answerCtrl = TextEditingController();
  final _pwd1Ctrl = TextEditingController();
  final _pwd2Ctrl = TextEditingController();

  bool _loadingQuestion = false;
  bool _verifyingAnswer = false;
  bool _submitting = false;

  // état “progressif”
  bool _questionFetched = false;
  bool _answerOk = false;

  // Données question
  int? _questionCode; // 1..3 (renvoyé par l’API)
  String? _questionLabel; // libellé renvoyé par l’API
  int _attempts = 0; // tentatives de réponse échouées

  Timer? _debounce;

  Map<String, String> get _acceptHeaders => {
    'Accept': 'application/json',
    'X-App-Key': _publicAppKey,
  };

  Map<String, String> get _jsonHeaders => {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    'X-App-Key': _publicAppKey,
  };

  @override
  void initState() {
    super.initState();
    // Quand l’email devient valide, on tente de charger la question (1 seule fois)
    _emailCtrl.addListener(_onEmailChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _emailCtrl.dispose();
    _answerCtrl.dispose();
    _pwd1Ctrl.dispose();
    _pwd2Ctrl.dispose();
    super.dispose();
  }

  // --- Helpers règles mot de passe ---
  bool _pwdHasMinLen(String s) => s.trim().length >= 8;
  bool _pwdHasUpper(String s) => RegExp(r'[A-Z]').hasMatch(s);
  bool _pwdHasSpec(String s) =>
      RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-+=~;\\/\[\]]').hasMatch(s);

  Widget _pwdRule({required bool ok, required String text}) {
    return Row(
      children: [
        Icon(
          ok ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 18,
          color: ok ? Colors.green : Colors.grey,
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(text)),
      ],
    );
  }

  bool _emailLooksValid(String s) =>
      RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(s.trim());

  // --------- Étape 1 : email → question secrète (auto) ----------
  void _onEmailChanged() {
    final email = _emailCtrl.text.trim();
    if (!_emailLooksValid(email)) return; // pas encore valide
    if (_questionFetched) return; // déjà fait

    // petit debounce pour éviter spam API en cours de frappe
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _fetchSecretQuestion(auto: true);
    });
  }

  Future<void> _fetchSecretQuestion({bool auto = false}) async {
    final t = AppLocalizations.of(context)!;
    final email = _emailCtrl.text.trim();

    if (!_emailLooksValid(email)) {
      if (!auto) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(t.forgotEnterValidEmail)));
      }
      return;
    }

    setState(() {
      _loadingQuestion = true;
      _questionFetched = false;
      _answerOk = false;
      _questionCode = null;
      _questionLabel = null;
      _attempts = 0;
    });

    try {
      final uri = Uri.parse(_secretQuestionUrl(email));
      final resp = await http
          .get(uri, headers: _acceptHeaders)
          .timeout(const Duration(seconds: 12));

      if (resp.statusCode == 200) {
        final map = jsonDecode(resp.body) as Map<String, dynamic>;
        setState(() {
          _questionCode = (map['question'] as num?)?.toInt();
          _questionLabel =
              (map['label'] as String?) ?? t.forgotQuestionFallback;
          _questionFetched = true;
        });
      } else if (resp.statusCode == 404) {
        setState(() {
          _questionFetched = false;
          _answerOk = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(t.forgotUnknownEmail)));
      } else {
        setState(() => _questionFetched = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.forgotErrorCode(resp.statusCode))),
        );
      }
    } on TimeoutException {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.forgotTimeoutRetry)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.forgotErrorWithMessage(e.toString()))),
      );
    } finally {
      if (mounted) setState(() => _loadingQuestion = false);
    }
  }

  // --------- Étape 2 : vérification réponse secrète ----------
  Future<void> _verifyAnswer() async {
    final t = AppLocalizations.of(context)!;

    if (!_questionFetched || _questionCode == null) return;

    final email = _emailCtrl.text.trim();
    final ans = _answerCtrl.text.trim();

    if (ans.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.forgotEnterYourAnswer)));
      return;
    }

    // Verrouillage après 3 échecs
    if (_attempts >= 3) {
      await _showLockDialog();
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
      return;
    }

    setState(() => _verifyingAnswer = true);
    try {
      final uri = Uri.parse(_secretAnswerVerifyUrl());
      final body = jsonEncode({'email': email, 'answer': ans});

      final resp = await http
          .post(uri, headers: _jsonHeaders, body: body)
          .timeout(const Duration(seconds: 12));

      bool ok = false;
      if (resp.statusCode == 200) {
        try {
          final m = jsonDecode(resp.body);
          ok = (m is Map && m['ok'] == true);
        } catch (_) {
          ok = false;
        }
      }

      if (!ok) {
        setState(() {
          _answerOk = false;
          _attempts += 1;
        });

        if (_attempts >= 3) {
          await _showLockDialog();
          if (!mounted) return;
          Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
          return;
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(t.forgotAnswerIncorrectAttempts(_attempts))),
          );
        }
        return;
      }

      setState(() => _answerOk = true);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.forgotAnswerCorrectSnack)));
    } on TimeoutException {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.forgotTimeoutRetry)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.forgotErrorWithMessage(e.toString()))),
      );
    } finally {
      if (mounted) setState(() => _verifyingAnswer = false);
    }
  }

  // --------- Étape 3 : envoi du nouveau mot de passe ----------
  Future<void> _submitReset() async {
    final t = AppLocalizations.of(context)!;

    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!_questionFetched || !_answerOk || _questionCode == null) return;

    final email = _emailCtrl.text.trim();
    final ans = _answerCtrl.text.trim();
    final p1 = _pwd1Ctrl.text;
    final p2 = _pwd2Ctrl.text;

    if (p1 != p2) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.forgotPasswordsDoNotMatch)));
      return;
    }
    if (!_pwdHasMinLen(p1) || !_pwdHasUpper(p1) || !_pwdHasSpec(p1)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.forgotPasswordTooWeak)));
      return;
    }

    setState(() => _submitting = true);
    try {
      final uri = Uri.parse(_resetPasswordUrl());
      final body = jsonEncode({
        'emailAddress': email,
        'questionSecrete': _questionCode,
        'reponseSecrete': ans,
        'newPassword': p1,
      });

      final resp = await http
          .post(uri, headers: _jsonHeaders, body: body)
          .timeout(const Duration(seconds: 15));

      if (resp.statusCode == 200 || resp.statusCode == 204) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(t.forgotResetSuccess)));
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
        return;
      }

      // échec (QA invalide, etc.)
      setState(() => _attempts += 1);

      if (_attempts >= 3) {
        await _showLockDialog();
        if (!mounted) return;
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
        return;
      }

      // Message API si présent
      String msg = t.forgotResetFailed(resp.statusCode);
      try {
        final m = jsonDecode(resp.body);
        if (m is Map && m['error'] is String) msg = m['error'] as String;
      } catch (_) {}

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(msg)));
      }
    } on TimeoutException {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(t.forgotTimeoutRetry)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.forgotErrorWithMessage(e.toString()))),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _showLockDialog() async {
    final t = AppLocalizations.of(context)!;

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.tooManyAttemptsTitle),
        content: Text(t.tooManyAttemptsMessage),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(t.ok),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    final okMin = _pwdHasMinLen(_pwd1Ctrl.text);
    final okUp = _pwdHasUpper(_pwd1Ctrl.text);
    final okSp = _pwdHasSpec(_pwd1Ctrl.text);
    final same = _pwd1Ctrl.text == _pwd2Ctrl.text;

    return Scaffold(
      appBar: AppBar(title: Text(t.forgotPasswordTitle), centerTitle: true),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            children: [
              // EMAIL
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Ionicons.mail),
                  labelText: t.forgotEmailLabel,
                  border: const OutlineInputBorder(),
                  suffixIcon: _loadingQuestion
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : IconButton(
                          tooltip: t.forgotFetchQuestionTooltip,
                          icon: const Icon(Ionicons.help),
                          onPressed: () => _fetchSecretQuestion(),
                        ),
                ),
                validator: (v) {
                  final s = v?.trim() ?? '';
                  if (s.isEmpty)
                    return t.emailHintRequired; // déjà dans tes ARB
                  return _emailLooksValid(s) ? null : t.emailHintInvalid;
                },
              ),

              const SizedBox(height: 12),

              // QUESTION
              if (_questionFetched) ...[
                TextFormField(
                  readOnly: true,
                  initialValue: _questionLabel ?? t.forgotQuestionFallback,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Ionicons.help_circle_outline),
                    labelText: t.forgotQuestionLabel,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),

                // RÉPONSE + vérifier
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _answerCtrl,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Ionicons.chatbox_ellipses_outline,
                          ),
                          labelText: t.forgotSecretAnswerLabel,
                          border: const OutlineInputBorder(),
                        ),
                        onFieldSubmitted: (_) => _verifyAnswer(),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? t.forgotAnswerRequired
                            : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 56,
                      child: OutlinedButton.icon(
                        icon: _verifyingAnswer
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Ionicons.checkmark_circle),
                        label: Text(_verifyingAnswer ? '...' : t.forgotVerify),
                        onPressed: _verifyingAnswer ? null : _verifyAnswer,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                if (_answerOk)
                  Text(t.forgotAnswerOkHint)
                else if (_attempts > 0)
                  Text(
                    t.forgotFailedAttempts(_attempts),
                    style: TextStyle(color: Colors.red.shade700),
                  ),
              ],

              // NOUVEAU MOT DE PASSE
              if (_answerOk) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _pwd1Ctrl,
                  obscureText: true,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Ionicons.lock_closed_outline),
                    labelText: t.forgotNewPasswordLabel,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (v) {
                    final s = (v ?? '').trim();
                    if (s.isEmpty) return t.forgotPasswordRequired;
                    if (!_pwdHasMinLen(s) ||
                        !_pwdHasUpper(s) ||
                        !_pwdHasSpec(s)) {
                      return t.forgotPasswordTooWeak;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                _pwdRule(ok: okMin, text: t.forgotPwdRuleMin8),
                const SizedBox(height: 4),
                _pwdRule(ok: okUp, text: t.forgotPwdRuleUpper),
                const SizedBox(height: 4),
                _pwdRule(ok: okSp, text: t.forgotPwdRuleSpecial),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _pwd2Ctrl,
                  obscureText: true,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Ionicons.lock_open_outline),
                    labelText: t.forgotConfirmPasswordLabel,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (_pwd1Ctrl.text.trim().isEmpty) {
                      return t.forgotEnterNewPasswordFirst;
                    }
                    if (_pwd1Ctrl.text != _pwd2Ctrl.text) {
                      return t.forgotPasswordsDoNotMatch;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      same ? Icons.check_circle : Icons.cancel,
                      size: 18,
                      color: same ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      same
                          ? t.forgotPasswordsMatch
                          : t.forgotPasswordsDoNotMatch,
                      style: TextStyle(color: same ? Colors.green : Colors.red),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 20),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Ionicons.arrow_back),
                      label: Text(t.cancel),
                      onPressed: _submitting
                          ? null
                          : () => Navigator.of(context).pop(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      icon: _submitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Ionicons.checkmark),
                      label: Text(_submitting ? t.forgotValidating : t.confirm),
                      onPressed: (!_answerOk || _submitting)
                          ? null
                          : _submitReset,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
