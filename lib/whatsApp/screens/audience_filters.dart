import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

typedef CountryOf<T> = String? Function(T);
typedef AgeOf<T> = int? Function(T);
typedef GenotypeOf<T> = String? Function(T);
typedef LatOf<T> = double? Function(T);
typedef LngOf<T> = double? Function(T);

class AudienceFilters<T> {
  final Set<String> countriesIso2; // ISO2 upper
  final Set<String> genotypes; // normalized lower
  final int? minAge;
  final int? maxAge;

  final bool distanceEnabled;
  final double? originLat;
  final double? originLng;
  final double? maxKm;

  const AudienceFilters({
    required this.countriesIso2,
    required this.genotypes,
    required this.minAge,
    required this.maxAge,
    required this.distanceEnabled,
    required this.originLat,
    required this.originLng,
    required this.maxKm,
  });

  AudienceFilters<T> copyWith({
    Set<String>? countriesIso2,
    Set<String>? genotypes,
    int? minAge,
    int? maxAge,
    bool? distanceEnabled,
    double? originLat,
    double? originLng,
    double? maxKm,
  }) {
    return AudienceFilters<T>(
      countriesIso2: countriesIso2 ?? this.countriesIso2,
      genotypes: genotypes ?? this.genotypes,
      minAge: minAge ?? this.minAge,
      maxAge: maxAge ?? this.maxAge,
      distanceEnabled: distanceEnabled ?? this.distanceEnabled,
      originLat: originLat ?? this.originLat,
      originLng: originLng ?? this.originLng,
      maxKm: maxKm ?? this.maxKm,
    );
  }

  static String _normIso2(String? raw) => (raw ?? '').trim().toUpperCase();
  static bool _isIso2(String s) => s.length == 2;
  static String _normGenotype(String? raw) => (raw ?? '').trim().toLowerCase();

  static ({int? min, int? max}) ageDomain<T>(List<T> all, AgeOf<T> ageOf) {
    final ages = <int>[];
    for (final p in all) {
      final a = ageOf(p);
      if (a != null) ages.add(a);
    }
    ages.sort();
    if (ages.isEmpty) return (min: null, max: null);
    return (min: ages.first, max: ages.last);
  }

  static List<String> countryOptions<T>(List<T> all, CountryOf<T> countryOf) {
    final set = <String>{};
    for (final p in all) {
      final c = _normIso2(countryOf(p));
      if (_isIso2(c)) set.add(c);
    }
    final list = set.toList()..sort();
    return list;
  }

  static List<String> genotypeOptions<T>(List<T> all, GenotypeOf<T> genoOf) {
    final set = <String>{};
    for (final p in all) {
      final g = _normGenotype(genoOf(p));
      if (g.isNotEmpty) set.add(g);
    }
    final list = set.toList()..sort();
    return list;
  }

  static AudienceFilters<T> defaultAll<T>(
    List<T> all, {
    required CountryOf<T> countryOf,
    required AgeOf<T> ageOf,
    required GenotypeOf<T> genotypeOf,
  }) {
    final countries = countryOptions(all, countryOf).toSet();
    final genos = genotypeOptions(all, genotypeOf).toSet();
    final dom = ageDomain(all, ageOf);

    return AudienceFilters<T>(
      countriesIso2: countries,
      genotypes: genos,
      minAge: dom.min,
      maxAge: dom.max,
      distanceEnabled: false,
      originLat: null,
      originLng: null,
      maxKm: null,
    );
  }

