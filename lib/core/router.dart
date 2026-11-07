import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/onboarding/screens/onboarding_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/chat/screens/chat_screen.dart';
import '../features/lawyer/screens/lawyer_profile_screen.dart';
import '../features/booking/screens/book_consultation_screen.dart';
import '../features/booking/screens/booking_confirmed_screen.dart';
import '../features/document/screens/document_screen.dart';
import '../features/saved/screens/saved_screen.dart';
import '../features/notifications/screens/notifications_screen.dart';
import '../features/consultation/screens/consultation_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/shell/app_shell.dart';
import '../data/models/lawyer_model.dart';
import '../data/models/booking_model.dart';

final routerProvider = Provider<GoRouter>((ref) => _router);

CustomTransitionPage<T> _buildPageWithDefaultTransition<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 280),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOut,
      );
      return FadeTransition(
        opacity: curvedAnimation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.04, 0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        ),
      );
    },
  );
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'onboarding',
      pageBuilder: (context, state) => _buildPageWithDefaultTransition(
        context: context,
        state: state,
        child: const OnboardingScreen(),
      ),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          AppShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              name: 'home',
              pageBuilder: (context, state) => _buildPageWithDefaultTransition(
                context: context,
                state: state,
                child: const HomeScreen(),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/chat',
              name: 'chat',
              pageBuilder: (context, state) {
                final extra = state.extra as Map<String, dynamic>?;
                return _buildPageWithDefaultTransition(
                  context: context,
                  state: state,
                  child: ChatScreen(initial: extra?['initial'] as String?),
                );
              },
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/consultation',
              name: 'consultation',
              pageBuilder: (context, state) => _buildPageWithDefaultTransition(
                context: context,
                state: state,
                child: const ConsultationScreen(),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              name: 'profile',
              pageBuilder: (context, state) => _buildPageWithDefaultTransition(
                context: context,
                state: state,
                child: const ProfileScreen(),
              ),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/lawyer/:id',
      name: 'lawyer',
      pageBuilder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final lawyer = extra?['lawyer'] as LawyerModel?;
        return _buildPageWithDefaultTransition(
          context: context,
          state: state,
          child: LawyerProfileScreen(lawyer: lawyer!),
        );
      },
    ),
    GoRoute(
      path: '/book',
      name: 'book',
      pageBuilder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final lawyer = extra?['lawyer'] as LawyerModel?;
        return _buildPageWithDefaultTransition(
          context: context,
          state: state,
          child: BookConsultationScreen(lawyer: lawyer!),
        );
      },
    ),
    GoRoute(
      path: '/booking-confirmed',
      name: 'bookingConfirmed',
      pageBuilder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final booking = extra?['booking'] as BookingModel?;
        return _buildPageWithDefaultTransition(
          context: context,
          state: state,
          child: BookingConfirmedScreen(booking: booking!),
        );
      },
    ),
    GoRoute(
      path: '/document',
      name: 'document',
      pageBuilder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return _buildPageWithDefaultTransition(
          context: context,
          state: state,
          child: DocumentScreen(
            topicTitle: extra?['topicTitle'] as String? ?? '',
          ),
        );
      },
    ),
    GoRoute(
      path: '/saved',
      name: 'saved',
      pageBuilder: (context, state) => _buildPageWithDefaultTransition(
        context: context,
        state: state,
        child: const SavedScreen(),
      ),
    ),
    GoRoute(
      path: '/notifications',
      name: 'notifications',
      pageBuilder: (context, state) => _buildPageWithDefaultTransition(
        context: context,
        state: state,
        child: const NotificationsScreen(),
      ),
    ),
  ],
);
