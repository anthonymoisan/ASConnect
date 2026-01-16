// lib/tabular/view/tabular_view.dart
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../l10n/app_localizations.dart';
import '../../whatsApp/services/conversation_api.dart'
    show personPhotoUrl, publicAppKey, ConversationApi;
import '../../whatsApp/services/conversation_events.dart';
import '../../whatsApp/screens/chat_page.dart';

import '../models/listPerson.dart';
import '../models/person.dart';
import '../services/tabular_api.dart';

// ✅ Filters logic lives here (single source of truth)
part 'tabular_view_filters.dart';

// -----------------------------------------------------------------------------
// Simple timing helper for console logs
// -----------------------------------------------------------------------------
Future<T> logTimed<T>(String label, Future<T> Function() fn) async {
  final sw = Stopwatch()..start();
  debugPrint('⏱️ START $label');
  try {
    final res = await fn();
    sw.stop();
    debugPrint('✅ END $label — ${sw.elapsedMilliseconds} ms');
    return res;
  } catch (e, st) {
    sw.stop();
    debugPrint('❌ FAIL $label — ${sw.elapsedMilliseconds} ms — $e');
    debugPrint('$st');
    rethrow;
  }
}

/// Options génotypes (familles UI)
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

  // Guards against double calls
  bool _loadingCountries = false;
  bool _loadingPeople = false;

  // ✅ Tri
  int? _sortColumnIndex;
  bool _sortAscending = true;

  // ✅ Vue filtrée affichée
  List<Person> _view = const <Person>[];

  // ✅ Dataset complet (hors "moi"), base pour filtres
  List<Person> _allPeople = const <Person>[];

  // ✅ Filtres (état) — utilisés par tabular_view_filters.dart
  final Set<String> _selectedGenotypes = <String>{...kTabularGenotypeOptions};
  final Set<String> _selectedCountries = <String>{};
  bool _connectedOnly = false;
  int? _selectedMinAge;
  int? _selectedMaxAge;
  int? _datasetMinAge;
  int? _datasetMaxAge;

  // ✅ Distance filter (mobile + web)
  bool _distanceFilterEnabled = false;
  double? _distanceOriginLat;
  double? _distanceOriginLng;
  double? _maxDistanceKm; // ex 100.0

  // ✅ Poll refresh status
  Timer? _pollTimer;
  bool _reloading = false;

  // ✅ You set it to 60s
  static const Duration _pollInterval = Duration(seconds: 60);

  // ----------------------------
  // Options pays (source: dataset)
  // Optimisation: on ne recalculera que si dataset change.
  // ----------------------------
  int _countryOptionsCacheHash = 0;
  List<String> _countryOptionsCache = const <String>[];

  // ---------------------------------------------------------------------------
  // "Table" layout constants
  // ---------------------------------------------------------------------------
  static const double _gap = 12;
  static const double _gapAgeGenotype = 22; // ✅ bigger gap between Age/Genotype
  static const double _avatarCol = 56;
  static const double _ageCol = 72;
  static const double _actionCol = 64;

  static const double _headerHeight = 46;
  static const double _filtersHeight = 72;

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
    // Évite setState() pendant build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadCountriesIfNeeded();
    });
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
  // ✅ Location helpers (mobile + web)
  // ---------------------------------------------------------------------------

  Future<bool> _ensureLocation() async {
    try {
      // Sur web, certains appels peuvent throw -> on reste permissif.
      try {
        final serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) return false;
      } catch (_) {
        // ignore (web)
      }

      try {
        var perm = await Geolocator.checkPermission();
        if (perm == LocationPermission.denied) {
          perm = await Geolocator.requestPermission();
        }
        if (perm == LocationPermission.denied ||
            perm == LocationPermission.deniedForever) {
          return false;
        }
      } catch (_) {
        // Sur web, le navigateur gère le prompt; on continue.
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: const Duration(seconds: 8),
      );

      _distanceOriginLat = pos.latitude;
      _distanceOriginLng = pos.longitude;
      return true;
    } catch (_) {
      return false;
    }
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
    if (_loadingPeople) return;
    _loadingPeople = true;

    try {
      final data = await logTimed(
        'TabularApi.fetchPeopleMapRepresentation (initial)',
        () => TabularApi.fetchPeopleMapRepresentation(),
      );
      debugPrint('📦 People loaded: ${data.items.length}');
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

      // ✅ init filtres (pays/âge) puis applique — via le part
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
    } finally {
      _loadingPeople = false;
    }

    // Logs debug dataset
    debugPrint('TOTAL allPeople=${_allPeople.length}');
    debugPrint(
      'missing genotype=${_allPeople.where((p) => (p.genotype ?? "").trim().isEmpty).length}',
    );
    debugPrint(
      'invalid countryCode=${_allPeople.where((p) => (p.countryCode ?? "").trim().length != 2).length}',
    );
    debugPrint('missing age=${_allPeople.where((p) => p.age == null).length}');
  }

  Future<void> _reload({bool silent = false}) async {
    if (_reloading) return;
    _reloading = true;

    try {
      final data = await logTimed(
        'TabularApi.fetchPeopleMapRepresentation (reload force=true)',
        () => TabularApi.fetchPeopleMapRepresentation(force: true),
      );
      debugPrint('📦 People reloaded: ${data.items.length}');
      if (!mounted) return;

      final meId = widget.currentPersonId;
      final newAll = data.items.where((p) => p.id != meId).toList();

      setState(() {
        _listPerson = data;
        _allPeople = List<Person>.from(newAll);
        _error = null;
        _loading = false;
      });

      _recomputeAgeDomainFromAllPeople();

      // ✅ Pays: garde intersection, sinon reset "all"
      if (_selectedCountries.isEmpty) {
        _selectedCountries.addAll(_countryOptions);
      } else {
        final opts = _countryOptions.toSet();
        _selectedCountries.removeWhere((c) => !opts.contains(c));
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
    if (_loadingCountries) return;

    _loadingCountries = true;
    try {
      final map = await logTimed(
        'TabularApi.fetchCountriesTranslated locale=$loc',
        () => TabularApi.fetchCountriesTranslated(locale: loc),
      );
      debugPrint('🌍 Countries loaded: ${map.length}');
      if (!mounted) return;

      setState(() {
        _countriesLocale = loc;
        _countriesByCode = map;
      });

      if (_sortColumnIndex == 4) {
        _applySort(4, _sortAscending);
      }
    } catch (_) {
      // fallback silencieux
    } finally {
      _loadingCountries = false;
    }
  }

  // ---------------------------------------------------------------------------
  // Labels (hors filtres)
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
  // Compose modal (envoie + ouvre chat)
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
  // UI (virtualized table + pinned filter bar + pinned header)
  // ---------------------------------------------------------------------------

  Widget _headerCell(
    String label, {
    required int columnIndex,
    required VoidCallback onTap,
    bool numeric = false,
  }) {
    final isActive = _sortColumnIndex == columnIndex;
    final icon = isActive
        ? (_sortAscending ? Icons.arrow_upward : Icons.arrow_downward)
        : Icons.unfold_more;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
        child: Align(
          alignment: numeric ? Alignment.centerRight : Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: isActive ? Colors.black : Colors.black87,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Icon(icon, size: 14, color: Colors.black54),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tableHeader(AppLocalizations l10n, BuildContext context) {
    final pseudoW = _maxPseudoWidth(context) + 16;
    final genoW = _maxGenotypeWidth(context) + 16;
    final countryW = _maxCountryWidth(context) + 16;
    final cityW = _maxCityWidth(context) + 16;

    return Container(
      height: _headerHeight,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          const SizedBox(width: _avatarCol),
          const SizedBox(width: _gap),
          SizedBox(
            width: pseudoW,
            child: _headerCell(
              l10n.tabularColPseudo,
              columnIndex: 1,
              onTap: () =>
                  _applySort(1, _sortColumnIndex == 1 ? !_sortAscending : true),
            ),
          ),
          const SizedBox(width: _gap),
          SizedBox(
            width: _ageCol,
            child: _headerCell(
              l10n.tabularColAge,
              columnIndex: 2,
              numeric: true,
              onTap: () =>
                  _applySort(2, _sortColumnIndex == 2 ? !_sortAscending : true),
            ),
          ),
          const SizedBox(width: _gapAgeGenotype),
          SizedBox(
            width: genoW,
            child: _headerCell(
              l10n.tabularColGenotype,
              columnIndex: 3,
              onTap: () =>
                  _applySort(3, _sortColumnIndex == 3 ? !_sortAscending : true),
            ),
          ),
          const SizedBox(width: _gap),
          SizedBox(
            width: countryW,
            child: _headerCell(
              l10n.tabularColCountry,
              columnIndex: 4,
              onTap: () =>
                  _applySort(4, _sortColumnIndex == 4 ? !_sortAscending : true),
            ),
          ),
          const SizedBox(width: _gap),
          SizedBox(
            width: cityW,
            child: _headerCell(
              l10n.tabularColCity,
              columnIndex: 5,
              onTap: () =>
                  _applySort(5, _sortColumnIndex == 5 ? !_sortAscending : true),
            ),
          ),
          const SizedBox(width: _gap),
          SizedBox(
            width: _actionCol,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  l10n.tabularColAction,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _personRow(
    AppLocalizations l10n,
    BuildContext context,
    Person p,
    int i,
  ) {
    final pseudoMax = _maxPseudoWidth(context);
    final genotypeMax = _maxGenotypeWidth(context);
    final countryMax = _maxCountryWidth(context);
    final cityMax = _maxCityWidth(context);

    final pseudo = _pseudo(p);
    final ageLabel = (p.age == null) ? '—' : l10n.mapPersonTileAge(p.age!);
    final genotype = _genotypeLabel(l10n, p);
    final country = _countryLabel(p);
    final city = _cityLabel(p);

    final bg = (i.isEven) ? Colors.white : Colors.grey.shade50;

    return Material(
      color: bg,
      child: InkWell(
        onTap: () => _openComposeMessageSheet(p),
        child: Container(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              SizedBox(
                width: _avatarCol,
                child: Center(child: _photoCell(p)),
              ),
              const SizedBox(width: _gap),
              SizedBox(
                width: _maxPseudoWidth(context) + 16,
                child: _ellipsisCell(
                  pseudo,
                  maxWidth: pseudoMax,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: _gap),
              SizedBox(
                width: _ageCol,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(ageLabel),
                ),
              ),
              const SizedBox(width: _gapAgeGenotype),
              SizedBox(
                width: _maxGenotypeWidth(context) + 16,
                child: _ellipsisCell(genotype, maxWidth: genotypeMax),
              ),
              const SizedBox(width: _gap),
              SizedBox(
                width: _maxCountryWidth(context) + 16,
                child: _ellipsisCell(country, maxWidth: countryMax),
              ),
              const SizedBox(width: _gap),
              SizedBox(
                width: _maxCityWidth(context) + 16,
                child: _ellipsisCell(city, maxWidth: cityMax),
              ),
              const SizedBox(width: _gap),
              SizedBox(
                width: _actionCol,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    tooltip: l10n.tabularSendMessageTooltip,
                    icon: const Icon(Icons.send),
                    onPressed: () => _openComposeMessageSheet(p),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filtersBarPinned(AppLocalizations l10n) {
    final tooltip = _tabularFiltersTooltipText(context);
    final tableLabel = _tableResultsLabel(l10n);

    return Container(
      height: _filtersHeight,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
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
              mainAxisAlignment: MainAxisAlignment.center,
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Text('Error: $_error'));

    if (_view.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async {
          await _loadCountriesIfNeeded();
          await _reload(silent: false);
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            _filtersBarPinned(l10n),
            const SizedBox(height: 24),
            const Center(child: Text('—')),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await _loadCountriesIfNeeded();
        await _reload(silent: false);
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // ✅ Filters pinned (always visible)
          SliverPersistentHeader(
            pinned: true,
            delegate: _PinnedHeaderDelegate(
              height: _filtersHeight,
              child: _filtersBarPinned(l10n),
            ),
          ),

          // ✅ Columns pinned (always visible under filters)
          SliverPersistentHeader(
            pinned: true,
            delegate: _PinnedHeaderDelegate(
              height: _headerHeight,
              child: _tableHeader(l10n, context),
            ),
          ),

          // ✅ Virtualized rows
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) => _personRow(l10n, ctx, _view[i], i),
              childCount: _view.length,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

// ============================================================================
// ✅ Pinned header delegate
// ============================================================================
class _PinnedHeaderDelegate extends SliverPersistentHeaderDelegate {
  _PinnedHeaderDelegate({required this.child, required this.height});

  final Widget child;
  final double height;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Material(elevation: overlapsContent ? 2 : 0, child: child);
  }

  @override
  bool shouldRebuild(covariant _PinnedHeaderDelegate oldDelegate) {
    return oldDelegate.child != child || oldDelegate.height != height;
  }
}

// ============================================================================
// ✅ BottomSheet dédiée => controller dispose uniquement au bon moment
// + envoie + ouvre le chat
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
