//filtres + bottomsheet + labels
// lib/mapCartoPeople/mapCartoPeople_state_filters.dart
part of map_carto_people;

extension _MapPeopleFilters on _MapPeopleByCityState {
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

  void _resetFiltersToDefault({bool rebuild = true}) {
    _selectedGenotypes
      ..clear()
      ..addAll(kGenotypeOptions);
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
        final l10n = AppLocalizations.of(context)!;
        _error = e.toString();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.mapFilterError(e.toString()))),
        );
        setState(() {});
      }
    }
  }

  String _filtersTooltipText(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final genoCount = _selectedGenotypes.length;
    final genoPart = genoCount > 0 ? l10n.mapGenotypeCount(genoCount) : null;

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

    final parts = [genoPart, agePart, distPart].whereType<String>().toList();
    return parts.isEmpty ? l10n.mapNoFilters : parts.join(' • ');
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
        if (g == null || g.trim().isNotEmpty == false) return false;
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
          // geno (compare values as stored from API)
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
            final l10n = AppLocalizations.of(ctx)!;

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
                                color: hasAges ? Colors.black87 : Colors.orange,
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
                              label: l10n.mapKmLabel(
                                localMaxKm.toStringAsFixed(0),
                              ),
                              onChanged: (v) {
                                setModalState(() => localMaxKm = v);
                                _clampAgeSelectionToDomain(setModalState);
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
                          _clampAgeSelectionToDomain(setModalState);
                        },
                      );
                    }).toList(),

                    const SizedBox(height: 16),

                    // Âge (dynamique + clamp)
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
                          child: Text(l10n.mapReset),
                          onPressed: () {
                            setModalState(() {
                              // 1) Filtres par défaut
                              tempGenos
                                ..clear()
                                ..addAll(kGenotypeOptions);
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
}
