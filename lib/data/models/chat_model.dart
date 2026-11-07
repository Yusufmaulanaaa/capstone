class ChatMessage {
  final String text;
  final bool isUser;
  final bool hasLawyers;
  final DateTime createdAt;

  ChatMessage({
    required this.text,
    required this.isUser,
    this.hasLawyers = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}

class SavedChat {
  final String id;
  final String title;
  final String preview;
  final DateTime savedAt;

  const SavedChat({
    required this.id,
    required this.title,
    required this.preview,
    required this.savedAt,
  });
}

class NotificationModel {
  final String id;
  final String title;
  final String subtitle;
  final String time;
  bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.time,
    this.isRead = false,
  });
}
