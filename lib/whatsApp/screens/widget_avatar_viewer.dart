// lib/whatsApp/screens/widget_avatar_viewer.dart

import 'dart:async';

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../tabular/models/person.dart';
import '../../tabular/services/tabular_api.dart';
import '../services/conversation_api.dart'; // personPhotoUrl, publicAppKey

class AvatarViewer {
  // ✅ Cache Person par id
  static final Map<int, Person> _personCache = <int, Person>{};

  // ✅ Cache dataset people (TTL) + dedup in-flight
  static List<Person>? _datasetCache;
  static DateTime? _datasetCacheAt;
  static const Duration _datasetTtl = Duration(minutes: 5);
  static Future<List<Person>>? _datasetInFlight;

  // ✅ Cache pays traduits par locale (TTL) + dedup in-flight
  static final Map<String, Map<String, String>> _countriesByLocaleCache =
      <String, Map<String, String>>{};
  static final Map<String, DateTime> _countriesCacheAt = <String, DateTime>{};
  static const Duration _countriesTtl = Duration(hours: 6);
  static final Map<String, Future<Map<String, String>>> _countriesInFlight =
      <String, Future<Map<String, String>>>{};

  static void open(BuildContext context, {required int peopleId}) {
    final l10n = AppLocalizations.of(context)!;
    final url = personPhotoUrl(peopleId);

    // ✅ locale pour la traduction pays
    final locale = Localizations.localeOf(context).languageCode.toLowerCase();

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
                Positioned.fill(
                  child: Center(
                    child: InteractiveViewer(
                      minScale: 1.0,
                      maxScale: 4.0,
                      child: Image.network(
                        url,
                        headers: const {'X-App-Key': publicAppKey},
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
                            child: CircularProgressIndicator(strokeWidth: 2),
                          );
                        },
                      ),
                    ),
                  ),
                ),

                // ✅ Bandeau infos (pseudo/age/genotype + pays traduit/ville)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _InfoOverlay(peopleId: peopleId, locale: locale),
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
      transitionBuilder: (ctx, anim, _, child) =>
          FadeTransition(opacity: anim, child: child),
    );
  }

  // ---------------------------------------------------------------------------
  // Data access
  // ---------------------------------------------------------------------------

  static Future<Person?> _getPerson(int id) async {
    final cached = _personCache[id];
    if (cached != null) return cached;

    final now = DateTime.now();
    final datasetOk =
        _datasetCache != null &&
        _datasetCacheAt != null &&
        now.difference(_datasetCacheAt!) < _datasetTtl;

    if (datasetOk) {
      for (final p in _datasetCache!) {
        if (p.id == id) {
          _personCache[id] = p;
          return p;
        }
      }
    }

    _datasetInFlight ??= () async {
      final list = await TabularApi.fetchPeopleMapRepresentation();
      final items = list.items;
      _datasetCache = items;
      _datasetCacheAt = DateTime.now();
      return items;
    }();

    final items = await _datasetInFlight!;
    _datasetInFlight = null;

    for (final p in items) {
      if (p.id == id) {
        _personCache[id] = p;
        return p;
      }
    }
    return null;
  }

  static Future<Map<String, String>> _getCountriesTranslated(
    String locale,
  ) async {
    final loc = locale.toLowerCase();
    final now = DateTime.now();

    final cached = _countriesByLocaleCache[loc];
    final at = _countriesCacheAt[loc];
    final ok =
        cached != null && at != null && now.difference(at) < _countriesTtl;
    if (ok) return cached;

    // dedup in-flight par locale
    final inflight = _countriesInFlight[loc];
    if (inflight != null) return inflight;

    final fut = () async {
      try {
        final map = await TabularApi.fetchCountriesTranslated(locale: loc);
        _countriesByLocaleCache[loc] = map;
        _countriesCacheAt[loc] = DateTime.now();
        return map;
      } catch (_) {
        // fallback vide => on affichera ISO2 si besoin
        _countriesByLocaleCache[loc] = const {};
        _countriesCacheAt[loc] = DateTime.now();
        return const <String, String>{};
      } finally {
        _countriesInFlight.remove(loc);
      }
    }();

    _countriesInFlight[loc] = fut;
    return fut;
  }
}

class _InfoOverlay extends StatelessWidget {
  final int peopleId;
  final String locale;

  const _InfoOverlay({required this.peopleId, required this.locale});

  String _pseudo(Person p) {
    final raw = p.pseudo.trim();
    return raw.isNotEmpty ? raw : '—';
  }

  String _ageLabel(AppLocalizations l10n, Person p) {
    final a = p.age;
    if (a == null) return '—';
    // comme TabularView
    try {
      return l10n.mapPersonTileAge(a);
    } catch (_) {
      return '$a';
    }
  }

  String _genotypeLabel(AppLocalizations l10n, Person p) {
    final g = (p.genotype ?? '').trim();
    if (g.isEmpty) return '—';

    final low = g.toLowerCase();
    if (low.contains('dél') ||
        low.contains('del') ||
        low.contains('deletion')) {
      return l10n.genotypeDeletion;
    }
    if (low.contains('mut')) return l10n.genotypeMutation;
    if (low.contains('upd')) return l10n.genotypeUpd;
    if (low.contains('icd')) return l10n.genotypeIcd;
    if (low.contains('clin')) return l10n.genotypeClinical;
    if (low.contains('mosa')) return l10n.genotypeMosaic;

    return g;
  }

  String _cityLabel(Person p) {
    final raw = (p.city ?? '').trim();
    return raw.isNotEmpty ? raw : '—';
  }

  String _countryLabelTranslated(
    Person p,
    Map<String, String> countriesByCode,
  ) {
    final code = (p.countryCode ?? '').trim().toUpperCase();
    if (code.length == 2) {
      final translated = countriesByCode[code];
      if (translated != null && translated.trim().isNotEmpty) {
        return translated.trim();
      }
      return code; // fallback ISO2
    }

    final raw = (p.country ?? '').trim();
    return raw.isNotEmpty ? raw : '—';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // ✅ on charge Person + pays traduits (en parallèle)
    final future = Future.wait([
      AvatarViewer._getPerson(peopleId),
      AvatarViewer._getCountriesTranslated(locale),
    ]);

    return FutureBuilder<List<dynamic>>(
      future: future,
      builder: (ctx, snap) {
        final done = snap.connectionState == ConnectionState.done;
        final Person? p = done ? (snap.data?[0] as Person?) : null;
        final Map<String, String> countries = done
            ? (snap.data?[1] as Map<String, String>? ?? const {})
            : const {};

        return Container(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.55),
                Colors.black.withOpacity(0.75),
              ],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!done)
                const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else if (p == null)
                const Text(
                  '—',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                )
              else ...[
                Text(
                  '${_pseudo(p)}  •  ${_ageLabel(l10n, p)}  •  ${_genotypeLabel(l10n, p)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${_countryLabelTranslated(p, countries)}  •  ${_cityLabel(p)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
