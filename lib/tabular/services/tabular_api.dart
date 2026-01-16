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

/// ----------------------------------------------------------------------------
/// TabularApi
/// - Cache TTL
/// - In-flight de-dup
/// - Debug profiling: network vs jsonDecode vs mapping
/// - Optional isolate parsing/mapping with compute()
/// ----------------------------------------------------------------------------
class TabularApi {
  static const String _baseUrl = _base;

  static final http.Client _client = http.Client();

  static const Duration _ttlPeople = Duration(minutes: 5);
  static const Duration _ttlCountries = Duration(hours: 12);

  static final Map<String, _CacheEntry<dynamic>> _cache = {};
  static final Map<String, Future<dynamic>> _inFlight = {};

  static Map<String, String> get _headers => {'X-App-Key': publicAppKey};

  /// Toggle: enable verbose debug logs in debug mode.
  /// You can also force-enable in release by setting to true manually
  /// (not recommended).
  static bool get _logEnabled => kDebugMode;

  /// Toggle: offload JSON decode + mapping to isolate (compute) in debug.
  /// For Flutter Web, compute may behave differently; it still works but
  /// the benefit can be smaller.
  static bool useIsolateParsingInDebug = true;

  static void dispose() {
    _client.close();
    _cache.clear();
    _inFlight.clear();
  }

  // --------------------------------------------------------------------------
  // Cache helpers
  // --------------------------------------------------------------------------

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

  /// In-flight de-duplication: if same key requested concurrently, share Future.
  static Future<T> _dedup<T>(String key, Future<T> Function() fn) {
    final existing = _inFlight[key];
    if (existing != null) return existing as Future<T>;

    final f = fn();
    _inFlight[key] = f;
    f.whenComplete(() => _inFlight.remove(key));
    return f;
  }

  static void _log(String msg) {
    if (_logEnabled) debugPrint(msg);
  }

  // --------------------------------------------------------------------------
  // Top-level / static functions for compute()
  // (compute requires a top-level or static function)
  // --------------------------------------------------------------------------

  static dynamic _jsonDecodeString(String body) => jsonDecode(body);

  static ListPerson _parseListPersonFromDecoded(dynamic decoded) {
    if (decoded is List) return ListPerson.fromJsonList(decoded);
    throw Exception('Format inattendu peopleMapRepresentation (expected List)');
  }

  // --------------------------------------------------------------------------
  // Public endpoints
  // --------------------------------------------------------------------------

