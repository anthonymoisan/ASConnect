import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

typedef CountryOf<T> = String? Function(T);
typedef AgeOf<T> = int? Function(T);
typedef GenotypeOf<T> = String? Function(T);
typedef LatOf<T> = double? Function(T);
typedef LngOf<T> = double? Function(T);
typedef LanguageOf<T> = String? Function(T);

// ============================================================================
// DATA: AudienceFilters
// - Génotypes: options CANONIQUES (comme Tabular) => UI stable + i18n stable
// - Matching genotype: robuste (comme Tabular) sur la valeur réelle du dataset
// ============================================================================

class AudienceFilters<T> {
  // ---------------------------------------------------------------------------
  // ✅ Options CANONIQUES (doit rester aligné avec Tabular kGenotypeOptions)
  // ---------------------------------------------------------------------------
  static const List<String> kGenotypeOptions = <String>[
    'délétion',
    'mutation',
    'upd',
    'icd',
    'clinique',
    'mosaïque',
  ];

  final Set<String> countriesIso2; // ISO2 upper
  final Set<String>
  genotypes; // ✅ selection = canonical values (strings ci-dessus)
  final Set<String> languages; // base codes lower ("fr","en","es")

  final int? minAge;
  final int? maxAge;

  final bool distanceEnabled;
  final double? originLat;
  final double? originLng;
  final double? maxKm;

