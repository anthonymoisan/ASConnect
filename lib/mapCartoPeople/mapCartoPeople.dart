// lib/mapCartoPeople/mapCartoPeople.dart
//
// Carte “Personnes par ville” (cluster) — flutter_map 8.2.x + flutter_map_marker_cluster 8.2.x
// ...

library map_carto_people;

import '../whatsApp/screens/chat_page.dart';

import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kReleaseMode, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'package:ionicons/ionicons.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../whatsApp/services/conversation_api.dart';
import '../whatsApp/services/conversation_events.dart';
import '../l10n/app_localizations.dart';

// --- Décommente ces imports si tu actives le cache disque des tuiles ---
// import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';

// Les fichiers "part" (même dossier ou sous-dossier selon ton arbo)
part 'mapCartoPeople_models.dart';
part 'mapCartoPeople_widgets.dart';
part 'mapCartoPeople_overlays.dart';
part 'mapCartoPeople_state.dart';

part 'mapCartoPeople_state_data.dart';
part 'mapCartoPeople_state_filters.dart';
part 'mapCartoPeople_state_geo.dart';
part 'mapCartoPeople_state_markers.dart';
part 'mapCartoPeople_state_ui.dart';
part 'mapCartoPeople_state_city_sheet.dart';
part 'mapCartoPeople_state_photo.dart';
part 'mapCartoPeople_state_fields.dart';

// 🔑 Clé d'application publique — valable pour tous les endpoints /api/public/*
const String _publicAppKey = String.fromEnvironment(
  'PUBLIC_APP_KEY',
  defaultValue: '',
);

enum _MapLevel { country, city }

// API (endpoints PUBLIC)

const String _env = String.fromEnvironment('ENV', defaultValue: 'prod');

const String _base = _env == 'prod'
    ? 'https://anthonymoisan.eu.pythonanywhere.com/api/public'
    : 'https://test-anthonymoisan.eu.pythonanywhere.com/api/public';

String get _peopleApi => '$_base/peopleMapRepresentation';
String _personPhotoUrl(int id) => '$_base/people/$id/photo';

class MapPeopleByCity extends StatefulWidget {
  const MapPeopleByCity({
    super.key,
    required this.currentPersonId, // ✅ AJOUT
    this.mapTilerApiKey,
    this.allowOsmInRelease = false,
    this.osmUserAgent =
        'ASConnexion/1.0 (mobile; contact: contact@fastfrance.org)',
  });

  /// ✅ ID "people" de l'utilisateur connecté (utilisé pour créer conversations et envoyer messages)
  final int currentPersonId;

  final String? mapTilerApiKey;
  final bool allowOsmInRelease;
  final String osmUserAgent;

  @override
  State<MapPeopleByCity> createState() => _MapPeopleByCityState();
}