  static double _haversineKm({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) {
    const double r = 6371.0;
    const double degToRad = 0.017453292519943295;

    final dLat = (lat2 - lat1) * degToRad;
    final dLon = (lon2 - lon1) * degToRad;

    final a =
        (sin(dLat / 2) * sin(dLat / 2)) +
        cos(lat1 * degToRad) *
            cos(lat2 * degToRad) *
            (sin(dLon / 2) * sin(dLon / 2));

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return r * c;
  }

  bool matchesPerson(
    T p, {
    required CountryOf<T> countryOf,
    required AgeOf<T> ageOf,
    required GenotypeOf<T> genotypeOf,
    required LatOf<T> latOf,
    required LngOf<T> lngOf,
    required ({int? min, int? max}) datasetAgeDomain,
    required List<String> datasetCountryOptions,
    required List<String> datasetGenotypeOptions,
  }) {
    final countryActive =
        countriesIso2.isNotEmpty &&
        datasetCountryOptions.isNotEmpty &&
        countriesIso2.length != datasetCountryOptions.length;

    if (countryActive) {
      final c = _normIso2(countryOf(p));
      if (!_isIso2(c) || !countriesIso2.contains(c)) return false;
    }

    final genoActive =
        genotypes.isNotEmpty &&
        datasetGenotypeOptions.isNotEmpty &&
        genotypes.length != datasetGenotypeOptions.length;

    if (genoActive) {
      final g = _normGenotype(genotypeOf(p));
      if (g.isEmpty) return false;
      final ok = genotypes.any((sel) => g.contains(sel) || sel.contains(g));
      if (!ok) return false;
    }

    final ageActive =
        datasetAgeDomain.min != null &&
        datasetAgeDomain.max != null &&
        minAge != null &&
        maxAge != null &&
        (minAge != datasetAgeDomain.min || maxAge != datasetAgeDomain.max);

    if (ageActive) {
      final a = ageOf(p);
      if (a == null) return false;
      if (a < minAge! || a > maxAge!) return false;
    }

    // Distance
    if (distanceEnabled) {
      // filtre OFF tant que pas prêt
      if (originLat == null || originLng == null || maxKm == null) return true;

      final lat = latOf(p);
      final lng = lngOf(p);
      if (lat == null || lng == null) return false;

      final d = _haversineKm(
        lat1: originLat!,
        lon1: originLng!,
        lat2: lat,
        lon2: lng,
      );
      if (d > maxKm!) return false;
    }

    return true;
  }
}

// ============================================================================
// UI: BottomSheet Audience Filters
// ============================================================================

class AudienceFiltersSheet<T> extends StatefulWidget {
  final List<T> allPeople;
  final AudienceFilters<T> initial;

  final CountryOf<T> countryOf;
  final AgeOf<T> ageOf;
  final GenotypeOf<T> genotypeOf;
  final LatOf<T> latOf;
  final LngOf<T> lngOf;

  final Map<String, String>? countriesByCode;

  /// IMPORTANT: on attend une fonction, pas un Future.
  final Future<({double lat, double lng})?> Function()? resolveMyLocation;

  const AudienceFiltersSheet({
    super.key,
    required this.allPeople,
    required this.initial,
    required this.countryOf,
    required this.ageOf,
    required this.genotypeOf,
    required this.latOf,
    required this.lngOf,
    this.countriesByCode,
    this.resolveMyLocation,
  });

  static Future<AudienceFilters<T>?> open<T>({
    required BuildContext context,
    required List<T> allPeople,
    required AudienceFilters<T> initial,
    required CountryOf<T> countryOf,
    required AgeOf<T> ageOf,
    required GenotypeOf<T> genotypeOf,
    required LatOf<T> latOf,
    required LngOf<T> lngOf,
    Map<String, String>? countriesByCode,
    Future<({double lat, double lng})?> Function()? resolveMyLocation,
  }) {
    return showModalBottomSheet<AudienceFilters<T>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => AudienceFiltersSheet<T>(
        allPeople: allPeople,
        initial: initial,
        countryOf: countryOf,
        ageOf: ageOf,
        genotypeOf: genotypeOf,
        latOf: latOf,
        lngOf: lngOf,
        countriesByCode: countriesByCode,
        resolveMyLocation: resolveMyLocation,
      ),
    );
  }

