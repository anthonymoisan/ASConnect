// lib/mapCarto/map_carto.dart
//
// Carte Flutter avec cache de données (markers) + keep-alive entre onglets,
// + client HTTP réutilisé, timeout 30s, retries.
//
// ✅ Adaptation demandée (Déc. 2025):
// - À l'initialisation : télécharger uniquement les Points Remarquables
// - Via l'onglet de sélection : télécharger à la demande IME, MDPH, CAMPS, MAS, Pharmacies, FAM
//
// Prérequis pubspec.yaml:
//   flutter_map: ^7.0.2
//   flutter_map_marker_popup: ^6.1.2
//   geolocator: ^13.0.1
//   latlong2: ^0.9.1
//   ionicons: ^0.2.2
//   url_launcher: ^6.3.0
//   http: ^1.2.2
//
// Et un RemarkableDialog avec possibilité de choisir / prendre une photo
// et qui retourne un RemarkableInput { shortDesc, longDesc, XFile? photo }

import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:ionicons/ionicons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

import 'place.dart';
import 'map_data_cache.dart';
import 'remarkable_dialog.dart';

class MapCarto extends StatefulWidget {
  const MapCarto({
    super.key,
    this.mapTilerApiKey,
    this.allowOsmInRelease = false,
    this.osmUserAgent =
        'ASConnexion/1.0 (mobile; contact: contact@fastfrance.org)',
  });

  final String? mapTilerApiKey;
  final bool allowOsmInRelease;
  final String osmUserAgent;

  @override
  State<MapCarto> createState() => _MapCartoState();
}

