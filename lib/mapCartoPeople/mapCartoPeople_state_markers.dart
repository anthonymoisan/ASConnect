//taille bulles + rebuild markers

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
    return size.clamp(kMinSize, kMaxSize).toDouble(); // ✅ clamp -> num
  }

  void _rebuildMarkers() {
    _cityMarkers.clear();

    final maxCount = _clusters.isNotEmpty
        ? _clusters.map((c) => c.count).reduce((a, b) => a > b ? a : b)
        : 1;

    for (final c in _clusters) {
      final base = _sizeForCount(c.count, maxCount);
      final scaled = (base * _zoomFactor)
          .clamp(kMinSize, kMaxSize * 2)
          .toDouble(); // ✅

      _cityMarkers.add(
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
    }

    if (mounted) setState(() {});
  }
}
