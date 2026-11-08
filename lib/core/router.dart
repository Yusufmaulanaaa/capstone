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
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/auth/screens/forgot_password_screen.dart';
import 'providers.dart';
import '../data/models/lawyer_model.dart';
import '../data/models/booking_model.dart';

CustomTransitionPage<T> _buildPageWithDefaultTransition<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curvedAnimation =
          CurvedAnimation(parent: animation, curve: Curves.easeOut);
      return FadeTransition(
        opacity: curvedAnimation,
        child: SlideTransition(
          position:
              Tween<Offset>(begin: const Offset(0.04, 0), end: Offset.zero)
                  .animate(curvedAnimation),
          child: child,
        ),
      );
    },
  );
}

final routerProvider = Provider<GoRouter>((ref) {
  final settings = ref.watch(settingsProvider);
  return GoRouter(
    initialLocation: settings.firstLaunchSeen ? '/home' : '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'onboarding',
        pageBuilder: (context, state) => _buildPageWithDefaultTransition(
            context: context, state: state, child: const OnboardingScreen()),
      ),
      GoRoute(
          path: '/login',
          name: 'login',
          pageBuilder: (c, s) => _buildPageWithDefaultTransition(
              context: c, state: s, child: const LoginScreen())),
      GoRoute(
          path: '/register',
          name: 'register',
          pageBuilder: (c, s) => _buildPageWithDefaultTransition(
              context: c, state: s, child: const RegisterScreen())),
      GoRoute(
          path: '/forgot-password',
          name: 'forgotPassword',
          pageBuilder: (c, s) => _buildPageWithDefaultTransition(
              context: c, state: s, child: const ForgotPasswordScreen())),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/home',
                name: 'home',
                pageBuilder: (c, s) => _buildPageWithDefaultTransition(
                    context: c, state: s, child: const HomeScreen()))
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/chat',
                name: 'chat',
                pageBuilder: (c, s) {
                  final extra = s.extra as Map<String, dynamic>?;
                  return _buildPageWithDefaultTransition(
                      context: c,
                      state: s,
                      child: ChatScreen(initial: extra?['initial'] as String?));
                })
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/consultation',
                name: 'consultation',
                pageBuilder: (c, s) => _buildPageWithDefaultTransition(
                    context: c, state: s, child: const ConsultationScreen()))
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/profile',
                name: 'profile',
                pageBuilder: (c, s) => _buildPageWithDefaultTransition(
                    context: c, state: s, child: const ProfileScreen()))
          ]),
        ],
      ),
      GoRoute(
          path: '/lawyer/:id',
          name: 'lawyer',
          pageBuilder: (c, s) {
            final extra = s.extra as Map<String, dynamic>?;
            return _buildPageWithDefaultTransition(
                context: c,
                state: s,
                child: LawyerProfileScreen(
                    lawyer: extra?['lawyer'] as LawyerModel));
          }),
      GoRoute(
          path: '/book',
          name: 'book',
          pageBuilder: (c, s) {
            final extra = s.extra as Map<String, dynamic>?;
            return _buildPageWithDefaultTransition(
                context: c,
                state: s,
                child: BookConsultationScreen(
                    lawyer: extra?['lawyer'] as LawyerModel));
          }),
      GoRoute(
          path: '/booking-confirmed',
          name: 'bookingConfirmed',
          pageBuilder: (c, s) {
            final extra = s.extra as Map<String, dynamic>?;
            return _buildPageWithDefaultTransition(
                context: c,
                state: s,
                child: BookingConfirmedScreen(
                    booking: extra?['booking'] as BookingModel));
          }),
      GoRoute(
          path: '/document',
          name: 'document',
          pageBuilder: (c, s) {
            final extra = s.extra as Map<String, dynamic>?;
            return _buildPageWithDefaultTransition(
                context: c,
                state: s,
                child: DocumentScreen(
                    topicTitle: extra?['topicTitle'] as String? ?? ''));
          }),
      GoRoute(
          path: '/saved',
          name: 'saved',
          pageBuilder: (c, s) => _buildPageWithDefaultTransition(
              context: c, state: s, child: const SavedScreen())),
      GoRoute(
          path: '/notifications',
          name: 'notifications',
          pageBuilder: (c, s) => _buildPageWithDefaultTransition(
              context: c, state: s, child: const NotificationsScreen())),
    ],
  );
});
