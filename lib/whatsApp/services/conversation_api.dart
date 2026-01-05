// lib/whatsApp/services/conversation_api.dart

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/conversation.dart';
import '../models/lastMessage.dart';
import '../models/chat_message.dart';
import '../models/conversation_summary.dart';

// 🔑 Clé d'application publique — valable pour tous les endpoints /api/public/*
const String _publicAppKey = String.fromEnvironment(
  'PUBLIC_APP_KEY',
  defaultValue: '',
);

// Exposé au reste de l’app
const String publicAppKey = _publicAppKey;

// Base API publique
const String _base = 'https://anthonymoisan.pythonanywhere.com/api/public';

// URL photo d’une personne
String personPhotoUrl(int id) => '$_base/people/$id/photo';

class _CacheEntry<T> {
  final T value;
  final DateTime expiresAt;
  _CacheEntry(this.value, this.expiresAt);

  bool get isValid => DateTime.now().isBefore(expiresAt);
}

class ConversationApi {
  static const String _baseUrl = _base;
  static const String _appKey = _publicAppKey;

  // ✅ Un seul client HTTP réutilisé
  static final http.Client _client = http.Client();

  // ✅ TTL (ajuste selon besoin)
  static const Duration _ttlShort = Duration(seconds: 8); // lastMessage, unread
  static const Duration _ttlLong = Duration(
    minutes: 15,
  ); // pseudo/id other member

  // ✅ caches (valeur)
  static final Map<String, _CacheEntry<dynamic>> _cache = {};

  // ✅ caches "in-flight" pour éviter les requêtes doublons
  static final Map<String, Future<dynamic>> _inFlight = {};

  static Map<String, String> get _headers => {'X-App-Key': _appKey};

  static void dispose() {
    _client.close();
    _cache.clear();
    _inFlight.clear();
  }

  // -----------------------
  // Helpers cache
  // -----------------------
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

