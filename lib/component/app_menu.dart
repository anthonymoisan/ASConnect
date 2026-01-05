// lib/app_menu.dart
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:url_launcher/url_launcher.dart';

// ✅ i18n
import '../l10n/app_localizations.dart';

enum MenuAction { profil, contact, privacy, logout, version }

class AppMenu extends StatelessWidget {
  const AppMenu({
    super.key,
    this.onSelected,
    this.selected,
    this.privacyUrl,
    this.contactEmail,
    this.appVersion,
    this.currentLocale,
    this.onLocaleChanged,
  });

  final void Function(MenuAction action)? onSelected;
  final MenuAction? selected;
  final String? privacyUrl;
  final String? contactEmail;
  final String? appVersion;

  /// null = langue système
  final Locale? currentLocale;
  final void Function(Locale? locale)? onLocaleChanged;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          children: [
            _MenuHeader(title: t.menu, subtitle: t.menuNavigation),
            const SizedBox(height: 8),

            // Mon profil
            _tile(
              context,
              icon: Ionicons.person_circle,
              label: t.menuMyProfile,
              action: MenuAction.profil,
            ),

            const Divider(height: 20),

            // Sélecteur de langue
            _languageSelector(context),

            const Divider(height: 20),

            // Nous contacter
            _tile(
              context,
              icon: Ionicons.mail_open,
              label: t.menuContact,
              action: MenuAction.contact,
              onTapOverride: () => _defaultContact(context),
            ),

            // Politique de confidentialité
            _tile(
              context,
              icon: Ionicons.document_text,
              label: t.menuPrivacyPolicy,
              action: MenuAction.privacy,
              onTapOverride: () => _defaultPrivacy(context),
            ),

            const SizedBox(height: 8),
            const Divider(height: 20),

            // Déconnexion
            _tile(
              context,
              icon: Ionicons.log_out,
              label: t.logoutTitle, // ✅ tu l’as déjà
              action: MenuAction.logout,
            ),

            // Version
            _tile(
              context,
              icon: Ionicons.information_circle,
              label: t.menuVersion,
              subtitle: appVersion?.trim().isNotEmpty == true
                  ? appVersion!.trim()
                  : null,
              action: MenuAction.version,
              onTapOverride: () => _defaultVersion(context),
            ),
          ],
        ),
      ),
    );
  }

  /// ✅ Bloc sélecteur de langue
  Widget _languageSelector(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final enabled = onLocaleChanged != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 6),
          child: Text(
            t.languageLabel,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.onSurface.withOpacity(0.75),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          decoration: BoxDecoration(
            border: Border.all(color: theme.dividerColor.withOpacity(0.7)),
            borderRadius: BorderRadius.circular(12),
            color: theme.colorScheme.surfaceVariant.withOpacity(0.25),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<Locale?>(
              value: currentLocale, // null = Système
              isExpanded: true,
              onChanged: enabled ? (v) => onLocaleChanged?.call(v) : null,
              items: [
                DropdownMenuItem<Locale?>(
                  value: null,
                  child: Text(t.systemLanguage),
                ),
                const DropdownMenuItem<Locale?>(
                  value: Locale('fr'),
                  child: Text('Français'),
                ),
                const DropdownMenuItem<Locale?>(
                  value: Locale('en'),
                  child: Text('English'),
                ),
                const DropdownMenuItem<Locale?>(
                  value: Locale('es'),
                  child: Text('Español'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Text(
            t.currentLanguage(_localeLabel(context, currentLocale)),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.60),
            ),
          ),
        ),
      ],
    );
  }

  String _localeLabel(BuildContext context, Locale? l) {
    final t = AppLocalizations.of(context)!;

    if (l == null) return t.systemLanguage;
    switch (l.languageCode) {
      case 'fr':
        return 'Français';
      case 'en':
        return 'English';
      case 'es':
        return 'Español';
      default:
        return l.languageCode;
    }
  }

  Widget _tile(
    BuildContext context, {
    required IconData icon,
    required String label,
    String? subtitle,
    required MenuAction action,
    Future<void> Function()? onTapOverride,
  }) {
    final isSelected = selected == action;
    return ListTile(
      leading: Icon(icon, color: isSelected ? Colors.blue : null),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          color: isSelected ? Colors.blue.shade700 : null,
        ),
      ),
      subtitle: subtitle != null ? Text(subtitle) : null,
      selected: isSelected,
      onTap: () async {
        Navigator.of(context).maybePop();

        if (onTapOverride != null) {
          if (onSelected == null) await onTapOverride();
        }

        onSelected?.call(action);
      },
    );
  }

  Future<void> _defaultContact(BuildContext context) async {
    final t = AppLocalizations.of(context)!;

    final email = (contactEmail?.trim().isNotEmpty ?? false)
        ? contactEmail!.trim()
        : 'contact@exemple.org';

    final uri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {'subject': t.menuContactSubject},
    );
    await launchUrl(uri);
  }

  Future<void> _defaultPrivacy(BuildContext context) async {
    final url = (privacyUrl?.trim().isNotEmpty ?? false)
        ? privacyUrl!.trim()
        : 'https://www.example.com/politique-de-confidentialite';
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _defaultVersion(BuildContext context) async {
    final t = AppLocalizations.of(context)!;

    showAboutDialog(
      context: context,
      applicationIcon: const Icon(Ionicons.apps),
      applicationName: t.appTitle,
      applicationVersion: appVersion ?? '-',
    );
  }
}

class _MenuHeader extends StatelessWidget {
  const _MenuHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      leading: CircleAvatar(
        radius: 22,
        backgroundColor: Colors.blue.shade50,
        child: const Icon(Ionicons.apps, color: Colors.blue),
      ),
      title: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w800,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(color: Colors.black54),
      ),
    );
  }
}
