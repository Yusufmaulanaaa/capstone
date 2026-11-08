import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme.dart';
import 'core/colors.dart';
import 'core/router.dart';
import 'core/providers.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final container = ProviderContainer();
  await container.read(settingsProvider.notifier).load();
  await container.read(authProvider.notifier).restore();
  runApp(UncontrolledProviderScope(
      container: container, child: const HukumInApp()));
}

class HukumInApp extends ConsumerWidget {
  const HukumInApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final settings = ref.watch(settingsProvider);
    return MaterialApp.router(
      title: 'HukumIn',
      debugShowCheckedModeBanner: false,
      theme: buildLightTheme(),
      darkTheme: buildLightTheme(),
      themeMode: ThemeMode.light,
      locale: settings.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
      builder: (context, child) {
        final media = MediaQuery.of(context);
        final scaled = media.copyWith(
          textScaler: TextScaler.linear(settings.textScale),
        );
        return MediaQuery(
          data: scaled,
          child: DeviceFrame(child: child ?? const SizedBox.shrink()),
        );
      },
    );
  }
}

/// On wide screens (web/desktop) renders the app inside a 412 px phone frame.
class DeviceFrame extends StatelessWidget {
  final Widget child;
  const DeviceFrame({super.key, required this.child});

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, c) {
        if (c.maxWidth <= 480) return child;
        return Container(
          color: C.outer,
          alignment: Alignment.center,
          child: Container(
            width: 412,
            height: c.maxHeight - 48,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: C.white,
              borderRadius: BorderRadius.circular(40),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x290A0A0F),
                  blurRadius: 48,
                  offset: Offset(0, 20),
                )
              ],
            ),
            child: Stack(children: [
              child,
              // iOS-style status bar "9:41" only in device frame
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: _StatusBar(),
              ),
              // Home indicator at bottom
              Positioned(
                bottom: 8,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: 134,
                    height: 5,
                    decoration: BoxDecoration(
                      color: C.ink,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ]),
          ),
        );
      });
}

class _StatusBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xCCFFFFFF), Color(0x00FFFFFF)],
          ),
        ),
        child: Row(children: [
          const Text(
            '9:41',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: C.ink,
            ),
          ),
          const Spacer(),
          const Icon(Icons.signal_cellular_4_bar, size: 16, color: C.ink),
          const SizedBox(width: 6),
          const Icon(Icons.wifi, size: 16, color: C.ink),
          const SizedBox(width: 6),
          Container(
            width: 25,
            height: 12,
            decoration: BoxDecoration(
              border: Border.all(color: C.ink),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.all(1.5),
                width: 18,
                height: 9,
                decoration: BoxDecoration(
                  color: C.ink,
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),
            ),
          ),
        ]),
      );
}
