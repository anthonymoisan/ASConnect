// lib/tabular/view/tabular_view.dart
import 'dart:async';

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../whatsApp/services/conversation_api.dart'
    show personPhotoUrl, publicAppKey, ConversationApi;
import '../../whatsApp/services/conversation_events.dart';
import '../../whatsApp/screens/chat_page.dart';

import '../models/listPerson.dart';
import '../models/person.dart';
import '../services/tabular_api.dart';

/// ✅ Options génotypes (mêmes “familles” que la carto)
const List<String> kTabularGenotypeOptions = <String>[
  'délétion',
  'mutation',
  'upd',
  'icd',
  'clinique',
  'mosaïque',
];

class TabularView extends StatefulWidget {
  final int currentPersonId;

  const TabularView({super.key, required this.currentPersonId});

  @override
  State<TabularView> createState() => _TabularViewState();
}

class _TabularViewState extends State<TabularView> with WidgetsBindingObserver {
  ListPerson? _listPerson;
  bool _loading = true;
  Object? _error;

  Map<String, String> _countriesByCode = {};
  String? _countriesLocale;

  // ✅ Tri
  int? _sortColumnIndex;
  bool _sortAscending = true;

  // ✅ Vue filtrée affichée
  List<Person> _view = const <Person>[];

  // ✅ Dataset complet (hors "moi"), base pour filtres
  List<Person> _allPeople = const <Person>[];

  // ✅ Filtres (état)
  final Set<String> _selectedGenotypes = <String>{...kTabularGenotypeOptions};
  final Set<String> _selectedCountries = <String>{};
  bool _connectedOnly = false;
  int? _selectedMinAge;
  int? _selectedMaxAge;
  int? _datasetMinAge;
  int? _datasetMaxAge;

