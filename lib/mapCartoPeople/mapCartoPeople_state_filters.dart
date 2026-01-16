// lib/mapCartoPeople/mapCartoPeople_state_filters.dart
part of map_carto_people;

extension _MapPeopleFilters on _MapPeopleByCityState {
  // ---------------------------------------------------------------------------
  // Labels
  // ---------------------------------------------------------------------------

  String _genotypeLabel(BuildContext context, String raw) {
    final l10n = AppLocalizations.of(context)!;
    switch (raw.trim().toLowerCase()) {
      case 'délétion':
      case 'deletion':
        return l10n.genotypeDeletion;
      case 'mutation':
        return l10n.genotypeMutation;
      case 'upd':
        return l10n.genotypeUPD;
      case 'icd':
        return l10n.genotypeICD;
      case 'clinique':
      case 'clinical':
        return l10n.genotypeClinical;
      case 'mosaïque':
      case 'mosaique':
      case 'mosaic':
        return l10n.genotypeMosaic;
      default:
        return raw;
    }
  }

  String _countryLabel(BuildContext context, String iso2) {
    final code = iso2.trim().toUpperCase();
    final label = _countryLabelsByIso2[code];
    return (label == null || label.trim().isEmpty) ? code : label;
  }

  // ---------------------------------------------------------------------------
  // FIT OPTIM (inchangé)
  // ---------------------------------------------------------------------------

  int _computeCityFitSig(List<_CityCluster> clusters) {
    if (clusters.isEmpty) return 0;
    final lats = clusters.map((c) => c.latLng.latitude).toList()..sort();
    final lngs = clusters.map((c) => c.latLng.longitude).toList()..sort();

    final minLat = (lats.first * 100).round();
    final maxLat = (lats.last * 100).round();
    final minLng = (lngs.first * 100).round();
    final maxLng = (lngs.last * 100).round();

    return minLat ^
        (maxLat << 6) ^
        (minLng << 12) ^
        (maxLng << 18) ^
        clusters.length;
  }

  bool _shouldFitCountries(List<_CountryCluster> clusters) {
    final sig = _computeFitSig(clusters);
    if (sig == _lastFitSig) return false;
    _lastFitSig = sig;
    return true;
  }

  bool _shouldFitCities(List<_CityCluster> clusters) {
    final sig = _computeCityFitSig(clusters);
    if (sig == _lastCityFitSig) return false;
    _lastCityFitSig = sig;
    return true;
  }

  // ---------------------------------------------------------------------------
  // Drill-down navigation (inchangé)
  // ---------------------------------------------------------------------------

  void _backToCountries({bool fit = true}) {
    setState(() {
      _level = _MapLevel.country;
      _activeCountry = null;
    });

    _rebuildMarkers();
    _fitMapToCountryClusters(_countryClusters);
  }

  void _openCountry(String iso2, {bool fit = true}) {
    final code = iso2.trim().toUpperCase();
    _level = _MapLevel.city;
    _activeCountry = code;

    final cc = _countryClusters.where((c) => c.countryCode == code).toList();
    if (cc.isEmpty) {
      _backToCountries(fit: fit);
      return;
    }

    _clusters = cc.first.cities;
    _rebuildMarkers();

    if (fit && _shouldFitCities(_clusters)) {
      _fitMapToClusters(_clusters);
    }
  }

  // ---------------------------------------------------------------------------
  // Reset (inchangé)
  // ---------------------------------------------------------------------------

  void _resetFiltersToDefault({bool rebuild = true}) {
    _selectedGenotypes
      ..clear()
      ..addAll(kGenotypeOptions);

    _selectedCountries
      ..clear()
      ..addAll(_countryOptions);

    _connectedOnly = false;

    // ✅ Domaine âge = dataset complet
    _selectedMinAge = _datasetMinAge;
    _selectedMaxAge = _datasetMaxAge;

    _distanceFilterEnabled = false;
    _distanceOrigin = null;
    _maxDistanceKm = null;

    if (rebuild) {
      final wasCityLevel = _level == _MapLevel.city;

      _level = _MapLevel.country;
      _activeCountry = null;

      _clusters = _allClusters;
      _countryClusters = _buildCountryClustersFromCityClusters(_allClusters);

      _rebuildMarkers();

      _lastFitSig = 0;
      _lastCityFitSig = 0;
      _didInitialFit = false;

      final z = _map.camera.zoom;
      final mustFit = wasCityLevel || z > 6.2;

      if (mustFit) {
        _fitMapToCountryClusters(_countryClusters);
      } else {
        if (_shouldFitCountries(_countryClusters)) {
          _fitMapToCountryClusters(_countryClusters);
        }
      }
    }

    _filteredAllClusters = _allClusters;
  }

