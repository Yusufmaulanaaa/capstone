import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/booking_model.dart';
import '../data/models/chat_model.dart';
import '../data/models/lawyer_model.dart';
import '../data/models/user_model.dart';
import '../data/services/api_client.dart';
import '../data/services/backend_api.dart';
import '../data/services/legal_qa_service.dart';
import '../data/services/session_store.dart';

class AppSettings {
  final Locale locale;
  final double textScale;
  final ThemeMode themeMode;
  final bool notifyChat;
  final bool notifyBooking;
  final bool notifyCase;
  final bool firstLaunchSeen;
  final bool guestMode;
  const AppSettings(
      {this.locale = const Locale('id'),
      this.textScale = 1.0,
      this.themeMode = ThemeMode.light,
      this.notifyChat = true,
      this.notifyBooking = true,
      this.notifyCase = true,
      this.firstLaunchSeen = false,
      this.guestMode = false});
  AppSettings copyWith(
          {Locale? locale,
          double? textScale,
          ThemeMode? themeMode,
          bool? notifyChat,
          bool? notifyBooking,
          bool? notifyCase,
          bool? firstLaunchSeen,
          bool? guestMode}) =>
      AppSettings(
          locale: locale ?? this.locale,
          textScale: textScale ?? this.textScale,
          themeMode: themeMode ?? this.themeMode,
          notifyChat: notifyChat ?? this.notifyChat,
          notifyBooking: notifyBooking ?? this.notifyBooking,
          notifyCase: notifyCase ?? this.notifyCase,
          firstLaunchSeen: firstLaunchSeen ?? this.firstLaunchSeen,
          guestMode: guestMode ?? this.guestMode);
}

class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier() : super(const AppSettings());
  static const _kLang = 'settings.lang',
      _kScale = 'settings.textScale',
      _kTheme = 'settings.themeMode',
      _kNChat = 'settings.notifyChat',
      _kNBook = 'settings.notifyBooking',
      _kNCase = 'settings.notifyCase',
      _kFirst = 'settings.firstLaunchSeen',
      _kGuest = 'settings.guestMode';
  Future<void> load() async {
    try {
      final p = await SharedPreferences.getInstance();
      state = AppSettings(
          locale: Locale(p.getString(_kLang) ?? 'id'),
          textScale: (p.getDouble(_kScale) ?? 1.0).clamp(0.9, 1.3),
          themeMode: ThemeMode.light,
          notifyChat: p.getBool(_kNChat) ?? true,
          notifyBooking: p.getBool(_kNBook) ?? true,
          notifyCase: p.getBool(_kNCase) ?? true,
          firstLaunchSeen: p.getBool(_kFirst) ?? false,
          guestMode: p.getBool(_kGuest) ?? false);
    } catch (_) {}
  }

  Future<void> _save() async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setString(_kLang, state.locale.languageCode);
      await p.setDouble(_kScale, state.textScale);
      await p.setInt(_kTheme, state.themeMode.index);
      await p.setBool(_kNChat, state.notifyChat);
      await p.setBool(_kNBook, state.notifyBooking);
      await p.setBool(_kNCase, state.notifyCase);
      await p.setBool(_kFirst, state.firstLaunchSeen);
      await p.setBool(_kGuest, state.guestMode);
    } catch (_) {}
  }

  Future<void> setLocale(Locale l) async {
    state = state.copyWith(locale: l);
    await _save();
  }

  Future<void> setTextScale(double v) async {
    state = state.copyWith(textScale: v.clamp(0.9, 1.3));
    await _save();
  }

  Future<void> setThemeMode(ThemeMode m) async {
    state = state.copyWith(themeMode: m);
    await _save();
  }

  Future<void> setNotifyChat(bool v) async {
    state = state.copyWith(notifyChat: v);
    await _save();
  }

  Future<void> setNotifyBooking(bool v) async {
    state = state.copyWith(notifyBooking: v);
    await _save();
  }

  Future<void> setNotifyCase(bool v) async {
    state = state.copyWith(notifyCase: v);
    await _save();
  }

  Future<void> markFirstLaunchSeen() async {
    if (!state.firstLaunchSeen) {
      state = state.copyWith(firstLaunchSeen: true);
      await _save();
    }
  }

  Future<void> setGuestMode(bool v) async {
    state = state.copyWith(guestMode: v);
    await _save();
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>(
    (_) => SettingsNotifier());
final sharedPreferencesProvider = FutureProvider<SharedPreferences>(
    (_) async => SharedPreferences.getInstance());

// Backend wiring
final sessionStoreProvider = Provider<SessionStore>((_) => SessionStore());
final apiClientProvider =
    Provider<ApiClient>((ref) => ApiClient(ref.watch(sessionStoreProvider)));
final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository(
    ref.watch(apiClientProvider), ref.watch(sessionStoreProvider)));
