class Conversation {
  final int id;
  final String title;
  final bool isGroup;
  final DateTime createdAt;
  final DateTime lastMessageAt;
  final int unreadCount;

  Conversation({
    required this.id,
    required this.title,
    required this.isGroup,
    required this.createdAt,
    required this.lastMessageAt,
    this.unreadCount = 0,
  });

  static DateTime _parseDateOrNow(dynamic v) {
    if (v == null) return DateTime.now();
    final s = v.toString().trim();
    final dt = DateTime.tryParse(s);
    return dt ?? DateTime.now();
  }

  static int _parseInt(dynamic v) {
    if (v is int) return v;
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: _parseInt(json['id']),
      title: (json['title'] ?? '').toString(),
      isGroup: (json['is_group'] ?? json['isGroup'] ?? false) == true,
      createdAt: _parseDateOrNow(json['created_at'] ?? json['createdAt']),
      lastMessageAt: _parseDateOrNow(
        json['last_message_at'] ?? json['lastMessageAt'],
      ),
      unreadCount: _parseInt(json['unread_count'] ?? json['unreadCount'] ?? 0),
    );
  }
}
