import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/booking_model.dart';
import '../models/lawyer_model.dart';
import 'mock_repository.dart';

enum CaseStageStatus { completed, current, upcoming }

class CaseStage {
  final String title;
  final String note;
  final CaseStageStatus status;
  final DateTime? date;
  const CaseStage(
      {required this.title,
      required this.note,
      required this.status,
      this.date});
  CaseStage copyWith({CaseStageStatus? status, String? note}) => CaseStage(
      title: title,
      note: note ?? this.note,
      status: status ?? this.status,
      date: date);
}

class CaseDocumentItem {
  final String name;
  final String sizeLabel;
  final String type;
  const CaseDocumentItem(
      {required this.name, required this.sizeLabel, required this.type});
}

class CaseNote {
  final String text;
  final DateTime at;
  const CaseNote({required this.text, required this.at});
}

class CaseModel {
  final String id;
  final String title;
  final String sourceChat;
  final List<CaseStage> stages;
  final List<CaseNote> notes;
  final List<CaseDocumentItem> documents;
  final String nextReminder;
  const CaseModel(
      {required this.id,
      required this.title,
      required this.sourceChat,
      required this.stages,
      required this.notes,
      required this.documents,
      required this.nextReminder});
  CaseStage get currentStage =>
      stages.firstWhere((s) => s.status == CaseStageStatus.current,
          orElse: () => stages.last);
}

class ConsultationHistoryItem {
  final String id;
  final LawyerModel lawyer;
  final DateTime date;
  final String time;
  final ConsultationType type;
  final String status; // Upcoming, Completed, Cancelled
  final int? rating;
  const ConsultationHistoryItem(
      {required this.id,
      required this.lawyer,
      required this.date,
      required this.time,
      required this.type,
      required this.status,
      this.rating});
  ConsultationHistoryItem copyWith(
          {String? status, DateTime? date, String? time, int? rating}) =>
      ConsultationHistoryItem(
          id: id,
          lawyer: lawyer,
          date: date ?? this.date,
          time: time ?? this.time,
          type: type,
          status: status ?? this.status,
          rating: rating ?? this.rating);
}

class PaymentReceipt {
  final String id;
  final String lawyerName;
  final String method;
  final String amount;
  final DateTime at;
  final String status;
  final String promo;
  const PaymentReceipt(
      {required this.id,
      required this.lawyerName,
      required this.method,
      required this.amount,
      required this.at,
      required this.status,
      required this.promo});
}

abstract class ICaseRepository {
  Future<List<CaseModel>> fetchCases();
  Future<void> addCase(CaseModel c);
}

abstract class IHistoryRepository {
  Future<List<ConsultationHistoryItem>> fetchConsultations();
}

abstract class IPaymentRepository {
  Future<PaymentReceipt> pay(
      {required BookingModel booking,
      required String method,
      required String promo,
      bool fail = false});
}

class MockCaseRepository implements ICaseRepository {
  static final List<CaseModel> _store = [];
  @override
  Future<List<CaseModel>> fetchCases() async {
    await Future.delayed(const Duration(milliseconds: 350));
    return List.unmodifiable(_store);
  }

  @override
  Future<void> addCase(CaseModel c) async {
    await Future.delayed(const Duration(milliseconds: 250));
    _store.insert(0, c);
  }
}

class MockHistoryRepository implements IHistoryRepository {
  @override
  Future<List<ConsultationHistoryItem>> fetchConsultations() async {
    await Future.delayed(const Duration(milliseconds: 350));
    final l = kLawyers;
    return [
      ConsultationHistoryItem(
          id: 'h1',
          lawyer: l[0],
          date: DateTime.now().add(const Duration(days: 1)),
          time: '10:00',
          type: ConsultationType.video,
          status: 'Upcoming'),
      ConsultationHistoryItem(
          id: 'h2',
          lawyer: l.length > 1 ? l[1] : l[0],
          date: DateTime.now().subtract(const Duration(days: 3)),
          time: '14:00',
          type: ConsultationType.voice,
          status: 'Completed',
          rating: 5),
      ConsultationHistoryItem(
          id: 'h3',
          lawyer: l.length > 2 ? l[2] : l[0],
          date: DateTime.now().subtract(const Duration(days: 10)),
          time: '09:00',
          type: ConsultationType.inPerson,
          status: 'Cancelled'),
    ];
  }
}

class MockPaymentRepository implements IPaymentRepository {
  @override
  Future<PaymentReceipt> pay(
      {required BookingModel booking,
      required String method,
      required String promo,
      bool fail = false}) async {
    await Future.delayed(const Duration(milliseconds: 900));
    if (fail) throw Exception('Pembayaran gagal (simulasi).');
    final discount = promo.trim().toUpperCase() == 'HUKUMIN10' ? 0.1 : 0.0;
    final total = (booking.priceNum * (1 - discount)).round();
    return PaymentReceipt(
        id: 'RCPT-${DateTime.now().millisecondsSinceEpoch}',
        lawyerName: booking.lawyerName,
        method: method,
        amount: 'Rp${total}rb',
        at: DateTime.now(),
        status: 'Berhasil',
        promo: discount > 0 ? promo : '-');
  }
}

final caseRepositoryProvider =
    Provider<ICaseRepository>((_) => MockCaseRepository());
final historyRepositoryProvider =
    Provider<IHistoryRepository>((_) => MockHistoryRepository());
final paymentRepositoryProvider =
    Provider<IPaymentRepository>((_) => MockPaymentRepository());

final casesProvider = FutureProvider<List<CaseModel>>(
    (ref) => ref.watch(caseRepositoryProvider).fetchCases());
final consultationsHistoryProvider =
    FutureProvider<List<ConsultationHistoryItem>>(
        (ref) => ref.watch(historyRepositoryProvider).fetchConsultations());