  @override
  State<AudienceFiltersSheet<T>> createState() =>
      _AudienceFiltersSheetState<T>();
}

class _AudienceFiltersSheetState<T> extends State<AudienceFiltersSheet<T>> {
  late AudienceFilters<T> _local;

  late final ({int? min, int? max}) _ageDomain;
  late final List<String> _countryOptions;
  late final List<String> _genotypeOptions;

  int _resultsCount = 0;
  Timer? _countDebounce;

  bool _resolvingLocation = false; // ✅ évite double tap / état “bloqué”

  @override
  void initState() {
    super.initState();
    _local = widget.initial;

    _ageDomain = AudienceFilters.ageDomain(widget.allPeople, widget.ageOf);
    _countryOptions = AudienceFilters.countryOptions(
      widget.allPeople,
      widget.countryOf,
    );
    _genotypeOptions = AudienceFilters.genotypeOptions(
      widget.allPeople,
      widget.genotypeOf,
    );

    if (_ageDomain.min != null && _ageDomain.max != null) {
      final mi = _ageDomain.min!;
      final ma = _ageDomain.max!;
      final curMin = (_local.minAge ?? mi).clamp(mi, ma);
      final curMax = (_local.maxAge ?? ma).clamp(mi, ma);
      _local = _local.copyWith(
        minAge: min(curMin, curMax),
        maxAge: max(curMin, curMax),
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => _scheduleCount());
  }

  @override
  void dispose() {
    _countDebounce?.cancel();
    super.dispose();
  }

  void _setLocal(AudienceFilters<T> next) {
    setState(() => _local = next);
    _scheduleCount();
  }

  void _scheduleCount() {
    _countDebounce?.cancel();
    _countDebounce = Timer(const Duration(milliseconds: 140), () {
      if (!mounted) return;
      final c = _countResultsOptimized(_local);
      if (!mounted) return;
      setState(() => _resultsCount = c);
    });
  }

  String _countryLabel(String iso2) {
    final code = iso2.trim().toUpperCase();
    final name = widget.countriesByCode?[code];
    if (name == null || name.trim().isEmpty) return code;
    return name.trim();
  }

  int _countResultsOptimized(AudienceFilters<T> f) {
    final countryActive =
        f.countriesIso2.isNotEmpty &&
        _countryOptions.isNotEmpty &&
        f.countriesIso2.length != _countryOptions.length;

    final genoActive =
        f.genotypes.isNotEmpty &&
        _genotypeOptions.isNotEmpty &&
        f.genotypes.length != _genotypeOptions.length;

    final ageActive =
        _ageDomain.min != null &&
        _ageDomain.max != null &&
        f.minAge != null &&
        f.maxAge != null &&
        (f.minAge != _ageDomain.min || f.maxAge != _ageDomain.max);

    final distanceReady =
        f.distanceEnabled &&
        f.originLat != null &&
        f.originLng != null &&
        f.maxKm != null;

    final selectedCountries = countryActive
        ? f.countriesIso2.map((e) => e.trim().toUpperCase()).toSet()
        : const <String>{};

    final selectedGenos = genoActive
        ? f.genotypes.map((e) => e.trim().toLowerCase()).toSet()
        : const <String>{};

    double? minLat, maxLat, minLng, maxLng;
    if (distanceReady) {
      final oLat = f.originLat!;
      final oLng = f.originLng!;
      final km = f.maxKm!;
      final dLat = km / 111.32;
      final cosLat = cos(oLat * pi / 180.0).abs();
      final dLng = cosLat < 1e-6 ? 180.0 : km / (111.32 * cosLat);

      minLat = oLat - dLat;
      maxLat = oLat + dLat;
      minLng = oLng - dLng;
      maxLng = oLng + dLng;
    }

    int count = 0;
    for (final p in widget.allPeople) {
      if (distanceReady) {
        final lat = widget.latOf(p);
        final lng = widget.lngOf(p);
        if (lat == null || lng == null) continue;

        if (lat < minLat! || lat > maxLat! || lng < minLng! || lng > maxLng!)
          continue;

        final d = AudienceFilters._haversineKm(
          lat1: f.originLat!,
          lon1: f.originLng!,
          lat2: lat,
          lon2: lng,
        );
        if (d > f.maxKm!) continue;
      }

      if (genoActive) {
        final g = (widget.genotypeOf(p) ?? '').trim().toLowerCase();
        if (g.isEmpty) continue;
        bool ok = false;
        for (final sel in selectedGenos) {
          if (g.contains(sel) || sel.contains(g)) {
            ok = true;
            break;
          }
        }
        if (!ok) continue;
      }

      if (countryActive) {
        final c = (widget.countryOf(p) ?? '').trim().toUpperCase();
        if (c.length != 2 || !selectedCountries.contains(c)) continue;
      }

      if (ageActive) {
        final a = widget.ageOf(p);
        if (a == null) continue;
        if (a < f.minAge! || a > f.maxAge!) continue;
      }

      count++;
    }
    return count;
  }

  void _reset() {
    final def = AudienceFilters.defaultAll<T>(
      widget.allPeople,
      countryOf: widget.countryOf,
      ageOf: widget.ageOf,
      genotypeOf: widget.genotypeOf,
    );
    _setLocal(def);
  }

  Future<void> _ensureLocationOrExplain() async {
    if (_resolvingLocation) return;

    if (widget.resolveMyLocation == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Géolocalisation non disponible (resolver manquant)."),
        ),
      );
      return;
    }