  const AudienceFilters({
    required this.countriesIso2,
    required this.genotypes,
    required this.languages,
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
    Set<String>? languages,
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
      languages: languages ?? this.languages,
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

  static String _normLang(String? raw) => (raw ?? '').trim().toLowerCase();

  /// "pt_BR" / "pt-BR" -> "pt"
  static String _langBase(String raw) {
    final t = _normLang(raw);
    if (t.isEmpty) return '';
    return t.split(RegExp(r'[_-]')).first;
  }

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

  /// ✅ Options langues (base codes)
  static List<String> languageOptions<T>(
    List<T> all,
    LanguageOf<T> languageOf,
  ) {
    final set = <String>{};
    for (final p in all) {
      final l = _langBase(languageOf(p) ?? '');
      if (l.isNotEmpty) set.add(l);
    }
    final list = set.toList()..sort();
    return list;
  }

  static AudienceFilters<T> defaultAll<T>(
    List<T> all, {
    required CountryOf<T> countryOf,
    required AgeOf<T> ageOf,
    required LanguageOf<T> languageOf,
  }) {
    final countries = countryOptions(all, countryOf).toSet();
    final langs = languageOptions(all, languageOf).toSet();
    final dom = ageDomain(all, ageOf);

    return AudienceFilters<T>(
      countriesIso2: countries,
      genotypes: kGenotypeOptions.toSet(), // ✅ canonical = select all
      languages: langs, // select all
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

  // ---------------------------------------------------------------------------
  // ✅ Matching genotype robuste (copie de Tabular, sans heuristique locale)
  // - on compare valeur dataset (normalisée) vs sélection (normalisée)
  // ---------------------------------------------------------------------------
  static bool _matchGenotypeNorm(String genotypeNorm, String selNorm) {
    final selIsDeletion = selNorm.contains('dél') || selNorm.contains('del');
    if (selIsDeletion &&
        (genotypeNorm.contains('dél') ||
            genotypeNorm.contains('del') ||
            genotypeNorm.contains('deletion'))) {
      return true;
    }
    return genotypeNorm.contains(selNorm) || selNorm.contains(genotypeNorm);
  }

  static bool _matchesGenotypeWithSelection(
    String? genotypeRaw,
    Set<String> selectedNorm,
  ) {
    final g = (genotypeRaw ?? '').trim();
    if (g.isEmpty) return false;

    final norm = g.toLowerCase();
    for (final sel in selectedNorm) {
      if (_matchGenotypeNorm(norm, sel)) return true;
    }
    return false;
  }

  bool matchesPerson(
    T p, {
    required CountryOf<T> countryOf,
    required AgeOf<T> ageOf,
    required GenotypeOf<T> genotypeOf,
    required LanguageOf<T> languageOf,
    required LatOf<T> latOf,
    required LngOf<T> lngOf,
    required ({int? min, int? max}) datasetAgeDomain,
    required List<String> datasetCountryOptions,
    required List<String> datasetLanguageOptions,
  }) {
    final countryActive =
        countriesIso2.isNotEmpty &&
        datasetCountryOptions.isNotEmpty &&
        countriesIso2.length != datasetCountryOptions.length;

    if (countryActive) {
      final c = _normIso2(countryOf(p));
      if (!_isIso2(c) || !countriesIso2.contains(c)) return false;
    }

    // ✅ genotype active seulement si user a “resserré” vs 6 options
    final genoActive =
        genotypes.isNotEmpty && genotypes.length != kGenotypeOptions.length;

    if (genoActive) {
      final selectedNorm = genotypes.map((e) => e.trim().toLowerCase()).toSet();
      final ok = _matchesGenotypeWithSelection(genotypeOf(p), selectedNorm);
      if (!ok) return false;
    }

    // ✅ languages active seulement si user a “resserré”
    final langActive =
        languages.isNotEmpty &&
        datasetLanguageOptions.isNotEmpty &&
        languages.length != datasetLanguageOptions.length;

    if (langActive) {
      final l = _langBase(languageOf(p) ?? '');
      if (l.isEmpty || !languages.contains(l)) return false;
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
// UI: BottomSheet Audience Filters (i18n)
// + Langues (.arb) + Génotypes (canonique + _genoLabel simple)
// ============================================================================

class AudienceFiltersSheet<T> extends StatefulWidget {
  final List<T> allPeople;
  final AudienceFilters<T> initial;

  final CountryOf<T> countryOf;
  final AgeOf<T> ageOf;
  final GenotypeOf<T> genotypeOf;
  final LanguageOf<T> languageOf;
  final LatOf<T> latOf;
  final LngOf<T> lngOf;

  final Map<String, String>? countriesByCode;

  /// base code -> nom traduit (selon locale UI)
  final Map<String, String>? languagesByCode;

  final Future<({double lat, double lng})?> Function()? resolveMyLocation;

  const AudienceFiltersSheet({
    super.key,
    required this.allPeople,
    required this.initial,
    required this.countryOf,
    required this.ageOf,
    required this.genotypeOf,
    required this.languageOf,
    required this.latOf,
    required this.lngOf,
    this.countriesByCode,
    this.languagesByCode,
    this.resolveMyLocation,
  });

  static Future<AudienceFilters<T>?> open<T>({
    required BuildContext context,
    required List<T> allPeople,
    required AudienceFilters<T> initial,
    required CountryOf<T> countryOf,
    required AgeOf<T> ageOf,
    required GenotypeOf<T> genotypeOf,
    required LanguageOf<T> languageOf,
    required LatOf<T> latOf,
    required LngOf<T> lngOf,
    Map<String, String>? countriesByCode,
    Map<String, String>? languagesByCode,
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
        languageOf: languageOf,
        latOf: latOf,
        lngOf: lngOf,
        countriesByCode: countriesByCode,
        languagesByCode: languagesByCode,
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
  late final List<String> _languageOptions;

  // ✅ Génotypes: CANONIQUES
  late final List<String> _genotypeOptions;

  int _resultsCount = 0;
  Timer? _countDebounce;

  bool _resolvingLocation = false;

  @override
  void initState() {
    super.initState();
    _local = widget.initial;

    _ageDomain = AudienceFilters.ageDomain(widget.allPeople, widget.ageOf);
    _countryOptions = AudienceFilters.countryOptions(
      widget.allPeople,
      widget.countryOf,
    );
    _languageOptions = AudienceFilters.languageOptions(
      widget.allPeople,
      widget.languageOf,
    );

    _genotypeOptions = AudienceFilters.kGenotypeOptions;

    // Clamp âge
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

    // Clamp langues (si vide -> all)
    if (_languageOptions.isNotEmpty) {
      if (_local.languages.isEmpty) {
        _local = _local.copyWith(languages: _languageOptions.toSet());
      } else {
        final opts = _languageOptions.toSet();
        final next = Set<String>.from(_local.languages)
          ..removeWhere((l) => !opts.contains(l));
        if (next.isEmpty) next.addAll(opts);
        _local = _local.copyWith(languages: next);
      }
    }

    // Clamp génotypes (si vide -> all canonical)
    if (_local.genotypes.isEmpty) {
      _local = _local.copyWith(genotypes: _genotypeOptions.toSet());
    } else {
      final opts = _genotypeOptions.toSet();
      final next = Set<String>.from(_local.genotypes)
        ..removeWhere((g) => !opts.contains(g));
      if (next.isEmpty) next.addAll(opts);
      _local = _local.copyWith(genotypes: next);
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

  String _capitalizeFirst(String s) {
    final t = s.trim();
    if (t.isEmpty) return t;
    return t[0].toUpperCase() + t.substring(1);
  }

  String _prettyLanguageLabel(String baseCode) {
    final code = baseCode.trim().toLowerCase();
    final fromMap = widget.languagesByCode?[code];
    if (fromMap != null && fromMap.trim().isNotEmpty) {
      return _capitalizeFirst(fromMap.trim());
    }
    return _capitalizeFirst(code);
  }

  // ✅ EXACTEMENT ta fonction (calée Tabular)
  String _genoLabel(BuildContext ctx, String raw) {
    final l10n = AppLocalizations.of(ctx)!;
    final g = raw.trim().toLowerCase();

    if (g.contains('dél') || g.contains('del') || g.contains('deletion')) {
      return l10n.genotypeDeletion;
    }
    if (g.contains('mut')) return l10n.genotypeMutation;
    if (g.contains('upd')) return l10n.genotypeUpd;
    if (g.contains('icd')) return l10n.genotypeIcd;
    if (g.contains('clin')) return l10n.genotypeClinical;
    if (g.contains('mosa')) return l10n.genotypeMosaic;

    return raw;
  }

  int _countResultsOptimized(AudienceFilters<T> f) {
    final countryActive =
        f.countriesIso2.isNotEmpty &&
        _countryOptions.isNotEmpty &&
        f.countriesIso2.length != _countryOptions.length;

    final genoActive =
        f.genotypes.isNotEmpty &&
        f.genotypes.length != AudienceFilters.kGenotypeOptions.length;

    final langActive =
        f.languages.isNotEmpty &&
        _languageOptions.isNotEmpty &&
        f.languages.length != _languageOptions.length;

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

    final selectedGenosNorm = genoActive
        ? f.genotypes.map((e) => e.trim().toLowerCase()).toSet()
        : const <String>{};

    final selectedLangs = langActive
        ? f.languages.map((e) => e.trim().toLowerCase()).toSet()
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

        if (lat < minLat! || lat > maxLat! || lng < minLng! || lng > maxLng!) {
          continue;
        }

        final d = AudienceFilters._haversineKm(
          lat1: f.originLat!,
          lon1: f.originLng!,
          lat2: lat,
          lon2: lng,
        );
        if (d > f.maxKm!) continue;
      }

      if (genoActive) {
        final g = (widget.genotypeOf(p) ?? '').trim();
        if (!AudienceFilters._matchesGenotypeWithSelection(
          g,
          selectedGenosNorm,
        ))
          continue;
      }

      if (langActive) {
        final raw = (widget.languageOf(p) ?? '').trim().toLowerCase();
        final base = raw.isEmpty ? '' : raw.split(RegExp(r'[_-]')).first;
        if (base.isEmpty || !selectedLangs.contains(base)) continue;
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
      languageOf: widget.languageOf,
    );
    _setLocal(def);
  }

  Future<void> _ensureLocationOrExplain() async {
    final l10n = AppLocalizations.of(context)!;

    if (_resolvingLocation) return;

    if (widget.resolveMyLocation == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.mapLocationResolverMissing)));
      return;
    }

    setState(() => _resolvingLocation = true);
    try {
      final loc = await widget.resolveMyLocation!();
      if (!mounted) return;

      if (loc == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.mapLocationUnableToGet)));
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
                  Text(
                    l10n.audience,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
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
                          ? l10n.mapResultsCount(resultsCount)
                          : l10n.mapNoResultsWithTheseFilters,
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
              Text(
                l10n.mapDistanceTitle,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.mapEnableDistanceFilter),
                value: _local.distanceEnabled,
                onChanged: _resolvingLocation
                    ? null
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
                        await _ensureLocationOrExplain();
                      },
              ),

              if (_local.distanceEnabled) ...[
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    (_local.originLat != null && _local.originLng != null)
                        ? l10n.mapOriginDefined(
                            _local.originLat!.toStringAsFixed(4),
                            _local.originLng!.toStringAsFixed(4),
                          )
                        : l10n.mapOriginUndefined,
                  ),
                  trailing: TextButton.icon(
                    icon: _resolvingLocation
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.my_location),
                    label: Text(l10n.mapMyPosition),
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
                        label: l10n.mapKmLabel(
                          (_local.maxKm ?? 100.0).toStringAsFixed(0),
                        ),
                        onChanged: (v) => _setLocal(_local.copyWith(maxKm: v)),
                      ),
                    ),
                    SizedBox(
                      width: 72,
                      child: Text(
                        l10n.mapKmLabel(
                          (_local.maxKm ?? 100.0).toStringAsFixed(0),
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 16),

              // Langues (.arb)
              Text(
                l10n.mapLanguagesSectionTitle,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Theme(
                data: Theme.of(
                  context,
                ).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  title: Text(
                    _languageOptions.isEmpty
                        ? l10n.mapAllLanguagesSelected
                        : (_local.languages.length == _languageOptions.length
                              ? l10n.mapAllLanguagesSelected
                              : l10n.mapLanguagesSelectedCount(
                                  _local.languages.length,
                                )),
                  ),
                  children: [
                    Row(
                      children: [
                        TextButton(
                          onPressed: _languageOptions.isEmpty
                              ? null
                              : () => _setLocal(
                                  _local.copyWith(
                                    languages: _languageOptions.toSet(),
                                  ),
                                ),
                          child: Text(l10n.mapSelectAll),
                        ),
                        TextButton(
                          onPressed: () =>
                              _setLocal(_local.copyWith(languages: <String>{})),
                          child: Text(l10n.mapClear),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ..._languageOptions.map((code) {
                      final checked = _local.languages.contains(code);
                      return CheckboxListTile(
                        value: checked,
                        title: Text(_prettyLanguageLabel(code)),
                        dense: true,
                        controlAffinity: ListTileControlAffinity.leading,
                        onChanged: (v) {
                          final next = Set<String>.from(_local.languages);
                          if (v == true) {
                            next.add(code);
                          } else {
                            next.remove(code);
                          }
                          _setLocal(_local.copyWith(languages: next));
                        },
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Pays
              Text(
                l10n.mapCountryTitle,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Theme(
                data: Theme.of(
                  context,
                ).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  title: Text(
                    _local.countriesIso2.length == _countryOptions.length
                        ? l10n.mapAllCountriesSelected
                        : l10n.mapCountriesSelectedCount(
                            _local.countriesIso2.length,
                          ),
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
                          child: Text(l10n.mapSelectAll),
                        ),
                        TextButton(
                          onPressed: () => _setLocal(
                            _local.copyWith(countriesIso2: <String>{}),
                          ),
                          child: Text(l10n.mapClear),
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

              // Génotypes (✅ canonique + label i18n stable)
              Text(
                l10n.mapGenotypeTitle,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              ..._genotypeOptions.map((g) {
                final checked = _local.genotypes.contains(g);
                return CheckboxListTile(
                  value: checked,
                  title: Text(_genoLabel(context, g)),
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
              Text(
                l10n.mapAgeTitle,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
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
                    Text(l10n.mapMinValue(_local.minAge ?? minAge)),
                    Text(l10n.mapMaxValue(_local.maxAge ?? maxAge)),
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

              // Actions
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
