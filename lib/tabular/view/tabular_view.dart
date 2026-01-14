// lib/tabular/view/tabular_view.dart
import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../l10n/app_localizations.dart';
import '../../whatsApp/services/conversation_api.dart'
    show personPhotoUrl, publicAppKey;
import '../models/listPerson.dart';
import '../models/person.dart';
import '../services/tabular_api.dart';

class TabularView extends StatefulWidget {
  final int currentPersonId;
  const TabularView({super.key, required this.currentPersonId});

  @override
  State<TabularView> createState() => _TabularViewState();
}

class _TabularViewState extends State<TabularView> with WidgetsBindingObserver {
  //ListPerson? _listPerson;
  bool _loading = true;
  Object? _error;

  Map<String, String> _countriesByCode = {};
  String? _countriesLocale;

  // ✅ Tri
  int? _sortColumnIndex;
  bool _sortAscending = true;

  List<Person> _view = const <Person>[];

  // ✅ polling (refresh régulier des statuts)
  Timer? _pollTimer;
  bool _pollingEnabled = true;
  bool _reloading = false;
  static const Duration _pollInterval = Duration(seconds: 15);

  @override
  void initState() {
    super.initState();
    //WidgetsBinding.instance.addObserver(this);

    _loadPeople();
    _startPolling();
  }

