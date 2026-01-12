// lib/mapCartoPeople/mapCartoPeople_state_filters.dart
part of map_carto_people;

extension _MapPeopleFilters on _MapPeopleByCityState {
  // ----------------------------
  // Labels
  // ----------------------------
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

  // ✅ Affichage pays: nom traduit si dispo, sinon ISO2
  String _countryLabel(BuildContext context, String iso2) {
    final code = iso2.trim().toUpperCase();
    final label = _countryLabelsByIso2[code];
    return (label == null || label.trim().isEmpty) ? code : label;
  }

  // ----------------------------
  // Drill-down navigation
  // ----------------------------
  void _backToCountries({bool fit = true}) {
    setState(() {
      _level = _MapLevel.country;
      _activeCountry = null;
    });

    _rebuildMarkers();
    if (fit) _fitMapToCountryClusters(_countryClusters);
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
    if (fit) _fitMapToClusters(_clusters);
  }

  // ----------------------------
  // Reset (global state)
  // ----------------------------
  void _resetFiltersToDefault({bool rebuild = true}) {
    _selectedGenotypes
      ..clear()
      ..addAll(kGenotypeOptions);

    _selectedCountries
      ..clear()
      ..addAll(_countryOptions);

    _selectedMinAge = _datasetMinAge;
    _selectedMaxAge = _datasetMaxAge;

    _distanceFilterEnabled = false;
    _distanceOrigin = null;
    _maxDistanceKm = null;

    if (rebuild) {
      _level = _MapLevel.country;
      _activeCountry = null;

      _clusters = _allClusters;
      _countryClusters = _buildCountryClustersFromCityClusters(_allClusters);

      _rebuildMarkers();
      _fitMapToCountryClusters(_countryClusters);
    }
    _filteredAllClusters = _allClusters;
  }

  // ----------------------------
  // Distance match
  // ----------------------------
  bool _matchesDistance(LatLng cityPos) {
    if (!_distanceFilterEnabled ||
        _distanceOrigin == null ||
        _maxDistanceKm == null) {
      return true;
    }
    final dKm = _geo.as(LengthUnit.Kilometer, _distanceOrigin!, cityPos);
    return dKm <= _maxDistanceKm!;
  }

