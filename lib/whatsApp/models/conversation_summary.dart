// lib/whatsApp/models/conversation_summary.dart

class ConversationSummary {
  final int id;
  final String title;
  final bool isGroup;
  final DateTime? createdAt;
  final DateTime? lastMessageAt;

  final int unreadCount; // ✅ nombre de messages non lus (pour le viewer)

  final int? otherPeopleId; // ✅ utile pour avatar en 1–1

  final LastMessageSummary? lastMessage;

  ConversationSummary({
    required this.id,
    required this.title,
    required this.isGroup,
    required this.createdAt,
    required this.lastMessageAt,
    required this.unreadCount,
    required this.otherPeopleId,
    required this.lastMessage,
  });

  factory ConversationSummary.fromJson(Map<String, dynamic> json) {
    return ConversationSummary(
      id: (json['id'] as int),
      title: (json['title'] ?? '') as String,
      isGroup: (json['is_group'] ?? false) as bool,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at']),
      lastMessageAt: json['last_message_at'] == null
          ? null
          : DateTime.parse(json['last_message_at']),
      unreadCount: (json['unread_count'] as int?) ?? 0,
      otherPeopleId: json['other_people_id'] as int?,
      lastMessage: (json['last_message'] == null)
          ? null
          : LastMessageSummary.fromJson(
              json['last_message'] as Map<String, dynamic>,
            ),
    );
  }
}

class LastMessageSummary {
  final int messageId;
  final int? senderPeopleId;
  final String pseudo;
  final String bodyText;
  final DateTime? createdAt;

  /// Option A : bool? (null si pas un message "à moi" ou si groupe)
  final bool? isSeen;

  LastMessageSummary({
    required this.messageId,
    required this.senderPeopleId,
    required this.pseudo,
    required this.bodyText,
    required this.createdAt,
    required this.isSeen,
  });

  factory LastMessageSummary.fromJson(Map<String, dynamic> json) {
    return LastMessageSummary(
      messageId: (json['message_id'] as int),
      senderPeopleId: json['sender_people_id'] as int?,
      pseudo: (json['pseudo'] ?? '') as String,
      bodyText: (json['body_text'] ?? '') as String,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at']),
      isSeen: json['is_seen'] as bool?,
    );
  }
}
