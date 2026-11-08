import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/chat_model.dart';
import '../data/models/lawyer_model.dart';
import '../data/models/booking_model.dart';
import '../data/models/user_model.dart';
import '../data/repositories/mock_repository.dart';

// ──────────────────────────────────────────────
// App settings (persisted)
// ──────────────────────────────────────────────
class AppSettings {
  final Locale locale;
  final double textScale;
  final ThemeMode themeMode;
  final bool notifyChat;
  final bool notifyBooking;
  final bool notifyCase;
  final bool firstLaunchSeen;
  final bool guestMode;
  const AppSettings({
    this.locale = const Locale('id'),
    this.textScale = 1.0,
    this.themeMode = ThemeMode.light,
    this.notifyChat = true,
    this.notifyBooking = true,
    this.notifyCase = true,
    this.firstLaunchSeen = false,
    this.guestMode = false,
  });

  AppSettings copyWith({
    Locale? locale,
    double? textScale,
    ThemeMode? themeMode,
    bool? notifyChat,
    bool? notifyBooking,
    bool? notifyCase,
    bool? firstLaunchSeen,
    bool? guestMode,
  }) =>
      AppSettings(
        locale: locale ?? this.locale,
        textScale: textScale ?? this.textScale,
        themeMode: themeMode ?? this.themeMode,
        notifyChat: notifyChat ?? this.notifyChat,
        notifyBooking: notifyBooking ?? this.notifyBooking,
        notifyCase: notifyCase ?? this.notifyCase,
        firstLaunchSeen: firstLaunchSeen ?? this.firstLaunchSeen,
        guestMode: guestMode ?? this.guestMode,
      );
}

class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier() : super(const AppSettings());
  static const _kLang = 'settings.lang';
  static const _kScale = 'settings.textScale';
  static const _kTheme = 'settings.themeMode';
  static const _kNChat = 'settings.notifyChat';
  static const _kNBook = 'settings.notifyBooking';
  static const _kNCase = 'settings.notifyCase';
  static const _kFirst = 'settings.firstLaunchSeen';
  static const _kGuest = 'settings.guestMode';

  Future<void> load() async {
    try {
      final p = await SharedPreferences.getInstance();
      final lang = p.getString(_kLang) ?? 'id';
      final scale = (p.getDouble(_kScale) ?? 1.0).clamp(0.9, 1.3);
      final theme = ThemeMode.light;
      state = AppSettings(
        locale: Locale(lang),
        textScale: scale,
        themeMode: theme,
        notifyChat: p.getBool(_kNChat) ?? true,
        notifyBooking: p.getBool(_kNBook) ?? true,
        notifyCase: p.getBool(_kNCase) ?? true,
        firstLaunchSeen: p.getBool(_kFirst) ?? false,
        guestMode: p.getBool(_kGuest) ?? false,
      );
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
  (_) => SettingsNotifier(),
);

final sharedPreferencesProvider =
    FutureProvider<SharedPreferences>((ref) async {
  return SharedPreferences.getInstance();
});

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

// ──────────────────────────────────────────────
// Auth (prototype/local state)
// ──────────────────────────────────────────────

class AuthNotifier extends StateNotifier<AppUser?> {
  AuthNotifier() : super(null);

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));
    state = AppUser(name: name.trim(), email: email.trim(), provider: 'email');
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));
    final e = email.trim();
    final name = e.contains('@') ? e.split('@').first : 'Pengguna';
    state = AppUser(
      name:
          name.isEmpty ? 'Pengguna' : name[0].toUpperCase() + name.substring(1),
      email: e,
      provider: 'email',
    );
  }

  Future<void> signInWithGoogle() async {
    // Prototype/mock: real Google Sign-In requires platform OAuth/Firebase config.
    await Future.delayed(const Duration(milliseconds: 800));
    state = const AppUser(
      name: 'Google User',
      email: 'google.user@hukumin.app',
      provider: 'google',
      photoUrl: 'https://i.pravatar.cc/150?img=68',
    );
  }

  void logout() => state = null;
}

final authProvider = StateNotifierProvider<AuthNotifier, AppUser?>(
  (_) => AuthNotifier(),
);
