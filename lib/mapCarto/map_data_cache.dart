// lib/mapCarto/map_data_cache.dart

import 'package:flutter_map/flutter_map.dart';
import 'place.dart';

/// Mini-cache en mémoire (TTL = 10 min)
class MapDataCache {
  static List<Marker>? ime, phar, mas, fam, mdph, camps, remarkable;
  static Map<Marker, Place>? markerToPlace;
  static DateTime? fetchedAt;

  static const _ttl = Duration(minutes: 10);

  static bool get isFresh =>
      fetchedAt != null && DateTime.now().difference(fetchedAt!) < _ttl;

  static void write({
    required List<Marker> imeM,
    required List<Marker> pharM,
    required List<Marker> masM,
    required List<Marker> famM,
    required List<Marker> mdphM,
    required List<Marker> campsM,
    required List<Marker> remarkM,
    required Map<Marker, Place> map,
  }) {
    ime = List.of(imeM);
    phar = List.of(pharM);
    mas = List.of(masM);
    fam = List.of(famM);
    mdph = List.of(mdphM);
    camps = List.of(campsM);
    remarkable = List.of(remarkM);
    markerToPlace = Map.of(map);
    fetchedAt = DateTime.now();
  }

  static void clear() {
    ime = phar = mas = fam = mdph = camps = remarkable = null;
    markerToPlace = null;
    fetchedAt = null;
  }
}
