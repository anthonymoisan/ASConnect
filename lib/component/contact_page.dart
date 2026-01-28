import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:http/http.dart' as http;

// ✅ Import l10n
import '../l10n/app_localizations.dart';

extension L10nX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  final _captchaCtrl = TextEditingController();

  bool _sending = false;
  late int _a;
  late int _b;
  late String _captchaToken; // validation serveur (anti-rejeu)

  static const String _apiBase = 'https://anthonymoisan.eu.pythonanywhere.com';
  static const String _contactPath = '/api/public/contact';

  static const String _publicAppKey = String.fromEnvironment(
    'PUBLIC_APP_KEY',
    defaultValue: '',
  );

  @override
  void initState() {
    super.initState();
    _regenCaptcha();
  }

  void _regenCaptcha() {
    final r = Random.secure();
    _a = 1 + r.nextInt(9);
    _b = 1 + r.nextInt(9);
    _captchaToken = '${DateTime.now().millisecondsSinceEpoch}:${_a}x${_b}';
    _captchaCtrl.clear();
    setState(() {});
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _messageCtrl.dispose();
    _captchaCtrl.dispose();
    super.dispose();
  }

  String? _required(String? v, String fieldLabel) {
    final s = (v ?? '').trim();
    return s.isEmpty ? context.l10n.fieldRequired(fieldLabel) : null;
  }

  bool get _captchaOK {
    final ans = int.tryParse(_captchaCtrl.text.trim());
    return ans != null && ans == _a + _b;
  }

  Future<http.Response> _postOnce(Uri uri, Map<String, dynamic> payload) {
    final headers = <String, String>{
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.acceptHeader: 'application/json',
      if (_publicAppKey.isNotEmpty) 'X-App-Key': _publicAppKey,
    };

    return http
        .post(uri, headers: headers, body: jsonEncode(payload))
        .timeout(const Duration(seconds: 15));
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _sendMessage() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (!_captchaOK) {
      _snack(context.l10n.contactCaptchaIncorrect);
      return;
    }

    setState(() => _sending = true);

    try {
      final uri = Uri.parse('$_apiBase$_contactPath');
      final subject = _titleCtrl.text.trim();
      final body = _messageCtrl.text.trim();

      final payload = {
        'subject': subject,
        'body': body,
        'captcha_answer': int.parse(_captchaCtrl.text.trim()),
        'captcha_token': _captchaToken,
      };

      http.Response resp;
      try {
        resp = await _postOnce(uri, payload);
      } on TimeoutException {
        resp = await _postOnce(uri, payload); // retry léger
      }

      Map<String, dynamic>? jsonResp;
      try {
        jsonResp =
            jsonDecode(utf8.decode(resp.bodyBytes)) as Map<String, dynamic>?;
      } catch (_) {}

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        _snack(context.l10n.contactMessageSent);
        _formKey.currentState?.reset();
        _titleCtrl.clear();
        _messageCtrl.clear();
        _regenCaptcha();
        if (mounted) Navigator.of(context).pop(true);
        return;
      }

      // Erreurs plus parlantes (i18n)
      String err = context.l10n.contactSendFailedWithCode(resp.statusCode);

      if (resp.statusCode == 401 || resp.statusCode == 403) {
        err = context.l10n.contactAccessDenied;
      } else if (resp.statusCode == 429) {
        err = context.l10n.contactTooManyRequests;
      } else if (resp.statusCode == 502 || resp.statusCode == 504) {
        err = context.l10n.contactServiceUnavailable;
      } else {
        final serverMsg =
            jsonResp?['error'] ?? jsonResp?['message'] ?? jsonResp?['detail'];
        if (serverMsg is String && serverMsg.isNotEmpty) err = serverMsg;
      }

      _snack(err);
      _regenCaptcha();
    } on SocketException {
      _snack(context.l10n.contactCheckInternet);
    } on TimeoutException {
      _snack(context.l10n.contactTimeout);
    } catch (e) {
      _snack(context.l10n.unexpectedError(e.toString()));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _cancelAndGoHome() {
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final viewInsets = MediaQuery.of(context).viewInsets;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.l10n.contactPageTitle,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 16 + viewInsets.bottom),
            children: [
              Row(
                children: [
                  Icon(
                    Ionicons.mail_open_outline,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    context.l10n.contactSendMessageTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Titre / Subject
              TextFormField(
                controller: _titleCtrl,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: context.l10n.contactSubjectLabel,
                  hintText: context.l10n.contactSubjectHint,
                  prefixIcon: const Icon(Ionicons.pricetag_outline),
                  border: const OutlineInputBorder(),
                ),
                validator: (v) =>
                    _required(v, context.l10n.contactSubjectLabel),
              ),
              const SizedBox(height: 12),

              // Message
              TextFormField(
                controller: _messageCtrl,
                minLines: 6,
                maxLines: 12,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(
                  labelText: context.l10n.contactMessageLabel,
                  hintText: context.l10n.contactMessageHint,
                  alignLabelWithHint: true,
                  prefixIcon: const Icon(Ionicons.chatbox_ellipses_outline),
                ),
                validator: (v) =>
                    _required(v, context.l10n.contactMessageLabel),
              ),
              const SizedBox(height: 16),

              // Captcha
              Row(
                children: [
                  Icon(
                    Ionicons.shield_checkmark_outline,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    context.l10n.contactAntiSpamTitle,
                    style: theme.textTheme.titleSmall,
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: context.l10n.contactRefresh,
                    icon: const Icon(Ionicons.refresh_outline),
                    onPressed: _sending ? null : _regenCaptcha,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(context.l10n.contactCaptchaQuestion(_a, _b)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _captchaCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: context.l10n.contactCaptchaAnswerLabel,
                  prefixIcon: const Icon(Ionicons.calculator_outline),
                  border: const OutlineInputBorder(),
                ),
                validator: (v) {
                  if ((v ?? '').trim().isEmpty)
                    return context.l10n.contactCaptchaRequired;
                  if (!_captchaOK) return context.l10n.contactCaptchaIncorrect;
                  return null;
                },
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      icon: _sending
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Ionicons.send_outline),
                      label: Text(
                        _sending
                            ? context.l10n.contactSending
                            : context.l10n.contactSend,
                      ),
                      onPressed: _sending ? null : _sendMessage,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Ionicons.close_circle_outline),
                      label: Text(context.l10n.contactCancel),
                      onPressed: _cancelAndGoHome,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),
              Text(
                context.l10n.contactFooterNote,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                ),
              ),
              if (_publicAppKey.isEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  context.l10n.contactMissingAppKey(
                    '--dart-define=PUBLIC_APP_KEY=ta_cle_publique',
                  ),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.red),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
