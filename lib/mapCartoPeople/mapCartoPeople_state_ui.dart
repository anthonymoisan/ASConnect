// lib/mapCartoPeople/mapCartoPeople_state_ui.dart
// Stratégie MapTiler par niveau (Pays vs Villes):
// - PAYS  : basic-v2, maxZoom=6  (moins de tuiles, suffisant pour bulles pays)
// - VILLES: basic-v2, maxZoom=8  (plus précis pour drill-down)
// - MapOptions.maxZoom dynamique (évite zoom inutile => tuiles inutiles)
// - debounce onMapEvent (évite rebuild markers en continu)
// - retinaMode=false + maxNativeZoom aligné

part of map_carto_people;

extension _MapPeopleUI on _MapPeopleByCityState {
  static const double kTilesMinZoom = 1.0;

  // ✅ plafonds zoom par niveau
  static const double kMaxZoomCountry = 6.0;
  static const double kMaxZoomCity = 12.0;

  double get _levelMaxZoom =>
      _level == _MapLevel.city ? kMaxZoomCity : kMaxZoomCountry;

  // ----------------------------
  // Tile layers
  // ----------------------------

  TileLayer _mapTilerBasic256({
    required double minZoom,
    required double maxZoom,
  }) => TileLayer(
    urlTemplate:
        'https://api.maptiler.com/maps/basic-v2/256/{z}/{x}/{y}.png?key={key}',
    additionalOptions: {'key': widget.mapTilerApiKey ?? ''},
    minZoom: minZoom,
    maxZoom: maxZoom,
    maxNativeZoom: maxZoom.toInt(),
    retinaMode: false,
    tileProvider: NetworkTileProvider(),
  );

  // Option si tu veux streets au niveau ville (plus “joli” mais + lourd):
  TileLayer _mapTilerStreets256({
    required double minZoom,
    required double maxZoom,
  }) => TileLayer(
    urlTemplate:
        'https://api.maptiler.com/maps/streets-v2/256/{z}/{x}/{y}.png?key={key}',
    additionalOptions: {'key': widget.mapTilerApiKey ?? ''},
    minZoom: minZoom,
    maxZoom: maxZoom,
    maxNativeZoom: maxZoom.toInt(),
    retinaMode: false,
    tileProvider: NetworkTileProvider(),
  );

  TileLayer _osmTileLayer() => TileLayer(
    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    userAgentPackageName: kUserAgentPackageName,
    maxZoom: 19,
    tileProvider: NetworkTileProvider(
      headers: {'User-Agent': widget.osmUserAgent},
    ),
  );

  // ----------------------------
  // UI
  // ----------------------------

