// lib/mapCartoPeople/mapCartoPeople_state_markers.dart
part of map_carto_people;

extension _MapPeopleMarkers on _MapPeopleByCityState {
  double _sizeForCount(int count, int maxCount) {
    final int c = count.clamp(1, 1000000);
    final int m = math.max(1, maxCount);
    if (m <= 1) return kMinSize;

    final double vMin = math.log(1.0 + 1.0); // log(2)
    final double vMax = math.log(1.0 + m.toDouble());
    final double v = math.log(1.0 + c.toDouble());

    double t = (v - vMin) / (vMax - vMin);
    t = t.clamp(0.0, 1.0);
    t = math.pow(t, kSizeCurveGamma).toDouble();

    final double size = kMinSize + t * (kMaxSize - kMinSize);
    return size.clamp(kMinSize, kMaxSize).toDouble();
  }

  // champs à ajouter dans le State :
  // int _markersSignature = 0;

  int _hashCombine(int h, int v) {
    h = 0x1fffffff & (h + v);
    h = 0x1fffffff & (h + ((0x0007ffff & h) << 10));
    return h ^ (h >> 6);
  }

  int _hashFinish(int h) {
    h = 0x1fffffff & (h + ((0x03ffffff & h) << 3));
    h ^= (h >> 11);
    return 0x1fffffff & (h + ((0x00003fff & h) << 15));
  }

  int _markerSig({
    required bool countryLevel,
    required double zoomFactor,
    required double lat,
    required double lng,
    required double size,
    required int count,
  }) {
    final int qLat = (lat * 1e5).round();
    final int qLng = (lng * 1e5).round();
    final int qSize = (size * 10).round();
    final int qZoom = (zoomFactor * 100).round();

    int h = 17;
    h = _hashCombine(h, countryLevel ? 1 : 0);
    h = _hashCombine(h, qZoom);
    h = _hashCombine(h, qLat);
    h = _hashCombine(h, qLng);
    h = _hashCombine(h, qSize);
    h = _hashCombine(h, count);
    return _hashFinish(h);
  }

  bool _shouldRebuildForZoom() {
    final s = _zoomFactor;
    if ((s - _lastMarkerScale).abs() < 0.08) return false;
    _lastMarkerScale = s;
    return true;
  }

  void _rebuildMarkers() {
    final bool countryLevel = _level == _MapLevel.country;

    // 1) calcule la nouvelle liste dans une variable locale
    final List<Marker> next = <Marker>[];
    int sig = 17;

    if (countryLevel) {
      if (_countryClusters.isEmpty) {
        // ✅ IMPORTANT: on remplace la référence de liste (pas de mutation in-place)
        if (_cityMarkers.isNotEmpty && mounted) {
          setState(() => _cityMarkers = const <Marker>[]);
        }
        return;
      }

      final maxCount = _countryClusters
          .map((c) => c.count)
          .reduce((a, b) => a > b ? a : b);

      for (final c in _countryClusters) {
        final base = _sizeForCount(c.count, maxCount);
        final scaled = (base * _zoomFactor)
            .clamp(kMinSize, kMaxSize * 2)
            .toDouble();

        next.add(
          Marker(
            point: c.latLng,
            width: scaled,
            height: scaled,
            alignment: Alignment.center,
            child: GestureDetector(
              onTap: () => _enterCountry(c),
              child: _Bubble(count: c.count, size: scaled),
            ),
          ),
        );

        sig = _hashCombine(
          sig,
          _markerSig(
            countryLevel: true,
            zoomFactor: _zoomFactor,
            lat: c.latLng.latitude,
            lng: c.latLng.longitude,
            size: scaled,
            count: c.count,
          ),
        );
      }
    } else {
      if (_clusters.isEmpty) {
        // ✅ IMPORTANT: on remplace la référence de liste (pas de mutation in-place)
        if (_cityMarkers.isNotEmpty && mounted) {
          setState(() => _cityMarkers = const <Marker>[]);
        }
        return;
      }

      final maxCount = _clusters
          .map((c) => c.count)
          .reduce((a, b) => a > b ? a : b);

      for (final c in _clusters) {
        final base = _sizeForCount(c.count, maxCount);
        final scaled = (base * _zoomFactor)
            .clamp(kMinSize, kMaxSize * 2)
            .toDouble();

        next.add(
          Marker(
            point: c.latLng,
            width: scaled,
            height: scaled,
            alignment: Alignment.center,
            child: GestureDetector(
              onTap: () => _openCitySheet(c),
              child: _Bubble(count: c.count, size: scaled),
            ),
          ),
        );

        sig = _hashCombine(
          sig,
          _markerSig(
            countryLevel: false,
            zoomFactor: _zoomFactor,
            lat: c.latLng.latitude,
            lng: c.latLng.longitude,
            size: scaled,
            count: c.count,
          ),
        );
      }
    }

    sig = _hashFinish(sig);

    // 2) si rien n'a changé => pas de setState
    if (sig == _markersSignature) return;
    _markersSignature = sig;

    if (!mounted) return;

    // 3) ✅ IMPORTANT: on remplace la référence de liste (pas de mutation in-place)
    setState(() {
      _cityMarkers = List<Marker>.unmodifiable(next);
    });
  }
}