  @override
  void dispose() {
    _stopPolling();
    //WidgetsBinding.instance.removeObserver(this);
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
      _pollingEnabled = true;
      _startPolling();
      _reload(silent: true);
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      _pollingEnabled = false;
      _stopPolling();
    }
  }

  void _startPolling() {
    if (!_pollingEnabled) return;
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
      final data = await TabularApi.fetchPeopleMapRepresentation(force: false);
      if (!mounted) return;

      setState(() {
        //_listPerson = data;
        _view = data.items
            .where((p) => p.id != widget.currentPersonId)
            .toList();
        _loading = false;
        _error = null;
      });

      if (_sortColumnIndex != null) {
        _applySort(_sortColumnIndex!, _sortAscending);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  // signature pour éviter setState si rien n’a changé (ex: dots)
  int _sig(List<Person> list) {
    int s = list.length;
    for (final p in list) {
      s = (s * 31) ^ p.id;
      s = (s * 31) ^ (p.age ?? 0);
      s = (s * 31) ^ ((p.city ?? '').hashCode);
      s = (s * 31) ^ ((p.countryCode ?? '').hashCode);
      s = (s * 31) ^ ((p.genotype ?? '').hashCode);

      // ✅ TRÈS IMPORTANT : inclure le statut
      s = (s * 31) ^ (p.isConnected ? 1 : 0);
    }
    return s;
  }

  Future<void> _reload({bool silent = false}) async {
    if (_reloading) return;
    _reloading = true;

    try {
      final data = await TabularApi.fetchPeopleMapRepresentation(force: true);
      if (!mounted) return;

      final int currentPersonId = widget.currentPersonId;

      final newView = data.items.where((p) => p.id != currentPersonId).toList();

      // ✅ logs utiles
      final onlineCount = newView.where((p) => p.isConnected).length;
      debugPrint(
        '[TABULAR] reload: online=$onlineCount / total=${newView.length}',
      );
      debugPrint(
        '[TABULAR] visible=${newView.length} (excluding me=$currentPersonId)',
      );

      final oldSig = _sig(_view);
      final newSig = _sig(newView);

      if (oldSig != newSig) {
        setState(() {
          //_listPerson = data;
          _view = newView;
          _error = null;
          _loading = false;
        });

        // si tri actif, retrier après refresh
        if (_sortColumnIndex != null) {
          _applySort(_sortColumnIndex!, _sortAscending);
        }
      }
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

      if (_sortColumnIndex == 4) {
        _applySort(4, _sortAscending);
      }
    } catch (_) {
      // fallback silencieux
    }
  }

  String _countryLabel(Person p) {
    final code = (p.countryCode ?? '').trim();
    if (code.isNotEmpty) {
      final translated = _countriesByCode[code];
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
  // 🔽 TRI
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
  // ✉️ Action "Envoyer un message"
  // ---------------------------------------------------------------------------

  void _sendMessage(Person p) {
    final l10n = AppLocalizations.of(context)!;

    final id = p.id;
    if (id == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.tabularSendMessageErrorNoId)));
      return;
    }

    // ✅ À brancher sur ton flow conversation
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.tabularSendMessageActionStub)));
  }

  // ---------------------------------------------------------------------------
  // 🖼️ Photo plein écran
  // ---------------------------------------------------------------------------

  void _openPersonPhotoFullScreen(Person p) {
    final l10n = AppLocalizations.of(context)!;

    final id = p.id ?? -1;
    final url = personPhotoUrl(id);

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
      transitionBuilder: (ctx, anim, _, child) =>
          FadeTransition(opacity: anim, child: child),
    );
  }

  // ---------------------------------------------------------------------------
  // 🧩 Avatar photo + dot (TOP RIGHT) rouge/vert
  // ---------------------------------------------------------------------------

  Widget _photoCell(Person p) {
    final isOnline = (p.isConnected == true);

    return _PeoplePhotoAvatarWithStatus(
      peopleId: p.id,
      radius: 18,
      isOnline: isOnline, // rouge/vert
      onTap: () => _openPersonPhotoFullScreen(p),
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
    if (_view.isEmpty) return const Center(child: Text('—'));

    final pseudoMax = _maxPseudoWidth(context);
    final genotypeMax = _maxGenotypeWidth(context);
    final countryMax = _maxCountryWidth(context);
    final cityMax = _maxCityWidth(context);

    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          _loading = true;
          _error = null;
        });
        await _loadCountriesIfNeeded();
        await _reload(silent: false);
      },
      child: LayoutBuilder(
        builder: (ctx, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SingleChildScrollView(
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
                    const DataColumn(label: Text('')), // photo
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
                      onSelectChanged: (_) => _openPersonPhotoFullScreen(p),
                      cells: [
                        DataCell(_photoCell(p)),
                        DataCell(
                          _ellipsisCell(
                            pseudo,
                            maxWidth: pseudoMax,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                        DataCell(Text(ageLabel)),
                        DataCell(
                          _ellipsisCell(genotype, maxWidth: genotypeMax),
                        ),
                        DataCell(_ellipsisCell(country, maxWidth: countryMax)),
                        DataCell(_ellipsisCell(city, maxWidth: cityMax)),
                        DataCell(
                          IconButton(
                            tooltip: l10n.tabularSendMessageTooltip,
                            icon: const Icon(Icons.send),
                            onPressed: () => _sendMessage(p),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ============================================================================
// ✅ Avatar robuste : fetch bytes avec header X-App-Key => Image.memory (comme conv)
// ============================================================================

class _PeoplePhotoAvatar extends StatefulWidget {
  const _PeoplePhotoAvatar({
    required this.peopleId,
    required this.radius,
    this.onTap,
  });

  final int? peopleId;
  final double radius;
  final VoidCallback? onTap;

  @override
  State<_PeoplePhotoAvatar> createState() => _PeoplePhotoAvatarState();
}

class _PeoplePhotoAvatarState extends State<_PeoplePhotoAvatar> {
  static final Map<int, Uint8List> _memCache = {};
  Future<Uint8List?>? _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void didUpdateWidget(covariant _PeoplePhotoAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.peopleId != widget.peopleId) {
      _future = _load();
    }
  }

  Future<Uint8List?> _load() async {
    final id = widget.peopleId;
    if (id == null) return null;

    final cached = _memCache[id];
    if (cached != null) return cached;

    final url = personPhotoUrl(id);

    final resp = await http.get(
      Uri.parse(url),
      headers: {'X-App-Key': publicAppKey},
    );

    if (resp.statusCode == 200 && resp.bodyBytes.isNotEmpty) {
      _memCache[id] = resp.bodyBytes;
      return resp.bodyBytes;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.radius;

    Widget avatarFallback({Widget? child}) => CircleAvatar(
      radius: r,
      backgroundColor: Colors.grey.shade200,
      child: child ?? const Icon(Icons.person, color: Colors.black54),
    );

    final id = widget.peopleId;
    if (id == null) return avatarFallback(child: const Icon(Icons.group));

    return GestureDetector(
      onTap: widget.onTap,
      child: FutureBuilder<Uint8List?>(
        future: _future,
        builder: (ctx, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return avatarFallback(
              child: const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }

          final bytes = snap.data;
          if (bytes == null) return avatarFallback();

          return CircleAvatar(
            radius: r,
            backgroundColor: Colors.grey.shade200,
            backgroundImage: MemoryImage(bytes),
          );
        },
      ),
    );
  }
}

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
  const _PeoplePhotoAvatarWithStatus({
    required this.peopleId,
    required this.radius,
    required this.isOnline,
    this.onTap,
  });

  final int? peopleId;
  final double radius;
  final bool isOnline;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
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
            child: _PeoplePhotoAvatar(
              peopleId: peopleId,
              radius: radius,
              onTap: onTap,
            ),
          ),
          Positioned(
            right: dotPadding,
            top: dotPadding,
            child: _StatusDot(
              isOnline: isOnline,
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