  // ---------------------------------------------------------------------------
  // Distance match
  // ---------------------------------------------------------------------------

  bool _matchesDistance(LatLng cityPos) {
    if (!_distanceFilterEnabled ||
        _distanceOrigin == null ||
        _maxDistanceKm == null) {
      return true;
    }
    final dKm = _geo.as(LengthUnit.Kilometer, _distanceOrigin!, cityPos);
    return dKm <= _maxDistanceKm!;
  }

  // ---------------------------------------------------------------------------
  // ✅ Helpers “filtres actifs”
  // ---------------------------------------------------------------------------

  bool get _genotypeFilterActive =>
      _selectedGenotypes.isNotEmpty &&
      _selectedGenotypes.length != kGenotypeOptions.length;

  bool get _countryFilterActive =>
      _selectedCountries.isNotEmpty &&
      _countryOptions.isNotEmpty &&
      _selectedCountries.length != _countryOptions.length;

  bool get _ageFilterActive {
    final minA = _selectedMinAge;
    final maxA = _selectedMaxAge;
    if (minA == null || maxA == null) return false;
    if (_datasetMinAge == null || _datasetMaxAge == null) return false;
    return (minA != _datasetMinAge || maxA != _datasetMaxAge);
  }

  bool _matchesGenotype(String? g, Set<String> selected) {
    final active =
        selected.isNotEmpty && selected.length != kGenotypeOptions.length;
    if (!active) return true;

    if (g == null || g.trim().isEmpty) return false;
    final norm = g.trim().toLowerCase();

    for (final sel in selected) {
      final s = sel.trim().toLowerCase();
      if (norm == s) return true;
    }
    return false;
  }

  bool _matchesCountry(String? iso2, Set<String> selected, List<String> opts) {
    final active =
        selected.isNotEmpty &&
        opts.isNotEmpty &&
        selected.length != opts.length;
    if (!active) return true;

    if (iso2 == null) return false;
    final v = iso2.trim().toUpperCase();
    if (v.length != 2) return false;
    return selected.contains(v);
  }

  bool _matchesConnected(_Person p, bool connectedOnly) {
    if (!connectedOnly) return true;
    return p.isConnected;
  }

  bool _matchesAge(int? age, int? minA, int? maxA, int? dsMin, int? dsMax) {
    if (minA == null || maxA == null || dsMin == null || dsMax == null) {
      return true;
    }

    // ✅ filtre actif seulement si on a resserré la plage (sinon on inclut tout)
    final active = (minA != dsMin || maxA != dsMax);
    if (!active) return true;

    if (age == null) return false;
    return age >= minA && age <= maxA;
  }

  // ---------------------------------------------------------------------------
  // ✅ Apply filters (global state) — sans recalcul domaine âge
  // ---------------------------------------------------------------------------

  Future<void> _applyFilters({
    bool rebuildOnly = false,
    bool doFit = true,
  }) async {
    try {
      List<_CityCluster> source = _allClusters;

      if (!rebuildOnly) {
        final filtered = <_CityCluster>[];

        for (final c in _allClusters) {
          if (!_matchesDistance(c.latLng)) continue;

          final people = <_Person>[];
          for (final p in c.people) {
            if (!_matchesGenotype(p.genotype, _selectedGenotypes)) continue;
            if (!_matchesCountry(
              p.countryCode,
              _selectedCountries,
              _countryOptions,
            ))
              continue;
            if (!_matchesConnected(p, _connectedOnly)) continue;
            if (!_matchesAge(
              p.ageInt,
              _selectedMinAge,
              _selectedMaxAge,
              _datasetMinAge,
              _datasetMaxAge,
            ))
              continue;

            people.add(p);
          }

          if (people.isNotEmpty) {
            filtered.add(
              _CityCluster(city: c.city, latLng: c.latLng, people: people),
            );
          }
        }

        source = filtered;
      }

      _filteredAllClusters = source;
      _countryClusters = _buildCountryClustersFromCityClusters(
        _filteredAllClusters,
      );

      final currentZ = _map.camera.zoom;
      final bool allowFit = currentZ < 8.2;

      if (_level == _MapLevel.city && _activeCountry != null) {
        final cc = _countryClusters
            .where((c) => c.countryCode == _activeCountry)
            .toList();

        if (cc.isEmpty) {
          _backToCountries(fit: doFit && allowFit);
        } else {
          _clusters = cc.first.cities;
          _rebuildMarkers();

          if (doFit && allowFit && _shouldFitCities(_clusters)) {
            _fitMapToClusters(_clusters);
          }
        }
      } else {
        _level = _MapLevel.country;
        _activeCountry = null;

        _rebuildMarkers();

        if (doFit && allowFit && _shouldFitCountries(_countryClusters)) {
          _fitMapToCountryClusters(_countryClusters);
        }
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        _error = e.toString();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.mapFilterError(e.toString()))),
        );
        setState(() {});
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Tooltip (inchangé, mais “genoPart” devrait être actif seulement si filtre actif)
  // ---------------------------------------------------------------------------

