import 'package:flutter/material.dart';

// ✅ i18n
import '../l10n/app_localizations.dart';

class VersionPage extends StatelessWidget {
  const VersionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context)!;

    // ✅ Si tu veux récupérer une version dynamique (pubspec) plus tard,
    // tu pourras remplacer "0.9" par une variable.
    const appVersion = '0.9';

    return Scaffold(
      appBar: AppBar(title: Text(t.menuVersion), centerTitle: true),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                t.versionMadeByFastFrance,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),

              // Logo centré
              SizedBox(
                width: 220,
                height: 220,
                child: Image.asset(
                  'assets/images/Accueil_Image.png',
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 24),

              // Version centrée
              Text(
                t.versionNumber(appVersion),
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