  // ✅ Poll refresh status
  Timer? _pollTimer;
  bool _reloading = false;
  static const Duration _pollInterval = Duration(seconds: 10);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _loadPeople();
    _startPolling();
  }

  @override
  void dispose() {
    _stopPolling();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadCountriesIfNeeded();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _startPolling();
      _reload(silent: true);
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      _stopPolling();
    }
  }

  void _startPolling() {
    if (_pollTimer != null) return;

    _pollTimer = Timer.periodic(_pollInterval, (_) async {
      if (!mounted) return;
      await _reload(silent: true);
    });
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  String _tableResultsLabel(AppLocalizations l10n) {
    final n = _view.length;
    return '${l10n.tableTabular} • $n';
  }

  // ---------------------------------------------------------------------------
  // Width strategy (auto + plafonds)
  // ---------------------------------------------------------------------------

  double _maxPseudoWidth(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w < 360) return 90;
    if (w < 600) return 110;
    return 130;
  }

  double _maxGenotypeWidth(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w < 360) return 120;
    if (w < 600) return 140;
    return 170;
  }

  double _maxCountryWidth(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w < 360) return 120;
    if (w < 600) return 150;
    return 190;
  }

  double _maxCityWidth(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w < 360) return 120;
    if (w < 600) return 150;
    return 190;
  }

  Widget _ellipsisCell(
    String text, {
    required double maxWidth,
    TextStyle? style,
    TextAlign? textAlign,
  }) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: style,
        textAlign: textAlign,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Data loading
  // ---------------------------------------------------------------------------

  Future<void> _loadPeople() async {
    try {
      final data = await TabularApi.fetchPeopleMapRepresentation();
      if (!mounted) return;

      final meId = widget.currentPersonId;
      final newAll = data.items.where((p) => p.id != meId).toList();

      setState(() {
        _listPerson = data;
        _allPeople = List<Person>.from(newAll);
        _view = List<Person>.from(newAll);
        _loading = false;
        _error = null;
      });

      // ✅ init filtres (pays/âge) puis applique
      _recomputeAgeDomainFromAllPeople();
      if (_selectedCountries.isEmpty) {
        _selectedCountries.addAll(_countryOptions);
      }
      _applyTabularFilters(keepSort: true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  Future<void> _reload({bool silent = false}) async {
    if (_reloading) return;
    _reloading = true;

    try {
      final data = await TabularApi.fetchPeopleMapRepresentation(force: true);
      if (!mounted) return;

      final meId = widget.currentPersonId;
      final newAll = data.items.where((p) => p.id != meId).toList();

      setState(() {
        _listPerson = data;
        _allPeople = List<Person>.from(newAll);
        _error = null;
        _loading = false;
      });

      // ✅ met à jour domaines + applique filtres
      _recomputeAgeDomainFromAllPeople();

      // ✅ si on n’avait pas encore init pays (rare), on init.
      if (_selectedCountries.isEmpty) {
        _selectedCountries.addAll(_countryOptions);
      } else {
        // ✅ optionnel : retire les pays qui n’existent plus dans le dataset
        final opts = _countryOptions.toSet();
        _selectedCountries.removeWhere((c) => !opts.contains(c));
        // ✅ si tout est devenu vide, on remet tout (pour éviter 0 résultat “involontaire”)
        if (_selectedCountries.isEmpty) {
          _selectedCountries.addAll(opts);
        }
      }

      _applyTabularFilters(keepSort: true);
    } catch (e) {
      if (!mounted) return;
      if (!silent) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
      _error = e;
    } finally {
      _reloading = false;
    }
  }

  Future<void> _loadCountriesIfNeeded() async {
    final loc = Localizations.localeOf(context).languageCode.toLowerCase();
    if (_countriesLocale == loc && _countriesByCode.isNotEmpty) return;

    try {
      final map = await TabularApi.fetchCountriesTranslated(locale: loc);
      if (!mounted) return;
      setState(() {
        _countriesLocale = loc;
        _countriesByCode = map;
      });

      // Si on trie sur pays, re-trier sur libellé traduit
      if (_sortColumnIndex == 4) {
        _applySort(4, _sortAscending);
      }
    } catch (_) {
      // fallback silencieux
    }
  }

  // ---------------------------------------------------------------------------
  // Labels
  // ---------------------------------------------------------------------------

  String _countryLabel(Person p) {
    final code = (p.countryCode ?? '').trim();
    if (code.isNotEmpty) {
      final translated = _countriesByCode[code.toUpperCase()];
      if (translated != null && translated.trim().isNotEmpty) {
        return translated.trim();
      }
    }
    final raw = p.country?.trim();
    return (raw?.isNotEmpty == true) ? raw! : '—';
  }

  String _pseudo(Person p) {
    final raw = p.pseudo.trim();
    return raw.isNotEmpty ? raw : '—';
  }

  String _cityLabel(Person p) {
    final raw = p.city?.trim();
    return (raw?.isNotEmpty == true) ? raw! : '—';
  }

  String _genotypeLabel(AppLocalizations l10n, Person p) {
    final g = (p.genotype ?? '').trim().toLowerCase();
    if (g.isEmpty) return '—';

    if (g.contains('dél') || g.contains('del') || g.contains('deletion')) {
      return l10n.genotypeDeletion;
    }
    if (g.contains('mut')) return l10n.genotypeMutation;
    if (g.contains('upd')) return l10n.genotypeUpd;
    if (g.contains('icd')) return l10n.genotypeIcd;
    if (g.contains('clin')) return l10n.genotypeClinical;
    if (g.contains('mosa')) return l10n.genotypeMosaic;

    return p.genotype!.trim();
  }

  // ---------------------------------------------------------------------------
  // TRI
  // ---------------------------------------------------------------------------

  void _applySort(int columnIndex, bool ascending) {
    final l10n = AppLocalizations.of(context)!;

    int cmpNullable<T extends Comparable>(T? a, T? b) {
      if (a == null && b == null) return 0;
      if (a == null) return 1;
      if (b == null) return -1;
      return a.compareTo(b);
    }

    int cmpString(String a, String b) =>
        a.toLowerCase().compareTo(b.toLowerCase());

    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;

      _view.sort((a, b) {
        int res = 0;

        switch (columnIndex) {
          case 1:
            res = cmpString(_pseudo(a), _pseudo(b));
            break;
          case 2:
            res = cmpNullable<int>(a.age, b.age);
            break;
          case 3:
            res = cmpString(_genotypeLabel(l10n, a), _genotypeLabel(l10n, b));
            break;
          case 4:
            res = cmpString(_countryLabel(a), _countryLabel(b));
            break;
          case 5:
            res = cmpString(_cityLabel(a), _cityLabel(b));
            break;
          default:
            res = 0;
        }

        return ascending ? res : -res;
      });
    });
  }

  // ---------------------------------------------------------------------------
  // ✅ Compose modal ROBUSTE (controller géré dans un StatefulWidget dédié)
  // ---------------------------------------------------------------------------

  Future<void> _openComposeMessageSheet(Person p) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      useRootNavigator: true,
      builder: (_) => _ComposeMessageSheet(
        person: p,
        displayName: _pseudo(p),
        currentPersonId: widget.currentPersonId,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Photo plein écran
  // ---------------------------------------------------------------------------

  void _openPersonPhotoFullScreen(Person p) {
    final l10n = AppLocalizations.of(context)!;

    final url = personPhotoUrl(p.id);

    final pseudo = _pseudo(p);
    final ageLabel = (p.age == null) ? '—' : l10n.mapPersonTileAge(p.age!);
    final genotype = _genotypeLabel(l10n, p);

    final country = _countryLabel(p);
    final city = _cityLabel(p);

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
      transitionBuilder: (ctx, anim, _, child) =>
          FadeTransition(opacity: anim, child: child),
    );
  }

  // Avatar + dot
  Widget _photoCell(Person p) {
    final url = personPhotoUrl(p.id);
    return _PeoplePhotoAvatarWithStatus(
      url: url,
      isConnected: p.isConnected,
      onTap: () => _openPersonPhotoFullScreen(p),
    );
  }

  // ---------------------------------------------------------------------------
  // ✅ Filtres (bar + sheet)
  // ---------------------------------------------------------------------------

  List<String> get _countryOptions {
    final set = <String>{};
    for (final p in _allPeople) {
      final c = (p.countryCode ?? '').trim().toUpperCase();
      if (c.length == 2) set.add(c);
    }
    final list = set.toList()
      ..sort(
        (a, b) => _countryLabelForIso2(
          a,
        ).toLowerCase().compareTo(_countryLabelForIso2(b).toLowerCase()),
      );
    return list;
  }

  String _countryLabelForIso2(String iso2) {
    final code = iso2.trim().toUpperCase();
    final translated = _countriesByCode[code];
    return (translated == null || translated.trim().isEmpty)
        ? code
        : translated.trim();
  }

  void _recomputeAgeDomainFromAllPeople() {
    final ages = _allPeople.map((p) => p.age).whereType<int>().toList()..sort();
    if (ages.isEmpty) {
      _datasetMinAge = null;
      _datasetMaxAge = null;
      return;
    }
    _datasetMinAge = ages.first;
    _datasetMaxAge = ages.last;
    _selectedMinAge ??= _datasetMinAge;
    _selectedMaxAge ??= _datasetMaxAge;
  }

  void _applyTabularFilters({bool keepSort = true}) {
    bool matchesGenotype(Person p) {
      if (_selectedGenotypes.isEmpty) return true;
      final g = (p.genotype ?? '').trim();
      if (g.isEmpty) return false;

      final norm = g.toLowerCase();

      for (final sel in _selectedGenotypes) {
        final s = sel.trim().toLowerCase();

        // matching “souple”
        if (norm.contains('deletion') &&
            (s.contains('dél') || s.contains('del'))) {
          return true;
        }
        if ((norm.contains('dél') || norm.contains('del')) &&
            s.contains('dél')) {
          return true;
        }

        if (norm.contains(s) || s.contains(norm)) return true;
      }
      return false;
    }

    bool matchesCountry(Person p) {
      if (_selectedCountries.isEmpty) return true;
      final code = (p.countryCode ?? '').trim().toUpperCase();
      if (code.length != 2) return false;
      return _selectedCountries.contains(code);
    }

    bool matchesConnected(Person p) {
      if (!_connectedOnly) return true;
      return p.isConnected;
    }

    bool matchesAge(Person p) {
      if (_selectedMinAge == null || _selectedMaxAge == null) return true;
      final a = p.age;
      if (a == null) return false;
      return a >= _selectedMinAge! && a <= _selectedMaxAge!;
    }

    final filtered = _allPeople.where((p) {
      return matchesGenotype(p) &&
          matchesCountry(p) &&
          matchesConnected(p) &&
          matchesAge(p);
    }).toList();

    setState(() {
      _view = filtered;
    });

    if (keepSort && _sortColumnIndex != null) {
      _applySort(_sortColumnIndex!, _sortAscending);
    }
  }

  void _resetTabularFiltersToDefault() {
    _selectedGenotypes
      ..clear()
      ..addAll(kTabularGenotypeOptions);

    _selectedCountries
      ..clear()
      ..addAll(_countryOptions);

    _connectedOnly = false;

    _selectedMinAge = _datasetMinAge;
    _selectedMaxAge = _datasetMaxAge;

    _applyTabularFilters();
  }

  String _tabularFiltersTooltipText(BuildContext ctx) {
    final l10n = AppLocalizations.of(ctx)!;

    final genoActive =
        _selectedGenotypes.length != kTabularGenotypeOptions.length;
    final genoPart = genoActive
        ? l10n.mapGenotypeCount(_selectedGenotypes.length)
        : null;

    final opts = _countryOptions;
    final countryActive =
        opts.isNotEmpty &&
        _selectedCountries.isNotEmpty &&
        _selectedCountries.length != opts.length;
    final countryPart = countryActive
        ? l10n.mapCountriesSelectedCount(_selectedCountries.length)
        : null;

    final ageActive =
        _datasetMinAge != null &&
        _datasetMaxAge != null &&
        _selectedMinAge != null &&
        _selectedMaxAge != null &&
        (_selectedMinAge != _datasetMinAge ||
            _selectedMaxAge != _datasetMaxAge);
    final agePart = ageActive
        ? l10n.mapAgeRangeYears(
            (_selectedMinAge ?? '?').toString(),
            (_selectedMaxAge ?? '?').toString(),
          )
        : null;

    final connectedPart = _connectedOnly ? l10n.mapConnectedOnlyChip : null;

    final parts = [
      genoPart,
      countryPart,
      agePart,
      connectedPart,
    ].whereType<String>().toList();

    return parts.isEmpty ? l10n.mapNoFilters : parts.join(' • ');
  }

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

  Future<void> _openTabularFiltersSheet() async {
    await _loadCountriesIfNeeded();
    _recomputeAgeDomainFromAllPeople();

    bool localConnectedOnly = _connectedOnly;
    final tempCountries = Set<String>.from(_selectedCountries);
    final tempGenos = Set<String>.from(_selectedGenotypes);

    int? localMin = _selectedMinAge ?? _datasetMinAge;
    int? localMax = _selectedMaxAge ?? _datasetMaxAge;

    int countResultsWithLocalFilters() {
      int count = 0;

      for (final p in _allPeople) {
        // geno
        if (tempGenos.isNotEmpty) {
          final g = (p.genotype ?? '').trim();
          if (g.isEmpty) continue;

          final norm = g.toLowerCase();
          bool ok = false;
          for (final sel in tempGenos) {
            final s = sel.toLowerCase();
            if (norm.contains(s) || s.contains(norm)) {
              ok = true;
              break;
            }
            if (norm.contains('deletion') &&
                (s.contains('dél') || s.contains('del'))) {
              ok = true;
              break;
            }
          }
          if (!ok) continue;
        }

        // country
        if (tempCountries.isNotEmpty) {
          final code = (p.countryCode ?? '').trim().toUpperCase();
          if (code.length != 2 || !tempCountries.contains(code)) continue;
        }

        // connected
        if (localConnectedOnly && !p.isConnected) continue;

        // age
        // age
        final minA = localMin;
        final maxA = localMax;
        if (minA != null && maxA != null) {
          final a = p.age;
          if (a == null || a < minA || a > maxA) continue;
        }

        count++;
      }

      return count;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final l10n = AppLocalizations.of(ctx)!;

            final hasAges = _datasetMinAge != null && _datasetMaxAge != null;
            final minAge = _datasetMinAge ?? 0;
            final maxAge = _datasetMaxAge ?? 0;

            if (hasAges) {
              localMin = (localMin ?? minAge).clamp(minAge, maxAge);
              localMax = (localMax ?? maxAge).clamp(minAge, maxAge);
              if (localMin! > localMax!) {
                localMin = minAge;
                localMax = maxAge;
              }
            } else {
              localMin = null;
              localMax = null;
            }

            final resultsCount = countResultsWithLocalFilters();
            final sortedCountryOptions = _countryOptions;

            return SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  bottom: 16 + MediaQuery.of(ctx).viewInsets.bottom,
                  top: 16,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(ctx).size.height * 0.85,
                  ),
                  child: ListView(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.tune),
                          const SizedBox(width: 8),
                          Text(
                            l10n.mapFiltersButtonTooltip,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),

                      // Compteur live
                      Padding(
                        padding: const EdgeInsets.only(top: 6, bottom: 12),
                        child: Row(
                          children: [
                            Icon(
                              resultsCount > 0
                                  ? Icons.people
                                  : Icons.warning_amber_rounded,
                              size: 18,
                              color: resultsCount > 0
                                  ? Colors.black54
                                  : Colors.orange,
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
                      ),

                      // Connectés
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          l10n.mapConnectionSectionTitle,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(l10n.mapConnectedOnlyLabel),
                        value: localConnectedOnly,
                        onChanged: (v) =>
                            setModalState(() => localConnectedOnly = v),
                      ),

                      const SizedBox(height: 16),

                      // Pays
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          l10n.mapCountryTitle,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Theme(
                        data: Theme.of(
                          ctx,
                        ).copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          tilePadding: EdgeInsets.zero,
                          title: Text(
                            tempCountries.length == sortedCountryOptions.length
                                ? l10n.mapAllCountriesSelected
                                : l10n.mapCountriesSelectedCount(
                                    tempCountries.length,
                                  ),
                          ),
                          children: [
                            Row(
                              children: [
                                TextButton(
                                  onPressed: () => setModalState(() {
                                    tempCountries
                                      ..clear()
                                      ..addAll(sortedCountryOptions);
                                  }),
                                  child: Text(l10n.mapSelectAll),
                                ),
                                TextButton(
                                  onPressed: () => setModalState(
                                    () => tempCountries.clear(),
                                  ),
                                  child: Text(l10n.mapClear),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ...sortedCountryOptions.map((iso2) {
                              final checked = tempCountries.contains(iso2);
                              return CheckboxListTile(
                                value: checked,
                                title: Text(_countryLabelForIso2(iso2)),
                                dense: true,
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                onChanged: (v) {
                                  setModalState(() {
                                    if (v == true) {
                                      tempCountries.add(iso2);
                                    } else {
                                      tempCountries.remove(iso2);
                                    }
                                  });
                                },
                              );
                            }),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Génotypes
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          l10n.mapGenotypeTitle,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(height: 6),
                      ...kTabularGenotypeOptions.map((g) {
                        final checked = tempGenos.contains(g);
                        return CheckboxListTile(
                          value: checked,
                          title: Text(_genoLabel(ctx, g)),
                          dense: true,
                          controlAffinity: ListTileControlAffinity.leading,
                          onChanged: (v) {
                            setModalState(() {
                              if (v == true) {
                                tempGenos.add(g);
                              } else {
                                tempGenos.remove(g);
                              }
                            });
                          },
                        );
                      }),

                      const SizedBox(height: 16),

                      // Âge
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          l10n.mapAgeTitle,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
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
                            Text(l10n.mapMinValue(localMin!)),
                            Text(l10n.mapMaxValue(localMax!)),
                          ],
                        ),
                        RangeSlider(
                          values: RangeValues(
                            localMin!.toDouble(),
                            localMax!.toDouble(),
                          ),
                          min: minAge.toDouble(),
                          max: maxAge.toDouble(),
                          divisions: (maxAge - minAge) > 0
                              ? (maxAge - minAge)
                              : null,
                          labels: RangeLabels(
                            localMin!.toString(),
                            localMax!.toString(),
                          ),
                          onChanged: (rng) {
                            setModalState(() {
                              localMin = rng.start.round();
                              localMax = rng.end.round();
                            });
                          },
                        ),
                      ],

                      const SizedBox(height: 12),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            child: Text(l10n.mapReset),
                            onPressed: () => setModalState(() {
                              localConnectedOnly = false;
                              tempGenos
                                ..clear()
                                ..addAll(kTabularGenotypeOptions);
                              tempCountries
                                ..clear()
                                ..addAll(sortedCountryOptions);

                              if (hasAges) {
                                localMin = minAge;
                                localMax = maxAge;
                              } else {
                                localMin = null;
                                localMax = null;
                              }
                            }),
                          ),
                          const SizedBox(width: 8),
                          TextButton(
                            child: Text(l10n.mapCancel),
                            onPressed: () => Navigator.of(ctx).pop(),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.check),
                            label: Text(l10n.mapApply),
                            onPressed: () {
                              _connectedOnly = localConnectedOnly;

                              _selectedGenotypes
                                ..clear()
                                ..addAll(tempGenos);

                              _selectedCountries
                                ..clear()
                                ..addAll(tempCountries);

                              _selectedMinAge = localMin;
                              _selectedMaxAge = localMax;

                              Navigator.of(ctx).pop();
                              _applyTabularFilters();
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Text('Error: $_error'));
    if (_view.isEmpty) {
      // ✅ même quand vide, on laisse pull-to-refresh + filtres
      return RefreshIndicator(
        onRefresh: () async {
          await _loadCountriesIfNeeded();
          await _reload(silent: false);
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            _filtersBar(l10n),
            const SizedBox(height: 24),
            const Center(child: Text('—')),
          ],
        ),
      );
    }

    final pseudoMax = _maxPseudoWidth(context);
    final genotypeMax = _maxGenotypeWidth(context);
    final countryMax = _maxCountryWidth(context);
    final cityMax = _maxCityWidth(context);

    return RefreshIndicator(
      onRefresh: () async {
        await _loadCountriesIfNeeded();
        await _reload(silent: false);
      },
      child: LayoutBuilder(
        builder: (ctx, constraints) {
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              _filtersBar(l10n),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: DataTable(
                    showCheckboxColumn: false,
                    sortColumnIndex: _sortColumnIndex,
                    sortAscending: _sortAscending,
                    columnSpacing: 14,
                    headingRowHeight: 44,
                    dataRowMinHeight: 54,
                    dataRowMaxHeight: 64,
                    columns: [
                      const DataColumn(label: Text('')),
                      DataColumn(
                        label: Text(l10n.tabularColPseudo),
                        onSort: (i, asc) => _applySort(i, asc),
                      ),
                      DataColumn(
                        label: Text(l10n.tabularColAge),
                        numeric: true,
                        onSort: (i, asc) => _applySort(i, asc),
                      ),
                      DataColumn(
                        label: Text(l10n.tabularColGenotype),
                        onSort: (i, asc) => _applySort(i, asc),
                      ),
                      DataColumn(
                        label: Text(l10n.tabularColCountry),
                        onSort: (i, asc) => _applySort(i, asc),
                      ),
                      DataColumn(
                        label: Text(l10n.tabularColCity),
                        onSort: (i, asc) => _applySort(i, asc),
                      ),
                      DataColumn(label: Text(l10n.tabularColAction)),
                    ],
                    rows: _view.map((p) {
                      final pseudo = _pseudo(p);
                      final ageLabel = (p.age == null)
                          ? '—'
                          : l10n.mapPersonTileAge(p.age!);
                      final genotype = _genotypeLabel(l10n, p);
                      final country = _countryLabel(p);
                      final city = _cityLabel(p);

                      return DataRow(
                        onSelectChanged: (_) => _openComposeMessageSheet(p),
                        cells: [
                          DataCell(_photoCell(p)),
                          DataCell(
                            _ellipsisCell(
                              pseudo,
                              maxWidth: pseudoMax,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          DataCell(Text(ageLabel)),
                          DataCell(
                            _ellipsisCell(genotype, maxWidth: genotypeMax),
                          ),
                          DataCell(
                            _ellipsisCell(country, maxWidth: countryMax),
                          ),
                          DataCell(_ellipsisCell(city, maxWidth: cityMax)),
                          DataCell(
                            IconButton(
                              tooltip: l10n.tabularSendMessageTooltip,
                              icon: const Icon(Icons.send),
                              onPressed: () => _openComposeMessageSheet(p),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }

  Widget _filtersBar(AppLocalizations l10n) {
    final tooltip = _tabularFiltersTooltipText(context);
    final tableLabel = _tableResultsLabel(l10n);

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
      child: Row(
        children: [
          Tooltip(
            message: tooltip,
            child: OutlinedButton.icon(
              onPressed: _openTabularFiltersSheet,
              icon: const Icon(Icons.tune),
              label: Text(l10n.mapFiltersButtonTooltip),
            ),
          ),
          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  tableLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  tooltip,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            tooltip: l10n.mapReset,
            onPressed: _resetTabularFiltersToDefault,
            icon: const Icon(Icons.restart_alt),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// ✅ BottomSheet dédiée => controller dispose uniquement au bon moment
// + envoie + ouvre le chat (même comportement que la carto)
// ============================================================================

class _ComposeMessageSheet extends StatefulWidget {
  final Person person;
  final String displayName;
  final int currentPersonId;

  const _ComposeMessageSheet({
    required this.person,
    required this.displayName,
    required this.currentPersonId,
  });

  @override
  State<_ComposeMessageSheet> createState() => _ComposeMessageSheetState();
}

class _ComposeMessageSheetState extends State<_ComposeMessageSheet> {
  late final TextEditingController _controller;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _cancel() {
    if (_sending) return;
    Navigator.of(context).pop();
  }

  Future<void> _send() async {
    if (_sending) return;

    final msg = _controller.text.trim();
    if (msg.isEmpty) return;

    setState(() => _sending = true);

    try {
      final meId = widget.currentPersonId;
      final otherId = widget.person.id;

      final conv = await TabularApi.createOrGetPrivateConversation(
        payload: <String, dynamic>{
          "p1_id": meId,
          "p2_id": otherId,
          "title": "Conversation ${widget.displayName}",
        },
      );

      final convId = conv.id;

      await ConversationApi.sendMessage(
        conversationId: convId,
        senderPeopleId: meId,
        bodyText: msg,
      );

      if (!mounted) return;

      _controller.clear();
      ConversationEvents.bump();

      final nav = Navigator.of(context, rootNavigator: true);
      nav.pop();

      Future.microtask(() {
        nav.push(
          MaterialPageRoute(
            builder: (_) =>
                ChatPage(conversationId: convId, currentPersonId: meId),
          ),
        );
      });
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;

      ScaffoldMessenger.of(
        Navigator.of(context, rootNavigator: true).context,
      ).showSnackBar(
        SnackBar(content: Text(l10n.mapPersonTileSendFailed(e.toString()))),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      top: false,
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.only(bottom: bottomInset),
        child: LayoutBuilder(
          builder: (ctx, c) {
            final maxH = MediaQuery.of(ctx).size.height * 0.60;

            return ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxH),
              child: Material(
                color: Colors.transparent,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              l10n.tabularSendMessageTitle(widget.displayName),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: l10n.close,
                            icon: const Icon(Icons.close),
                            onPressed: _sending ? null : _cancel,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _controller,
                        autofocus: true,
                        minLines: 2,
                        maxLines: 8,
                        textInputAction: TextInputAction.newline,
                        decoration: InputDecoration(
                          hintText: l10n.tabularSendMessageHint,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          TextButton(
                            onPressed: _sending ? null : _cancel,
                            child: Text(l10n.tabularSendMessageCancel),
                          ),
                          const Spacer(),
                          ElevatedButton.icon(
                            onPressed: _sending ? null : _send,
                            icon: _sending
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.send),
                            label: Text(l10n.tabularSendMessageSend),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Dot + avatar
// -----------------------------------------------------------------------------

class _StatusDot extends StatelessWidget {
  const _StatusDot({
    required this.isOnline,
    required this.tooltipOnline,
    required this.tooltipOffline,
    this.size = 12,
  });

  final bool isOnline;
  final String tooltipOnline;
  final String tooltipOffline;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: isOnline ? tooltipOnline : tooltipOffline,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isOnline ? Colors.green : Colors.red,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 3,
              offset: Offset(0, 1),
            ),
          ],
        ),
      ),
    );
  }
}

class _PeoplePhotoAvatarWithStatus extends StatelessWidget {
  final String url;
  final bool isConnected;
  final VoidCallback? onTap;

  const _PeoplePhotoAvatarWithStatus({
    required this.url,
    required this.isConnected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const double radius = 18;
    final box = radius * 2;

    final dotSize = (radius * 0.55).clamp(10.0, 14.0).toDouble();
    final dotPadding = (radius * 0.12).clamp(1.0, 4.0).toDouble();

    final l10n = AppLocalizations.of(context)!;

    return SizedBox(
      width: box,
      height: box,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Align(
            alignment: Alignment.center,
            child: InkWell(
              onTap: onTap,
              customBorder: const CircleBorder(),
              child: ClipOval(
                child: Image.network(
                  url,
                  headers: const {'X-App-Key': publicAppKey},
                  width: box,
                  height: box,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: box,
                    height: box,
                    color: Colors.grey.shade200,
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.person,
                      size: 20,
                      color: Colors.black45,
                    ),
                  ),
                  loadingBuilder: (ctx, child, prog) {
                    if (prog == null) return child;
                    return Container(
                      width: box,
                      height: box,
                      color: Colors.grey.shade200,
                      alignment: Alignment.center,
                      child: const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          Positioned(
            right: dotPadding,
            top: dotPadding,
            child: _StatusDot(
              isOnline: isConnected,
              size: dotSize,
              tooltipOnline: l10n.statusOnline,
              tooltipOffline: l10n.statusOffline,
            ),
          ),
        ],
      ),
    );
  }
}
