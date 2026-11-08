import 'package:flutter/material.dart';
import 'colors.dart';

/// The bundled typeface family (see `pubspec.yaml` → `flutter/fonts`).
const String kFontFamily = 'Urbanist';

ThemeData buildLightTheme() {
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: C.white,
    colorScheme: ColorScheme.fromSeed(
      seedColor: C.ink,
      primary: C.ink,
      brightness: Brightness.light,
      surface: C.white,
    ),
    splashFactory: InkRipple.splashFactory,
    extensions: const [AppColors.light],
  );
  return base.copyWith(
    textTheme: base.textTheme.apply(
      fontFamily: kFontFamily,
      bodyColor: C.ink,
      displayColor: C.ink,
    ),
    primaryTextTheme: base.primaryTextTheme.apply(fontFamily: kFontFamily),
  );
}

ThemeData buildDarkTheme() {
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: C.ink,
    colorScheme: ColorScheme.fromSeed(
      seedColor: C.white,
      primary: C.white,
      brightness: Brightness.dark,
      surface: C.ink,
    ),
    splashFactory: InkRipple.splashFactory,
    extensions: const [AppColors.dark],
  );
  return base.copyWith(
    textTheme: base.textTheme.apply(
      fontFamily: kFontFamily,
      bodyColor: C.white,
      displayColor: C.white,
    ),
    primaryTextTheme: base.primaryTextTheme.apply(fontFamily: kFontFamily),
  );
}

// Backward-compatible: preserve original screens' default look.
ThemeData buildTheme() => buildLightTheme();