final lawyersApiProvider =
    Provider<LawyersApi>((ref) => LawyersApi(ref.watch(apiClientProvider)));
final chatApiProvider =
    Provider<ChatApi>((ref) => ChatApi(ref.watch(apiClientProvider)));
final legalQaProvider = Provider<LegalQaService>((ref) => LegalQaService());
final bookingsApiProvider =
    Provider<BookingsApi>((ref) => BookingsApi(ref.watch(apiClientProvider)));
final notificationsApiProvider = Provider<NotificationsApi>(
    (ref) => NotificationsApi(ref.watch(apiClientProvider)));

final lawyersProvider = FutureProvider.autoDispose<List<LawyerModel>>(
    (ref) => ref.watch(lawyersApiProvider).fetch());
final lawyerDetailProvider = FutureProvider.autoDispose
    .family<LawyerModel, String>(
        (ref, id) => ref.watch(lawyersApiProvider).detail(id));
final myBookingsProvider =
    FutureProvider.autoDispose<List<BookingModel>>((ref) async {
  final user = ref.watch(authProvider);
  if (user == null) return const <BookingModel>[];
  return ref.watch(bookingsApiProvider).list();
});
final bookingSlotsProvider = FutureProvider.autoDispose
    .family<List<Map<String, dynamic>>, ({String lawyerId, String date})>(
        (ref, q) => ref.watch(bookingsApiProvider).slots(q.lawyerId, q.date));
final conversationsProvider =
    FutureProvider.autoDispose<List<SavedChat>>((ref) async {
  final user = ref.watch(authProvider);
  if (user == null) return const <SavedChat>[];
  return ref.watch(chatApiProvider).conversations();
});

// Chat
class ChatState {
  final List<ChatMessage> messages;
  final String? conversationId;
  const ChatState({this.messages = const [], this.conversationId});
  ChatState copyWith(
          {List<ChatMessage>? messages,
          String? conversationId,
          bool clearConversation = false}) =>
      ChatState(
          messages: messages ?? this.messages,
          conversationId: clearConversation
              ? null
              : (conversationId ?? this.conversationId));
}

class ChatNotifier extends StateNotifier<ChatState> {
  ChatNotifier() : super(const ChatState());
  void setMessages(List<ChatMessage> msgs,
          {String? conversationId, bool clearConversation = false}) =>
      state = state.copyWith(
          messages: msgs,
          conversationId: conversationId,
          clearConversation: clearConversation);
  void addMessage(ChatMessage msg) =>
      state = state.copyWith(messages: [...state.messages, msg]);
  void newConversation() => state = const ChatState();
}

final chatProvider =
    StateNotifierProvider<ChatNotifier, ChatState>((_) => ChatNotifier());
final typingProvider = StateProvider<bool>((_) => false);

// Saved (local favorites)
final savedChatsProvider =
    StateNotifierProvider<SavedChatsNotifier, List<SavedChat>>(
        (_) => SavedChatsNotifier());