  /// ✅ GET /peopleMapRepresentation
  ///
  /// Returns decoded JSON (dynamic) to allow separating "raw" decode from mapping.
  ///
  /// Debug logs show:
  /// - cache HIT/MISS
  /// - network time
  /// - payload size
  /// - jsonDecode time (and whether isolate)
  static Future<dynamic> fetchPeopleMapRepresentationRaw({
    bool force = false,
  }) async {
    // Cache-buster for intermediates if force==true
    final uri = Uri.parse('$_baseUrl/peopleMapRepresentation').replace(
      queryParameters: force
          ? {'t': DateTime.now().millisecondsSinceEpoch.toString()}
          : null,
    );

    const cacheKey = 'people:mapRepresentationRaw';

    if (!force) {
      final cached = _getCache<dynamic>(cacheKey);
      if (cached != null) {
        _log('[TABULAR] peopleMapRepresentationRaw cache HIT');
        return cached;
      }
      _log('[TABULAR] peopleMapRepresentationRaw cache MISS');
    } else {
      _cache.remove(cacheKey);
      _log(
        '[TABULAR] peopleMapRepresentationRaw force=true (cache cleared + buster)',
      );
    }

    // Important: if force==true, separate inFlight key to avoid blocking normal fetch
    final inFlightKey = force ? '$cacheKey:force' : cacheKey;

    return _dedup<dynamic>(inFlightKey, () async {
      final headers = <String, String>{
        ..._headers,
        if (force) ...{'Cache-Control': 'no-cache', 'Pragma': 'no-cache'},
      };

      // ---- Network timing
      final netSw = Stopwatch()..start();
      final resp = await _client
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 60));
      netSw.stop();

      final status = resp.statusCode;
      final bytes = resp.bodyBytes.length;
      final kb = (bytes / 1024).toStringAsFixed(1);

      _log('[TABULAR] GET $uri');
      _log(
        '[TABULAR] peopleMapRepresentationRaw network=${netSw.elapsedMilliseconds}ms '
        'status=$status size=${kb}KB force=$force',
      );

      if (status != 200) {
        throw Exception(
          'Erreur fetchPeopleMapRepresentation ($status) : ${resp.body}',
        );
      }

      // ---- JSON decode timing (optionally isolate)
      final decodeSw = Stopwatch()..start();
      final dynamic decoded;

      final useIso = _logEnabled && useIsolateParsingInDebug && !kIsWeb;
      // On web, isolate behavior can differ; keep direct decode by default.
      if (useIso) {
        decoded = await compute(_jsonDecodeString, resp.body);
        decodeSw.stop();
        _log(
          '[TABULAR] peopleMapRepresentationRaw jsonDecode=${decodeSw.elapsedMilliseconds}ms (isolate)',
        );
      } else {
        decoded = jsonDecode(resp.body);
        decodeSw.stop();
        _log(
          '[TABULAR] peopleMapRepresentationRaw jsonDecode=${decodeSw.elapsedMilliseconds}ms (main)',
        );
      }

      // Cache only if not forced
      if (!force) {
        _setCache(cacheKey, decoded, _ttlPeople);
        _log(
          '[TABULAR] peopleMapRepresentationRaw cached ttl=${_ttlPeople.inMinutes}m',
        );
      }

      return decoded;
    });
  }

  /// ✅ Method used by TabularView
  ///
  /// Debug logs show:
  /// - mapping time (decoded -> ListPerson)
  /// - items count
  static Future<ListPerson> fetchPeopleMapRepresentation({
    bool force = false,
  }) async {
    final decoded = await fetchPeopleMapRepresentationRaw(force: force);

    final mapSw = Stopwatch()..start();
    final ListPerson parsed;

    final useIso = _logEnabled && useIsolateParsingInDebug && !kIsWeb;
    if (useIso) {
      parsed = await compute(_parseListPersonFromDecoded, decoded);
      mapSw.stop();
      _log(
        '[TABULAR] peopleMapRepresentation mapping=${mapSw.elapsedMilliseconds}ms (isolate)',
      );
    } else {
      parsed = _parseListPersonFromDecoded(decoded);
      mapSw.stop();
      _log(
        '[TABULAR] peopleMapRepresentation mapping=${mapSw.elapsedMilliseconds}ms (main)',
      );
    }

    _log(
      '[TABULAR] peopleMapRepresentation parsed items=${parsed.items.length}',
    );
    return parsed;
  }

  /// ✅ GET /people/countriesTranslated?locale=xx
  ///
  /// Debug logs show:
  /// - cache HIT/MISS
  /// - network time + payload size
  /// - jsonDecode time
  /// - parsed map size
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
      if (cached != null) {
        _log(
          '[TABULAR] countriesTranslated($loc) cache HIT size=${cached.length}',
        );
        return cached;
      }
      _log('[TABULAR] countriesTranslated($loc) cache MISS');
    } else {
      _cache.remove(cacheKey);
      _log('[TABULAR] countriesTranslated($loc) force=true (cache cleared)');
    }

    return _dedup<Map<String, String>>(cacheKey, () async {
      // Network
      final netSw = Stopwatch()..start();
      final resp = await _client
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 60));
      netSw.stop();

      final status = resp.statusCode;
      final bytes = resp.bodyBytes.length;
      final kb = (bytes / 1024).toStringAsFixed(1);

      _log('[TABULAR] GET $uri');
      _log(
        '[TABULAR] countriesTranslated($loc) network=${netSw.elapsedMilliseconds}ms '
        'status=$status size=${kb}KB',
      );

      if (status != 200) {
        throw Exception(
          'Erreur countriesTranslated($loc) ($status) : ${resp.body}',
        );
      }

      // Decode
      final decodeSw = Stopwatch()..start();
      final dynamic decoded;
      final useIso = _logEnabled && useIsolateParsingInDebug && !kIsWeb;

      if (useIso) {
        decoded = await compute(_jsonDecodeString, resp.body);
        decodeSw.stop();
        _log(
          '[TABULAR] countriesTranslated($loc) jsonDecode=${decodeSw.elapsedMilliseconds}ms (isolate)',
        );
      } else {
        decoded = jsonDecode(resp.body);
        decodeSw.stop();
        _log(
          '[TABULAR] countriesTranslated($loc) jsonDecode=${decodeSw.elapsedMilliseconds}ms (main)',
        );
      }

      // Parse
      List<dynamic>? countriesList;

      if (decoded is Map<String, dynamic>) {
        countriesList =
            (decoded['countries'] as List?) ??
            (decoded['COUNTRIES'] as List?) ??
            (decoded['Countries'] as List?);
      } else if (decoded is List) {
        countriesList = decoded;
      }

      if (countriesList == null || countriesList.isEmpty) {
        _log('[TABULAR] countriesTranslated($loc) parsed EMPTY');
        final empty = <String, String>{};
        _setCache(cacheKey, empty, _ttlCountries);
        return empty;
      }

      final parseSw = Stopwatch()..start();
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
      parseSw.stop();

      _log(
        '[TABULAR] countriesTranslated($loc) parsed size=${map.length} parse=${parseSw.elapsedMilliseconds}ms',
      );
      _setCache(cacheKey, map, _ttlCountries);
      _log(
        '[TABULAR] countriesTranslated($loc) cached ttl=${_ttlCountries.inHours}h',
      );
      return map;
    });
  }

  /// ✅ POST /conversations/private
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

    final bodyString = jsonEncode(payload);
    final key = 'conversations:private:${bodyString.hashCode}';

    Future<Conversation> run() async {
      final netSw = Stopwatch()..start();
      final resp = await _client
          .post(uri, headers: headers, body: bodyString)
          .timeout(const Duration(seconds: 60));
      netSw.stop();

      _log(
        '[TABULAR] POST $uri network=${netSw.elapsedMilliseconds}ms status=${resp.statusCode}',
      );

      if (resp.statusCode != 200 && resp.statusCode != 201) {
        throw Exception(
          'Erreur createOrGetPrivateConversation (${resp.statusCode}) : ${resp.body}',
        );
      }

      final decodeSw = Stopwatch()..start();
      final decoded = jsonDecode(resp.body);
      decodeSw.stop();

      _log(
        '[TABULAR] conversations/private jsonDecode=${decodeSw.elapsedMilliseconds}ms',
      );

      if (decoded is! Map<String, dynamic>) {
        throw Exception('Format inattendu conversations/private: ${resp.body}');
      }

      return Conversation.fromJson(decoded);
    }

    if (!dedup) return run();
    return _dedup<Conversation>(key, run);
  }
}
