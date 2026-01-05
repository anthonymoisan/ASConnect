// lib/mapCartoPeople/mapCartoPeople_state.dart
part of map_carto_people;

class _MapPeopleByCityState extends State<MapPeopleByCity>
    with AutomaticKeepAliveClientMixin<MapPeopleByCity> {
  @override
  bool get wantKeepAlive => true;

  final _map = MapController();

  // Vue initiale (France / Europe)
  final _initialCenter = const LatLng(48.8566, 2.3522);
  final double _initialZoom = 5.5;

  static const _userAgentPackageName = 'fr.asconnexion.app';

  bool _loading = false;
  String? _error;

  // Pour éviter les appels parallèles
  bool _loadingInProgress = false;

  // Écran d'initialisation (masque la carte + tuiles grises au tout début)
  bool _initializing = true; // tant que la 1ère charge n’est pas finie
  bool _firstLoadTried = false;

  // Données agrégées par ville (courantes vs source)
  List<_CityCluster> _clusters = []; // vue courante (après filtres)
  List<_CityCluster> _allClusters = []; // source (sans filtres)

  // --- CACHE en mémoire de la structure des clusters ---
  List<_CityCluster>? _clustersCache;
  DateTime? _clustersCacheTime;
  static const Duration _cacheTtl = Duration(minutes: 10);
  bool get _cacheIsFresh =>
      _clustersCache != null &&
      _clustersCacheTime != null &&
      DateTime.now().difference(_clustersCacheTime!) < _cacheTtl;

  // Marqueurs pour clustering
  final List<Marker> _cityMarkers = [];

  // Filtres
  static const List<String> _genotypeOptions = <String>[
    'Délétion',
    'Mutation',
    'UPD',
    'ICD',
    'Clinique',
    'Mosaïque',
  ];
  final Set<String> _selectedGenotypes = {}; // tous cochés par défaut
  int? _datasetMinAge;
  int? _datasetMaxAge;
  int? _selectedMinAge;
  int? _selectedMaxAge;

  // Distance (km) depuis position utilisateur
  LatLng? _distanceOrigin;
  double? _maxDistanceKm;
  bool _distanceFilterEnabled = false;
  final Distance _geo = const Distance();

  // Tailles bulles
  static const double _minSize = 20.0;
  static const double _maxSize = 52.0;
  // Courbure taille (gamma) — <1 gonfle petits cercles
  static const double _sizeCurveGamma = 0.65;

  // Zoom dynamique
  double _currentZoom = 5.5; // maj via onMapEvent
  double get _zoomFactor {
    final dz = _currentZoom - _initialZoom;
    final f = math.pow(2.0, dz * 0.17).toDouble(); // ~ +12-13% / cran
    return f.clamp(0.6, 2.0);
  }

  // Compteur de personnes (après filtres)
  int get _peopleCount => _clusters.fold<int>(0, (sum, c) => sum + c.count);

  @override
  void initState() {
    super.initState();

    assert(
      _publicAppKey.isNotEmpty,
      '⚠️ PUBLIC_APP_KEY manquante. Lance l’app avec '
      '--dart-define=PUBLIC_APP_KEY=... pour accéder à /api/public/*',
    );

    // Par défaut : TOUS les génotypes cochés
    _selectedGenotypes.addAll(_genotypeOptions);
    _currentZoom = _initialZoom;
    _loadAndBuild(); // première charge
  }

  // Réinitialiser les filtres par défaut
  void _resetFiltersToDefault({bool rebuild = true}) {
    _selectedGenotypes
      ..clear()
      ..addAll(_genotypeOptions);
    _selectedMinAge = _datasetMinAge;
    _selectedMaxAge = _datasetMaxAge;
    _distanceFilterEnabled = false;
    _distanceOrigin = null;
    _maxDistanceKm = null;
    if (rebuild) {
      _clusters = _allClusters;
      _rebuildMarkers();
    }
  }

  // Reload : ignorer filtres + préférer cache
  Future<void> _reloadFromCacheIgnoringFilters() async {
    final cacheFreshNow = _cacheIsFresh;
    debugPrint(
      "[MAP_PEOPLE] 🔄 _reloadFromCacheIgnoringFilters (cacheFresh=$cacheFreshNow)",
    );
    if (cacheFreshNow) {
      _allClusters = List<_CityCluster>.from(_clustersCache!);
      final ages =
          _allClusters
              .expand((c) => c.people.map((p) => p.ageInt))
              .whereType<int>()
              .toList()
            ..sort();
      if (ages.isNotEmpty) {
        _datasetMinAge = ages.first;
        _datasetMaxAge = ages.last;
      }
      _resetFiltersToDefault(rebuild: true);
      return;
    }
    await _loadAndBuild(force: true);
    _resetFiltersToDefault(rebuild: true);
  }

  // Reload : ignorer filtres + FORCER réseau (MAJ cache)
  Future<void> _reloadFromNetworkIgnoringFilters() async {
    debugPrint(
      "[MAP_PEOPLE] 🔄 _reloadFromNetworkIgnoringFilters (force network)",
    );

    // 1) Recharge depuis l'API (force=true => ignore cache)
    await _loadAndBuild(force: true);

    // 2) Et on remet les filtres par défaut (vue “full dataset”)
    _resetFiltersToDefault(rebuild: true);
  }

  // Charge et construit la vue (force=true pour ignorer cache)
  Future<void> _loadAndBuild({bool force = false}) async {
    final start = DateTime.now();
    final cacheFreshSnapshot = _cacheIsFresh && !force;
    debugPrint(
      "[MAP_PEOPLE] ▶️ _loadAndBuild(force=$force) START @ $start (cacheFresh=$cacheFreshSnapshot)",
    );

    if (_loadingInProgress) {
      debugPrint(
        "[MAP_PEOPLE] ⛔ _loadAndBuild ignoré : un chargement est déjà en cours",
      );
      return;
    }
    _loadingInProgress = true;

    try {
      setState(() {
        _loading = true;
        _error = null;
        _cityMarkers.clear();
        _clusters = [];
        _allClusters = [];
        if (!_firstLoadTried) _initializing = true; // affiche l'écran d'init
      });

      // Utilisation du cache si dispo et pas de force
      if (!force && _cacheIsFresh) {
        debugPrint("[MAP_PEOPLE] ✅ Utilisation du cache en mémoire");
        _allClusters = List<_CityCluster>.from(_clustersCache!);
        final ages =
            _allClusters
                .expand((c) => c.people.map((p) => p.ageInt))
                .whereType<int>()
                .toList()
              ..sort();
        if (ages.isNotEmpty) {
          _datasetMinAge = ages.first;
          _datasetMaxAge = ages.last;
          _selectedMinAge ??= _datasetMinAge;
          _selectedMaxAge ??= _datasetMaxAge;
        }
        _clusters = _allClusters;
        _rebuildMarkers();
        setState(() {
          _loading = false;
          _firstLoadTried = true;
          _initializing = false;
        });
        return;
      }

      final httpStart = DateTime.now();
      debugPrint("[MAP_PEOPLE] 🌐 HTTP GET $_peopleApi");

      final res = await http
          .get(
            Uri.parse(_peopleApi),
            headers: {
              'Accept': 'application/json',
              'User-Agent':
                  'ASConnexion/1.0 (mobile; contact: contact@fastfrance.org)',
              'X-App-Key': _publicAppKey,
            },
          )
          .timeout(const Duration(seconds: 60));

      final httpDuration = DateTime.now().difference(httpStart).inMilliseconds;
      debugPrint(
        "[MAP_PEOPLE] 🌐 HTTP ${res.statusCode} reçu en ${httpDuration} ms",
      );

      if (res.statusCode != 200) {
        debugPrint(
          "[MAP_PEOPLE] 🌐 Corps non-200: ${res.body.substring(0, res.body.length.clamp(0, 500))}",
        );
        throw Exception('HTTP ${res.statusCode} : ${res.body}');
      }

      final decodeStart = DateTime.now();
      final List list = json.decode(res.body) as List;
      final decodeDur = DateTime.now().difference(decodeStart).inMilliseconds;
      debugPrint(
        "[MAP_PEOPLE] 🧩 JSON décodé (${list.length} enregistrements) en ${decodeDur} ms",
      );

      final buildPeopleStart = DateTime.now();
      final people = list
          .whereType<Map>()
          .map((m) => _Person.fromJson(m.cast<String, dynamic>()))
          .where(
            (p) =>
                (p.city ?? '').trim().isNotEmpty &&
                p.latitude != null &&
                p.longitude != null,
          )
          .toList();
      final buildPeopleDur = DateTime.now()
          .difference(buildPeopleStart)
          .inMilliseconds;
      debugPrint(
        "[MAP_PEOPLE] 👥 ${people.length} personnes valides construites en ${buildPeopleDur} ms",
      );

      final clusterStart = DateTime.now();
      final Map<String, _CityCluster> clustersMap = {};
      for (final p in people) {
        final key = (p.city ?? '').trim().toLowerCase();
        if (key.isEmpty) continue;
        final pos = LatLng(p.latitude!, p.longitude!);
        clustersMap.putIfAbsent(
          key,
          () => _CityCluster(city: p.city!.trim(), latLng: pos, people: []),
        );
        clustersMap[key]!.people.add(p);
      }

      _allClusters = clustersMap.values.toList();
      final clusterDur = DateTime.now().difference(clusterStart).inMilliseconds;
      debugPrint(
        "[MAP_PEOPLE] 🏙️ ${_allClusters.length} clusters ville construits en ${clusterDur} ms",
      );

      // Cache
      final cacheStart = DateTime.now();
      _clustersCache = _allClusters
          .map(
            (c) => _CityCluster(
              city: c.city,
              latLng: c.latLng,
              people: List<_Person>.from(c.people),
            ),
          )
          .toList();
      _clustersCacheTime = DateTime.now();
      final cacheDur = DateTime.now().difference(cacheStart).inMilliseconds;
      debugPrint(
        "[MAP_PEOPLE] 🧠 Cache mis à jour en ${cacheDur} ms (clusters=${_allClusters.length})",
      );

      // Bornes d’âge dataset
      final ageStart = DateTime.now();
      final allAges = people.map((e) => e.ageInt).whereType<int>().toList()
        ..sort();
      if (allAges.isNotEmpty) {
        _datasetMinAge = allAges.first;
        _datasetMaxAge = allAges.last;
        _selectedMinAge ??= _datasetMinAge;
        _selectedMaxAge ??= _datasetMaxAge;
      }
      final ageDur = DateTime.now().difference(ageStart).inMilliseconds;
      debugPrint(
        "[MAP_PEOPLE] 📊 Bornes d’âge calculées en ${ageDur} ms (min=$_datasetMinAge, max=$_datasetMaxAge)",
      );

      _clusters = _allClusters;
      _rebuildMarkers();
    } catch (e, st) {
      debugPrint("[MAP_PEOPLE] ❌ Exception dans _loadAndBuild: $e");
      debugPrint("[MAP_PEOPLE] Stack: $st");

      if (_cacheIsFresh) {
        debugPrint(
          "[MAP_PEOPLE] ⚠️ Erreur réseau mais cache dispo, utilisation du cache",
        );
        _allClusters = List<_CityCluster>.from(_clustersCache!);
        _clusters = _allClusters;
        _rebuildMarkers();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Réseau indisponible — cache utilisé: $e')),
          );
        }
      } else {
        if (mounted) {
          setState(() => _error = e.toString());
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Erreur chargement : $e')));
        }
      }
    } finally {
      final totalMs = DateTime.now().difference(start).inMilliseconds;
      debugPrint(
        "[MAP_PEOPLE] ⏱️ _loadAndBuild(force=$force) FIN en ${totalMs} ms",
      );
      _loadingInProgress = false;
      if (mounted) {
        setState(() {
          _loading = false;
          _firstLoadTried = true;
          _initializing = false; // on retire l’overlay d’init
        });
      }
    }
  }

  // Géoloc
  Future<bool> _ensureLocation({bool showSnackOnError = true}) async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (showSnackOnError) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Service de localisation désactivé')),
          );
        }
        return false;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (showSnackOnError) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Permission localisation refusée')),
          );
        }
        return false;
      }
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _distanceOrigin = LatLng(pos.latitude, pos.longitude);
      return true;
    } catch (e) {
      if (showSnackOnError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Localisation indisponible : $e')),
        );
      }
      return false;
    }
  }

  // Cercle de distance
  List<LatLng> _buildGeoCircle(
    LatLng center,
    double radiusKm, {
    int steps = 180,
  }) {
    const earthRadiusKm = 6371.0;
    final lat0 = center.latitude * math.pi / 180.0;
    final lon0 = center.longitude * math.pi / 180.0;
    final dByR = radiusKm / earthRadiusKm;

    final pts = <LatLng>[];
    for (int i = 0; i < steps; i++) {
      final brg = (i * (360.0 / steps)) * math.pi / 180.0;
      final lat = math.asin(
        math.sin(lat0) * math.cos(dByR) +
            math.cos(lat0) * math.sin(dByR) * math.cos(brg),
      );
      final lon =
          lon0 +
          math.atan2(
            math.sin(brg) * math.sin(dByR) * math.cos(lat0),
            math.cos(dByR) - math.sin(lat0) * math.sin(lat),
          );
      pts.add(LatLng(lat * 180.0 / math.pi, lon * 180.0 / math.pi));
    }
    return pts;
  }

  PolygonLayer _distanceCircleLayer() {
    if (!_distanceFilterEnabled ||
        _distanceOrigin == null ||
        _maxDistanceKm == null) {
      return const PolygonLayer(polygons: []);
    }
    final ring = _buildGeoCircle(_distanceOrigin!, _maxDistanceKm!, steps: 180);
    return PolygonLayer(
      polygons: [
        Polygon(
          points: ring,
          borderStrokeWidth: 2.0,
          borderColor: Colors.blueAccent.withOpacity(0.9),
          color: Colors.blueAccent.withOpacity(0.07),
        ),
      ],
    );
  }

  // Taille bulles (LOG + gamma)
  double _sizeForCount(int count, int maxCount) {
    final int c = count.clamp(1, 1000000);
    final int m = math.max(1, maxCount);
    if (m <= 1) return _minSize;

    final double vMin = math.log(1.0 + 1.0); // log(2)
    final double vMax = math.log(1.0 + m.toDouble());
    final double v = math.log(1.0 + c.toDouble());

    double t = (v - vMin) / (vMax - vMin);
    t = t.clamp(0.0, 1.0);
    t = math.pow(t, _sizeCurveGamma).toDouble();

    final double size = _minSize + t * (_maxSize - _minSize);
    return size.clamp(_minSize, _maxSize);
  }

  // Filtrage
  bool _matchesDistance(LatLng cityPos) {
    if (!_distanceFilterEnabled ||
        _distanceOrigin == null ||
        _maxDistanceKm == null) {
      return true;
    }
    final dKm = _geo.as(LengthUnit.Kilometer, _distanceOrigin!, cityPos);
    return dKm <= _maxDistanceKm!;
  }

  Future<void> _applyFilters({bool rebuildOnly = false}) async {
    try {
      List<_CityCluster> source = _allClusters;

      bool matchesGenotype(String? g) {
        if (_selectedGenotypes.isEmpty) return true;
        if (g == null || g.trim().isEmpty) return false;
        final norm = g.trim().toLowerCase();
        for (final sel in _selectedGenotypes) {
          if (norm == sel.trim().toLowerCase()) return true;
        }
        return false;
      }

      bool matchesAge(int? age) {
        if (_selectedMinAge == null || _selectedMaxAge == null) return true;
        if (age == null) return false;
        return age >= _selectedMinAge! && age <= _selectedMaxAge!;
      }

      if (!rebuildOnly) {
        final filtered = <_CityCluster>[];
        for (final c in _allClusters) {
          if (!_matchesDistance(c.latLng)) continue;

          final filteredPeople = <_Person>[];
          for (final p in c.people) {
            if (matchesGenotype(p.genotype) && matchesAge(p.ageInt)) {
              filteredPeople.add(p);
            }
          }
          if (filteredPeople.isNotEmpty) {
            filtered.add(
              _CityCluster(
                city: c.city,
                latLng: c.latLng,
                people: filteredPeople,
              ),
            );
          }
        }
        source = filtered;
      }

      _clusters = source;
      _rebuildMarkers();
    } catch (e) {
      if (mounted) {
        _error = e.toString();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur filtre : $e')));
        setState(() {});
      }
    }
  }

  // Reconstruit les marqueurs
  void _rebuildMarkers() {
    _cityMarkers.clear();

    final maxCount = _clusters.isNotEmpty
        ? _clusters.map((c) => c.count).reduce((a, b) => a > b ? a : b)
        : 1;

    for (final c in _clusters) {
      final base = _sizeForCount(c.count, maxCount);
      final scaled = (base * _zoomFactor).clamp(_minSize, _maxSize * 2);

      _cityMarkers.add(
        Marker(
          point: c.latLng,
          width: scaled,
          height: scaled,
          alignment: Alignment.center,
          child: GestureDetector(
            onTap: () => _openCitySheet(c),
            child: _Bubble(count: c.count, size: scaled),
          ),
        ),
      );
    }

    if (mounted) setState(() {});
  }

  // --- Visionneuse photo plein écran (modale) ---
  Future<void> _showPhotoViewer(String url) async {
    await showGeneralDialog(
      context: context,
      barrierLabel: 'Photo',
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.9),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (ctx, a1, a2) {
        return SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(onTap: () => Navigator.of(ctx).pop()),
              ),
              Center(
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Image.network(
                    url,
                    headers: {'X-App-Key': _publicAppKey},
                    fit: BoxFit.contain,
                    loadingBuilder: (c, child, prog) => prog == null
                        ? child
                        : const CircularProgressIndicator(),
                    errorBuilder: (c, e, s) => const Icon(
                      Icons.broken_image,
                      size: 72,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 12,
                top: 12,
                child: IconButton(
                  tooltip: 'Fermer',
                  icon: const Icon(Icons.close, color: Colors.white, size: 28),
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
              ),
            ],
          ),
        );
      },
      transitionBuilder: (ctx, anim, _, child) =>
          FadeTransition(opacity: anim, child: child),
    );
  }

  // UI
  @override
  Widget build(BuildContext context) {
    super.build(context); // IMPORTANT pour keep-alive

    final tilesBlockedInRelease =
        kReleaseMode &&
        !widget.allowOsmInRelease &&
        (widget.mapTilerApiKey == null || widget.mapTilerApiKey!.isEmpty);

    return Stack(
      children: [
        FlutterMap(
          mapController: _map,
          options: MapOptions(
            initialCenter: _initialCenter,
            initialZoom: _initialZoom,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
            ),
            onMapEvent: (evt) {
              final z = evt.camera.zoom;
              if ((z - _currentZoom).abs() > 0.01) {
                _currentZoom = z;
                _rebuildMarkers();
              }
            },
          ),
          children: [
            if (!tilesBlockedInRelease && !_initializing) _buildTileLayer(),
            _distanceCircleLayer(),

            MarkerClusterLayerWidget(
              options: MarkerClusterLayerOptions(
                markers: _cityMarkers,
                maxClusterRadius: 50,
                spiderfyCircleRadius: 36,
                spiderfySpiralDistanceMultiplier: 2,
                disableClusteringAtZoom: 12,
                size: const Size(48, 48),
                zoomToBoundsOnClick: false,
                onClusterTap: (cluster) {
                  final points = cluster.markers.map((m) => m.point).toList();
                  if (points.isEmpty) return;
                  if (points.length == 1) {
                    _map.move(
                      points.first,
                      (_currentZoom + 2).clamp(3.0, 18.0),
                    );
                    return;
                  }
                  final bounds = LatLngBounds.fromPoints(points);
                  _map.fitCamera(
                    CameraFit.bounds(
                      bounds: bounds,
                      padding: const EdgeInsets.all(24),
                    ),
                  );
                },
                builder: (context, markers) {
                  final n = markers.length;
                  return Container(
                    width: 46,
                    height: 46,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.indigo.withOpacity(0.90),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      '$n',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  );
                },
              ),
            ),

            MarkerLayer(markers: _cityMarkers),
            _buildAttribution(),
          ],
        ),

        Positioned(
          left: 12,
          top: 12,
          child: SafeArea(
            child: Tooltip(
              message: _filtersTooltipText(),
              preferBelow: false,
              child: FloatingActionButton.small(
                heroTag: 'settingsPeopleCity',
                onPressed: _openSettingsSheet,
                tooltip: 'Filtres',
                child: const Icon(Ionicons.options),
              ),
            ),
          ),
        ),

        Positioned(
          left: 84,
          right: 84,
          top: 12,
          child: SafeArea(
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, anim) =>
                    FadeTransition(opacity: anim, child: child),
                child: Container(
                  key: ValueKey(_peopleCount),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.55),
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    '$_peopleCount personne${_peopleCount > 1 ? "s" : ""}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        Positioned(
          right: 12,
          top: 12,
          child: SafeArea(
            child: FloatingActionButton.small(
              heroTag: 'refreshPeopleCity',
              onPressed: _reloadFromNetworkIgnoringFilters,
              tooltip:
                  'Recharger (réseau, ignore filtres, met à jour le cache)',
              child: const Icon(Ionicons.refresh),
            ),
          ),
        ),

        if (tilesBlockedInRelease)
          Positioned(
            left: 12,
            right: 12,
            top: 80,
            child: Card(
              color: Colors.amber.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  'Tuiles OSM désactivées en production.\n'
                  'Configure une clé MapTiler (ou passe allowOsmInRelease=true).',
                  style: TextStyle(color: Colors.amber.shade900),
                ),
              ),
            ),
          ),

        if (_loading) const _PositionedFillLoader(),

        if (_initializing)
          const _InitOverlay(
            message: 'Nous initialisons l’ensemble des données…',
          ),

        if (_error != null)
          Positioned(
            left: 12,
            right: 12,
            bottom: 84,
            child: Card(
              color: Colors.red.shade50,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _error!,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.red.shade800),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // Helpers UI
  String _filtersTooltipText() {
    final genoCount = _selectedGenotypes.length;
    final genoPart = genoCount > 0
        ? '$genoCount génotype${genoCount > 1 ? "s" : ""}'
        : null;

    final ageActive =
        _selectedMinAge != null &&
        _selectedMaxAge != null &&
        _datasetMinAge != null &&
        _datasetMaxAge != null &&
        (_selectedMinAge != _datasetMinAge ||
            _selectedMaxAge != _datasetMaxAge);
    final agePart = ageActive
        ? '${_selectedMinAge ?? "?"}–${_selectedMaxAge ?? "?"} ans'
        : null;

    final distActive =
        _distanceFilterEnabled &&
        _distanceOrigin != null &&
        _maxDistanceKm != null;
    final distPart = distActive
        ? '≤ ${_maxDistanceKm!.toStringAsFixed(0)} km'
        : null;

    final parts = [genoPart, agePart, distPart].whereType<String>().toList();
    return parts.isEmpty ? 'Aucun filtre' : parts.join(' • ');
  }

  Widget _buildTileLayer() {
    final canUseOsm = !kReleaseMode || widget.allowOsmInRelease;

    if (!canUseOsm && (widget.mapTilerApiKey?.isNotEmpty ?? false)) {
      return TileLayer(
        urlTemplate:
            'https://api.maptiler.com/maps/streets-v2/{z}/{x}/{y}.png?key={key}',
        additionalOptions: {'key': widget.mapTilerApiKey!},
        maxZoom: 19,
        tileProvider: NetworkTileProvider(),
      );
    }

    return TileLayer(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      userAgentPackageName: _userAgentPackageName,
      maxZoom: 19,
      tileProvider: NetworkTileProvider(
        headers: {'User-Agent': widget.osmUserAgent},
      ),
    );
  }

  Widget _buildAttribution() {
    final usingMapTiler =
        kReleaseMode &&
        !widget.allowOsmInRelease &&
        (widget.mapTilerApiKey?.isNotEmpty ?? false);

    return RichAttributionWidget(
      attributions: [
        TextSourceAttribution(
          usingMapTiler
              ? '© MapTiler © OpenStreetMap contributors'
              : '© OpenStreetMap contributors',
          onTap: () => launchUrl(
            Uri.parse('https://www.openstreetmap.org/copyright'),
            mode: LaunchMode.externalApplication,
          ),
        ),
      ],
    );
  }

  // BottomSheet Ville
  Future<void> _openCitySheet(_CityCluster cluster) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: 16 + MediaQuery.of(ctx).viewInsets.bottom,
            top: 16,
          ),
          child: SafeArea(
            top: false,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 520),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Icon(Ionicons.business),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${cluster.city} • ${cluster.count} personne${cluster.count > 1 ? "s" : ""}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.separated(
                      itemCount: cluster.people.length,
                      separatorBuilder: (_, __) =>
                          Divider(height: 12, color: Colors.grey.shade200),
                      itemBuilder: (ctx, i) {
                        final p = cluster.people[i];
                        return _PersonTile(
                          person: p,
                          currentPersonId:
                              widget.currentPersonId, // ou ton id courant réel
                          buildPhotoUrl: () => _personPhotoUrl(p.id ?? -1),
                          onOpenPhoto: (url) => _showPhotoViewer(url),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Feuille de Filtres (avec compteur live + âges dynamiques et clamp)
  Future<void> _openSettingsSheet() async {
    // Copie locale
    final tempGenos = Set<String>.from(_selectedGenotypes);
    int? localMin = _selectedMinAge ?? _datasetMinAge;
    int? localMax = _selectedMaxAge ?? _datasetMaxAge;

    bool localDistanceEnabled = _distanceFilterEnabled;
    LatLng? localOrigin = _distanceOrigin;
    double localMaxKm = _maxDistanceKm ?? 100.0;

    // Helpers internes (calcul domaine & clamp)
    List<_Person> _peopleModalFilteredByGenoDist() {
      bool genotypeOk(String? g) {
        if (tempGenos.isEmpty) return false;
        if (g == null || g.trim().isEmpty) return false;
        final norm = g.trim().toLowerCase();
        for (final sel in tempGenos) {
          if (norm == sel.trim().toLowerCase()) return true;
        }
        return false;
      }

      bool distanceOk(LatLng cityPos) {
        if (!localDistanceEnabled || localOrigin == null || localMaxKm <= 0) {
          return true;
        }
        final dKm = _geo.as(LengthUnit.Kilometer, localOrigin!, cityPos);
        return dKm <= localMaxKm;
      }

      final out = <_Person>[];
      for (final c in _allClusters) {
        if (!distanceOk(c.latLng)) continue;
        for (final p in c.people) {
          if (genotypeOk(p.genotype)) out.add(p);
        }
      }
      return out;
    }

    ({bool hasAges, int minAge, int maxAge}) _currentAgeDomainForModal() {
      final ages =
          _peopleModalFilteredByGenoDist()
              .map((p) => p.ageInt)
              .whereType<int>()
              .toList()
            ..sort();
      if (ages.isEmpty) return (hasAges: false, minAge: 0, maxAge: 0);
      return (hasAges: true, minAge: ages.first, maxAge: ages.last);
    }

    void _clampAgeSelectionToDomain(StateSetter setModalState) {
      final dom = _currentAgeDomainForModal();
      if (!dom.hasAges) {
        setModalState(() {
          localMin = null;
          localMax = null;
        });
        return;
      }
      setModalState(() {
        localMin = (localMin ?? dom.minAge).clamp(dom.minAge, dom.maxAge);
        localMax = (localMax ?? dom.maxAge).clamp(dom.minAge, dom.maxAge);
        if (localMin! > localMax!) {
          localMin = dom.minAge;
          localMax = dom.maxAge;
        }
      });
    }

    int _countModalWithAgeBounds(int minA, int maxA) {
      int count = 0;
      for (final c in _allClusters) {
        // distance
        if (localDistanceEnabled && localOrigin != null && localMaxKm > 0) {
          final dKm = _geo.as(LengthUnit.Kilometer, localOrigin!, c.latLng);
          if (dKm > localMaxKm) continue;
        }
        for (final p in c.people) {
          // geno
          if (!tempGenos.contains((p.genotype ?? '').trim())) continue;
          // age
          final a = p.ageInt;
          if (a != null && a >= minA && a <= maxA) count++;
        }
      }
      return count;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final dom = _currentAgeDomainForModal();
            final bool hasAges = dom.hasAges;
            final int minAge = hasAges ? dom.minAge : 0;
            final int maxAge = hasAges ? dom.maxAge : 0;

            if (hasAges) {
              // Corrige localement pour l'affichage
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

            final int startI = hasAges ? localMin! : 0;
            final int endI = hasAges ? localMax! : 0;
            final int resultsCount = hasAges
                ? _countModalWithAgeBounds(startI, endI)
                : 0;

            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: 16 + MediaQuery.of(ctx).viewInsets.bottom,
                top: 16,
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: const [
                        Icon(Ionicons.options),
                        SizedBox(width: 8),
                        Text(
                          'Filtres',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),

                    // Compteur live
                    Padding(
                      padding: const EdgeInsets.only(top: 6.0, bottom: 12.0),
                      child: Row(
                        children: [
                          Icon(
                            hasAges
                                ? Ionicons.people
                                : Ionicons.alert_circle_outline,
                            size: 18,
                            color: hasAges ? Colors.black54 : Colors.orange,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              hasAges
                                  ? '$resultsCount résultat${resultsCount > 1 ? "s" : ""}'
                                  : 'Aucun résultat avec ces filtres (génotype/distance).',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: hasAges ? Colors.black87 : Colors.orange,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Distance
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Distance (depuis ma position)',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    SwitchListTile(
                      title: const Text('Activer le filtre de distance'),
                      value: localDistanceEnabled,
                      onChanged: (v) async {
                        if (v) {
                          setModalState(() => localDistanceEnabled = true);
                          final ok = await _ensureLocation();
                          if (ok && _distanceOrigin != null) {
                            setModalState(() {
                              localOrigin = _distanceOrigin;
                            });
                            _clampAgeSelectionToDomain(setModalState);
                          } else {
                            setModalState(() => localDistanceEnabled = false);
                          }
                        } else {
                          setModalState(() => localDistanceEnabled = false);
                          _clampAgeSelectionToDomain(setModalState);
                        }
                      },
                    ),
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        localOrigin != null
                            ? 'Origine : ${localOrigin!.latitude.toStringAsFixed(4)}, ${localOrigin!.longitude.toStringAsFixed(4)}'
                            : 'Origine : non définie',
                      ),
                      trailing: TextButton.icon(
                        icon: const Icon(Ionicons.locate),
                        label: const Text('Ma position'),
                        onPressed: () async {
                          final ok = await _ensureLocation();
                          if (ok && _distanceOrigin != null) {
                            setModalState(() {
                              localDistanceEnabled = true;
                              localOrigin = _distanceOrigin;
                            });
                            _clampAgeSelectionToDomain(setModalState);
                          }
                        },
                      ),
                    ),
                    if (localDistanceEnabled) ...[
                      Row(
                        children: [
                          Expanded(
                            child: Slider(
                              value: localMaxKm.clamp(1, 1000),
                              min: 1,
                              max: 1000,
                              divisions: 999,
                              label: '${localMaxKm.toStringAsFixed(0)} km',
                              onChanged: (v) {
                                setModalState(() => localMaxKm = v);
                                _clampAgeSelectionToDomain(setModalState);
                              },
                            ),
                          ),
                          SizedBox(
                            width: 72,
                            child: Text(
                              '${localMaxKm.toStringAsFixed(0)} km',
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 16),

                    // Génotypes
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Génotype',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(height: 6),
                    ..._genotypeOptions.map((g) {
                      final checked = tempGenos.contains(g);
                      return CheckboxListTile(
                        value: checked,
                        title: Text(g),
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
                          _clampAgeSelectionToDomain(setModalState);
                        },
                      );
                    }).toList(),

                    const SizedBox(height: 16),

                    // Âge (dynamique + clamp)
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Âge (années)',
                        style: TextStyle(fontWeight: FontWeight.w700),
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
                        children: [Text('Min : $startI'), Text('Max : $endI')],
                      ),
                      RangeSlider(
                        values: RangeValues(startI.toDouble(), endI.toDouble()),
                        min: minAge.toDouble(),
                        max: maxAge.toDouble(),
                        divisions: (maxAge - minAge) > 0
                            ? (maxAge - minAge)
                            : null,
                        labels: RangeLabels(startI.toString(), endI.toString()),
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
                          child: const Text('Réinitialiser'),
                          onPressed: () {
                            setModalState(() {
                              // 1) Filtres par défaut
                              tempGenos
                                ..clear()
                                ..addAll(_genotypeOptions);
                              localDistanceEnabled = false;
                              localOrigin = null;
                              localMaxKm = 100.0;

                              // 2) Recalcule le domaine d’âge
                              final dom = _currentAgeDomainForModal();

                              // 3) Positionne le RangeSlider sur les bornes du domaine
                              if (dom.hasAges) {
                                localMin = dom.minAge;
                                localMax = dom.maxAge;
                              } else {
                                localMin = null;
                                localMax = null;
                              }
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          child: const Text('Annuler'),
                          onPressed: () => Navigator.of(ctx).pop(),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          icon: const Icon(Ionicons.checkmark),
                          label: const Text('Appliquer'),
                          onPressed: () async {
                            _selectedGenotypes
                              ..clear()
                              ..addAll(tempGenos);

                            _selectedMinAge = hasAges ? startI : null;
                            _selectedMaxAge = hasAges ? endI : null;

                            _distanceFilterEnabled = localDistanceEnabled;
                            _distanceOrigin = localOrigin;
                            _maxDistanceKm = localDistanceEnabled
                                ? localMaxKm
                                : null;

                            Navigator.of(ctx).pop();
                            await _applyFilters();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Actions annexes
  Future<void> _openPhotoUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<bool> _sendMessagePlaceholder(int? personId, String message) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return message.trim().isNotEmpty && personId != null;
  }
}
