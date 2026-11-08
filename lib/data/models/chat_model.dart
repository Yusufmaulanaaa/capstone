import 'dart:typed_data';
import 'lawyer_model.dart';

class DocumentScanResult {
  final String fileName;
  final Uint8List originalBytes;
  final Uint8List processedBytes;
  final int originalWidth;
  final int originalHeight;
  final int processedWidth;
  final int processedHeight;
  final double brightness;
  final double contrast;
  final double sharpness;
  final double textCoverage;
  final String qualityLabel;
  final String detectedCategory;
  final List<String> pcdSteps;
  final String summary;

  const DocumentScanResult({
    required this.fileName,
    required this.originalBytes,
    required this.processedBytes,
    required this.originalWidth,
    required this.originalHeight,
    required this.processedWidth,
    required this.processedHeight,
    required this.brightness,
    required this.contrast,
    required this.sharpness,
    required this.textCoverage,
    required this.qualityLabel,
    required this.detectedCategory,
    required this.pcdSteps,
    required this.summary,
  });
}

class ChatMessage {
  final String text;
  final bool isUser;
  final bool hasLawyers;
  final DateTime createdAt;
  final DocumentScanResult? scan;
  final List<LawyerModel> lawyers;

  ChatMessage({
    required this.text,
    required this.isUser,
    this.hasLawyers = false,
    DateTime? createdAt,
    this.scan,
    this.lawyers = const <LawyerModel>[],
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

  factory SavedChat.fromJson(Map<String, dynamic> j) => SavedChat(
        id: '${j['id']}',
        title: '${j['title'] ?? 'Percakapan'}',
        preview: '${j['preview'] ?? j['updatedAt'] ?? ''}',
        savedAt: DateTime.tryParse('${j['savedAt'] ?? j['updatedAt'] ?? j['createdAt']}') ?? DateTime.now(),
      );
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

  factory NotificationModel.fromJson(Map<String, dynamic> j) {
    final created = DateTime.tryParse('${j['createdAt'] ?? ''}');
    String rel = '${j['time'] ?? ''}';
    if (rel.isEmpty && created != null) {
      final d = DateTime.now().difference(created);
      if (d.inMinutes < 60) {
        rel = '${d.inMinutes}m lalu';
      } else if (d.inHours < 24) {
        rel = '${d.inHours}j lalu';
      } else {
        rel = '${created.day}/${created.month}/${created.year}';
      }
    }
    return NotificationModel(
      id: '${j['id']}',
      title: '${j['title'] ?? ''}',
      subtitle: '${j['subtitle'] ?? j['body'] ?? ''}',
      time: rel,
      isRead: j['isRead'] == true || j['read'] == true,
    );
  }

  NotificationModel copyWith({bool? isRead}) => NotificationModel(id: id, title: title, subtitle: subtitle, time: time, isRead: isRead ?? this.isRead);
}