  String _filtersTooltipText(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final genoActive =
        _selectedGenotypes.isNotEmpty &&
        _selectedGenotypes.length != kGenotypeOptions.length;
    final genoPart = genoActive
        ? l10n.mapGenotypeCount(_selectedGenotypes.length)
        : null;

    final countryActive =
        _countryOptions.isNotEmpty &&
        _selectedCountries.isNotEmpty &&
        _selectedCountries.length != _countryOptions.length;
    final countryPart = countryActive
        ? l10n.mapCountriesSelectedCount(_selectedCountries.length)
        : null;

    final ageActive =
        _selectedMinAge != null &&
        _selectedMaxAge != null &&
        _datasetMinAge != null &&
        _datasetMaxAge != null &&
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
        _distanceOrigin != null &&
        _maxDistanceKm != null;
    final distPart = distActive
        ? l10n.mapDistanceMaxKm(_maxDistanceKm!.toStringAsFixed(0))
        : null;

    final parts = [
      genoPart,
      countryPart,
      agePart,
      distPart,
      connectedPart,
    ].whereType<String>().toList();

    return parts.isEmpty ? l10n.mapNoFilters : parts.join(' • ');
  }

  // ---------------------------------------------------------------------------
  // Fit map : villes / pays (inchangé)
  // ---------------------------------------------------------------------------

  void _fitMapToClusters(List<_CityCluster> clusters, {double padding = 36}) {
    if (!mounted) return;
    if (clusters.isEmpty) return;

    final points = clusters.map((c) => c.latLng).toList();
    if (points.length == 1) {
      final p = points.first;
      _map.move(p, (_currentZoom < 9 ? 9.5 : _currentZoom).clamp(3.0, 18.0));
      return;
    }

    final bounds = LatLngBounds.fromPoints(points);
    _map.fitCamera(
      CameraFit.bounds(bounds: bounds, padding: EdgeInsets.all(padding)),
    );
  }

  void _fitMapToCountryClusters(
    List<_CountryCluster> clusters, {
    double padding = 36,
  }) {
    if (!mounted) return;
    if (clusters.isEmpty) return;

    final points = clusters.map((c) => c.latLng).toList();
    if (points.length == 1) {
      final p = points.first;
      _map.move(p, (_currentZoom < 5 ? 5.5 : _currentZoom).clamp(3.0, 18.0));
      return;
    }

    final bounds = LatLngBounds.fromPoints(points);
    _map.fitCamera(
      CameraFit.bounds(bounds: bounds, padding: EdgeInsets.all(padding)),
    );
  }

  // ---------------------------------------------------------------------------
  // ✅ BottomSheet filtres — sans recalcul du domaine âge
  // ---------------------------------------------------------------------------

