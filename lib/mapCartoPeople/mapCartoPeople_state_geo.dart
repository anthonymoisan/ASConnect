//géoloc + cercle distance
part of map_carto_people;

extension _MapPeopleGeo on _MapPeopleByCityState {
  // Géoloc
  Future<bool> _ensureLocation({bool showSnackOnError = true}) async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (showSnackOnError && mounted) {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.mapLocationServiceDisabled)),
          );
        }
        return false;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (showSnackOnError && mounted) {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.mapLocationPermissionDenied)),
          );
        }
        return false;
      }
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _distanceOrigin = LatLng(pos.latitude, pos.longitude);
      return true;
    } catch (e) {
      if (showSnackOnError && mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.mapLocationUnavailable(e.toString()))),
        );
      }
      return false;
    }
  }

  // Cercle de distance
  List<LatLng> _buildGeoCircle(
    LatLng center,
    double radiusKm, {
    int steps = 180,
  }) {
    const earthRadiusKm = 6371.0;
    final lat0 = center.latitude * math.pi / 180.0;
    final lon0 = center.longitude * math.pi / 180.0;
    final dByR = radiusKm / earthRadiusKm;

    final pts = <LatLng>[];
    for (int i = 0; i < steps; i++) {
      final brg = (i * (360.0 / steps)) * math.pi / 180.0;
      final lat = math.asin(
        math.sin(lat0) * math.cos(dByR) +
            math.cos(lat0) * math.sin(dByR) * math.cos(brg),
      );
      final lon =
          lon0 +
          math.atan2(
            math.sin(brg) * math.sin(dByR) * math.cos(lat0),
            math.cos(dByR) - math.sin(lat0) * math.sin(lat),
          );
      pts.add(LatLng(lat * 180.0 / math.pi, lon * 180.0 / math.pi));
    }
    return pts;
  }

  PolygonLayer _distanceCircleLayer() {
    if (!_distanceFilterEnabled ||
        _distanceOrigin == null ||
        _maxDistanceKm == null) {
      return const PolygonLayer(polygons: []);
    }
    final ring = _buildGeoCircle(_distanceOrigin!, _maxDistanceKm!, steps: 180);
    return PolygonLayer(
      polygons: [
        Polygon(
          points: ring,
          borderStrokeWidth: 2.0,
          borderColor: Colors.blueAccent.withOpacity(0.9),
          color: Colors.blueAccent.withOpacity(0.07),
        ),
      ],
    );
  }
}
