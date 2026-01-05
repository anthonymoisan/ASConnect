class LastMessage {
  final String body;
  final String pseudo;
  final DateTime createdAt;

  // NEW (pour le ✓✓)
  final int? messageId;
  final int? senderPeopleId;
  final bool? isSeen; // null si ce n'est pas un message envoyé par moi

  LastMessage({
    required this.body,
    required this.pseudo,
    required this.createdAt,
    this.messageId,
    this.senderPeopleId,
    this.isSeen,
  });

  factory LastMessage.fromJson(Map<String, dynamic> json) {
    return LastMessage(
      body: (json['body_text'] ?? '') as String,
      pseudo: (json['pseudo'] ?? '') as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      messageId: json['message_id'] as int?,
      senderPeopleId: json['sender_people_id'] as int?,
      isSeen: json['is_seen'] as bool?,
    );
  }
}
