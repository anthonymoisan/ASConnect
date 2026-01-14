import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/listPerson.dart';
import '../../whatsApp/services/conversation_api.dart' show publicAppKey;
import '../../whatsApp/models/conversation.dart';

const String _base = 'https://anthonymoisan.pythonanywhere.com/api/public';

class _CacheEntry<T> {
  final T value;
  final DateTime expiresAt;
  _CacheEntry(this.value, this.expiresAt);
  bool get isValid => DateTime.now().isBefore(expiresAt);
}

class TabularApi {
  static const String _baseUrl = _base;

  static final http.Client _client = http.Client();

  static const Duration _ttlPeople = Duration(minutes: 5);
  static const Duration _ttlCountries = Duration(hours: 12);

  static final Map<String, _CacheEntry<dynamic>> _cache = {};
  static final Map<String, Future<dynamic>> _inFlight = {};

  static Map<String, String> get _headers => {'X-App-Key': publicAppKey};

  static void dispose() {
    _client.close();
    _cache.clear();
    _inFlight.clear();
  }

  static T? _getCache<T>(String key) {
    final e = _cache[key];
    if (e == null) return null;
    if (!e.isValid) {
      _cache.remove(key);
      return null;
    }
    return e.value as T;
  }

  static void _setCache<T>(String key, T value, Duration ttl) {
    _cache[key] = _CacheEntry<T>(value, DateTime.now().add(ttl));
  }

  static Future<T> _dedup<T>(String key, Future<T> Function() fn) {
    final existing = _inFlight[key];
    if (existing != null) return existing as Future<T>;

    final f = fn();
    _inFlight[key] = f;
    f.whenComplete(() => _inFlight.remove(key));
    return f;
  }

