import 'dart:typed_data';

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

  ChatMessage({
    required this.text,
    required this.isUser,
    this.hasLawyers = false,
    DateTime? createdAt,
    this.scan,
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