  Widget buildMapPeopleUI(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final tilesBlockedInRelease =
        kReleaseMode &&
        !widget.allowOsmInRelease &&
        (widget.mapTilerApiKey == null || widget.mapTilerApiKey!.isEmpty);

    final bool isCityLevel = _level == _MapLevel.city;

    final String bannerText =
        isCityLevel && (_activeCountry?.isNotEmpty ?? false)
        ? '${_activeCountry!.toUpperCase()} • ${l10n.mapPeopleCountBanner(_peopleCount)}'
        : l10n.mapPeopleCountBanner(_peopleCount);

    // ✅ clamp l'initialZoom selon le niveau courant
    final safeInitialZoom = _initialZoom
        .clamp(kTilesMinZoom, _levelMaxZoom)
        .toDouble();

    return Stack(
      children: [
        FlutterMap(
          mapController: _map,
          options: MapOptions(
            initialCenter: _initialCenter,
            initialZoom: safeInitialZoom,

            // ✅ minZoom global
            minZoom: kTilesMinZoom,

            // ✅ maxZoom dynamique (pays/villes)
            maxZoom: _levelMaxZoom,

            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
            ),

            // ✅ debounce cross-version (flutter_map v8)
            onMapEvent: (evt) {
              _mapEventDebounce?.cancel();
              _mapEventDebounce = Timer(const Duration(milliseconds: 180), () {
                if (!mounted) return;

                final z = _map.camera.zoom;

                // ✅ si on est au niveau PAYS, on empêche le zoom de dépasser le plafond
                // (utile si un ancien état avait un maxZoom plus haut)
                final clampedZ = z
                    .clamp(kTilesMinZoom, _levelMaxZoom)
                    .toDouble();
                if ((clampedZ - z).abs() > 0.001) {
                  _map.move(_map.camera.center, clampedZ);
                }

                if ((clampedZ - _currentZoom).abs() > 0.10) {
                  _currentZoom = clampedZ;
                }
                _rebuildMarkers();
              });
            },
          ),
          children: [
            if (!tilesBlockedInRelease && !_initializing)
              _buildTileLayerByLevel(),
            _distanceCircleLayer(),
            if (_cityMarkers.isNotEmpty) MarkerLayer(markers: _cityMarkers),
            _buildAttribution(),
          ],
        ),

        // ✅ Bouton retour (uniquement au niveau ville)
        if (isCityLevel)
          Positioned(
            left: 12,
            top: 12,
            child: SafeArea(
              child: FloatingActionButton.small(
                heroTag: 'backPeopleCountry',
                onPressed: () => _backToCountries(fit: true),
                tooltip: l10n.mapBack ?? 'Retour',
                child: const Icon(Ionicons.arrow_back),
              ),
            ),
          ),

        // ✅ Filtres : visibles uniquement au niveau pays
        if (!isCityLevel)
          Positioned(
            left: 12,
            top: 12,
            child: SafeArea(
              child: Tooltip(
                message: _filtersTooltipText(context),
                preferBelow: false,
                child: FloatingActionButton.small(
                  heroTag: 'settingsPeopleCity',
                  onPressed: _openSettingsSheet,
                  tooltip: l10n.mapFiltersButtonTooltip,
                  child: const Icon(Ionicons.options),
                ),
              ),
            ),
          ),

        // ✅ Badge central
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
                  key: ValueKey(
                    '${_peopleCount}_${_activeCountry ?? ''}_${_level.name}',
                  ),
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
                    bannerText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ),
        ),

        // ✅ Refresh
        Positioned(
          right: 12,
          top: 12,
          child: SafeArea(
            child: FloatingActionButton.small(
              heroTag: 'refreshPeopleCity',
              onPressed: _reloadFromNetworkIgnoringFilters,
              tooltip: l10n.mapReloadFromNetworkTooltip,
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
              color: Colors.amberAccent,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(l10n.mapTilesBlockedInReleaseMessage),
              ),
            ),
          ),

        if (_loading) const _PositionedFillLoader(),
        if (_initializing)
          _InitOverlay(message: l10n.mapInitializingDataMessage),

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

  // ----------------------------
  // Tile strategy by level
  // ----------------------------
  Widget _buildTileLayerByLevel() {
    final canUseOsm = !kReleaseMode || widget.allowOsmInRelease;

    // Release + OSM interdit -> MapTiler obligatoire (si key)
    final mustUseMapTiler = !canUseOsm;

    // 🟢 si OSM autorisé (debug / allowOsmInRelease), on peut rester en OSM
    if (!mustUseMapTiler) {
      return _osmTileLayer();
    }

    // 🔑 si pas de clé -> couche vide (mais ce cas est géré par tilesBlockedInRelease)
    if (!(widget.mapTilerApiKey?.isNotEmpty ?? false)) {
      return const SizedBox.shrink();
    }

    // ✅ Niveau PAYS : basic-v2 + maxZoomCountry
    if (_level == _MapLevel.country) {
      return _mapTilerBasic256(
        minZoom: kTilesMinZoom,
        maxZoom: kMaxZoomCountry,
      );
    }

    // ✅ Niveau VILLES :
    // - basic-v2 (le moins cher) recommandé
    // - ou streets-v2 si tu veux + de détail (plus de poids)
    const bool useStreetsAtCityLevel = false; // ← mets true si tu veux
    if (useStreetsAtCityLevel) {
      return _mapTilerStreets256(minZoom: kTilesMinZoom, maxZoom: kMaxZoomCity);
    }
    return _mapTilerBasic256(minZoom: kTilesMinZoom, maxZoom: kMaxZoomCity);
  }

  // ----------------------------
  // Attribution
  // ----------------------------
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
}
