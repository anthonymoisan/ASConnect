// lib/contact_page.dart
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:http/http.dart' as http;

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
  late String _captchaToken; // pour validation serveur (anti-rejeu)

  // API publique (proxy)
  static const String _apiBase = 'https://anthonymoisan.pythonanywhere.com';
  static const String _contactPath = '/api/public/contact';

  // Clé d'application publique injectée via --dart-define=PUBLIC_APP_KEY=...
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

  String? _required(String? v, String label) {
    final s = (v ?? '').trim();
    return s.isEmpty ? '$label requis' : null;
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

  Future<void> _sendMessage() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!_captchaOK) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Captcha incorrect.")));
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
        // champs captcha envoyés au serveur
        'captcha_answer': int.parse(_captchaCtrl.text.trim()),
        'captcha_token': _captchaToken,
      };

      http.Response resp;
      try {
        resp = await _postOnce(uri, payload);
      } on TimeoutException {
        // 1 retry léger
        resp = await _postOnce(uri, payload);
      }

      Map<String, dynamic>? jsonResp;
      try {
        jsonResp =
            jsonDecode(utf8.decode(resp.bodyBytes)) as Map<String, dynamic>?;
      } catch (_) {}

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Message envoyé ✅')));
        _formKey.currentState?.reset();
        _titleCtrl.clear();
        _messageCtrl.clear();
        _regenCaptcha();
        Navigator.of(context).pop(true);
        return;
      }

      // Gestion d'erreurs plus parlante
      String err = 'Échec de l’envoi (${resp.statusCode})';
      if (resp.statusCode == 401 || resp.statusCode == 403) {
        err = "Accès refusé (clé d'application manquante ou invalide).";
      } else if (resp.statusCode == 429) {
        err = "Trop de requêtes. Réessaie dans quelques secondes.";
      } else if (resp.statusCode == 502 || resp.statusCode == 504) {
        err = "Service temporairement indisponible. Réessaie plus tard.";
      } else {
        final serverMsg =
            jsonResp?['error'] ?? jsonResp?['message'] ?? jsonResp?['detail'];
        if (serverMsg is String && serverMsg.isNotEmpty) err = serverMsg;
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      _regenCaptcha();
    } on SocketException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vérifie ta connexion internet.")),
      );
    } on TimeoutException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Délai dépassé. Réessaie plus tard.")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erreur inattendue : $e")));
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
          'Nous contacter',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
                    'Envoyer un message',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Titre
              TextFormField(
                controller: _titleCtrl,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Titre',
                  hintText: 'Sujet de votre demande',
                  prefixIcon: Icon(Ionicons.pricetag_outline),
                  border: OutlineInputBorder(),
                ),
                validator: (v) => _required(v, 'Titre'),
              ),
              const SizedBox(height: 12),

              // Message
              TextFormField(
                controller: _messageCtrl,
                minLines: 6,
                maxLines: 12,
                textInputAction: TextInputAction.newline,
                decoration: const InputDecoration(
                  labelText: 'Message',
                  hintText: 'Décrivez votre demande…',
                  alignLabelWithHint: true,
                  prefixIcon: Icon(Ionicons.chatbox_ellipses_outline),
                ),
                validator: (v) => _required(v, 'Message'),
              ),
              const SizedBox(height: 16),

              // Captcha simple
              Row(
                children: [
                  Icon(
                    Ionicons.shield_checkmark_outline,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Vérification anti-spam',
                    style: theme.textTheme.titleSmall,
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: "Rafraîchir",
                    icon: const Icon(Ionicons.refresh_outline),
                    onPressed: _sending ? null : _regenCaptcha,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('Combien font $_a + $_b ?'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _captchaCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Réponse',
                  prefixIcon: Icon(Ionicons.calculator_outline),
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if ((v ?? '').trim().isEmpty) return 'Captcha requis';
                  if (!_captchaOK) return 'Captcha incorrect';
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Actions
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
                      label: Text(_sending ? 'Envoi…' : 'Envoyer'),
                      onPressed: _sending ? null : _sendMessage,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Ionicons.close_circle_outline),
                      label: const Text('Annuler'),
                      onPressed: _cancelAndGoHome,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),
              Text(
                "Votre message est envoyé via notre API publique sécurisée. Merci !",
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                ),
              ),
              if (_publicAppKey.isEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  "⚠️ Clé d'application absente. Lance l'app avec "
                  "--dart-define=PUBLIC_APP_KEY=ta_cle_publique",
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
