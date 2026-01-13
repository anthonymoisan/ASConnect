// lib/tabular/view/tabular_view.dart
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../whatsApp/services/conversation_api.dart'
    show personPhotoUrl, publicAppKey;
import '../models/listPerson.dart';
import '../models/person.dart';
import '../services/tabular_api.dart';

class TabularView extends StatefulWidget {
  const TabularView({super.key});

  @override
  State<TabularView> createState() => _TabularViewState();
}

class _TabularViewState extends State<TabularView> {
  ListPerson? _listPerson;
  bool _loading = true;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await TabularApi.fetchPeopleMapRepresentation();
      if (!mounted) return;

      debugPrint('[TABULAR] people count = ${data.count}');

      setState(() {
        _listPerson = data;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  // ---------------------------------------------------------------------------
  // 🧬 Génotype : valeur brute API -> libellé ARB (langue sélectionnée)
  // ---------------------------------------------------------------------------
  String _genotypeLabel(BuildContext context, String? raw) {
    final l10n = AppLocalizations.of(context)!;

    if (raw == null) return '—';
    final v = raw.trim();
    if (v.isEmpty) return '—';

    final s = v.toLowerCase();

    // accepte "Délétion", "Deletion", "del", "deletion", etc.
    if (s.startsWith('dél') || s.startsWith('del'))
      return l10n.genotypeDeletion;
    if (s.startsWith('mut')) return l10n.genotypeMutation;
    if (s == 'upd') return l10n.genotypeUpd;
    if (s == 'icd') return l10n.genotypeIcd;
    if (s.startsWith('cli')) return l10n.genotypeClinical;
    if (s.startsWith('mos')) return l10n.genotypeMosaic;

    // fallback : on affiche la valeur API si inconnue
    return v;
  }

  void _openPersonPhotoFullScreen(Person p) {
    final l10n = AppLocalizations.of(context)!;

    final int id = p.id ?? -1;
    final String url = personPhotoUrl(id);

    final String pseudo = (p.pseudo?.trim().isNotEmpty == true)
        ? p.pseudo!.trim()
        : (p.firstName?.trim().isNotEmpty == true)
        ? p.firstName!.trim()
        : '—';

    final String ageLabel = (p.age == null)
        ? '—'
        : l10n.mapPersonTileAge(p.age!);

    // ✅ genotype localisé via ARB
    final String genotype = _genotypeLabel(context, p.genotype);

    final String country = (p.country?.trim().isNotEmpty == true)
        ? p.country!.trim()
        : '—';
    final String city = (p.city?.trim().isNotEmpty == true)
        ? p.city!.trim()
        : '—';

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: l10n.photo,
      barrierColor: Colors.black,
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (ctx, _, __) {
        final l10n2 = AppLocalizations.of(ctx)!;

        return Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: InteractiveViewer(
                          minScale: 1.0,
                          maxScale: 4.0,
                          child: Image.network(
                            url,
                            headers: {'X-App-Key': publicAppKey},
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.person,
                              size: 120,
                              color: Colors.white54,
                            ),
                            loadingBuilder: (ctx2, child, prog) {
                              if (prog == null) return child;
                              return const SizedBox(
                                width: 36,
                                height: 36,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            Text(
                              '$pseudo  •  $ageLabel  •  $genotype',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '$country  •  $city',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 14),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(ctx).pop(),
                    tooltip: l10n2.close,
                  ),
                ),
              ],
            ),
          ),
        );
      },
      transitionBuilder: (ctx, anim, _, child) {
        return FadeTransition(opacity: anim, child: child);
      },
    );
  }

  Widget _photoAvatar(Person p, {double radius = 22}) {
    final int id = p.id ?? -1;
    final String url = personPhotoUrl(id);

    return GestureDetector(
      onTap: () => _openPersonPhotoFullScreen(p),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: Colors.grey.shade200,
        backgroundImage: NetworkImage(
          url,
          headers: {'X-App-Key': publicAppKey},
        ),
        onBackgroundImageError: (_, __) {},
        child: const SizedBox.shrink(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Tabular')),
        body: Center(child: Text('Error: $_error')),
      );
    }

    final people = _listPerson?.items ?? const <Person>[];

    return Scaffold(
      appBar: AppBar(title: const Text('Tabular')),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _loading = true;
            _error = null;
          });
          await _load();
        },
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: people.length,
          separatorBuilder: (_, __) =>
              Divider(height: 1, color: Colors.grey.shade200),
          itemBuilder: (ctx, i) {
            final p = people[i];

            final pseudo = (p.pseudo?.trim().isNotEmpty == true)
                ? p.pseudo!.trim()
                : (p.firstName?.trim().isNotEmpty == true)
                ? p.firstName!.trim()
                : '—';

            final ageLabel = (p.age == null)
                ? '—'
                : l10n.mapPersonTileAge(p.age!);

            // ✅ genotype localisé via ARB
            final genotype = _genotypeLabel(context, p.genotype);

            final country = (p.country?.trim().isNotEmpty == true)
                ? p.country!.trim()
                : '—';
            final city = (p.city?.trim().isNotEmpty == true)
                ? p.city!.trim()
                : '—';

            return ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: _photoAvatar(p, radius: 22),
              title: Text(
                '$pseudo  •  $ageLabel  •  $genotype',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text(
                '$country  •  $city',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey.shade700),
              ),
              onTap: () => _openPersonPhotoFullScreen(p),
            );
          },
        ),
      ),
    );
  }
}