  /// ✅ GET /people/mapRepresentation
  static Future<dynamic> fetchPeopleMapRepresentationRaw({
    bool force = false,
  }) async {
    // ✅ cache-buster pour éviter caches intermédiaires (proxy/CDN/navigateur)
    final uri = Uri.parse('$_baseUrl/peopleMapRepresentation').replace(
      queryParameters: force
          ? {'t': DateTime.now().millisecondsSinceEpoch.toString()}
          : null,
    );

    const cacheKey = 'people:mapRepresentationRaw';

    if (!force) {
      final cached = _getCache<dynamic>(cacheKey);
      if (cached != null) return cached;
    } else {
      _cache.remove(cacheKey);
    }

    // ✅ IMPORTANT : si force==true, on évite la dédup inFlight du cacheKey
    final key = force ? '$cacheKey:force' : cacheKey;

    return _dedup<dynamic>(key, () async {
      final headers = <String, String>{
        ..._headers,
        if (force) ...{'Cache-Control': 'no-cache', 'Pragma': 'no-cache'},
      };

      final resp = await _client
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 60));

      if (resp.statusCode != 200) {
        throw Exception(
          'Erreur fetchPeopleMapRepresentation (${resp.statusCode}) : ${resp.body}',
        );
      }

      final decoded = jsonDecode(resp.body);

      // ✅ on ne met en cache que si pas "force"
      if (!force) {
        _setCache(cacheKey, decoded, _ttlPeople);
      }

      return decoded;
    });
  }

  /// ✅ Méthode utilisée par la TabularView
  static Future<ListPerson> fetchPeopleMapRepresentation({
    bool force = false,
  }) async {
    final decoded = await fetchPeopleMapRepresentationRaw(force: force);

    if (decoded is List) {
      return ListPerson.fromJsonList(decoded);
    }

    throw Exception('Format inattendu peopleMapRepresentation');
  }

  /// ✅ GET /people/countriesTranslated?locale=xx
  /// Retour attendu: { COUNT: n, COUNTRIES: [ {code, name}, ... ], LOCALE: xx }
  static Future<Map<String, String>> fetchCountriesTranslated({
    required String locale,
    bool force = false,
  }) async {
    final loc = locale.trim().toLowerCase();
    final uri = Uri.https(
      'anthonymoisan.pythonanywhere.com',
      '/api/public/people/countriesTranslated',
      {'locale': loc},
    );

    final cacheKey = 'countriesTranslated:$loc';

    if (!force) {
      final cached = _getCache<Map<String, String>>(cacheKey);
      if (cached != null) return cached;
    } else {
      _cache.remove(cacheKey);
    }

    return _dedup<Map<String, String>>(cacheKey, () async {
      try {
        final resp = await _client
            .get(uri, headers: _headers)
            .timeout(const Duration(seconds: 60));

        if (resp.statusCode != 200) {
          throw Exception(
            'Erreur countriesTranslated($loc) (${resp.statusCode}) : ${resp.body}',
          );
        }

        final decoded = jsonDecode(resp.body);

        // ✅ On supporte plusieurs formats possibles
        List<dynamic>? countriesList;

        if (decoded is Map<String, dynamic>) {
          countriesList =
              (decoded['countries'] as List?) ??
              (decoded['COUNTRIES'] as List?) ??
              (decoded['Countries'] as List?);
        } else if (decoded is List) {
          // Cas improbable mais on gère: liste directe
          countriesList = decoded;
        }

        if (countriesList == null || countriesList.isEmpty) {
          debugPrint('[TABULAR] countriesTranslated($loc) parsed EMPTY');
          final empty = <String, String>{};
          _setCache(cacheKey, empty, _ttlCountries);
          return empty;
        }

        final map = <String, String>{};
        for (final item in countriesList) {
          if (item is Map) {
            final code = (item['code'] ?? item['CODE'] ?? '').toString().trim();
            final name = (item['name'] ?? item['NAME'] ?? '').toString().trim();
            if (code.isNotEmpty && name.isNotEmpty) {
              map[code] = name;
            }
          }
        }

        debugPrint(
          '[TABULAR] countriesTranslated($loc) parsed size=${map.length}',
        );
        _setCache(cacheKey, map, _ttlCountries);
        return map;
      } catch (e) {
        debugPrint('[TABULAR] countriesTranslated($loc) error: $e');
        rethrow;
      }
    });
  }

  /// ✅ POST /conversations/private
  /// Le backend crée OU retrouve une conversation privée selon le contenu du payload.
  /// Retour attendu:
  /// {
  ///   "created_at": "...",
  ///   "id": 1,
  ///   "is_group": false,
  ///   "last_message_at": "...",
  ///   "title": "Conversation 1-2"
  /// }
  static Future<Conversation> createOrGetPrivateConversation({
    required Map<String, dynamic> payload,
    bool dedup = true,
  }) async {
    final uri = Uri.https(
      'anthonymoisan.pythonanywhere.com',
      '/api/public/conversations/private',
    );

    final headers = <String, String>{
      ..._headers,
      'Content-Type': 'application/json',
    };

    // Optionnel: dédup "inFlight" pour éviter double POST si l’UI déclenche 2 fois.
    // On calcule une clé stable à partir du JSON.
    final bodyString = jsonEncode(payload);
    final key = 'conversations:private:${bodyString.hashCode}';

    Future<Conversation> run() async {
      final resp = await _client
          .post(uri, headers: headers, body: bodyString)
          .timeout(const Duration(seconds: 60));

      if (resp.statusCode != 200 && resp.statusCode != 201) {
        throw Exception(
          'Erreur createOrGetPrivateConversation (${resp.statusCode}) : ${resp.body}',
        );
      }

      final decoded = jsonDecode(resp.body);
      if (decoded is! Map<String, dynamic>) {
        throw Exception('Format inattendu conversations/private: ${resp.body}');
      }

      return Conversation.fromJson(decoded);
    }

    if (!dedup) return run();
    return _dedup<Conversation>(key, run);
  }
}
