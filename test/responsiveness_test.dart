import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hukumin/core/theme.dart';
import 'package:hukumin/features/onboarding/screens/onboarding_screen.dart';
import 'package:hukumin/features/home/screens/home_screen.dart';
import 'package:hukumin/features/chat/screens/chat_screen.dart';
import 'package:hukumin/features/lawyer/screens/lawyer_profile_screen.dart';
import 'package:hukumin/features/booking/screens/book_consultation_screen.dart';
import 'package:hukumin/features/booking/screens/booking_confirmed_screen.dart';
import 'package:hukumin/features/document/screens/document_screen.dart';
import 'package:hukumin/features/saved/screens/saved_screen.dart';
import 'package:hukumin/features/notifications/screens/notifications_screen.dart';
import 'package:hukumin/data/repositories/mock_repository.dart';
import 'package:hukumin/data/models/booking_model.dart';

Widget _buildResponsiveTestApp({
  required Widget child,
  required double width,
  required double height,
  required double textScale,
}) {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => child,
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (_, __) => const HomeScreen(),
      ),
      GoRoute(
        path: '/chat',
        name: 'chat',
        builder: (_, __) => const ChatScreen(),
      ),
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (_, __) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/saved',
        name: 'saved',
        builder: (_, __) => const SavedScreen(),
      ),
      GoRoute(
        path: '/document',
        name: 'document',
        builder: (_, __) =>
            const DocumentScreen(topicTitle: 'AI Generated Letter'),
      ),
    ],
  );

  return ProviderScope(
    child: MediaQuery(
      data: MediaQueryData(
        size: Size(width, height),
        textScaler: TextScaler.linear(textScale),
        padding: const EdgeInsets.only(top: 24, bottom: 16),
      ),
      child: MaterialApp.router(
        theme: buildTheme(),
        routerConfig: router,
      ),
    ),
  );
}

void main() {
  const widths = [320.0, 393.0, 412.0];
  const heights = [640.0, 852.0, 915.0];
  const textScale = 1.3;

  for (var i = 0; i < widths.length; i++) {
    final w = widths[i];
    final h = heights[i];

    group('Responsive check at ${w.toInt()}x${h.toInt()} (scale $textScale):',
        () {
      testWidgets('Onboarding Screen renders without overflow', (tester) async {
        tester.view.physicalSize = Size(w, h);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          _buildResponsiveTestApp(
            child: const OnboardingScreen(),
            width: w,
            height: h,
            textScale: textScale,
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });

      testWidgets('Home Screen renders without overflow', (tester) async {
        tester.view.physicalSize = Size(w, h);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          _buildResponsiveTestApp(
            child: const HomeScreen(),
            width: w,
            height: h,
            textScale: textScale,
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });

      testWidgets('Chat Screen renders without overflow', (tester) async {
        tester.view.physicalSize = Size(w, h);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          _buildResponsiveTestApp(
            child: const ChatScreen(),
            width: w,
            height: h,
            textScale: textScale,
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });

      testWidgets('Lawyer Profile Screen renders without overflow',
          (tester) async {
        tester.view.physicalSize = Size(w, h);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          _buildResponsiveTestApp(
            child: LawyerProfileScreen(lawyer: kLawyers[0]),
            width: w,
            height: h,
            textScale: textScale,
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });

      testWidgets('Book Consultation Screen renders without overflow',
          (tester) async {
        tester.view.physicalSize = Size(w, h);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          _buildResponsiveTestApp(
            child: BookConsultationScreen(lawyer: kLawyers[0]),
            width: w,
            height: h,
            textScale: textScale,
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });

      testWidgets('Booking Confirmed Screen renders without overflow',
          (tester) async {
        tester.view.physicalSize = Size(w, h);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        final sampleBooking = BookingModel(
          lawyerName: 'Michale Chan',
          lawyerRole: 'Employment Lawyer',
          lawyerPhoto: '',
          price: '€75/hr',
          priceNum: 75,
          date: DateTime.now(),
          time: '10:00',
          type: ConsultationType.video,
          note: 'Workplace harassment consultation',
        );

        await tester.pumpWidget(
          _buildResponsiveTestApp(
            child: BookingConfirmedScreen(booking: sampleBooking),
            width: w,
            height: h,
            textScale: textScale,
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });

      testWidgets('AI Document Screen renders without overflow',
          (tester) async {
        tester.view.physicalSize = Size(w, h);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          _buildResponsiveTestApp(
            child: const DocumentScreen(topicTitle: 'Divorce demand'),
            width: w,
            height: h,
            textScale: textScale,
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });

      testWidgets('Saved Screen renders without overflow', (tester) async {
        tester.view.physicalSize = Size(w, h);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          _buildResponsiveTestApp(
            child: const SavedScreen(),
            width: w,
            height: h,
            textScale: textScale,
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });

      testWidgets('Notifications Screen renders without overflow',
          (tester) async {
        tester.view.physicalSize = Size(w, h);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          _buildResponsiveTestApp(
            child: const NotificationsScreen(),
            width: w,
            height: h,
            textScale: textScale,
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    });
  }
}
