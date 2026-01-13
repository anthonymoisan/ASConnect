import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/listPerson.dart';

// 🔑 Clé d'application publique — valable pour tous les endpoints /api/public/*
const String _publicAppKey = String.fromEnvironment(
  'PUBLIC_APP_KEY',
  defaultValue: '',
);

// Base API publique
const String _base = 'https://anthonymoisan.pythonanywhere.com/api/public';

class _CacheEntry<T> {
  final T value;
  final DateTime expiresAt;
  _CacheEntry(this.value, this.expiresAt);
  bool get isValid => DateTime.now().isBefore(expiresAt);
}

class TabularApi {
  static const String _baseUrl = _base;
  static const String _appKey = _publicAppKey;

  static final http.Client _client = http.Client();

  // TTL conseillé : dataset “people map” bouge moins souvent que les messages
  static const Duration _ttlPeople = Duration(minutes: 5);

  static final Map<String, _CacheEntry<dynamic>> _cache = {};
  static final Map<String, Future<dynamic>> _inFlight = {};

  static Map<String, String> get _headers => {'X-App-Key': _appKey};

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

  /// ✅ Récupère la représentation "map" des personnes (liste)
  /// force=true => ignore le cache
  static Future<ListPerson> fetchPeopleMapRepresentation({
    bool force = false,
  }) async {
    final uri = Uri.parse('$_baseUrl/peopleMapRepresentation');
    const cacheKey = 'people:mapRepresentation';

    if (!force) {
      final cached = _getCache<ListPerson>(cacheKey);
      if (cached != null) return cached;
    } else {
      _cache.remove(cacheKey);
    }

    return _dedup<ListPerson>(cacheKey, () async {
      final resp = await _client
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 60));

      if (resp.statusCode != 200) {
        throw Exception(
          'Erreur fetchPeopleMapRepresentation (${resp.statusCode}) : ${resp.body}',
        );
      }

      final decoded = jsonDecode(resp.body);

      // ton API renvoie souvent une List directement
      if (decoded is List) {
        final listPerson = ListPerson.fromJsonList(decoded);
        _setCache(cacheKey, listPerson, _ttlPeople);
        return listPerson;
      }

      throw Exception('Format inattendu peopleMapRepresentation');
    });
  }
}
