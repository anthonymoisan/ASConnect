//build + tile layer + attribution

// lib/mapCartoPeople/mapCartoPeople_state_ui.dart
part of map_carto_people;

extension _MapPeopleUI on _MapPeopleByCityState {
  Widget buildMapPeopleUI(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
                    l10n.mapPeopleCountBanner(_peopleCount),
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
              color: Colors.amber.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  l10n.mapTilesBlockedInReleaseMessage,
                  style: TextStyle(color: Colors.amber.shade900),
                ),
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
      userAgentPackageName: kUserAgentPackageName,
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
}
