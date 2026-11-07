import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hukumin/core/theme.dart';
import 'package:hukumin/features/onboarding/screens/onboarding_screen.dart';
import 'package:hukumin/features/home/screens/home_screen.dart';
import 'package:hukumin/features/chat/screens/chat_screen.dart';

Widget wrap(Widget child) => ProviderScope(
      child: MaterialApp(
        theme: buildTheme(),
        debugShowCheckedModeBanner: false,
        home: child,
      ),
    );

void main() {
  for (final spec in [
    ['onboarding', const OnboardingScreen(), 393.0, 852.0],
    ['home', const HomeScreen(), 393.0, 852.0],
    ['chat', const ChatScreen(), 393.0, 852.0],
  ]) {
    testWidgets('render ${spec[0]}', (tester) async {
      tester.view.physicalSize = Size(spec[2] as double, spec[3] as double);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(wrap(spec[1] as Widget));
      await tester.pump(const Duration(milliseconds: 500));
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('png/${spec[0]}.png'),
      );
    });
  }
}
