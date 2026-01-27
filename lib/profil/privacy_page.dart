import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// ✅ i18n
import '../l10n/app_localizations.dart';

// =====================
//   CONFIG PUBLIQUE
// =====================

// Clé d'application publique (envoyée en X-App-Key)
const String _publicAppKey = String.fromEnvironment(
  'PUBLIC_APP_KEY',
  defaultValue: '',
);

// Base API publique
const String kPublicApiBase =
    'https://anthonymoisan.eu.pythonanywhere.com/api/public';

// Helpers d'URL
String _deleteAccountUrl(int personId) =>
    '$kPublicApiBase/people/delete/$personId';

// Headers communs (sans Basic Auth)
Map<String, String> _publicHeaders() => {
  'Accept': 'application/json',
  'X-App-Key': _publicAppKey,
};

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key, required this.personId});

  final int personId;

  Future<void> _deleteAccount(BuildContext context) async {
    final t = AppLocalizations.of(context)!;

    // 1) Demande de confirmation
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(t.privacyDeleteTitle),
        content: Text(t.privacyDeleteConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(t.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(t.ok),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // 2) Petit loader
    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );
    }

    String? errorMsg;
    try {
      final uri = Uri.parse(_deleteAccountUrl(personId));
      final resp = await http
          .delete(uri, headers: _publicHeaders())
          .timeout(const Duration(seconds: 30));

      if (context.mounted) Navigator.of(context).pop(); // ferme le loader

      if (resp.statusCode == 200) {
        // 3) Succès → popup + redirection vers /login au clic sur OK
        if (context.mounted) {
          await showDialog<void>(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => AlertDialog(
              title: Text(t.privacyDeletedOkTitle),
              content: Text(t.privacyDeletedOkBody),
              actions: [
                FilledButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text(t.ok),
                ),
              ],
            ),
          );

          // Redirige vers /login et purge la pile
          Navigator.of(context).pushNamedAndRemoveUntil('/login', (r) => false);
        }
        return;
      } else {
        errorMsg = t.privacyDeleteFailedWithCode(resp.statusCode);

        // essaie de lire un message d’erreur API
        try {
          final m = jsonDecode(utf8.decode(resp.bodyBytes));
          final msg = (m is Map && m['message'] is String)
              ? (m['message'] as String)
              : null;
          final err = (m is Map && m['error'] is String)
              ? (m['error'] as String)
              : null;

          final picked = (msg != null && msg.isNotEmpty)
              ? msg
              : (err != null && err.isNotEmpty)
              ? err
              : null;

          if (picked != null) errorMsg = picked;
        } catch (_) {}
      }
    } on TimeoutException {
      errorMsg = t.timeoutRetry;
      if (context.mounted) {
        Navigator.of(context).pop(); // ferme le loader si encore ouvert
      }
    } catch (e) {
      errorMsg = t.errorWithMessage(e.toString());
      if (context.mounted) {
        Navigator.of(context).pop(); // ferme le loader si encore ouvert
      }
    }

    if (errorMsg != null && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMsg)));
    }
  }

  void _goHome(BuildContext context) {
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context)!;
    final viewInsets = MediaQuery.of(context).viewInsets;

    return Scaffold(
      appBar: AppBar(title: Text(t.privacyTitle), centerTitle: true),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 16 + viewInsets.bottom),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: theme.dividerColor.withOpacity(0.6),
                    ),
                    borderRadius: BorderRadius.circular(12),
                    color: theme.colorScheme.surfaceVariant.withOpacity(0.25),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: SingleChildScrollView(
                    child: Text(t.consentText, textAlign: TextAlign.justify),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.delete_forever_outlined),
                      label: Text(t.privacyRightToBeForgotten),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.colorScheme.error,
                        side: BorderSide(color: theme.colorScheme.error),
                      ),
                      onPressed: () => _deleteAccount(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      icon: const Icon(Icons.check),
                      label: Text(t.ok),
                      onPressed: () => _goHome(context),
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
