// lib/mapCartoPeople/mapCartoPeople_state_data.dart
// API + cache + construction clusters + country labels i18n
part of map_carto_people;

extension _MapPeopleData on _MapPeopleByCityState {
  // ------------------------------
  // ✅ Helper: apply a dataset (clusters) and rebuild all derived state consistently
  // ------------------------------
  void _applyClustersAsDataset(
    List<_CityCluster> clusters, {
    required bool fit,
  }) {
    _allClusters = clusters;

    // Bornes d’âge dataset
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

    // Pays options
    final countries =
        _allClusters
            .expand((c) => c.people)
            .map((p) => (p.countryCode ?? '').trim().toUpperCase())
            .where((c) => c.length == 2)
            .toSet()
            .toList()
          ..sort();

    _countryOptions = countries;

    if (_selectedCountries.isEmpty ||
        _selectedCountries.length != _countryOptions.length) {
      _selectedCountries
        ..clear()
        ..addAll(_countryOptions);
    }

    // ✅ Langues options (indépendant du filtre pays)
    //
    String? normLang(String? v) {
      final s = (v ?? '').trim().toLowerCase();
      if (s.isEmpty) return null;
      if (s.contains('-')) return s.split('-').first.trim();
      if (s.contains('_')) return s.split('_').first.trim();
      return s;
    }

    final languages =
        _allClusters
            .expand((c) => c.people)
            .map((p) => normLang(p.lang))
            .whereType<String>()
            .toSet()
            .toList()
          ..sort();

    _languageOptions = languages;

    if (_selectedLanguages.isEmpty ||
        (_languageOptions.isNotEmpty &&
            _selectedLanguages.length != _languageOptions.length)) {
      _selectedLanguages
        ..clear()
        ..addAll(_languageOptions);
    }

    // Niveau & clusters pays
    _level = _MapLevel.country;
    _activeCountry = null;
    _countryClusters = _buildCountryClustersFromCityClusters(_allClusters);

    // ✅ important pour rebuild markers / drilldown
    _filteredAllClusters = _allClusters;

    _rebuildMarkers();

    if (fit) {
      _fitOnNextFrameOnceCountry();
    }
  }

  // ------------------------------
  // ✅ Fit signature: avoid refit if the dataset bounds didn't really change
  // (reduces MapTiler tile downloads)
  // ------------------------------
  int _computeFitSig(List<_CountryCluster> cc) {
    if (cc.isEmpty) return 0;

    final lats = cc.map((c) => c.latLng.latitude).toList()..sort();
    final lngs = cc.map((c) => c.latLng.longitude).toList()..sort();

    // quantize to reduce sensitivity to tiny variations
    final minLat = (lats.first * 100).round();
    final maxLat = (lats.last * 100).round();
    final minLng = (lngs.first * 100).round();
    final maxLng = (lngs.last * 100).round();

    return minLat ^ (maxLat << 6) ^ (minLng << 12) ^ (maxLng << 18) ^ cc.length;
  }

  // ------------------------------
  // Country labels (ISO2 -> translated)
  // ------------------------------
  Future<void> _ensureCountryLabelsForLocale(BuildContext context) async {
    final loc = Localizations.localeOf(context);

    // Use "pt_BR" style if countryCode exists, else "fr"
    final String locale =
        (loc.countryCode != null && loc.countryCode!.trim().isNotEmpty)
        ? '${loc.languageCode}_${loc.countryCode}'
        : loc.languageCode;

    if (_countryLabelsLocale == locale && _countryLabelsByIso2.isNotEmpty) {
      return;
    }
    if (_loadingCountryLabels) return;

    _loadingCountryLabels = true;

    try {
      const String _env = String.fromEnvironment('ENV', defaultValue: 'prod');

      const String _base = _env == 'prod'
          ? 'anthonymoisan.eu.pythonanywhere.com'
          : 'test-anthonymoisan.eu.pythonanywhere.com';

      final uri = Uri.https(_base, '/api/public/people/countriesTranslated', {
        'locale': locale,
      });

      final res = await http
          .get(
            uri,
            headers: {'Accept': 'application/json', 'X-App-Key': _publicAppKey},
          )
          .timeout(const Duration(seconds: 30));

      if (res.statusCode != 200) {
        throw Exception(
          "HTTP map Carto issue with countries ${res.statusCode}",
        );
      }

      final decoded = json.decode(res.body);

      // Format attendu :
      // { "count": 36, "countries": [ { "code":"FR", "name":"France" }, ... ], "locale": "fr" }
      final Map<String, String> map = {};

      if (decoded is Map) {
        final countries = decoded['countries'];
        if (countries is List) {
          for (final e in countries) {
            if (e is Map) {
              final iso = (e['code'] ?? '').toString().trim().toUpperCase();
              final name = (e['name'] ?? '').toString().trim();
              if (iso.length == 2 && name.isNotEmpty) {
                map[iso] = name;
              }
            }
          }
        }
      }

      // On ne garde que les pays présents dans le dataset (options)
      final presentIso = _countryOptions
          .map((e) => e.trim().toUpperCase())
          .toSet();

      final filtered = <String, String>{};
      for (final iso in presentIso) {
        final label = map[iso];
        if (label != null && label.isNotEmpty) filtered[iso] = label;
      }

      if (mounted) {
        setState(() {
          _countryLabelsByIso2 = filtered;
          _countryLabelsLocale = locale;
        });
      }
    } catch (_) {
      // Fallback : labels vides => l'UI affichera l'ISO2
      if (mounted) {
        setState(() {
          _countryLabelsByIso2 = {};
          _countryLabelsLocale = locale;
        });
      }
    } finally {
      _loadingCountryLabels = false;
    }
  }

