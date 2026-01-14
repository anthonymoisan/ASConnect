// lib/tabular/view/tabular_view_filters.dart
part of 'tabular_view.dart';

extension _TabularFilters on _TabularViewState {
  // ----------------------------
  // State filtres (à ajouter dans _TabularViewState via "late"/init ci-dessous)
  // ----------------------------
  // Set<String> _selectedGenotypes;
  // Set<String> _selectedCountries;
  // bool _connectedOnly;
  // int? _selectedMinAge;
  // int? _selectedMaxAge;
  // int? _datasetMinAge;
  // int? _datasetMaxAge;
  // List<Person> _allPeople;

  // ----------------------------
  // Options
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
  // Labels (mêmes règles que tabular)
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
    final code = iso2.trim().toUpperCase();
    final translated = _countriesByCode[code];
    return (translated == null || translated.trim().isEmpty)
        ? code
        : translated;
  }

  // ----------------------------
  // Domain (min/max âge dataset)
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

    // init si jamais
    _selectedMinAge ??= _datasetMinAge;
    _selectedMaxAge ??= _datasetMaxAge;
  }

  // ----------------------------
  // Apply filters -> _view
  // ----------------------------
  void _applyTabularFilters({bool keepSort = true}) {
    bool matchesGenotype(Person p) {
      if (_selectedGenotypes.isEmpty) return true;
      final g = (p.genotype ?? '').trim();
      if (g.isEmpty) return false;

      final norm = g.toLowerCase();
      for (final sel in _selectedGenotypes) {
        final s = sel.trim().toLowerCase();
        // matching “souple” comme tes labels
        if (norm.contains('del') && s.contains('dél')) return true;
        if (norm.contains('dél') && s.contains('del')) return true;
        if (norm.contains(s)) return true;
        if (s.contains(norm)) return true;
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

  // ----------------------------
  // Tooltip résumé filtres (comme carto)
  // ----------------------------
  String _tabularFiltersTooltipText(BuildContext ctx) {
    final l10n = AppLocalizations.of(ctx)!;

    final genoActive = _selectedGenotypes.length != kGenotypeOptions.length;
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

    final parts = [
      genoPart,
      countryPart,
      agePart,
      connectedPart,
    ].whereType<String>().toList();

    return parts.isEmpty ? l10n.mapNoFilters : parts.join(' • ');
  }

  // ----------------------------
  // Options pays (source: liste courante + pays traduits)
  // ----------------------------
  List<String> get _countryOptions {
    final set = <String>{};
    for (final p in _allPeople) {
      final c = (p.countryCode ?? '').trim().toUpperCase();
      if (c.length == 2) set.add(c);
    }
    final list = set.toList()
      ..sort(
        (a, b) => _countryLabelForIso2(context, a).toLowerCase().compareTo(
          _countryLabelForIso2(context, b).toLowerCase(),
        ),
      );
    return list;
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

    _applyTabularFilters();
  }

  // ----------------------------
  // BottomSheet filtres (même style “carto”)
  // ----------------------------
  Future<void> _openTabularFiltersSheet() async {
    // assure-toi d’avoir les labels pays dans la bonne langue
    await _loadCountriesIfNeeded();

    // domain âge
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
        if (localMin != null && localMax != null) {
          final a = p.age;
          if (a == null || a < localMin || a > localMax) continue;
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
                            const Icon(Icons.people, size: 18),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                l10n.mapResultsCount(resultsCount),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
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

                      // Pays (Expansion)
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
}
