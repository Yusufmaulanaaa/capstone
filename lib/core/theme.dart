import 'package:flutter/material.dart';
import 'colors.dart';

/// The bundled typeface family (see `pubspec.yaml` → `flutter/fonts`).
///
/// Urbanist is shipped inside the app bundle rather than pulled at runtime
/// so the UI renders identically offline and inside widget tests.
const String kFontFamily = 'Urbanist';

ThemeData buildTheme() {
  final base = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: C.white,
    colorScheme: ColorScheme.fromSeed(seedColor: C.ink, primary: C.ink),
    splashFactory: InkRipple.splashFactory,
  );

  return base.copyWith(
    textTheme: base.textTheme.apply(fontFamily: kFontFamily),
    primaryTextTheme: base.primaryTextTheme.apply(fontFamily: kFontFamily),
  );
}