  Future<void> _openSettingsSheet() async {
    if (_level == _MapLevel.city) return;

    await _ensureCountryLabelsForLocale(context);

    bool localConnectedOnly = _connectedOnly;
    final tempCountries = Set<String>.from(_selectedCountries);
    final tempGenos = Set<String>.from(_selectedGenotypes);

    // ✅ Domaine âge FIXE dataset
    final hasAges = _datasetMinAge != null && _datasetMaxAge != null;
    int? localMin = _selectedMinAge ?? _datasetMinAge;
    int? localMax = _selectedMaxAge ?? _datasetMaxAge;

    bool localDistanceEnabled = _distanceFilterEnabled;
    LatLng? localOrigin = _distanceOrigin;
    double localMaxKm = _maxDistanceKm ?? 100.0;

    int countResultsWithLocalFilters() {
      final countryOpts = _countryOptions;

      final genoActive =
          tempGenos.isNotEmpty && tempGenos.length != kGenotypeOptions.length;
      final countryActive =
          tempCountries.isNotEmpty &&
          countryOpts.isNotEmpty &&
          tempCountries.length != countryOpts.length;

      final ageActive =
          hasAges &&
          localMin != null &&
          localMax != null &&
          (localMin != _datasetMinAge || localMax != _datasetMaxAge);

      int count = 0;

      for (final c in _allClusters) {
        // distance au niveau ville
        if (localDistanceEnabled && localOrigin != null && localMaxKm > 0) {
          final dKm = _geo.as(LengthUnit.Kilometer, localOrigin!, c.latLng);
          if (dKm > localMaxKm) continue;
        }

        for (final p in c.people) {
          // genotype
          if (genoActive) {
            if (!_matchesGenotype(p.genotype, tempGenos)) continue;
          }

          // country
          if (countryActive) {
            final iso = p.countryCode;
            if (iso == null) continue;
            final v = iso.trim().toUpperCase();
            if (v.length != 2 || !tempCountries.contains(v)) continue;
          }

          // connected
          if (localConnectedOnly && !p.isConnected) continue;

          // age (actif seulement si resserré)
          if (ageActive) {
            final a = p.ageInt;
            if (a == null || a < localMin! || a > localMax!) continue;
          }

          count++;
        }
      }

      return count;
    }

    final sortedCountryOptions = [..._countryOptions]
      ..sort(
        (a, b) => _countryLabel(
          context,
          a,
        ).toLowerCase().compareTo(_countryLabel(context, b).toLowerCase()),
      );

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final l10n = AppLocalizations.of(ctx)!;

            // ✅ Clamp slider dans le domaine dataset uniquement
            if (hasAges) {
              final minAge = _datasetMinAge!;
              final maxAge = _datasetMaxAge!;
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
                          const Icon(Ionicons.options),
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
                        padding: const EdgeInsets.only(top: 6.0, bottom: 12.0),
                        child: Row(
                          children: [
                            Icon(
                              resultsCount > 0
                                  ? Ionicons.people
                                  : Ionicons.alert_circle_outline,
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

                      // Distance
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          l10n.mapDistanceTitle,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      SwitchListTile(
                        title: Text(l10n.mapEnableDistanceFilter),
                        value: localDistanceEnabled,
                        onChanged: (v) async {
                          if (v) {
                            setModalState(() => localDistanceEnabled = true);
                            final ok = await _ensureLocation();
                            if (ok && _distanceOrigin != null) {
                              setModalState(() {
                                localOrigin = _distanceOrigin;
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
                          localOrigin != null
                              ? l10n.mapOriginDefined(
                                  localOrigin!.latitude.toStringAsFixed(4),
                                  localOrigin!.longitude.toStringAsFixed(4),
                                )
                              : l10n.mapOriginUndefined,
                        ),
                        trailing: TextButton.icon(
                          icon: const Icon(Ionicons.locate),
                          label: Text(l10n.mapMyPosition),
                          onPressed: () async {
                            final ok = await _ensureLocation();
                            if (ok && _distanceOrigin != null) {
                              setModalState(() {
                                localDistanceEnabled = true;
                                localOrigin = _distanceOrigin;
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
                            tempCountries.length == _countryOptions.length
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
                                      ..addAll(_countryOptions);
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
                                title: Text(_countryLabel(ctx, iso2)),
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
                          title: Text(_genotypeLabel(ctx, g)),
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

                      // Âge — domaine FIXE dataset
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
                          min: _datasetMinAge!.toDouble(),
                          max: _datasetMaxAge!.toDouble(),
                          divisions: (_datasetMaxAge! - _datasetMinAge!) > 0
                              ? (_datasetMaxAge! - _datasetMinAge!)
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

                              tempCountries
                                ..clear()
                                ..addAll(_countryOptions);

                              tempGenos
                                ..clear()
                                ..addAll(kGenotypeOptions);

                              localDistanceEnabled = false;
                              localOrigin = null;
                              localMaxKm = 100.0;

                              localMin = _datasetMinAge;
                              localMax = _datasetMaxAge;
                            }),
                          ),
                          const SizedBox(width: 8),
                          TextButton(
                            child: Text(l10n.mapCancel),
                            onPressed: () => Navigator.of(ctx).pop(),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            icon: const Icon(Ionicons.checkmark),
                            label: Text(l10n.mapApply),
                            onPressed: () async {
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
