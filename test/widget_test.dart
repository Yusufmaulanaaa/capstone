import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hukumin/core/theme.dart';
import 'package:hukumin/core/providers.dart';
import 'package:hukumin/features/onboarding/screens/onboarding_screen.dart';
import 'package:hukumin/features/home/screens/home_screen.dart';
import 'package:hukumin/features/chat/screens/chat_screen.dart';
import 'package:hukumin/features/booking/screens/book_consultation_screen.dart';
import 'package:hukumin/features/booking/screens/booking_confirmed_screen.dart';
import 'package:hukumin/features/saved/screens/saved_screen.dart';
import 'package:hukumin/features/auth/screens/login_screen.dart';
import 'package:hukumin/features/auth/screens/register_screen.dart';
import 'package:hukumin/data/repositories/mock_repository.dart';
import 'package:hukumin/data/models/lawyer_model.dart';
import 'package:hukumin/data/models/booking_model.dart';

Widget _buildTestApp({
  required String initialLocation,
  Map<String, dynamic>? extra,
  List<Override> overrides = const [],
}) {
  final testRouter = GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: '/',
        name: 'onboarding',
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (_, __) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (_, __) => const HomeScreen(),
      ),
      GoRoute(
        path: '/chat',
        name: 'chat',
        builder: (_, state) {
          final ext = state.extra as Map<String, dynamic>?;
          return ChatScreen(initial: ext?['initial'] as String?);
        },
      ),
      GoRoute(
        path: '/book',
        name: 'book',
        builder: (_, state) {
          final ext = state.extra as Map<String, dynamic>?;
          return BookConsultationScreen(
            lawyer: ext?['lawyer'] as LawyerModel? ?? kLawyers[0],
          );
        },
      ),
      GoRoute(
        path: '/booking-confirmed',
        name: 'bookingConfirmed',
        builder: (_, state) {
          final ext = state.extra as Map<String, dynamic>?;
          final booking = ext?['booking'] as BookingModel? ??
              BookingModel(
                lawyerName: 'Rizky Pratama, S.H.',
                lawyerRole: 'Pengacara Pidana',
                lawyerPhoto: '',
                price: 'Rp350rb/jam',
                priceNum: 350,
                date: DateTime.now(),
                time: '10:00',
                type: ConsultationType.video,
              );
          return BookingConfirmedScreen(booking: booking);
        },
      ),
      GoRoute(
        path: '/saved',
        name: 'saved',
        builder: (_, __) => const SavedScreen(),
      ),
    ],
  );

  return ProviderScope(
    overrides: overrides,
    child: MaterialApp.router(
      theme: buildTheme(),
      routerConfig: testRouter,
    ),
  );
}

void main() {
  // ── Test 1: Onboarding → Login navigation ────────────────
  testWidgets('Onboarding navigates to Login', (tester) async {
    await tester.pumpWidget(_buildTestApp(initialLocation: '/'));
    await tester.pumpAndSettle();

    expect(find.text('Ceritakan Masalah Hukummu,'), findsOneWidget);
    expect(find.text('Get Started'), findsNothing);
    expect(find.text('Masuk'), findsOneWidget);
    expect(find.text('Buat akun'), findsOneWidget);

    await tester.tap(find.text('Masuk'));
    await tester.pumpAndSettle();

    expect(find.text('Masuk ke HukumIn'), findsOneWidget);
  });

  // ── Test 2: Chat bubble render + PCD attach UI ──────────
  testWidgets('Chat: shows greeting and document attach control',
      (tester) async {
    await tester.pumpWidget(_buildTestApp(initialLocation: '/chat'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('asisten hukum HukumIn'),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.attach_file_rounded), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });

  // ── Test 3: Booking flow reaches confirmation screen ──────
  testWidgets('Booking flow reaches confirmation screen', (tester) async {
    final lawyer = kLawyers[0];

    await tester.pumpWidget(
      _buildTestApp(
        initialLocation: '/book',
        extra: {'lawyer': lawyer},
      ),
    );
    await tester.pumpAndSettle();

    final btn = find.text('Confirm booking');
    expect(btn, findsOneWidget);

    // Tap day 1 (find text of today's day number)
    final todayStr = '${DateTime.now().day}';
    final dayFinder = find.text(todayStr).first;
    await tester.tap(dayFinder);
    await tester.pumpAndSettle();

    // Tap 09:00 slot
    await tester.tap(find.text('09:00'));
    await tester.pumpAndSettle();

    // Tap confirm
    await tester.tap(btn);
    await tester.pumpAndSettle();

    expect(find.text('Consultation booked!'), findsOneWidget);
  });

  // ── Test 4: Saved empty state ─────────────────────────────
  testWidgets('Saved screen: lawyers tab shows empty state', (tester) async {
    await tester.pumpWidget(
      _buildTestApp(
        initialLocation: '/saved',
        overrides: [
          savedLawyersProvider.overrideWith((_) => SavedLawyersNotifier()),
        ],
      ),
    );
    await tester.pumpAndSettle();

    // Tap lawyers tab
    await tester.tap(find.text('Lawyers'));
    await tester.pumpAndSettle();

    expect(find.text('Nothing saved yet'), findsOneWidget);
    expect(find.text('Start a chat'), findsOneWidget);
  });
}