class SavedChatsNotifier extends StateNotifier<List<SavedChat>> {
  SavedChatsNotifier() : super(const []);
  void remove(String id) => state = state.where((s) => s.id != id).toList();
  void add(SavedChat chat) {
    if (state.any((s) => s.id == chat.id)) return;
    state = [chat, ...state];
  }
}

final savedLawyersProvider =
    StateNotifierProvider<SavedLawyersNotifier, List<LawyerModel>>(
        (_) => SavedLawyersNotifier());

class SavedLawyersNotifier extends StateNotifier<List<LawyerModel>> {
  SavedLawyersNotifier() : super([]);
  void toggle(LawyerModel lawyer) {
    state = state.any((l) => l.id == lawyer.id)
        ? state.where((l) => l.id != lawyer.id).toList()
        : [lawyer, ...state];
  }

  void remove(String id) => state = state.where((l) => l.id != id).toList();
  bool isSaved(String id) => state.any((l) => l.id == id);
}

// Notifications (backend-backed)
final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, List<NotificationModel>>(
        (ref) => NotificationsNotifier(ref));

class NotificationsNotifier extends StateNotifier<List<NotificationModel>> {
  final Ref ref;
  NotificationsNotifier(this.ref) : super(const []);
  int get unreadCount => state.where((n) => !n.isRead).length;
  Future<void> refresh() async {
    final user = ref.read(authProvider);
    if (user == null) {
      state = const [];
      return;
    }
    try {
      final res = await ref.read(notificationsApiProvider).list();
      state = res.items;
    } catch (_) {}
  }

  Future<void> markAllRead() async {
    state = [for (final n in state) n.copyWith(isRead: true)];
    if (ref.read(authProvider) != null) {
      try {
        await ref.read(notificationsApiProvider).readAll();
      } catch (_) {}
    }
  }

  void markRead(String id) {
    state = [for (final n in state) n.id == id ? n.copyWith(isRead: true) : n];
  }
}

final unreadCountProvider = Provider<int>(
    (ref) => ref.watch(notificationsProvider).where((n) => !n.isRead).length);

// Booking draft
class BookingDraft {
  final LawyerModel? lawyer;
  final DateTime? date;
  final String? time;
  final ConsultationType type;
  final String note;
  const BookingDraft(
      {this.lawyer,
      this.date,
      this.time,
      this.type = ConsultationType.video,
      this.note = ''});
  BookingDraft copyWith(
          {LawyerModel? lawyer,
          DateTime? date,
          String? time,
          ConsultationType? type,
          String? note}) =>
      BookingDraft(
          lawyer: lawyer ?? this.lawyer,
          date: date ?? this.date,
          time: time ?? this.time,
          type: type ?? this.type,
          note: note ?? this.note);
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
        (_) => BookingDraftNotifier());
final chatSavedProvider = StateProvider<bool>((_) => false);

// Auth
class AuthNotifier extends StateNotifier<AppUser?> {
  final Ref ref;
  AuthNotifier(this.ref) : super(null);
  Future<void> restore() async {
    try {
      state = await ref.read(authRepositoryProvider).restore();
    } catch (_) {
      state = null;
    }
    if (state != null) {
      await ref.read(notificationsProvider.notifier).refresh();
    }
  }

  Future<void> register(
      {required String name,
      required String email,
      required String password}) async {
    state = await ref
        .read(authRepositoryProvider)
        .register(name: name, email: email, password: password);
    await ref.read(notificationsProvider.notifier).refresh();
  }

  Future<void> login({required String email, required String password}) async {
    state = await ref
        .read(authRepositoryProvider)
        .login(email: email, password: password);
    await ref.read(notificationsProvider.notifier).refresh();
  }

  Future<void> signInWithGoogle() async {
    throw ApiException(
        'Login Google belum dikonfigurasi. Silakan masuk dengan email dan kata sandi.');
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = null;
    ref.read(chatProvider.notifier).newConversation();
    ref.read(notificationsProvider.notifier).state = const [];
  }
}

final authProvider =
    StateNotifierProvider<AuthNotifier, AppUser?>((ref) => AuthNotifier(ref));
