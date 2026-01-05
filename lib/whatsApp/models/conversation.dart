class Conversation {
  final int id;
  final String title;
  final bool isGroup;
  final DateTime createdAt;
  final DateTime lastMessageAt;

  // ✅ NEW
  final int unreadCount;

  Conversation({
    required this.id,
    required this.title,
    required this.isGroup,
    required this.createdAt,
    required this.lastMessageAt,
    this.unreadCount = 0,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] as int,
      title: (json['title'] ?? '') as String,
      isGroup: (json['is_group'] ?? false) as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      lastMessageAt: DateTime.parse(json['last_message_at'] as String),

      // ✅ NEW
      unreadCount: (json['unread_count'] ?? 0) as int,
    );
  }
}