  // ------------------------------
  // ✅ Language labels (ISO alpha-2 -> translated) via API
  // Endpoint: /api/public/people/languagesTranslated?locale=fr
  // Response:
  // { "locale":"fr", "langues":[{"code":"fr","name":"Français"}, ...], "count": N }
  // ------------------------------
  Future<void> _ensureLanguageLabelsForLocale(BuildContext context) async {
    final loc = Localizations.localeOf(context);

    // Use "pt_BR" style if countryCode exists, else "fr"
    final String locale =
        (loc.countryCode != null && loc.countryCode!.trim().isNotEmpty)
        ? '${loc.languageCode}_${loc.countryCode}'
        : loc.languageCode;

    // ⚠️ Nécessite que votre State déclare :
    //   Map<String, String> _languageLabelsByCode = {};
    //   String _languageLabelsLocale = '';
    //   bool _loadingLanguageLabels = false;
    //
    // Convention: codes langue en lower-case ("fr", "en"...)
    if (_languageLabelsLocale == locale && _languageLabelsByCode.isNotEmpty) {
      return;
    }
    if (_loadingLanguageLabels) return;

    _loadingLanguageLabels = true;

    try {
      const String _env = String.fromEnvironment('ENV', defaultValue: 'prod');

      const String _base = _env == 'prod'
          ? 'anthonymoisan.eu.pythonanywhere.com'
          : 'test-anthonymoisan.eu.pythonanywhere.com';

      final uri = Uri.https(_base, '/api/public/people/languagesTranslated', {
        'locale': locale,
      });

      final res = await http
          .get(
            uri,
            headers: {'Accept': 'application/json', 'X-App-Key': _publicAppKey},
          )
          .timeout(const Duration(seconds: 30));

      if (res.statusCode != 200) {
        throw Exception(
          "HTTP map Carto issue with languages ${res.statusCode}",
        );
      }

      final decoded = json.decode(res.body);

      final Map<String, String> map = {};

      if (decoded is Map) {
        final langues = decoded['langues'];
        if (langues is List) {
          for (final e in langues) {
            if (e is Map) {
              final code = (e['code'] ?? '').toString().trim().toLowerCase();
              final name = (e['name'] ?? '').toString().trim();
              if (code.isNotEmpty && name.isNotEmpty) {
                // normalise "fr-FR" -> "fr"
                final norm = code.contains('-')
                    ? code.split('-').first.trim()
                    : (code.contains('_')
                          ? code.split('_').first.trim()
                          : code);
                if (norm.isNotEmpty) map[norm] = name;
              }
            }
          }
        }
      }

      // On ne garde que les langues présentes dans le dataset (options)
      final present = _languageOptions
          .map((e) => e.trim().toLowerCase())
          .toSet();

      final filtered = <String, String>{};
      for (final code in present) {
        final label = map[code];
        if (label != null && label.isNotEmpty) filtered[code] = label;
      }

      if (mounted) {
        setState(() {
          _languageLabelsByCode = filtered;
          _languageLabelsLocale = locale;
        });
      }
    } catch (_) {
      // Fallback : labels vides => l'UI affichera le code (FR/EN/...)
      if (mounted) {
        setState(() {
          _languageLabelsByCode = {};
          _languageLabelsLocale = locale;
        });
      }
    } finally {
      _loadingLanguageLabels = false;
    }
  }