    setState(() => _resolvingLocation = true);
    try {
      final loc = await widget.resolveMyLocation!();
      if (!mounted) return;

      if (loc == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Impossible d’obtenir la position. Vérifie services GPS + autorisations.",
            ),
          ),
        );
        // On laisse distanceEnabled à false si pas de loc
        _setLocal(_local.copyWith(distanceEnabled: false));
        return;
      }

      _setLocal(
        _local.copyWith(
          distanceEnabled: true,
          originLat: loc.lat,
          originLng: loc.lng,
          maxKm: _local.maxKm ?? 100.0,
        ),
      );
    } finally {
      if (mounted) setState(() => _resolvingLocation = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final resultsCount = _resultsCount;

    final hasAges = _ageDomain.min != null && _ageDomain.max != null;
    final minAge = _ageDomain.min ?? 0;
    final maxAge = _ageDomain.max ?? 0;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
          top: 16,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.88,
          ),
          child: ListView(
            padding: EdgeInsets.zero,
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: [
              Row(
                children: [
                  const Icon(Icons.groups),
                  const SizedBox(width: 8),
                  const Text(
                    'Audience',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Row(
                children: [
                  Icon(
                    resultsCount > 0
                        ? Icons.people
                        : Icons.warning_amber_rounded,
                    size: 18,
                    color: resultsCount > 0 ? Colors.black54 : Colors.orange,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      resultsCount > 0
                          ? '${resultsCount.toString()} ${resultsCount > 1 ? "personnes" : "personne"}'
                          : "Aucun résultat avec ces filtres",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: resultsCount > 0
                            ? Colors.black87
                            : Colors.orange,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Distance
              const Text(
                'Distance',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Activer le filtre distance'),
                value: _local.distanceEnabled,
                onChanged: _resolvingLocation
                    ? null // pendant l’obtention de la loc, on désactive temporairement
                    : (v) async {
                        if (!v) {
                          _setLocal(
                            _local.copyWith(
                              distanceEnabled: false,
                              originLat: null,
                              originLng: null,
                              maxKm: null,
                            ),
                          );
                          return;
                        }
                        // si on active => on force la résolution de la position (sinon filtre inutile)
                        await _ensureLocationOrExplain();
                      },
              ),

              if (_local.distanceEnabled) ...[
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    (_local.originLat != null && _local.originLng != null)
                        ? 'Origine: ${_local.originLat!.toStringAsFixed(4)}, ${_local.originLng!.toStringAsFixed(4)}'
                        : 'Origine non définie',
                  ),
                  trailing: TextButton.icon(
                    icon: _resolvingLocation
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.my_location),
                    label: const Text('Ma position'),
                    onPressed: _resolvingLocation
                        ? null
                        : _ensureLocationOrExplain,
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Slider(
                        value: (_local.maxKm ?? 100.0).clamp(1, 1000),
                        min: 1,
                        max: 1000,
                        divisions: 999,
                        label:
                            '${(_local.maxKm ?? 100.0).toStringAsFixed(0)} km',
                        onChanged: (v) => _setLocal(_local.copyWith(maxKm: v)),
                      ),
                    ),
                    SizedBox(
                      width: 72,
                      child: Text(
                        '${(_local.maxKm ?? 100.0).toStringAsFixed(0)} km',
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 16),

              // Pays
              const Text('Pays', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Theme(
                data: Theme.of(
                  context,
                ).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  title: Text(
                    _local.countriesIso2.length == _countryOptions.length
                        ? 'Tous les pays'
                        : '${_local.countriesIso2.length} sélectionné(s)',
                  ),
                  children: [
                    Row(
                      children: [
                        TextButton(
                          onPressed: () => _setLocal(
                            _local.copyWith(
                              countriesIso2: _countryOptions.toSet(),
                            ),
                          ),
                          child: const Text('Tout sélectionner'),
                        ),
                        TextButton(
                          onPressed: () => _setLocal(
                            _local.copyWith(countriesIso2: <String>{}),
                          ),
                          child: const Text('Effacer'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ..._countryOptions.map((iso2) {
                      final checked = _local.countriesIso2.contains(iso2);
                      return CheckboxListTile(
                        value: checked,
                        title: Text(_countryLabel(iso2)),
                        dense: true,
                        controlAffinity: ListTileControlAffinity.leading,
                        onChanged: (v) {
                          final next = Set<String>.from(_local.countriesIso2);
                          if (v == true) {
                            next.add(iso2);
                          } else {
                            next.remove(iso2);
                          }
                          _setLocal(_local.copyWith(countriesIso2: next));
                        },
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Génotype
              const Text(
                'Génotype',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              ..._genotypeOptions.map((g) {
                final checked = _local.genotypes.contains(g);
                return CheckboxListTile(
                  value: checked,
                  title: Text(g),
                  dense: true,
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (v) {
                    final next = Set<String>.from(_local.genotypes);
                    if (v == true) {
                      next.add(g);
                    } else {
                      next.remove(g);
                    }
                    _setLocal(_local.copyWith(genotypes: next));
                  },
                );
              }),

              const SizedBox(height: 16),

              // Âge
              const Text('Âge', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              if (!hasAges)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: LinearProgressIndicator(minHeight: 2),
                )
              else ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Min: ${_local.minAge}'),
                    Text('Max: ${_local.maxAge}'),
                  ],
                ),
                RangeSlider(
                  values: RangeValues(
                    (_local.minAge ?? minAge).toDouble(),
                    (_local.maxAge ?? maxAge).toDouble(),
                  ),
                  min: minAge.toDouble(),
                  max: maxAge.toDouble(),
                  divisions: (maxAge - minAge) > 0 ? (maxAge - minAge) : null,
                  labels: RangeLabels(
                    (_local.minAge ?? minAge).toString(),
                    (_local.maxAge ?? maxAge).toString(),
                  ),
                  onChanged: (rng) => _setLocal(
                    _local.copyWith(
                      minAge: rng.start.round(),
                      maxAge: rng.end.round(),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: _reset, child: Text(l10n.mapReset)),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(null),
                    child: Text(l10n.cancel),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.check),
                    label: Text(l10n.mapApply),
                    onPressed: () => Navigator.of(context).pop(_local),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
