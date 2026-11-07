import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/chat_model.dart';
import '../data/models/lawyer_model.dart';
import '../data/models/booking_model.dart';
import '../data/repositories/mock_repository.dart';

// ──────────────────────────────────────────────
// Chat
// ──────────────────────────────────────────────

class ChatNotifier extends StateNotifier<List<ChatMessage>> {
  ChatNotifier() : super([]);

  void addMessage(ChatMessage msg) => state = [...state, msg];

  void setMessages(List<ChatMessage> msgs) => state = msgs;
}

final chatProvider = StateNotifierProvider<ChatNotifier, List<ChatMessage>>(
  (_) => ChatNotifier(),
);

final typingProvider = StateProvider<bool>((_) => false);

// ──────────────────────────────────────────────
// Saved chats & lawyers
// ──────────────────────────────────────────────

final savedChatsProvider =
    StateNotifierProvider<SavedChatsNotifier, List<SavedChat>>(
  (_) => SavedChatsNotifier(),
);

class SavedChatsNotifier extends StateNotifier<List<SavedChat>> {
  SavedChatsNotifier()
      : super([
          SavedChat(
            id: 'sc1',
            title: 'Wrongful termination case',
            preview: 'AI found 3 lawyers for your employment issue.',
            savedAt: DateTime.now().subtract(const Duration(hours: 2)),
          ),
          SavedChat(
            id: 'sc2',
            title: 'Landlord deposit dispute',
            preview: 'Here are tenant-rights lawyers in Austin.',
            savedAt: DateTime.now().subtract(const Duration(days: 1)),
          ),
        ]);

  void remove(String id) => state = state.where((s) => s.id != id).toList();

  void add(SavedChat chat) => state = [chat, ...state];
}

final savedLawyersProvider =
    StateNotifierProvider<SavedLawyersNotifier, List<LawyerModel>>(
  (_) => SavedLawyersNotifier(),
);

class SavedLawyersNotifier extends StateNotifier<List<LawyerModel>> {
  SavedLawyersNotifier() : super([]);

  void toggle(LawyerModel lawyer) {
    if (state.any((l) => l.id == lawyer.id)) {
      state = state.where((l) => l.id != lawyer.id).toList();
    } else {
      state = [lawyer, ...state];
    }
  }

  void remove(String id) => state = state.where((l) => l.id != id).toList();

  bool isSaved(String id) => state.any((l) => l.id == id);
}

// ──────────────────────────────────────────────
// Notifications
// ──────────────────────────────────────────────

final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, List<NotificationModel>>(
  (_) => NotificationsNotifier(),
);

class NotificationsNotifier extends StateNotifier<List<NotificationModel>> {
  NotificationsNotifier() : super([...kNotifications]);

  void markAllRead() {
    state = state
        .map((n) => NotificationModel(
              id: n.id,
              title: n.title,
              subtitle: n.subtitle,
              time: n.time,
              isRead: true,
            ))
        .toList();
  }

  void markRead(String id) {
    state = state.map((n) {
      if (n.id == id) {
        return NotificationModel(
          id: n.id,
          title: n.title,
          subtitle: n.subtitle,
          time: n.time,
          isRead: true,
        );
      }
      return n;
    }).toList();
  }

  int get unreadCount => state.where((n) => !n.isRead).length;
}

final unreadCountProvider = Provider<int>((ref) {
  return ref.watch(notificationsProvider.notifier).unreadCount;
});

// ──────────────────────────────────────────────
// Booking draft
// ──────────────────────────────────────────────

class BookingDraft {
  final LawyerModel? lawyer;
  final DateTime? date;
  final String? time;
  final ConsultationType type;
  final String note;

  const BookingDraft({
    this.lawyer,
    this.date,
    this.time,
    this.type = ConsultationType.video,
    this.note = '',
  });

  BookingDraft copyWith({
    LawyerModel? lawyer,
    DateTime? date,
    String? time,
    ConsultationType? type,
    String? note,
  }) =>
      BookingDraft(
        lawyer: lawyer ?? this.lawyer,
        date: date ?? this.date,
        time: time ?? this.time,
        type: type ?? this.type,
        note: note ?? this.note,
      );

  bool get isComplete => date != null && time != null;
}

class BookingDraftNotifier extends StateNotifier<BookingDraft> {
  BookingDraftNotifier() : super(const BookingDraft());

  void setLawyer(LawyerModel l) => state = state.copyWith(lawyer: l);
  void setDate(DateTime d) => state = state.copyWith(date: d);
  void setTime(String t) => state = state.copyWith(time: t);
  void setType(ConsultationType t) => state = state.copyWith(type: t);
  void setNote(String n) => state = state.copyWith(note: n);
  void reset() => state = const BookingDraft();
}

final bookingDraftProvider =
    StateNotifierProvider<BookingDraftNotifier, BookingDraft>(
  (_) => BookingDraftNotifier(),
);

// ──────────────────────────────────────────────
// Chat saved toggle
// ──────────────────────────────────────────────

final chatSavedProvider = StateProvider<bool>((_) => false);