  // ------------------------------
  // Build country clusters from city clusters
  // ------------------------------
  List<_CountryCluster> _buildCountryClustersFromCityClusters(
    List<_CityCluster> cityClusters,
  ) {
    final Map<String, List<_CityCluster>> byCountry = {};

    for (final city in cityClusters) {
      final codes = city.people
          .map((p) => (p.countryCode ?? '').trim().toUpperCase())
          .where((c) => c.length == 2)
          .toSet()
          .toList();

      if (codes.isEmpty) continue;

      // Hypothèse: 1 pays par cluster ville
      final code = codes.first;
      byCountry.putIfAbsent(code, () => []).add(city);
    }

    final out = <_CountryCluster>[];

    byCountry.forEach((code, cities) {
      double lat = 0;
      double lon = 0;
      for (final c in cities) {
        lat += c.latLng.latitude;
        lon += c.latLng.longitude;
      }
      final center = LatLng(lat / cities.length, lon / cities.length);

      out.add(
        _CountryCluster(countryCode: code, latLng: center, cities: cities),
      );
    });

    out.sort((a, b) => a.countryCode.compareTo(b.countryCode));
    return out;
  }

  // Reload : ignorer filtres + préférer cache
  Future<void> _reloadFromCacheIgnoringFilters() async {
    final cacheFreshNow = _cacheIsFresh;
    debugPrint(
      "[MAP_PEOPLE] 🔄 _reloadFromCacheIgnoringFilters (cacheFresh=$cacheFreshNow)",
    );

    if (cacheFreshNow) {
      if (mounted) {
        setState(() {
          _error = null;
          _loading = false;
          _initializing = false;
        });
      }

      _applyClustersAsDataset(
        List<_CityCluster>.from(_clustersCache!),
        fit: true,
      );
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

    // ✅ ne force plus un refit systématique
    // _didInitialFit = false;

    await _loadAndBuild(force: true);
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
      if (mounted) {
        setState(() {
          _loading = true;
          _error = null;

          // ✅ prefer replacing list reference (safer if you later re-enable clustering)
          _cityMarkers = const <Marker>[];

          _clusters = [];
          _allClusters = [];
          _countryClusters = [];

          if (!_firstLoadTried) _initializing = true;
        });
      }

      // ----------------- CACHE -----------------
      if (!force && _cacheIsFresh) {
        debugPrint("[MAP_PEOPLE] ✅ Utilisation du cache en mémoire");

        _applyClustersAsDataset(
          List<_CityCluster>.from(_clustersCache!),
          fit: true,
        );

        if (mounted) {
          setState(() {
            _loading = false;
            _firstLoadTried = true;
            _initializing = false;
          });
        }
        return;
      }

      // ----------------- RÉSEAU -----------------
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

      // Clusters villes
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

      final builtClusters = clustersMap.values.toList();

      final clusterDur = DateTime.now().difference(clusterStart).inMilliseconds;
      debugPrint(
        "[MAP_PEOPLE] 🏙️ ${builtClusters.length} clusters ville construits en ${clusterDur} ms",
      );

      // Cache
      final cacheStart = DateTime.now();
      _clustersCache = builtClusters
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
        "[MAP_PEOPLE] 🧠 Cache mis à jour en ${cacheDur} ms (clusters=${builtClusters.length})",
      );

      // ✅ Apply dataset consistently
      _applyClustersAsDataset(builtClusters, fit: true);
    } catch (e, st) {
      debugPrint("[MAP_PEOPLE] ❌ Exception dans _loadAndBuild: $e");
      debugPrint("[MAP_PEOPLE] Stack: $st");

      if (_cacheIsFresh) {
        debugPrint(
          "[MAP_PEOPLE] ⚠️ Erreur réseau mais cache dispo, utilisation du cache",
        );

        // ✅ Rejoue la même logique que le chemin cache normal
        _applyClustersAsDataset(
          List<_CityCluster>.from(_clustersCache!),
          fit: false, // évite un refit => évite des tuiles MapTiler
        );

        // SnackBar seulement si l'écran n'est plus en "initializing"
        if (mounted && !_initializing) {
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
          _initializing = false;
        });
      }
    }
  }

  // Fit après frame : clusters pays
  // ✅ Optimisé: ne fit pas si les bounds n'ont pas vraiment changé
  void _fitOnNextFrameOnceCountry() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final sig = _computeFitSig(_countryClusters);

      // ⚠️ Assure-toi d’avoir dans ton State:
      // int _lastFitSig = 0;
      if (sig == _lastFitSig) return;
      _lastFitSig = sig;

      if (_didInitialFit) return;
      _didInitialFit = true;

      _fitMapToCountryClusters(_countryClusters);
    });
  }
}