    // nettoyage inFlight à la fin
    f.whenComplete(() => _inFlight.remove(key));
    return f;
  }

  // -----------------------
  // API
  // -----------------------

  /// Récupère toutes les conversations d'une personne (user connecté)
  static Future<List<Conversation>> fetchConversationsForPerson(
    int personId,
  ) async {
    final uri = Uri.parse('$_baseUrl/people/$personId/conversations');
    final cacheKey = 'convs:$personId';

    // cache court : liste peut changer souvent
    final cached = _getCache<List<Conversation>>(cacheKey);
    if (cached != null) return cached;

    return _dedup<List<Conversation>>(cacheKey, () async {
      final response = await _client.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList =
            jsonDecode(response.body) as List<dynamic>;
        final convs = jsonList
            .map((json) => Conversation.fromJson(json as Map<String, dynamic>))
            .toList();

        _setCache(cacheKey, convs, _ttlShort);
        return convs;
      }
      throw Exception('Erreur API (${response.statusCode}) : ${response.body}');
    });
  }

  /// Récupère l'id de l'autre membre (celui qui n'est pas currentPersonId)
  static Future<int?> fetchOtherMemberId({
    required int conversationId,
    required int currentPersonId,
  }) async {
    final cacheKey = 'otherId:$conversationId:$currentPersonId';
    final cached = _getCache<int?>(cacheKey);
    if (cached != null) return cached;

    return _dedup<int?>(cacheKey, () async {
      final uri = Uri.parse(
        '$_baseUrl/conversations/$conversationId/members/ids',
      );
      final response = await _client.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
            jsonDecode(response.body) as Map<String, dynamic>;
        final List<dynamic> ids = (data['member_ids'] ?? []) as List<dynamic>;
        final others = ids
            .where((id) => (id as int) != currentPersonId)
            .toList();
        final other = others.isEmpty ? null : others.first as int;

        _setCache(cacheKey, other, _ttlLong);
        return other;
      }

      throw Exception(
        'Erreur fetchOtherMemberId (${response.statusCode}) : ${response.body}',
      );
    });
  }

  /// Récupère le pseudo de l'autre membre à partir de son infoPublic
  static Future<String?> fetchOtherMemberPseudo({
    required int conversationId,
    required int currentPersonId,
  }) async {
    final cacheKey = 'otherPseudo:$conversationId:$currentPersonId';
    final cached = _getCache<String?>(cacheKey);
    if (cached != null) return cached;

    return _dedup<String?>(cacheKey, () async {
      final otherId = await fetchOtherMemberId(
        conversationId: conversationId,
        currentPersonId: currentPersonId,
      );
      if (otherId == null) {
        _setCache(cacheKey, null, _ttlLong);
        return null;
      }

      final uri = Uri.parse('$_baseUrl/people/$otherId/infoPublic');
      final response = await _client.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
            jsonDecode(response.body) as Map<String, dynamic>;
        final pseudo = data['pseudo'] as String?;
        _setCache(cacheKey, pseudo, _ttlLong);
        return pseudo;
      } else if (response.statusCode == 404) {
        _setCache(cacheKey, null, _ttlLong);
        return null;
      }

      throw Exception(
        'Erreur fetchOtherMemberPseudo (${response.statusCode}) : ${response.body}',
      );
    });
  }

  /// Récupère le dernier message d'une conversation (cache court)
  static Future<LastMessage?> fetchLastMessage(
    int conversationId, {
    int? viewerPeopleId,
  }) async {
    final cacheKey = 'lastMsg:$conversationId:${viewerPeopleId ?? "none"}';
    final cached = _getCache<LastMessage?>(cacheKey);
    if (cached != null) return cached;

    return _dedup<LastMessage?>(cacheKey, () async {
      final base = '$_baseUrl/conversations/$conversationId/messages/last';
      final uri = (viewerPeopleId == null)
          ? Uri.parse(base)
          : Uri.parse(base).replace(
              queryParameters: {'viewer_people_id': viewerPeopleId.toString()},
            );

      final response = await _client.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
            jsonDecode(response.body) as Map<String, dynamic>;
        if (data.isEmpty) {
          _setCache(cacheKey, null, _ttlShort);
          return null;
        }
        if (data['last_message'] == null && data.length == 1) {
          _setCache(cacheKey, null, _ttlShort);
          return null;
        }

        final lm = LastMessage.fromJson(data);
        _setCache(cacheKey, lm, _ttlShort);
        return lm;
      } else if (response.statusCode == 404) {
        _setCache(cacheKey, null, _ttlShort);
        return null;
      }

      throw Exception(
        'Erreur fetchLastMessage (${response.statusCode}) : ${response.body}',
      );
    });
  }

  /// Récupère tous les messages d'une conversation
  static Future<List<ChatMessage>> fetchMessages(
    int conversationId, {
    int? viewerPeopleId,
  }) async {
    final base = '$_baseUrl/conversations/$conversationId/messages';
    final uri = (viewerPeopleId == null)
        ? Uri.parse(base)
        : Uri.parse(base).replace(
            queryParameters: {'viewer_people_id': viewerPeopleId.toString()},
          );

    final response = await _client.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body) as List<dynamic>;
      return jsonList
          .map((j) => ChatMessage.fromJson(j as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Erreur API (${response.statusCode}) : ${response.body}');
  }

  // ✅ POST /api/public/conversations/<id>/read
  static Future<void> markConversationRead({
    required int conversationId,
    required int peoplePublicId,
    required int lastReadMessageId,
  }) async {
    final uri = Uri.parse('$_baseUrl/conversations/$conversationId/read');

    final resp = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json', 'X-App-Key': _appKey},
      body: jsonEncode({
        'people_public_id': peoplePublicId,
        'last_read_message_id': lastReadMessageId,
      }),
    );

    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw Exception(
        'Erreur markConversationRead (${resp.statusCode}) : ${resp.body}',
      );
    }

    // ✅ invalidation cache : last message / unread peuvent changer
    _cache.removeWhere((k, _) => k.startsWith('lastMsg:$conversationId:'));
  }

  static Future<void> sendMessage({
    required int conversationId,
    required int senderPeopleId,
    required String bodyText,
    int? replyToMessageId,
  }) async {
    final uri = Uri.parse('$_baseUrl/conversations/$conversationId/messages');

    final body = <String, dynamic>{
      'sender_people_id': senderPeopleId,
      'body_text': bodyText,
      'reply_to_message_id': replyToMessageId,
      'has_attachments': false,
      'status': 'normal',
    };

    final response = await _client.post(
      uri,
      headers: {'X-App-Key': _appKey, 'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Erreur envoi message: ${response.statusCode} ${response.body}',
      );
    }

    // ✅ invalidation cache last message
    _cache.removeWhere((k, _) => k.startsWith('lastMsg:$conversationId:'));
  }

  static Future<void> editMessage({
    required int messageId,
    required int editorPeopleId,
    required String newBodyText,
  }) async {
    final uri = Uri.parse('$_baseUrl/messages/$messageId/edit');

    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json', 'X-App-Key': _appKey},
      body: jsonEncode({
        'editor_people_id': editorPeopleId,
        'new_text': newBodyText,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Erreur édition (${response.statusCode}) : ${response.body}',
      );
    }
  }

  static Future<void> deleteMessage({
    required int messageId,
    required int editorPeopleId,
  }) async {
    final uri = Uri.parse('$_baseUrl/messages/$messageId');

    final response = await _client.delete(
      uri,
      headers: {'Content-Type': 'application/json', 'X-App-Key': _appKey},
      body: jsonEncode({'editor_people_id': editorPeopleId}),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(
        'Erreur suppression (${response.statusCode}) : ${response.body}',
      );
    }
  }

  static Future<void> setReaction({
    required int messageId,
    required int peoplePublicId,
    required String emoji,
    required bool deleted,
  }) async {
    final uri = Uri.parse('$_baseUrl/messages/$messageId/reactions');

    final body = <String, dynamic>{
      'deleted': deleted,
      'emoji': emoji,
      'message_id': messageId,
      'people_public_id': peoplePublicId,
    };

    final resp = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json', 'X-App-Key': _appKey},
      body: jsonEncode(body),
    );

    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw Exception('Erreur setReaction (${resp.statusCode}) : ${resp.body}');
    }
  }

  static Future<void> leaveConversation({
    required int conversationId,
    required int peoplePublicId,
    required bool softDeleteOwnMessages,
    required bool deleteEmptyConversation,
  }) async {
    final uri = Uri.parse('$_baseUrl/conversations/$conversationId/leave');

    final body = <String, dynamic>{
      'people_public_id': peoplePublicId,
      'soft_delete_own_messages': softDeleteOwnMessages,
      'delete_empty_conversation': deleteEmptyConversation,
    };

    final resp = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json', 'X-App-Key': _appKey},
      body: jsonEncode(body),
    );

    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw Exception(
        'Erreur leaveConversation (${resp.statusCode}) : ${resp.body}',
      );
    }
  }

  static Future<List<Conversation>> fetchConversationsUnreadForPerson(
    int personId,
  ) async {
    final uri = Uri.parse('$_baseUrl/people/$personId/conversationsUnRead');
    final cacheKey = 'unreadList:$personId';

    final cached = _getCache<List<Conversation>>(cacheKey);
    if (cached != null) return cached;

    return _dedup<List<Conversation>>(cacheKey, () async {
      final response = await _client.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList =
            jsonDecode(response.body) as List<dynamic>;
        final convs = jsonList
            .map((json) => Conversation.fromJson(json as Map<String, dynamic>))
            .toList();

        _setCache(cacheKey, convs, _ttlShort);
        return convs;
      }
      throw Exception('Erreur API (${response.statusCode}) : ${response.body}');
    });
  }

  // ✅ Total des messages non lus (somme des unread_count)
  static Future<int> fetchUnreadTotalForPerson(int personId) async {
    final uri = Uri.parse('$_baseUrl/people/$personId/conversationsUnRead');
    final cacheKey = 'unreadTotal:$personId';

    final cached = _getCache<int>(cacheKey);
    if (cached != null) return cached;

    return _dedup<int>(cacheKey, () async {
      final response = await _client.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList =
            jsonDecode(response.body) as List<dynamic>;
        int total = 0;
        for (final item in jsonList) {
          final m = item as Map<String, dynamic>;
          total += (m['unread_count'] as int?) ?? 0;
        }

        _setCache(cacheKey, total, _ttlShort);
        return total;
      }

      throw Exception(
        'Erreur fetchUnreadTotalForPerson (${response.statusCode}) : ${response.body}',
      );
    });
  }

  static Future<List<ConversationSummary>> fetchConversationsSummaryForPerson(
    int personId,
  ) async {
    final uri = Uri.parse('$_baseUrl/people/$personId/conversationsSummary');

    final response = await http.get(uri, headers: {'X-App-Key': _appKey});

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body) as List<dynamic>;
      return jsonList
          .map((j) => ConversationSummary.fromJson(j as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception(
        'Erreur fetchConversationsSummaryForPerson (${response.statusCode}) : ${response.body}',
      );
    }
  }
}
