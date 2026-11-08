import 'package:flutter/material.dart';

/// App color palette â€” do NOT add colors outside this class.
/// Light mode tokens preserve the original HukumIn look.
abstract final class C {
  static const Color ink = Color(0xFF0A0A0F);
  static const Color white = Color(0xFFFFFFFF);
  static const Color gray = Color(0xFF6B7280);
  static const Color line = Color(0xFFE8E9ED);
  static const Color card = Color(0xFFF7F7F8);
  static const Color outer = Color(0xFFEDEEF1);
  static const Color red = Color(0xFFEF4444);
  static const Color gold = Color(0xFFF5B301);

  // Dark mode tokens (same palette inverted, as specified)
  static const Color darkLine = Color(0xFF26272E);
  static const Color darkCard = Color(0xFF14151A);
}

/// Theme-aware tokens so existing widgets can be extended without new styles.
class AppColors extends ThemeExtension<AppColors> {
  final Color ink;
  final Color bg;
  final Color gray;
  final Color line;
  final Color card;
  final Color red;
  final Color gold;
  const AppColors({
    required this.ink,
    required this.bg,
    required this.gray,
    required this.line,
    required this.card,
    required this.red,
    required this.gold,
  });

  static const light = AppColors(
    ink: C.ink,
    bg: C.white,
    gray: C.gray,
    line: C.line,
    card: C.card,
    red: C.red,
    gold: C.gold,
  );

  static const dark = AppColors(
    ink: C.white,
    bg: C.ink,
    gray: C.gray,
    line: C.darkLine,
    card: C.darkCard,
    red: C.red,
    gold: C.gold,
  );

  @override
  AppColors copyWith({
    Color? ink,
    Color? bg,
    Color? gray,
    Color? line,
    Color? card,
    Color? red,
    Color? gold,
  }) =>
      AppColors(
        ink: ink ?? this.ink,
        bg: bg ?? this.bg,
        gray: gray ?? this.gray,
        line: line ?? this.line,
        card: card ?? this.card,
        red: red ?? this.red,
        gold: gold ?? this.gold,
      );

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t) ?? a;
    return AppColors(
      ink: l(ink, other.ink),
      bg: l(bg, other.bg),
      gray: l(gray, other.gray),
      line: l(line, other.line),
      card: l(card, other.card),
      red: l(red, other.red),
      gold: l(gold, other.gold),
    );
  }
}
