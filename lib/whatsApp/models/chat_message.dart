// lib/whatsApp/models/chat_message.dart

class MessageReaction {
  final int peoplePublicId;
  final String emoji;

  MessageReaction({required this.peoplePublicId, required this.emoji});

  factory MessageReaction.fromJson(Map<String, dynamic> json) {
    return MessageReaction(
      peoplePublicId: json['people_public_id'] as int,
      emoji: json['emoji'] as String,
    );
  }
}

class ChatMessage {
  final int id;
  final int senderPeopleId;
  final String bodyText;
  final DateTime createdAt;
  final String pseudo;

  /// Date de dernière édition (null si jamais édité)
  final DateTime? editedAt;

  /// Id du message auquel on répond (nullable)
  final int? replyToMessageId;

  /// Texte du message auquel on répond (nullable)
  final String? replyBodyText;

  /// Liste des réactions individuelles
  final List<MessageReaction> reactions;

  /// ✅ Option A: vu/non vu sur les messages envoyés par le viewer
  /// Peut être null si non applicable (message de l’autre, groupe, etc.)
  final bool? isSeen;

  ChatMessage({
    required this.id,
    required this.senderPeopleId,
    required this.bodyText,
    required this.createdAt,
    required this.pseudo,
    this.editedAt,
    this.replyToMessageId,
    this.replyBodyText,
    this.reactions = const [],
    this.isSeen,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final reactionsJson = (json['reactions'] as List<dynamic>?) ?? const [];

    return ChatMessage(
      id: json['message_id'] as int,
      senderPeopleId: json['sender_people_id'] as int,
      bodyText: (json['body_text'] ?? '') as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      pseudo: (json['pseudo'] ?? '') as String,

      editedAt: json['edited_at'] != null
          ? DateTime.parse(json['edited_at'] as String)
          : null,

      replyToMessageId: json['reply_to_message_id'] as int?,
      replyBodyText: json['reply_body_text'] as String?,

      reactions: reactionsJson
          .map((r) => MessageReaction.fromJson(r as Map<String, dynamic>))
          .toList(),

      isSeen: json['is_seen'] as bool?,
    );
  }
}
