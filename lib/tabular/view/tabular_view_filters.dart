// lib/tabular/view/tabular_view_filters.dart
part of 'tabular_view.dart';

extension _TabularFilters on _TabularViewState {
  // ---------------------------------------------------------------------------
  // Objectif (cohérence + simplification)
  // - Min/Max âge = domaine du dataset (=_allPeople), PAS recalculé selon autres critères
  // - Les filtres appliqués doivent prendre en compte :
  //   âge + pays + génotypes + connecté + distance
  //
  // IMPORTANT :
  // - Pour éviter d'exclure des personnes "sans âge" quand le slider est full-range,
  //   le filtre âge est actif seulement si l'utilisateur a resserré la plage.
  // - Pour éviter d'exclure des personnes à cause de countryCode sale (espaces, lowercase, etc),
  //   on normalise toujours countryCode avec trim().toUpperCase().
  // ---------------------------------------------------------------------------

  // ----------------------------
  // Options (doit rester aligné avec kTabularGenotypeOptions)
  // ----------------------------
  static const List<String> kGenotypeOptions = <String>[
    'délétion',
    'mutation',
    'upd',
    'icd',
    'clinique',
    'mosaïque',
  ];

  // ----------------------------
  // Normalisation
  // ----------------------------
  String _normIso2(String? raw) => (raw ?? '').trim().toUpperCase();
  bool _isIso2(String s) => s.length == 2;

