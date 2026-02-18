// lib/login_page.dart
import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_localized_locales/flutter_localized_locales.dart';

import 'signup_page.dart';
import 'forgot_password_page.dart';

// ✅ AppLocalizations généré chez toi dans lib/l10n/
import '../l10n/app_localizations.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
    this.onLogin,
    this.onSignUp,
    this.onForgotPassword,
    this.backgroundAsset = 'assets/images/ImageFond.png',
    this.currentLocale,
    this.onLocaleChanged,
  });

  final Future<void> Function(String email, String password, int id)? onLogin;
  final VoidCallback? onSignUp;
  final VoidCallback? onForgotPassword;
  final String backgroundAsset;

  /// ✅ Locale actuelle (null = système)
  final Locale? currentLocale;

  /// ✅ Callback vers main.dart pour changer la locale (null = système)
  final void Function(Locale? locale)? onLocaleChanged;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();

  bool _obscure = true;
  bool _loading = false;

  // ✅ état local du dropdown (rafraîchit immédiatement l’UI)
  String? _selectedLangCode; // null = système

  static const String _env = String.fromEnvironment(
    'ENV',
    defaultValue: 'prod',
  );
  static const String _apiBase = _env == 'prod'
      ? 'https://anthonymoisan.eu.pythonanywhere.com'
      : 'https://test-anthonymoisan.eu.pythonanywhere.com';

  static const String _loginPath = '/api/public/auth/login';

  // Clé d'application publique (passée au build/run via --dart-define)
  static const String _publicAppKey = String.fromEnvironment(
    'PUBLIC_APP_KEY',
    defaultValue: '',
  );

  @override
  void initState() {
    super.initState();

    // au démarrage : reflète le choix parent (null = système)
    _selectedLangCode = widget.currentLocale?.languageCode;

    WidgetsBinding.instance.addPostFrameCallback((_) => _hideAuthSnackbars());
    _emailCtrl.addListener(_hideAuthSnackbars);
    _pwdCtrl.addListener(_hideAuthSnackbars);
  }

  @override
  void didUpdateWidget(covariant LoginPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    // ✅ si le parent change la locale, on resynchronise le dropdown
    final oldCode = oldWidget.currentLocale?.languageCode;
    final newCode = widget.currentLocale?.languageCode;
    if (oldCode != newCode) {
      setState(() {
        _selectedLangCode = newCode; // null = système
      });
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _pwdCtrl.dispose();
    super.dispose();
  }

  // --- Gestion SnackBar d'erreur auth ---
  void _hideAuthSnackbars() {
    if (!mounted) return;
    final sm = ScaffoldMessenger.of(context);
    sm.hideCurrentSnackBar();
    sm.clearSnackBars();
  }

  void _showPersistentAuthError(String msg) {
    if (!mounted) return;
    final sm = ScaffoldMessenger.of(context);
    sm.hideCurrentSnackBar();
    sm.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 8),
        backgroundColor: Theme.of(context).colorScheme.error,
        content: SizedBox(
          width: double.infinity,
          child: Text(
            msg,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onError,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  int? _extractId(String body) {
    try {
      final d = jsonDecode(body);
      if (d is Map && d['id'] != null) {
        if (d['id'] is int) return d['id'] as int;
        return int.tryParse('${d['id']}');
      }
      if (d is int) return d;
      if (d is String) return int.tryParse(d);
    } catch (_) {
      return int.tryParse(body.trim());
    }
    return null;
  }

  Future<void> _submit() async {
    final t = AppLocalizations.of(context)!;

    if (!(_formKey.currentState?.validate() ?? false)) return;

    _hideAuthSnackbars();
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);

    try {
      final email = _emailCtrl.text.trim();
      final pass = _pwdCtrl.text;

      final uri = Uri.parse('$_apiBase$_loginPath');

      final headers = <String, String>{
        'Content-Type': 'application/json',
        if (_publicAppKey.isNotEmpty) 'X-App-Key': _publicAppKey,
      };

      final resp = await http
          .post(
            uri,
            headers: headers,
            body: jsonEncode({'email': email, 'password': pass}),
          )
          .timeout(const Duration(seconds: 12));

      if (resp.statusCode == 200) {
        final id = _extractId(resp.body);
        if (id != null && id > 0) {
          if (widget.onLogin != null) {
            await widget.onLogin!(email, pass, id);
          }
          if (!mounted) return;
          Navigator.of(
            context,
          ).pushReplacementNamed('/home', arguments: {'id': id});
          return;
        } else {
          _showPersistentAuthError(t.invalidCredentials);
          return;
        }
      }

      if (resp.statusCode == 401) {
        String msg = t.invalidCredentials;
        try {
          final d = jsonDecode(resp.body);
          msg = d['message']?.toString() ?? d['error']?.toString() ?? msg;
        } catch (_) {}
        _showPersistentAuthError(msg);
        return;
      }

      if (resp.statusCode == 403) {
        _showPersistentAuthError(t.accessDeniedKey);
        return;
      }

      if (resp.statusCode == 400) {
        _showPersistentAuthError(t.badRequest);
        return;
      }

      if (resp.statusCode == 429) {
        _showPersistentAuthError(t.tooManyAttempts);
        return;
      }

      if (resp.statusCode == 500) {
        _showPersistentAuthError(t.serviceUnavailable);
        return;
      }

      _showPersistentAuthError(t.serverErrorWithCode(resp.statusCode));
    } on FormatException {
      _showPersistentAuthError(
        AppLocalizations.of(context)!.unexpectedServerResponse,
      );
    } on http.ClientException {
      _showPersistentAuthError(
        AppLocalizations.of(context)!.cannotConnectServer,
      );
    } on TimeoutException {
      _showPersistentAuthError(
        AppLocalizations.of(context)!.timeoutCheckConnection,
      );
    } catch (e) {
      _showPersistentAuthError(
        AppLocalizations.of(context)!.errorWithMessage(e.toString()),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openSignUp() async {
    _hideAuthSnackbars();

    if (widget.onSignUp != null) {
      widget.onSignUp!.call();
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute(
        settings: const RouteSettings(name: '/signup'),
        builder: (_) => const SignUpPage(),
      ),
    );

    _hideAuthSnackbars();
  }

  void _openForgotPassword() {
    _hideAuthSnackbars();

    if (widget.onForgotPassword != null) {
      widget.onForgotPassword!.call();
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        settings: const RouteSettings(name: '/forgot-password'),
        builder: (_) => ForgotPasswordPage(),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // ✅ Sélecteur de langue : non hardcodé
  // - options = AppLocalizations.supportedLocales
  // - label = ARB languageName si dispo, sinon LocaleNames
  // - value = _selectedLangCode (null = système) => UI bouge instantanément
  // - selectedItemBuilder : si "système", affiche la langue effective (pas “Système”)
  // ---------------------------------------------------------------------------
  Widget _languageSelector(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    final localeNames = LocaleNames.of(
      context,
    ); // peut être null si delegate absent
    final effectiveCode = Localizations.localeOf(context).languageCode;

    // codes supportés (unique, triés)
    final supportedCodes = <String>{
      for (final l in AppLocalizations.supportedLocales) l.languageCode,
    }.toList()..sort();

    String prettyNameForCode(String code) {
      // 1) Si tu as `languageName` dans tes ARB -> “Français/English/Español…”
      try {
        final l10n = lookupAppLocalizations(Locale(code));
        final s = l10n.languageName.trim();
        if (s.isNotEmpty) return s;
      } catch (_) {
        // ignore
      }

      // 2) Fallback via flutter_localized_locales
      final n = localeNames?.nameOf(code);
      if (n != null && n.trim().isNotEmpty) return n;

      // 3) Ultime fallback
      return code;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black12),
        color: Theme.of(context).colorScheme.surface.withOpacity(0.75),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.language, size: 18),
          const SizedBox(width: 10),
          DropdownButtonHideUnderline(
            child: DropdownButton<String?>(
              value: _selectedLangCode, // null = système
              isDense: true,
              onChanged: (code) {
                // 1) refresh immédiat UI
                setState(() => _selectedLangCode = code);

                // 2) remonte au parent (MaterialApp.locale)
                final cb = widget.onLocaleChanged;
                if (cb != null) {
                  cb(code == null ? null : Locale(code));
                }

                FocusScope.of(context).unfocus();
              },

              // ✅ texte affiché dans le champ sélectionné :
              // si null => afficher la langue effective, pas "Système"
              selectedItemBuilder: (_) {
                return [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(prettyNameForCode(effectiveCode)),
                  ),
                  ...supportedCodes.map(
                    (c) => Align(
                      alignment: Alignment.centerLeft,
                      child: Text(prettyNameForCode(c)),
                    ),
                  ),
                ];
              },

              items: [
                DropdownMenuItem<String?>(
                  value: null,
                  child: Text('🌐 ${t.systemLanguage}'),
                ),
                ...supportedCodes.map(
                  (code) => DropdownMenuItem<String?>(
                    value: code,
                    child: Text(prettyNameForCode(code)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Image.asset(widget.backgroundAsset, fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.20)),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface.withOpacity(0.86),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 12,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Ionicons.people,
                                    color: theme.colorScheme.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    t.loginTitle,
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 11),
                              Text(
                                t.loginIntro,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.75),
                                ),
                              ),
                              const SizedBox(height: 18),

                              // Email
                              TextFormField(
                                controller: _emailCtrl,
                                keyboardType: TextInputType.emailAddress,
                                autofillHints: const [
                                  AutofillHints.username,
                                  AutofillHints.email,
                                ],
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Ionicons.mail),
                                  labelText: t.emailLabel,
                                  border: const OutlineInputBorder(),
                                ),
                                validator: (v) {
                                  final s = v?.trim() ?? '';
                                  if (s.isEmpty) return t.emailHintRequired;
                                  final ok = RegExp(
                                    r'^[^@]+@[^@]+\.[^@]+$',
                                  ).hasMatch(s);
                                  if (!ok) return t.emailHintInvalid;
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),

                              // Mot de passe
                              TextFormField(
                                controller: _pwdCtrl,
                                obscureText: _obscure,
                                autofillHints: const [AutofillHints.password],
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Ionicons.lock_closed),
                                  labelText: t.passwordLabel,
                                  border: const OutlineInputBorder(),
                                  suffixIcon: IconButton(
                                    tooltip: _obscure ? t.show : t.hide,
                                    icon: Icon(
                                      _obscure
                                          ? Ionicons.eye
                                          : Ionicons.eye_off,
                                    ),
                                    onPressed: () =>
                                        setState(() => _obscure = !_obscure),
                                  ),
                                ),
                                validator: (v) => (v == null || v.isEmpty)
                                    ? t.passwordRequired
                                    : null,
                              ),

                              const SizedBox(height: 16),

                              // Bouton Se connecter
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: FilledButton.icon(
                                  icon: _loading
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Icon(Ionicons.log_in),
                                  label: Text(
                                    _loading ? t.loginLoading : t.loginButton,
                                  ),
                                  onPressed: _loading ? null : _submit,
                                ),
                              ),

                              const SizedBox(height: 12),

                              // Liens
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  TextButton(
                                    onPressed: _openSignUp,
                                    child: Text(t.createAccount),
                                  ),
                                  const SizedBox(height: 4),
                                  TextButton(
                                    onPressed: _openForgotPassword,
                                    child: Text(t.forgotPassword),
                                  ),
                                ],
                              ),

                              // ✅ Sélecteur de langue en bas (non hardcodé)
                              const SizedBox(height: 14),
                              Center(child: _languageSelector(context)),

                              if (_publicAppKey.isEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  t.missingAppKeyWarning,
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