class _MapCartoState extends State<MapCarto>
    with AutomaticKeepAliveClientMixin<MapCarto>, WidgetsBindingObserver {
  @override
  bool get wantKeepAlive => true;

  // Réseau
  static const _HTTP_TIMEOUT = Duration(seconds: 30);
  static const _HTTP_RETRIES = 5;
  late final http.Client _client;

  final _map = MapController();
  final _popupController = PopupController();

  // Vue initiale (Paris)
  final _center = const LatLng(48.8566, 2.3522);
  double _zoom = 12.5;

  // =======================
  //        BACKENDS
  // =======================
  static const _BASE = 'https://anthonymoisan.pythonanywhere.com';

  // v6 (→ PRIVÉ Basic)
  static String get _apiIme => '$_BASE/api/v6/resources/Ime';
  static String get _apiPhar => '$_BASE/api/v6/resources/PharmaceuticalOffice';
  static String get _apiMas => '$_BASE/api/v6/resources/Mas';
  static String get _apiFam => '$_BASE/api/v6/resources/Fam';
  static String get _apiMdph => '$_BASE/api/v6/resources/Mdph';
  static String get _apiCamps => '$_BASE/api/v6/resources/Camps';

  // Points remarquables (public)
  static String get _apiPointsList =>
      '$_BASE/api/public/pointRemarquableRepresentation';
  static String get _apiPointsCreate => '$_BASE/api/public/pointRemarquable';

  static const _userAgentPackageName = 'fr.asconnexion.app';

  // ---- Secrets injectés via --dart-define ----
  // Public : X-App-Key
  static const _PUBLIC_APP_KEY = String.fromEnvironment(
    'PUBLIC_APP_KEY',
    defaultValue: '',
  );

  // Privé : Basic (V6 uniquement)
  static const _PRIVATE_USERNAME = String.fromEnvironment(
    'V6_LOGIN',
    defaultValue: 'admin',
  );

  static const _PRIVATE_PASSWORD_B64 = String.fromEnvironment(
    'V6_PASSWORD_B64',
    defaultValue: '',
  );

  static String get _PRIVATE_PASSWORD {
    if (_PRIVATE_PASSWORD_B64.isEmpty) return '';
    try {
      return utf8.decode(base64.decode(_PRIVATE_PASSWORD_B64));
    } catch (_) {
      return '';
    }
  }

  // Icônes et couleurs
  static const Map<PlaceType, IconData> _typeIcons = {
    PlaceType.ime: Ionicons.bag,
    PlaceType.phar: Ionicons.medkit,
    PlaceType.mas: Ionicons.business,
    PlaceType.fam: Ionicons.home_sharp,
    PlaceType.mdph: Ionicons.shield,
    PlaceType.camps: Ionicons.card,
    PlaceType.remarkable: Ionicons.star,
  };

  Color _typeColor(PlaceType t) => switch (t) {
    PlaceType.ime => Colors.red,
    PlaceType.phar => Colors.green,
    PlaceType.mas => Colors.amber,
    PlaceType.fam => Colors.purple,
    PlaceType.mdph => Colors.black,
    PlaceType.camps => Colors.grey,
    PlaceType.remarkable => Colors.orange,
  };

  // État data & erreurs
  bool _loading = false;
  String? _error;

  // Marqueurs par couche
  final List<Marker> _imeMarkers = [];
  final List<Marker> _pharMarkers = [];
  final List<Marker> _masMarkers = [];
  final List<Marker> _famMarkers = [];
  final List<Marker> _mdphMarkers = [];
  final List<Marker> _campsMarkers = [];
  final List<Marker> _remarkableMarkers = [];

  // Association marker -> Place (pour la popup)
  final Map<Marker, Place> _markerToPlace = {};

  // Infos supplémentaires pour les points remarquables
  final Map<Place, int> _remarkableId = {}; // id DB
  final Map<Place, bool> _remarkableHasPhoto = {}; // photo disponible ?

  // ✅ Visibilité couches
  // - Par défaut : seulement Points Remarquables visibles
  bool _showIme = false;
  bool _showPhar = false;
  bool _showMas = false;
  bool _showFam = false;
  bool _showMdph = false;
  bool _showCamps = false;
  bool _showRemarkable = true;

  // ✅ Chargement par couche (téléchargée ou restaurée cache)
  final Map<PlaceType, bool> _loaded = {
    PlaceType.ime: false,
    PlaceType.phar: false,
    PlaceType.mas: false,
    PlaceType.fam: false,
    PlaceType.mdph: false,
    PlaceType.camps: false,
    PlaceType.remarkable: false,
  };

  // ✅ Uniquement les points remarquables au démarrage
  static const Set<PlaceType> _initialTypes = {PlaceType.remarkable};

  // Localisation
  Marker? _meMarker;
  bool _locating = false;

  // Suivi continu
  StreamSubscription<Position>? _posSub;
  DateTime? _lastUpdate;
  DateTime? _lastCenterAt;
  bool _autoCenter = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _client = http.Client();

    debugPrint(
      '[MAPCARTO] PRIVATE_USER=$_PRIVATE_USERNAME '
      'PWD_LEN=${_PRIVATE_PASSWORD.length} '
      'PWD_SET=${_PRIVATE_PASSWORD.isNotEmpty}',
    );

    // ✅ Restore cache : uniquement couche "remarkable" au démarrage
    if (MapDataCache.isFresh) {
      _remarkableMarkers.addAll(MapDataCache.remarkable ?? const []);
      if (MapDataCache.markerToPlace != null) {
        _markerToPlace.addAll(MapDataCache.markerToPlace!);
      }
      _loaded[PlaceType.remarkable] = _remarkableMarkers.isNotEmpty;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
    } else {
      _loadInitialMarkersOnly();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _goToMyLocation(silent: true);
      _startPositionStream();
    });
  }

  @override
  void dispose() {
    _posSub?.cancel();
    _client.close();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // -------- Helpers HEADERS --------

  Map<String, String> _baseHeaders({Map<String, String>? extra}) {
    return {
      'Accept': 'application/json',
      'User-Agent': widget.osmUserAgent,
      if (extra != null) ...extra,
    };
  }

  // Public: X-Api-Key
  Map<String, String> _publicHeaders({bool jsonBody = true}) {
    return _baseHeaders(
      extra: {
        'X-App-Key': _PUBLIC_APP_KEY,
        if (jsonBody) 'Content-Type': 'application/json',
      },
    );
  }

  // Privé: Basic (V6 uniquement)
  Map<String, String> _privateHeaders({bool jsonBody = true}) {
    final auth = base64Encode(
      utf8.encode('$_PRIVATE_USERNAME:$_PRIVATE_PASSWORD'),
    );
    return _baseHeaders(
      extra: {
        'Authorization': 'Basic $auth',
        if (jsonBody) 'Content-Type': 'application/json',
      },
    );
  }

  // -------- Helper HTTP avec timeout + retry + backoff exponentiel --------

  Future<http.Response> _getWithRetry(
    Uri uri, {
    required Map<String, String> headers,
    int retries = _HTTP_RETRIES,
  }) async {
    int attempt = 0;
    Duration backoff = const Duration(seconds: 2);

    while (true) {
      attempt++;
      try {
        final resp = await _client
            .get(uri, headers: headers)
            .timeout(_HTTP_TIMEOUT);
        return resp;
      } on TimeoutException catch (_) {
        if (attempt > retries) rethrow;
      } catch (_) {
        if (attempt > retries) rethrow;
      }
      await Future.delayed(backoff);
      backoff *= 2;
    }
  }

  Future<http.Response> _postWithRetry(
    Uri uri, {
    required Map<String, String> headers,
    Object? body,
    int retries = _HTTP_RETRIES,
  }) async {
    int attempt = 0;
    Duration backoff = const Duration(seconds: 2);

    while (true) {
      attempt++;
      try {
        final resp = await _client
            .post(uri, headers: headers, body: body)
            .timeout(_HTTP_TIMEOUT);
        return resp;
      } on TimeoutException catch (_) {
        if (attempt > retries) rethrow;
      } catch (_) {
        if (attempt > retries) rethrow;
      }
      await Future.delayed(backoff);
      backoff *= 2;
    }
  }

  // --------------------- Chargement des couches ---------------------

  // ✅ Initial : Points remarquables uniquement
  Future<void> _loadInitialMarkersOnly() async {
    setState(() {
      _loading = true;
      _error = null;

      _remarkableMarkers.clear();
      _markerToPlace.clear();
      _remarkableId.clear();
      _remarkableHasPhoto.clear();

      // autres couches vides au démarrage
      _imeMarkers.clear();
      _pharMarkers.clear();
      _masMarkers.clear();
      _famMarkers.clear();
      _mdphMarkers.clear();
      _campsMarkers.clear();

      for (final t in _loaded.keys) {
        _loaded[t] = false;
      }
    });

    String? firstError;

    try {
      debugPrint(
        '[MAPCARTO] >>> Début chargement Points remarquables à ${DateTime.now()}',
      );
      try {
        await _fetchRemarkables();
        _loaded[PlaceType.remarkable] = true;
        debugPrint(
          '[MAPCARTO] <<< Fin chargement Points remarquables (${_remarkableMarkers.length} markers)',
        );
      } catch (e) {
        firstError ??= 'Erreur points remarquables : $e';
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur chargement points remarquables : $e'),
            ),
          );
        }
      }

      MapDataCache.write(
        imeM: _imeMarkers,
        pharM: _pharMarkers,
        masM: _masMarkers,
        famM: _famMarkers,
        mdphM: _mdphMarkers,
        campsM: _campsMarkers,
        remarkM: _remarkableMarkers,
        map: _markerToPlace,
      );

      if (mounted && firstError != null) setState(() => _error = firstError);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ✅ Chargement à la demande (toutes les autres couches)
  Future<void> _ensureLoaded(PlaceType type) async {
    if (_loaded[type] == true) return;

    // Si cache fresh : récup immédiate sans réseau si dispo
    if (MapDataCache.isFresh) {
      if (type == PlaceType.ime && (MapDataCache.ime?.isNotEmpty ?? false)) {
        _imeMarkers.addAll(MapDataCache.ime!);
        _loaded[type] = true;
        if (mounted) setState(() {});
        return;
      }
      if (type == PlaceType.mdph && (MapDataCache.mdph?.isNotEmpty ?? false)) {
        _mdphMarkers.addAll(MapDataCache.mdph!);
        _loaded[type] = true;
        if (mounted) setState(() {});
        return;
      }
      if (type == PlaceType.camps &&
          (MapDataCache.camps?.isNotEmpty ?? false)) {
        _campsMarkers.addAll(MapDataCache.camps!);
        _loaded[type] = true;
        if (mounted) setState(() {});
        return;
      }
      if (type == PlaceType.mas && (MapDataCache.mas?.isNotEmpty ?? false)) {
        _masMarkers.addAll(MapDataCache.mas!);
        _loaded[type] = true;
        if (mounted) setState(() {});
        return;
      }
      if (type == PlaceType.fam && (MapDataCache.fam?.isNotEmpty ?? false)) {
        _famMarkers.addAll(MapDataCache.fam!);
        _loaded[type] = true;
        if (mounted) setState(() {});
        return;
      }
      if (type == PlaceType.phar && (MapDataCache.phar?.isNotEmpty ?? false)) {
        _pharMarkers.addAll(MapDataCache.phar!);
        _loaded[type] = true;
        if (mounted) setState(() {});
        return;
      }
      if (type == PlaceType.remarkable &&
          (MapDataCache.remarkable?.isNotEmpty ?? false)) {
        _remarkableMarkers.addAll(MapDataCache.remarkable!);
        _loaded[type] = true;
        if (mounted) setState(() {});
        return;
      }
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      if (type == PlaceType.ime) {
        await _fetchAndAdd(
          _apiIme,
          PlaceType.ime,
          _imeMarkers,
          privateAuth: true,
        );
      } else if (type == PlaceType.mdph) {
        await _fetchAndAdd(
          _apiMdph,
          PlaceType.mdph,
          _mdphMarkers,
          privateAuth: true,
        );
      } else if (type == PlaceType.camps) {
        await _fetchAndAdd(
          _apiCamps,
          PlaceType.camps,
          _campsMarkers,
          privateAuth: true,
        );
      } else if (type == PlaceType.mas) {
        await _fetchAndAdd(
          _apiMas,
          PlaceType.mas,
          _masMarkers,
          privateAuth: true,
        );
      } else if (type == PlaceType.fam) {
        await _fetchAndAdd(
          _apiFam,
          PlaceType.fam,
          _famMarkers,
          privateAuth: true,
        );
      } else if (type == PlaceType.phar) {
        await _fetchAndAdd(
          _apiPhar,
          PlaceType.phar,
          _pharMarkers,
          privateAuth: true,
        );
      } else if (type == PlaceType.remarkable) {
        await _fetchRemarkables();
      } else {
        return;
      }

      _loaded[type] = true;

      MapDataCache.write(
        imeM: _imeMarkers,
        pharM: _pharMarkers,
        masM: _masMarkers,
        famM: _famMarkers,
        mdphM: _mdphMarkers,
        campsM: _campsMarkers,
        remarkM: _remarkableMarkers,
        map: _markerToPlace,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur chargement ${type.name} : $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _fetchAndAdd(
    String url,
    PlaceType type,
    List<Marker> target, {
    required bool privateAuth,
  }) async {
    final uri = Uri.parse(url);

    const max429Retries = 2;
    int attempt429 = 0;

    while (true) {
      final res = await _getWithRetry(
        uri,
        headers: privateAuth ? _privateHeaders() : _publicHeaders(),
      );

      if (res.statusCode == 429) {
        attempt429++;
        if (attempt429 > max429Retries) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Trop de requêtes sur "$url". Certaines données peuvent manquer.',
                ),
              ),
            );
          }
          return;
        }

        Duration wait = const Duration(seconds: 3);
        final retryAfter = res.headers['retry-after'];
        if (retryAfter != null) {
          final secs = int.tryParse(retryAfter);
          if (secs != null && secs > 0 && secs < 120) {
            wait = Duration(seconds: secs);
          }
        }
        await Future.delayed(wait);
        continue;
      }

      if (res.statusCode != 200) {
        throw Exception('HTTP ${res.statusCode} → $url : ${res.body}');
      }

      final dynamic data = json.decode(res.body);
      final List list = (data is List)
          ? data
          : (data is Map && data['items'] is List)
          ? data['items']
          : const [];

      for (final item in list) {
        if (item is Map) {
          final place = Place.fromJson(item.cast<String, dynamic>(), type);
          if (place.lat != null && place.lon != null) {
            final m = _buildPlaceMarker(place);
            target.add(m);
            _markerToPlace[m] = place;
          }
        }
      }

      return;
    }
  }

  Future<void> _fetchRemarkables() async {
    final uri = Uri.parse(_apiPointsList);
    final res = await _getWithRetry(uri, headers: _publicHeaders());

    if (res.statusCode == 429) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Trop de requêtes pour les points remarquables. Réessaie plus tard.',
            ),
          ),
        );
      }
      return;
    }

    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode} → $_apiPointsList : ${res.body}');
    }

    // Important : on remplace la liste (évite doublons)
    _remarkableMarkers.clear();

    final List list = json.decode(res.body) as List;
    for (final item in list) {
      if (item is! Map) continue;

      final lat = toDoubleOrNull(item['latitude']);
      final lon = toDoubleOrNull(item['longitude']);
      final shortDesc = item['short_desc']?.toString();
      final longDesc = item['long_desc']?.toString();

      final dynamic idRaw = item['id'];
      final int? id = (idRaw is int)
          ? idRaw
          : int.tryParse(idRaw?.toString() ?? '');
      final dynamic hasPhotoRaw = item['has_photo'];
      final bool hasPhoto =
          hasPhotoRaw == true || hasPhotoRaw == 1 || hasPhotoRaw == '1';

      if (lat == null || lon == null) continue;

      final place = Place(
        type: PlaceType.remarkable,
        name: shortDesc ?? 'Point remarquable',
        address: longDesc ?? '',
        lat: lat,
        lon: lon,
      );

      final m = _buildPlaceMarker(place);
      _remarkableMarkers.add(m);
      _markerToPlace[m] = place;

      if (id != null) _remarkableId[place] = id;
      _remarkableHasPhoto[place] = hasPhoto;
    }
  }

  // --------------------- UI ---------------------

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final visibleMarkers = <Marker>[
      if (_showIme) ..._imeMarkers,
      if (_showPhar) ..._pharMarkers,
      if (_showMas) ..._masMarkers,
      if (_showFam) ..._famMarkers,
      if (_showMdph) ..._mdphMarkers,
      if (_showCamps) ..._campsMarkers,
      if (_showRemarkable) ..._remarkableMarkers,
    ];

    final tilesBlockedInRelease =
        kReleaseMode &&
        !widget.allowOsmInRelease &&
        (widget.mapTilerApiKey == null || widget.mapTilerApiKey!.isEmpty);

    return Stack(
      children: [
        Listener(
          behavior: HitTestBehavior.opaque,
          onPointerMove: (_) {
            if (_autoCenter) setState(() => _autoCenter = false);
          },
          child: FlutterMap(
            mapController: _map,
            options: MapOptions(
              initialCenter: _center,
              initialZoom: _zoom,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
              ),
              onTap: (_, __) {
                _popupController.hideAllPopups();
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
            children: [
              if (!tilesBlockedInRelease) _buildTileLayer(),
              if (_meMarker != null) MarkerLayer(markers: [_meMarker!]),
              PopupMarkerLayerWidget(
                options: PopupMarkerLayerOptions(
                  markers: visibleMarkers,
                  popupController: _popupController,
                  markerTapBehavior: MarkerTapBehavior.togglePopup(),
                  popupDisplayOptions: PopupDisplayOptions(
                    builder: (context, marker) => _buildPopup(marker),
                    snap: PopupSnap.markerTop,
                  ),
                ),
              ),
              _buildAttribution(),
            ],
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
                  'Tuiles OSM désactivées en production.\n'
                  'Configure une clé MapTiler (ou un autre fournisseur) '
                  'ou passe allowOsmInRelease=true pour un usage léger conforme.',
                  style: TextStyle(color: Colors.amber.shade900),
                ),
              ),
            ),
          ),

        if (_loading)
          const Positioned.fill(
            child: IgnorePointer(
              ignoring: true,
              child: Center(child: CircularProgressIndicator()),
            ),
          ),

        // Filtres (haut-gauche)
        Positioned(
          left: 12,
          top: 12,
          child: SafeArea(
            child: FloatingActionButton.small(
              tooltip: 'Filtres / couches',
              heroTag: 'settingsFab',
              onPressed: _openFullScreenSettingsSheet,
              child: const Icon(Ionicons.options),
            ),
          ),
        ),

        // Recentrer (haut-droit)
        Positioned(
          right: 12,
          top: 12,
          child: SafeArea(
            child: FloatingActionButton.small(
              tooltip: 'Recentrer sur ma position',
              heroTag: 'locateFab',
              onPressed: _onRecenterPressed,
              child: const Icon(Ionicons.locate),
            ),
          ),
        ),

        // Ajouter un point remarquable (haut-centre)
        Positioned(
          top: 12,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Center(
              child: FloatingActionButton.small(
                tooltip: 'Ajouter un point remarquable',
                heroTag: 'addRemarkableFab',
                onPressed: _onAddRemarkablePressed,
                child: const Icon(Ionicons.star),
              ),
            ),
          ),
        ),

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

  // ----- Paramètres d’affichage -----

  void _openFullScreenSettingsSheet() {
    bool tmpIme = _showIme;
    bool tmpPhar = _showPhar;
    bool tmpMas = _showMas;
    bool tmpFam = _showFam;
    bool tmpMdph = _showMdph;
    bool tmpCamps = _showCamps;
    bool tmpRemark = _showRemarkable;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      barrierColor: Colors.black54,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final h = MediaQuery.of(ctx).size.height;
            return SizedBox(
              height: h,
              child: Scaffold(
                appBar: AppBar(
                  leading: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(ctx).pop(),
                    tooltip: 'Fermer',
                  ),
                  title: const Text('Paramètres d’affichage'),
                ),
                body: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                  children: [
                    _sectionSwitch(
                      icon: Icon(
                        _typeIcons[PlaceType.ime],
                        color: _typeColor(PlaceType.ime),
                      ),
                      title: 'IME',
                      subtitle: _loaded[PlaceType.ime] == true
                          ? 'Afficher les IME'
                          : 'Afficher et télécharger les IME',
                      value: tmpIme,
                      onChanged: (v) => setModalState(() => tmpIme = v),
                    ),
                    const Divider(height: 18),
                    _sectionSwitch(
                      icon: Icon(
                        _typeIcons[PlaceType.phar],
                        color: _typeColor(PlaceType.phar),
                      ),
                      title: 'Pharmacies',
                      subtitle: _loaded[PlaceType.phar] == true
                          ? 'Afficher les Pharmacies'
                          : 'Afficher et télécharger les Pharmacies',
                      value: tmpPhar,
                      onChanged: (v) => setModalState(() => tmpPhar = v),
                    ),
                    const Divider(height: 18),
                    _sectionSwitch(
                      icon: Icon(
                        _typeIcons[PlaceType.mas],
                        color: _typeColor(PlaceType.mas),
                      ),
                      title: 'MAS',
                      subtitle: _loaded[PlaceType.mas] == true
                          ? 'Afficher les MAS'
                          : 'Afficher et télécharger les MAS',
                      value: tmpMas,
                      onChanged: (v) => setModalState(() => tmpMas = v),
                    ),
                    const Divider(height: 18),
                    _sectionSwitch(
                      icon: Icon(
                        _typeIcons[PlaceType.fam],
                        color: _typeColor(PlaceType.fam),
                      ),
                      title: 'FAM',
                      subtitle: _loaded[PlaceType.fam] == true
                          ? 'Afficher les FAM'
                          : 'Afficher et télécharger les FAM',
                      value: tmpFam,
                      onChanged: (v) => setModalState(() => tmpFam = v),
                    ),
                    const Divider(height: 18),
                    _sectionSwitch(
                      icon: Icon(
                        _typeIcons[PlaceType.mdph],
                        color: _typeColor(PlaceType.mdph),
                      ),
                      title: 'MDPH',
                      subtitle: _loaded[PlaceType.mdph] == true
                          ? 'Afficher les MDPH'
                          : 'Afficher et télécharger les MDPH',
                      value: tmpMdph,
                      onChanged: (v) => setModalState(() => tmpMdph = v),
                    ),
                    const Divider(height: 18),
                    _sectionSwitch(
                      icon: Icon(
                        _typeIcons[PlaceType.camps],
                        color: _typeColor(PlaceType.camps),
                      ),
                      title: 'Camps',
                      subtitle: _loaded[PlaceType.camps] == true
                          ? 'Afficher les Camps'
                          : 'Afficher et télécharger les Camps',
                      value: tmpCamps,
                      onChanged: (v) => setModalState(() => tmpCamps = v),
                    ),
                    const Divider(height: 18),
                    _sectionSwitch(
                      icon: Icon(
                        _typeIcons[PlaceType.remarkable],
                        color: _typeColor(PlaceType.remarkable),
                      ),
                      title: 'Points remarquables',
                      subtitle: 'Afficher les points remarquables',
                      value: tmpRemark,
                      onChanged: (v) => setModalState(() => tmpRemark = v),
                    ),
                  ],
                ),
                bottomNavigationBar: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          child: const Text('Annuler'),
                          onPressed: () => Navigator.of(ctx).pop(),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.check),
                          label: const Text('Appliquer'),
                          onPressed: () async {
                            setState(() {
                              _showIme = tmpIme;
                              _showPhar = tmpPhar;
                              _showMas = tmpMas;
                              _showFam = tmpFam;
                              _showMdph = tmpMdph;
                              _showCamps = tmpCamps;
                              _showRemarkable = tmpRemark;
                            });

                            Navigator.of(ctx).pop();

                            // ✅ Charge à la demande uniquement ce que l'utilisateur active
                            if (_showIme) await _ensureLoaded(PlaceType.ime);
                            if (_showMdph) await _ensureLoaded(PlaceType.mdph);
                            if (_showCamps)
                              await _ensureLoaded(PlaceType.camps);
                            if (_showMas) await _ensureLoaded(PlaceType.mas);
                            if (_showPhar) await _ensureLoaded(PlaceType.phar);
                            if (_showFam) await _ensureLoaded(PlaceType.fam);

                            // (Points remarquables : déjà chargés au démarrage, mais safe)
                            if (_showRemarkable) {
                              await _ensureLoaded(PlaceType.remarkable);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _sectionSwitch({
    required Widget icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: icon,
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch(value: value, onChanged: onChanged),
    );
  }

  // --------------------- Tuiles & attribution ---------------------

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
      userAgentPackageName: _userAgentPackageName,
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

  // --------------------- Popups ---------------------

  Marker _buildPlaceMarker(Place place) {
    final iconData = _typeIcons[place.type] ?? Ionicons.location;
    final color = _typeColor(place.type);

    return Marker(
      point: LatLng(place.lat!, place.lon!),
      width: 44,
      height: 44,
      alignment: Alignment.topCenter,
      child: Icon(iconData, size: 36, color: color),
    );
  }

  Widget _buildPopup(Marker marker) {
    final place = _markerToPlace[marker];
    if (place == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Text('Aucune donnée'),
        ),
      );
    }

    if (place.type == PlaceType.remarkable) {
      final int? id = _remarkableId[place];
      final bool hasPhoto = _remarkableHasPhoto[place] ?? false;

      Widget? photoWidget;
      if (hasPhoto && id != null) {
        final photoUrl = '$_BASE/api/public/pointRemarquable/$id/photo';

        photoWidget = Center(
          child: GestureDetector(
            onTap: () => _showFullScreenPhoto(photoUrl),
            child: Container(
              margin: const EdgeInsets.only(top: 8, bottom: 8),
              constraints: const BoxConstraints(maxHeight: 180, maxWidth: 260),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey.shade200,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  photoUrl,
                  headers: {'X-App-Key': _PUBLIC_APP_KEY},
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stack) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Photo indisponible',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    );
                  },
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: progress.expectedTotalBytes != null
                            ? (progress.cumulativeBytesLoaded /
                                  (progress.expectedTotalBytes ?? 1))
                            : null,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      }

      return Card(
        margin: const EdgeInsets.all(8),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Ionicons.star,
                      color: _typeColor(PlaceType.remarkable),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        place.name ?? 'Point remarquable',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                if ((place.address ?? '').isNotEmpty)
                  Text(place.address!, style: const TextStyle(fontSize: 14)),
                if (photoWidget != null) photoWidget,
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: (place.lat != null && place.lon != null)
                          ? () => _openMaps(place.lat!, place.lon!, place.name)
                          : null,
                      icon: const Icon(Icons.directions),
                      label: const Text('Itinéraire'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    final typeLabel = switch (place.type) {
      PlaceType.ime => 'IME',
      PlaceType.phar => 'Pharmacie',
      PlaceType.mas => 'MAS',
      PlaceType.fam => 'FAM',
      PlaceType.mdph => 'MDPH',
      PlaceType.camps => 'Camps',
      PlaceType.remarkable => 'Point remarquable',
    };

    return Card(
      margin: const EdgeInsets.all(8),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${place.name ?? 'Point'} • $typeLabel',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              if ((place.address ?? '').isNotEmpty)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.place, size: 18),
                    const SizedBox(width: 6),
                    Expanded(child: Text(place.address!)),
                  ],
                ),
              if ((place.phone ?? '').isNotEmpty) ...[
                const SizedBox(height: 6),
                InkWell(
                  onTap: () => _call(place.phone!),
                  child: Row(
                    children: [
                      const Icon(Icons.phone, size: 18),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          place.phone!,
                          style: const TextStyle(
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if ((place.phone ?? '').isNotEmpty)
                    TextButton.icon(
                      onPressed: () => _call(place.phone!),
                      icon: const Icon(Icons.call),
                      label: const Text('Appeler'),
                    ),
                  TextButton.icon(
                    onPressed: (place.lat != null && place.lon != null)
                        ? () => _openMaps(place.lat!, place.lon!, place.name)
                        : null,
                    icon: const Icon(Icons.directions),
                    label: const Text('Itinéraire'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _call(String phone) async {
    final cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');
    final uri = Uri(scheme: 'tel', path: cleaned);
    final ok = await launchUrl(uri);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Impossible de lancer l'appel.")),
      );
    }
  }

  Future<void> _openMaps(double lat, double lon, String? label) async {
    final name = (label ?? 'Destination')
        .replaceAll(RegExp('[()\\n]'), ' ')
        .trim();

    final geo = Uri.parse(
      'geo:$lat,$lon?q=${Uri.encodeComponent("$lat,$lon ($name)")}',
    );
    if (await canLaunchUrl(geo)) {
      if (await launchUrl(geo, mode: LaunchMode.externalApplication)) return;
    }

    final web = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent("$lat,$lon ($name)")}',
    );
    final ok = await launchUrl(web, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Impossible d’ouvrir la carte.")),
      );
    }
  }

  // --------------------- Géolocalisation ---------------------

  Future<void> _onRecenterPressed() async {
    final ok = await _ensureLocationPermission(showDefaultSnackbars: false);
    if (!ok) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Activer la géolocalisation pour recentrer la carte sur votre position',
            ),
          ),
        );
      }
      return;
    }
    setState(() => _autoCenter = true);
    await _goToMyLocation(silent: true);
  }

  Future<bool> _ensureLocationPermission({
    bool showDefaultSnackbars = true,
  }) async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (showDefaultSnackbars && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Active la localisation sur l’appareil.'),
          ),
        );
      }
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      if (showDefaultSnackbars && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permission localisation refusée.')),
        );
      }
      return false;
    }
    if (permission == LocationPermission.deniedForever) {
      if (showDefaultSnackbars && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Autorise la localisation dans les réglages.'),
          ),
        );
      }
      return false;
    }
    return true;
  }

  Future<void> _goToMyLocation({bool silent = false}) async {
    if (_locating) return;
    _locating = true;
    if (mounted) setState(() {});

    try {
      final ok = await _ensureLocationPermission();
      if (!ok) return;

      Position? pos;
      try {
        pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 6),
        );
      } catch (_) {
        pos = await Geolocator.getLastKnownPosition();
      }

      if (pos == null) {
        if (!silent && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Position indisponible.')),
          );
        }
        return;
      }

      _updateMyMarker(pos, center: true, forceZoomIfNeeded: 15.0);
      _lastCenterAt = DateTime.now();
    } finally {
      _locating = false;
      if (mounted) setState(() {});
    }
  }

  void _startPositionStream() async {
    final ok = await _ensureLocationPermission(showDefaultSnackbars: false);
    if (!ok) return;

    LocationSettings locationSettings;
    if (Platform.isAndroid) {
      locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0,
        intervalDuration: const Duration(seconds: 2),
      );
    } else if (Platform.isIOS) {
      locationSettings = AppleSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 0,
      );
    } else {
      locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0,
      );
    }

    await _posSub?.cancel();

    _posSub = Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen(
          (pos) {
            final now = DateTime.now();
            if (_lastUpdate == null ||
                now.difference(_lastUpdate!) >= const Duration(seconds: 2)) {
              _lastUpdate = now;

              final shouldCenter =
                  _autoCenter &&
                  (_lastCenterAt == null ||
                      now.difference(_lastCenterAt!) >=
                          const Duration(seconds: 5));

              _updateMyMarker(
                pos,
                center: shouldCenter,
                forceZoomIfNeeded: 15.0,
              );

              if (shouldCenter) _lastCenterAt = now;
            }
          },
          onError: (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Erreur localisation: $e')),
              );
            }
          },
        );
  }

  void _updateMyMarker(
    Position pos, {
    bool center = false,
    double? forceZoomIfNeeded,
  }) {
    final me = LatLng(pos.latitude, pos.longitude);

    _meMarker = Marker(
      point: me,
      width: 28,
      height: 28,
      alignment: Alignment.center,
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: Colors.blueAccent,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: [
            BoxShadow(
              color: Colors.blueAccent.withOpacity(0.5),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
      ),
    );

    if (center) {
      final currentZoom = _map.camera.zoom.isFinite ? _map.camera.zoom : _zoom;
      final targetZoom =
          (forceZoomIfNeeded != null && currentZoom < forceZoomIfNeeded)
          ? forceZoomIfNeeded
          : currentZoom;
      _map.move(me, targetZoom);
    }

    if (mounted) setState(() {});
  }

  Future<void> _showFullScreenPhoto(String url) async {
    await showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.of(ctx).pop(),
          child: Stack(
            children: [
              Positioned.fill(child: Container(color: Colors.black)),
              Center(
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Image.network(
                    url,
                    headers: {'X-App-Key': _PUBLIC_APP_KEY},
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const Positioned(
                top: 40,
                right: 20,
                child: Icon(Icons.close, color: Colors.white, size: 30),
              ),
            ],
          ),
        );
      },
    );
  }

  // --------------------- Ajout point remarquable ---------------------

  Future<void> _onAddRemarkablePressed() async {
    final ok = await _ensureLocationPermission(showDefaultSnackbars: false);
    if (!ok) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'La géolocalisation n’est pas activée (permission ou service). '
              'Active-la pour ajouter un point remarquable.',
            ),
          ),
        );
      }
      return;
    }

    Position? pos;
    try {
      pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 6),
      );
    } catch (_) {
      pos = await Geolocator.getLastKnownPosition();
    }

    if (pos == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Impossible d’obtenir ta position actuelle. '
              'Vérifie que la localisation est activée et réessaie.',
            ),
          ),
        );
      }
      return;
    }

    final lat = pos.latitude;
    final lon = pos.longitude;

    final result = await showDialog<RemarkableInput?>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => RemarkableDialog(lat: lat, lon: lon),
    );

    if (result == null) return;

    final missing = <String>[];
    if (result.shortDesc.trim().isEmpty) missing.add('description courte');
    if (result.longDesc.trim().isEmpty) missing.add('description longue');

    if (missing.isNotEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Impossible d’enregistrer : ${missing.join(" et ")} manquante.',
            ),
          ),
        );
      }
      return;
    }

    try {
      final uri = Uri.parse(_apiPointsCreate);

      http.Response res;

      if (result.photo != null) {
        final req = http.MultipartRequest('POST', uri)
          ..headers.addAll(_publicHeaders(jsonBody: false))
          ..fields['longitude'] = lon.toString()
          ..fields['latitude'] = lat.toString()
          ..fields['short_desc'] = result.shortDesc.trim()
          ..fields['long_desc'] = result.longDesc.trim();

        req.files.add(
          await http.MultipartFile.fromPath('photo', result.photo!.path),
        );

        final streamed = await req.send().timeout(_HTTP_TIMEOUT);
        res = await http.Response.fromStream(streamed);
      } else {
        final payload = json.encode({
          'longitude': lon.toString(),
          'latitude': lat.toString(),
          'short_desc': result.shortDesc.trim(),
          'long_desc': result.longDesc.trim(),
        });

        res = await _postWithRetry(
          uri,
          headers: _publicHeaders(jsonBody: true),
          body: payload,
        );
      }

      if (res.statusCode != 201 && res.statusCode != 200) {
        throw Exception('HTTP ${res.statusCode} : ${res.body}');
      }

      int? newId;
      try {
        final dynamic decoded = json.decode(res.body);
        if (decoded is Map) {
          final dynamic idRaw = decoded['id'];
          newId = (idRaw is int)
              ? idRaw
              : int.tryParse(idRaw?.toString() ?? '');
        }
      } catch (_) {}

      final place = Place(
        type: PlaceType.remarkable,
        name: result.shortDesc.trim(),
        address: result.longDesc.trim(),
        lat: lat,
        lon: lon,
      );

      final m = _buildPlaceMarker(place);
      setState(() {
        _remarkableMarkers.add(m);
        _markerToPlace[m] = place;
        if (newId != null) _remarkableId[place] = newId!;
        _remarkableHasPhoto[place] = (result.photo != null);
        _loaded[PlaceType.remarkable] = true;
      });

      MapDataCache.write(
        imeM: _imeMarkers,
        pharM: _pharMarkers,
        masM: _masMarkers,
        famM: _famMarkers,
        mdphM: _mdphMarkers,
        campsM: _campsMarkers,
        remarkM: _remarkableMarkers,
        map: _markerToPlace,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Point remarquable ajouté.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur ajout point : $e')));
    }
  }
}

// --------------------- Helpers JSON ---------------------

double? toDoubleOrNull(dynamic v) {
  if (v == null) return null;
  if (v is double) return v;
  if (v is int) return v.toDouble();
  final s = v.toString().trim().replaceAll(',', '.');
  return double.tryParse(s);
}
