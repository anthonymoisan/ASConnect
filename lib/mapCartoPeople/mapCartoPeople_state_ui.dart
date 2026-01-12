// lib/mapCartoPeople/mapCartoPeople_state_ui.dart
// Optimisations MapTiler (web + mobile):
// - maxZoom réduit à 8 (au lieu de 10) => forte baisse de consommation de tuiles
// - debounce sur onMapEvent (évite rebuild markers en continu)
// - retinaMode désactivé + maxNativeZoom aligné

part of map_carto_people;

extension _MapPeopleUI on _MapPeopleByCityState {
  static const double kTilesMinZoom = 1.0;
  static const double kTilesMaxZoom = 8.0;

  TileLayer _mapTilerTileLayer() => TileLayer(
    urlTemplate:
        'https://api.maptiler.com/maps/streets-v2/256/{z}/{x}/{y}.png?key={key}',
    additionalOptions: {'key': widget.mapTilerApiKey ?? ''},
    minZoom: kTilesMinZoom,
    maxZoom: kTilesMaxZoom,
    maxNativeZoom: kTilesMaxZoom.toInt(),
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

    final safeInitialZoom = _initialZoom
        .clamp(kTilesMinZoom, kTilesMaxZoom)
        .toDouble();

    return Stack(
      children: [
        FlutterMap(
          mapController: _map,
          options: MapOptions(
            initialCenter: _initialCenter,
            initialZoom: safeInitialZoom,
            minZoom: kTilesMinZoom,
            maxZoom: kTilesMaxZoom,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
            ),

            // ✅ flutter_map v8: pas de MapEventZoomEnd => debounce cross-version
            onMapEvent: (evt) {
              _mapEventDebounce?.cancel();
              _mapEventDebounce = Timer(const Duration(milliseconds: 180), () {
                if (!mounted) return;

                final z = _map.camera.zoom;
                if ((z - _currentZoom).abs() > 0.10) {
                  _currentZoom = z;
                }
                _rebuildMarkers();
              });
            },
          ),
          children: [
            if (!tilesBlockedInRelease && !_initializing)
              _buildTileLayerOptimized(),
            _distanceCircleLayer(),
            if (_cityMarkers.isNotEmpty) MarkerLayer(markers: _cityMarkers),
            _buildAttribution(),
          ],
        ),

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

  Widget _buildTileLayerOptimized() {
    final canUseOsm = !kReleaseMode || widget.allowOsmInRelease;

    if (!canUseOsm && (widget.mapTilerApiKey?.isNotEmpty ?? false)) {
      return _mapTilerTileLayer();
    }
    return _osmTileLayer();
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
}
