import '../models/booking_model.dart';
import '../models/lawyer_model.dart';

// UI-only models kept for compatibility with unused/local features.
enum CaseStageStatus { completed, current, upcoming }

class ConsultationHistoryItem {
  final String id;
  final LawyerModel? lawyer;
  final BookingModel? booking;
  final DateTime date;
  final String time;
  final ConsultationType type;
  final String status;
  final int? rating;
  const ConsultationHistoryItem({required this.id, this.lawyer, this.booking, required this.date, required this.time, required this.type, required this.status, this.rating});
  String get lawyerName => booking?.lawyerName ?? lawyer?.name ?? 'Pengacara';
  String get lawyerRole => booking?.lawyerRole ?? lawyer?.role ?? '';
  String get lawyerPhoto => booking?.lawyerPhoto ?? lawyer?.photo ?? '';
}
