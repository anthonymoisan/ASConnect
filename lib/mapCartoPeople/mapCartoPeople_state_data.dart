//API + cache + construction clusters
part of map_carto_people;

extension _MapPeopleData on _MapPeopleByCityState {
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

      final countries =
          _allClusters
              .expand((c) => c.people)
              .map((p) => (p.country ?? '').trim())
              .where((c) => c.isNotEmpty)
              .toSet()
              .toList()
            ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

      _countryOptions = countries;

      if (_selectedCountries.isEmpty ||
          _selectedCountries.length != _countryOptions.length) {
        _selectedCountries
          ..clear()
          ..addAll(_countryOptions);
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
    _didInitialFit = false;
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
      // Utilisation du cache si dispo et pas de force
      if (!force && _cacheIsFresh) {
        debugPrint("[MAP_PEOPLE] ✅ Utilisation du cache en mémoire");
        _allClusters = List<_CityCluster>.from(_clustersCache!);

        // âges depuis _allClusters
        final ages =
            _allClusters
                .expand((c) => c.people.map((p) => p.ageInt))
                .whereType<int>()
                .toList()
              ..sort();

        // ✅ pays depuis _allClusters (pas de variable `people` ici)
        final countries =
            _allClusters
                .expand((c) => c.people)
                .map((p) => (p.country ?? '').trim())
                .where((c) => c.isNotEmpty)
                .toSet()
                .toList()
              ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

        _countryOptions = countries;

        // ✅ Par défaut : tout sélectionné (ou si options changent)
        if (_selectedCountries.isEmpty ||
            _selectedCountries.length != _countryOptions.length) {
          _selectedCountries
            ..clear()
            ..addAll(_countryOptions);
        }

        if (ages.isNotEmpty) {
          _datasetMinAge = ages.first;
          _datasetMaxAge = ages.last;
          _selectedMinAge ??= _datasetMinAge;
          _selectedMaxAge ??= _datasetMaxAge;
        }

        _clusters = _allClusters;
        _rebuildMarkers();
        _fitOnNextFrameOnce(_clusters);

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

      final countries =
          people
              .map((p) => (p.country ?? '').trim())
              .where((c) => c.isNotEmpty)
              .toSet()
              .toList()
            ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

      _countryOptions = countries;

      // ✅ Par défaut : tout sélectionné
      if (_selectedCountries.isEmpty) {
        _selectedCountries.addAll(_countryOptions);
      }

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
      _fitOnNextFrameOnce(_clusters);
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
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.mapNetworkUnavailableCacheUsed(e.toString())),
            ),
          );
        }
      } else {
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          setState(() => _error = e.toString());
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.mapLoadGenericError(e.toString()))),
          );
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
}