  // ----------------------------
  // Distance helper (Haversine) — km
  // (garde ta version : OK)
  // ----------------------------
  double _haversineKm({
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

  bool _matchesDistance(Person p) {
    if (!_distanceFilterEnabled) return true;

    final maxKm = _maxDistanceKm;
    final oLat = _distanceOriginLat;
    final oLng = _distanceOriginLng;

    // origine/max non définis => filtre OFF
    if (maxKm == null || oLat == null || oLng == null) return true;

    final lat = p.latitude;
    final lng = p.longitude;
    if (lat == null || lng == null) return false;

    final d = _haversineKm(lat1: oLat, lon1: oLng, lat2: lat, lon2: lng);
    return d <= maxKm;
  }

  // ----------------------------
  // Labels
  // ----------------------------
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

  String _countryLabelForIso2(BuildContext ctx, String iso2) {
    final code = _normIso2(iso2);
    final translated = _countriesByCode[code];
    return (translated == null || translated.trim().isEmpty)
        ? code
        : translated.trim();
  }

  // ----------------------------
  // Domaine âge (dataset) : uniquement basé sur _allPeople
  // ----------------------------
  void _recomputeAgeDomainFromAllPeople() {
    final ages = _allPeople.map((p) => p.age).whereType<int>().toList()..sort();
    if (ages.isEmpty) {
      _datasetMinAge = null;
      _datasetMaxAge = null;
      return;
    }

    _datasetMinAge = ages.first;
    _datasetMaxAge = ages.last;

    // default full-range
    _selectedMinAge ??= _datasetMinAge;
    _selectedMaxAge ??= _datasetMaxAge;

    // clamp
    _selectedMinAge = _selectedMinAge!.clamp(_datasetMinAge!, _datasetMaxAge!);
    _selectedMaxAge = _selectedMaxAge!.clamp(_datasetMinAge!, _datasetMaxAge!);

    if (_selectedMinAge! > _selectedMaxAge!) {
      _selectedMinAge = _datasetMinAge;
      _selectedMaxAge = _datasetMaxAge;
    }
  }

  List<String> get _countryOptions {
    // Hash cheap : longueur + 3 ids (début/milieu/fin)
    final n = _allPeople.length;
    int h = n;
    if (n > 0) {
      h = 31 * h + _allPeople.first.id.hashCode;
      h = 31 * h + _allPeople[n ~/ 2].id.hashCode;
      h = 31 * h + _allPeople.last.id.hashCode;
    }

    if (h == _countryOptionsCacheHash && _countryOptionsCache.isNotEmpty) {
      return _countryOptionsCache;
    }

    final set = <String>{};
    for (final p in _allPeople) {
      final c = _normIso2(p.countryCode);
      if (_isIso2(c)) set.add(c);
    }

    final list = set.toList()
      ..sort(
        (a, b) => _countryLabelForIso2(context, a).toLowerCase().compareTo(
          _countryLabelForIso2(context, b).toLowerCase(),
        ),
      );

    _countryOptionsCacheHash = h;
    _countryOptionsCache = list;
    return list;
  }

  // ----------------------------
  // Matching genotype (optimisé + robuste)
  // ----------------------------
  bool _matchGenotypeNorm(String genotypeNorm, String selNorm) {
    // cas "délétion" / "deletion" / "del"
    final selIsDeletion = selNorm.contains('dél') || selNorm.contains('del');
    if (selIsDeletion &&
        (genotypeNorm.contains('dél') ||
            genotypeNorm.contains('del') ||
            genotypeNorm.contains('deletion'))) {
      return true;
    }

    // match générique
    return genotypeNorm.contains(selNorm) || selNorm.contains(genotypeNorm);
  }

  bool _matchesGenotypeWithSelection(Person p, Set<String> selectedNorm) {
    final g = (p.genotype ?? '').trim();
    if (g.isEmpty) return false;

    final norm = g.toLowerCase();
    for (final sel in selectedNorm) {
      if (_matchGenotypeNorm(norm, sel)) return true;
    }
    return false;
  }

  // ----------------------------
  // "Predicate" unique : utilisé partout (liste + compteur live)
  // ----------------------------
  bool _matchesAllFilters(
    Person p, {
    required bool genotypeActive,
    required Set<String> selectedGenotypesNorm,
    required bool countryActive,
    required Set<String> selectedCountriesNorm,
    required bool connectedOnly,
    required bool ageActive,
    required int? minAge,
    required int? maxAge,
    required bool distanceEnabled,
    required double? originLat,
    required double? originLng,
    required double? maxKm,
  }) {
    // distance
    if (distanceEnabled) {
      if (originLat == null || originLng == null || maxKm == null) {
        // si on dit "enabled" mais pas prêt => on exclut (cohérent avec UI distance)
        return false;
      }
      final lat = p.latitude;
      final lng = p.longitude;
      if (lat == null || lng == null) return false;
      final d = _haversineKm(
        lat1: originLat,
        lon1: originLng,
        lat2: lat,
        lon2: lng,
      );
      if (d > maxKm) return false;
    }

    // genotype
    if (genotypeActive) {
      if (!_matchesGenotypeWithSelection(p, selectedGenotypesNorm))
        return false;
    }

    // country
    if (countryActive) {
      final code = _normIso2(p.countryCode);
      if (!_isIso2(code) || !selectedCountriesNorm.contains(code)) return false;
    }

    // connected
    if (connectedOnly && !p.isConnected) return false;

    // age
    if (ageActive) {
      final a = p.age;
      if (a == null) return false;
      final mi = minAge!;
      final ma = maxAge!;
      if (a < mi || a > ma) return false;
    }

    return true;
  }

  // ----------------------------
  // Apply filters -> _view (unique)
  // ----------------------------
  void _applyTabularFilters({bool keepSort = true}) {
    final countryOpts = _countryOptions;

    final genotypeActive =
        _selectedGenotypes.isNotEmpty &&
        _selectedGenotypes.length != kGenotypeOptions.length;

    final countryActive =
        _selectedCountries.isNotEmpty &&
        countryOpts.isNotEmpty &&
        _selectedCountries.length != countryOpts.length;

    final minA = _selectedMinAge;
    final maxA = _selectedMaxAge;

    final ageActive =
        _datasetMinAge != null &&
        _datasetMaxAge != null &&
        minA != null &&
        maxA != null &&
        (minA != _datasetMinAge || maxA != _datasetMaxAge);

    final selectedGenotypesNorm = genotypeActive
        ? _selectedGenotypes.map((e) => e.trim().toLowerCase()).toSet()
        : const <String>{};

    final selectedCountriesNorm = countryActive
        ? _selectedCountries.map((e) => _normIso2(e)).toSet()
        : const <String>{};

    // distance config
    final distanceEnabled =
        _distanceFilterEnabled &&
        _distanceOriginLat != null &&
        _distanceOriginLng != null &&
        _maxDistanceKm != null;

    final filtered = <Person>[];
    for (final p in _allPeople) {
      final ok = _matchesAllFilters(
        p,
        genotypeActive: genotypeActive,
        selectedGenotypesNorm: selectedGenotypesNorm,
        countryActive: countryActive,
        selectedCountriesNorm: selectedCountriesNorm,
        connectedOnly: _connectedOnly,
        ageActive: ageActive,
        minAge: minA,
        maxAge: maxA,
        distanceEnabled: distanceEnabled,
        originLat: _distanceOriginLat,
        originLng: _distanceOriginLng,
        maxKm: _maxDistanceKm,
      );
      if (ok) filtered.add(p);
    }

    setState(() {
      _view = filtered;
    });

    if (keepSort && _sortColumnIndex != null) {
      _applySort(_sortColumnIndex!, _sortAscending);
    }
  }

  // ----------------------------
  // Tooltip résumé filtres
  // ----------------------------
  String _tabularFiltersTooltipText(BuildContext ctx) {
    final l10n = AppLocalizations.of(ctx)!;

    final genoActive =
        _selectedGenotypes.isNotEmpty &&
        _selectedGenotypes.length != kGenotypeOptions.length;
    final genoPart = genoActive
        ? l10n.mapGenotypeCount(_selectedGenotypes.length)
        : null;

    final allCountries = _countryOptions;
    final countryActive =
        allCountries.isNotEmpty &&
        _selectedCountries.isNotEmpty &&
        _selectedCountries.length != allCountries.length;
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

    final distActive =
        _distanceFilterEnabled &&
        _distanceOriginLat != null &&
        _distanceOriginLng != null &&
        _maxDistanceKm != null;
    final distPart = distActive
        ? l10n.mapDistanceMaxKm(_maxDistanceKm!.toStringAsFixed(0))
        : null;

    final parts = <String?>[
      genoPart,
      countryPart,
      agePart,
      distPart,
      connectedPart,
    ].whereType<String>().toList();

    return parts.isEmpty ? l10n.mapNoFilters : parts.join(' • ');
  }

  // ----------------------------
  // Reset filtres
  // ----------------------------
  void _resetTabularFiltersToDefault() {
    _selectedGenotypes
      ..clear()
      ..addAll(kGenotypeOptions);

    _selectedCountries
      ..clear()
      ..addAll(_countryOptions);

    _connectedOnly = false;

    _selectedMinAge = _datasetMinAge;
    _selectedMaxAge = _datasetMaxAge;

    _distanceFilterEnabled = false;
    _distanceOriginLat = null;
    _distanceOriginLng = null;
    _maxDistanceKm = null;

    _applyTabularFilters();
  }

  // ----------------------------
  // BottomSheet filtres
  // - utilise EXACTEMENT le même predicate que la liste
  // - pas de recalcul dynamique min/max âge
  // ----------------------------
  Future<void> _openTabularFiltersSheet() async {
    await _loadCountriesIfNeeded();
    _recomputeAgeDomainFromAllPeople();

    bool localConnectedOnly = _connectedOnly;
    final tempCountries = Set<String>.from(_selectedCountries);
    final tempGenos = Set<String>.from(_selectedGenotypes);

    int? localMin = _selectedMinAge ?? _datasetMinAge;
    int? localMax = _selectedMaxAge ?? _datasetMaxAge;

    bool localDistanceEnabled = _distanceFilterEnabled;
    double? localOriginLat = _distanceOriginLat;
    double? localOriginLng = _distanceOriginLng;
    double localMaxKm = _maxDistanceKm ?? 100.0;

    int countResultsWithLocalFilters() {
      final countryOpts = _countryOptions;

      final genotypeActive =
          tempGenos.isNotEmpty && tempGenos.length != kGenotypeOptions.length;

      final countryActive =
          tempCountries.isNotEmpty &&
          countryOpts.isNotEmpty &&
          tempCountries.length != countryOpts.length;

      final minA = localMin;
      final maxA = localMax;

      final ageActive =
          _datasetMinAge != null &&
          _datasetMaxAge != null &&
          minA != null &&
          maxA != null &&
          (minA != _datasetMinAge || maxA != _datasetMaxAge);

      final selectedGenotypesNorm = genotypeActive
          ? tempGenos.map((e) => e.trim().toLowerCase()).toSet()
          : const <String>{};

      final selectedCountriesNorm = countryActive
          ? tempCountries.map((e) => _normIso2(e)).toSet()
          : const <String>{};

      final distanceEnabled =
          localDistanceEnabled &&
          localOriginLat != null &&
          localOriginLng != null;

      int count = 0;
      for (final p in _allPeople) {
        final ok = _matchesAllFilters(
          p,
          genotypeActive: genotypeActive,
          selectedGenotypesNorm: selectedGenotypesNorm,
          countryActive: countryActive,
          selectedCountriesNorm: selectedCountriesNorm,
          connectedOnly: localConnectedOnly,
          ageActive: ageActive,
          minAge: minA,
          maxAge: maxA,
          distanceEnabled: distanceEnabled,
          originLat: localOriginLat,
          originLng: localOriginLng,
          maxKm: localDistanceEnabled ? localMaxKm : null,
        );
        if (ok) count++;
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

                      // -----------------------------------------------------------------
                      // Distance
                      // -----------------------------------------------------------------
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          l10n.mapDistanceTitle,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(l10n.mapEnableDistanceFilter),
                        value: localDistanceEnabled,
                        onChanged: (v) async {
                          if (v) {
                            setModalState(() => localDistanceEnabled = true);

                            final ok = await _ensureLocation();
                            if (ok &&
                                _distanceOriginLat != null &&
                                _distanceOriginLng != null) {
                              setModalState(() {
                                localOriginLat = _distanceOriginLat;
                                localOriginLng = _distanceOriginLng;
                              });
                            } else {
                              setModalState(() => localDistanceEnabled = false);
                            }
                          } else {
                            setModalState(() => localDistanceEnabled = false);
                          }
                        },
                      ),
                      ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          (localOriginLat != null && localOriginLng != null)
                              ? l10n.mapOriginDefined(
                                  localOriginLat!.toStringAsFixed(4),
                                  localOriginLng!.toStringAsFixed(4),
                                )
                              : l10n.mapOriginUndefined,
                        ),
                        trailing: TextButton.icon(
                          icon: const Icon(Icons.my_location),
                          label: Text(l10n.mapMyPosition),
                          onPressed: () async {
                            final ok = await _ensureLocation();
                            if (ok &&
                                _distanceOriginLat != null &&
                                _distanceOriginLng != null) {
                              setModalState(() {
                                localDistanceEnabled = true;
                                localOriginLat = _distanceOriginLat;
                                localOriginLng = _distanceOriginLng;
                              });
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
                                label: l10n.mapKmLabel(
                                  localMaxKm.toStringAsFixed(0),
                                ),
                                onChanged: (v) =>
                                    setModalState(() => localMaxKm = v),
                              ),
                            ),
                            SizedBox(
                              width: 72,
                              child: Text(
                                l10n.mapKmLabel(localMaxKm.toStringAsFixed(0)),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                      ],

                      const SizedBox(height: 16),

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
                                  onPressed: () => setModalState(() {
                                    tempCountries.clear();
                                  }),
                                  child: Text(l10n.mapClear),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ...sortedCountryOptions.map((iso2) {
                              final checked = tempCountries.contains(iso2);
                              return CheckboxListTile(
                                value: checked,
                                title: Text(_countryLabelForIso2(ctx, iso2)),
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
                      ...kGenotypeOptions.map((g) {
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
                                ..addAll(kGenotypeOptions);

                              tempCountries
                                ..clear()
                                ..addAll(sortedCountryOptions);

                              localDistanceEnabled = false;
                              localOriginLat = null;
                              localOriginLng = null;
                              localMaxKm = 100.0;

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

                              _distanceFilterEnabled = localDistanceEnabled;
                              _distanceOriginLat = localOriginLat;
                              _distanceOriginLng = localOriginLng;
                              _maxDistanceKm = localDistanceEnabled
                                  ? localMaxKm
                                  : null;

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
}