  // ----------------------------
  // Apply filters (global state)
  // ----------------------------
  Future<void> _applyFilters({
    bool rebuildOnly = false,
    bool doFit = true,
  }) async {
    try {
      // ✅ base “full dataset”
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

      bool matchesCountry(String? iso2) {
        if (_selectedCountries.isEmpty) return true;
        if (iso2 == null) return false;
        final v = iso2.trim().toUpperCase();
        if (v.length != 2) return false;
        return _selectedCountries.contains(v);
      }

      bool matchesAge(int? age) {
        if (_selectedMinAge == null || _selectedMaxAge == null) return true;
        if (age == null) return false;
        return age >= _selectedMinAge! && age <= _selectedMaxAge!;
      }

      // ✅ calcule la source filtrée globale
      if (!rebuildOnly) {
        final filtered = <_CityCluster>[];

        for (final c in _allClusters) {
          if (!_matchesDistance(c.latLng)) continue;

          final filteredPeople = <_Person>[];
          for (final p in c.people) {
            if (matchesGenotype(p.genotype) &&
                matchesAge(p.ageInt) &&
                matchesCountry(p.countryCode)) {
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

      // ✅ IMPORTANT : on mémorise la source filtrée
      _filteredAllClusters = source;

      // ✅ rebuild des pays à partir de la source filtrée (pas _allClusters)
      _countryClusters = _buildCountryClustersFromCityClusters(
        _filteredAllClusters,
      );

      // ✅ si on est déjà en drilldown pays -> villes, on garde le même pays
      if (_level == _MapLevel.city && _activeCountry != null) {
        final cc = _countryClusters
            .where((c) => c.countryCode == _activeCountry)
            .toList();

        if (cc.isEmpty) {
          // pays n'existe plus après filtre -> retour liste pays
          _backToCountries(fit: doFit);
        } else {
          // ✅ villes filtrées du pays actif
          _clusters = cc.first.cities;
          _rebuildMarkers();
          if (doFit) _fitMapToClusters(_clusters);
        }
      } else {
        // ✅ sinon on revient au niveau pays (filtré)
        _level = _MapLevel.country;
        _activeCountry = null;
        _rebuildMarkers();
        if (doFit) _fitMapToCountryClusters(_countryClusters);
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

  // ----------------------------
  // Tooltip résumé filtres
  // ----------------------------
  String _filtersTooltipText(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final genoCount = _selectedGenotypes.length;
    final genoPart = genoCount > 0 ? l10n.mapGenotypeCount(genoCount) : null;

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
    ].whereType<String>().toList();

    return parts.isEmpty ? l10n.mapNoFilters : parts.join(' • ');
  }

  // ----------------------------
  // Fit map : villes
  // ----------------------------
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

  // ----------------------------
  // Fit map : pays
  // ----------------------------
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

  void _enterCountry(_CountryCluster country) {
    setState(() {
      _level = _MapLevel.city;
      _activeCountry = country.countryCode;
    });

    // ✅ drilldown SUR LA SOURCE FILTRÉE (sinon tu perds les filtres)
    final base = _filteredAllClusters.isNotEmpty
        ? _filteredAllClusters
        : _allClusters;

    _clusters = base
        .map((cl) {
          final people = cl.people
              .where(
                (p) =>
                    (p.countryCode ?? '').trim().toUpperCase() ==
                    country.countryCode,
              )
              .toList();
          if (people.isEmpty) return null;
          return _CityCluster(city: cl.city, latLng: cl.latLng, people: people);
        })
        .whereType<_CityCluster>()
        .toList();

    _rebuildMarkers();
    _fitMapToClusters(_clusters);
  }

  // ----------------------------
  // BottomSheet filtres
  // ----------------------------
  Future<void> _openSettingsSheet() async {
    if (_level == _MapLevel.city) return; // ✅ pas de filtres au niveau villes
    // ✅ s'assure qu'on a les libellés pays dans la bonne langue
    await _ensureCountryLabelsForLocale(context);

    final tempCountries = Set<String>.from(_selectedCountries);
    final tempGenos = Set<String>.from(_selectedGenotypes);
    int? localMin = _selectedMinAge ?? _datasetMinAge;
    int? localMax = _selectedMaxAge ?? _datasetMaxAge;

    bool localDistanceEnabled = _distanceFilterEnabled;
    LatLng? localOrigin = _distanceOrigin;
    double localMaxKm = _maxDistanceKm ?? 100.0;

    bool ageTouched = false;

    bool genotypeOk(String? g) {
      if (tempGenos.isEmpty) return false;
      if (g == null || g.trim().isEmpty) return false;
      final norm = g.trim().toLowerCase();
      for (final sel in tempGenos) {
        if (norm == sel.trim().toLowerCase()) return true;
      }
      return false;
    }

    bool countryOk(String? iso2) {
      if (tempCountries.isEmpty) return true;
      if (iso2 == null) return false;
      final v = iso2.trim().toUpperCase();
      if (v.length != 2) return false;
      return tempCountries.contains(v);
    }

    bool distanceOk(LatLng cityPos) {
      if (!localDistanceEnabled || localOrigin == null || localMaxKm <= 0) {
        return true;
      }
      final dKm = _geo.as(LengthUnit.Kilometer, localOrigin!, cityPos);
      return dKm <= localMaxKm;
    }

    List<_Person> _peopleModalFilteredByGenoCountryDist() {
      final out = <_Person>[];
      for (final c in _allClusters) {
        if (!distanceOk(c.latLng)) continue;
        for (final p in c.people) {
          if (genotypeOk(p.genotype) && countryOk(p.countryCode)) {
            out.add(p);
          }
        }
      }
      return out;
    }

    ({bool hasAges, int minAge, int maxAge}) _currentAgeDomainForModal() {
      final ages =
          _peopleModalFilteredByGenoCountryDist()
              .map((p) => p.ageInt)
              .whereType<int>()
              .toList()
            ..sort();
      if (ages.isEmpty) return (hasAges: false, minAge: 0, maxAge: 0);
      return (hasAges: true, minAge: ages.first, maxAge: ages.last);
    }

    void _syncAgeSelectionToDomain(StateSetter setModalState) {
      final dom = _currentAgeDomainForModal();

      if (!dom.hasAges) {
        setModalState(() {
          localMin = null;
          localMax = null;
        });
        return;
      }

      setModalState(() {
        // ✅ on garde la sélection existante si elle existe, sinon on prend le domaine complet
        final prevMin = localMin ?? dom.minAge;
        final prevMax = localMax ?? dom.maxAge;

        localMin = prevMin.clamp(dom.minAge, dom.maxAge);
        localMax = prevMax.clamp(dom.minAge, dom.maxAge);

        // ✅ sécurité si le domaine s’est fortement resserré
        if (localMin! > localMax!) {
          localMin = dom.minAge;
          localMax = dom.maxAge;
        }
      });
    }

    int _countModalWithAgeBounds(int minA, int maxA) {
      int count = 0;

      for (final c in _allClusters) {
        if (!distanceOk(c.latLng)) continue;

        for (final p in c.people) {
          if (!tempGenos.contains((p.genotype ?? '').trim())) continue;
          if (!countryOk(p.countryCode)) continue;

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
            final l10n = AppLocalizations.of(ctx)!;

            final dom = _currentAgeDomainForModal();
            final bool hasAges = dom.hasAges;
            final int minAge = hasAges ? dom.minAge : 0;
            final int maxAge = hasAges ? dom.maxAge : 0;

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

            final int startI = hasAges ? localMin! : 0;
            final int endI = hasAges ? localMax! : 0;
            final int resultsCount = hasAges
                ? _countModalWithAgeBounds(startI, endI)
                : 0;

            // ✅ tri par libellé traduit (fallback ISO2)
            final sortedCountryOptions = [..._countryOptions]
              ..sort(
                (a, b) => _countryLabel(
                  ctx,
                  a,
                ).toLowerCase().compareTo(_countryLabel(ctx, b).toLowerCase()),
              );

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
                                    ? l10n.mapResultsCount(resultsCount)
                                    : l10n.mapNoResultsWithTheseFilters,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: hasAges
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
                              _syncAgeSelectionToDomain(setModalState);
                            } else {
                              setModalState(() => localDistanceEnabled = false);
                            }
                          } else {
                            setModalState(() => localDistanceEnabled = false);
                            _syncAgeSelectionToDomain(setModalState);
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
                              _syncAgeSelectionToDomain(setModalState);
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
                                onChanged: (v) {
                                  setModalState(() => localMaxKm = v);
                                  _syncAgeSelectionToDomain(setModalState);
                                },
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
                                  onPressed: () {
                                    setModalState(() {
                                      tempCountries
                                        ..clear()
                                        ..addAll(_countryOptions);
                                    });
                                    _syncAgeSelectionToDomain(setModalState);
                                  },
                                  child: Text(l10n.mapSelectAll),
                                ),
                                TextButton(
                                  onPressed: () {
                                    setModalState(() => tempCountries.clear());
                                    _syncAgeSelectionToDomain(setModalState);
                                  },
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
                                  _syncAgeSelectionToDomain(setModalState);
                                },
                              );
                            }).toList(),
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
                            _syncAgeSelectionToDomain(setModalState);
                          },
                        );
                      }).toList(),

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
                            Text(l10n.mapMinValue(startI)),
                            Text(l10n.mapMaxValue(endI)),
                          ],
                        ),
                        RangeSlider(
                          values: RangeValues(
                            startI.toDouble(),
                            endI.toDouble(),
                          ),
                          min: minAge.toDouble(),
                          max: maxAge.toDouble(),
                          divisions: (maxAge - minAge) > 0
                              ? (maxAge - minAge)
                              : null,
                          labels: RangeLabels(
                            startI.toString(),
                            endI.toString(),
                          ),
                          onChanged: (rng) {
                            setModalState(() {
                              ageTouched = true;
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
                            onPressed: () {
                              setModalState(() {
                                ageTouched = false;
                                tempCountries
                                  ..clear()
                                  ..addAll(_countryOptions);
                                tempGenos
                                  ..clear()
                                  ..addAll(kGenotypeOptions);

                                localDistanceEnabled = false;
                                localOrigin = null;
                                localMaxKm = 100.0;

                                final dom = _currentAgeDomainForModal();
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
                            child: Text(l10n.mapCancel),
                            onPressed: () => Navigator.of(ctx).pop(),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            icon: const Icon(Ionicons.checkmark),
                            label: Text(l10n.mapApply),
                            onPressed: () async {
                              _selectedGenotypes
                                ..clear()
                                ..addAll(tempGenos);

                              _selectedCountries
                                ..clear()
                                ..addAll(tempCountries);

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
