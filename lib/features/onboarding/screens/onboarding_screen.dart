import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/colors.dart';
import '../../../core/strings.dart';
import '../../../shared/widgets/widgets.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, c) => SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: c.maxHeight),
                child: IntrinsicHeight(
                  child: Column(children: [
                    Expanded(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 320),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(40, 32, 40, 8),
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color(0xFFF1F1F3),
                                C.white,
                              ],
                            ),
                          ),
                          child: Image.asset(
                            'assets/images/lady_justice.png',
                            fit: BoxFit.contain,
                            errorBuilder: (c, e, s) =>
                                CustomPaint(painter: ScalesPainter()),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                      child: Column(children: [
                        const Text(
                          AppStrings.onboardingLine1,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w500,
                            color: C.ink,
                            height: 1.25,
                          ),
                        ),
                        const Text(
                          AppStrings.onboardingLine2,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: C.ink,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          AppStrings.onboardingSubtitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: C.gray,
                            fontSize: 14.5,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),
                        BlackButton(
                          label: AppStrings.getStarted,
                          icon: Icons.arrow_forward_rounded,
                          onTap: () => context.goNamed('home'),
                        ),
                      ]),
                    ),
                  ]),
                ),
              ),
            ),
          ),
        ),
      );
}

/// Scales illustration fallback.
class ScalesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()
      ..color = const Color(0xFF8C8578)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    final cx = s.width / 2;
    final top = s.height * 0.12;
    final beamY = top + 28;
    final panY = s.height * 0.58;
    canvas.drawCircle(
        Offset(cx, top), 8, Paint()..color = const Color(0xFF8C8578));
    canvas.drawLine(Offset(cx, top), Offset(cx, s.height * 0.92), p);
    canvas.drawLine(
        Offset(s.width * 0.14, beamY), Offset(s.width * 0.86, beamY), p);
    for (final x in [s.width * 0.14, s.width * 0.86]) {
      canvas.drawLine(Offset(x, beamY), Offset(x - 48, panY), p);
      canvas.drawLine(Offset(x, beamY), Offset(x + 48, panY), p);
      canvas.drawArc(
          Rect.fromCenter(center: Offset(x, panY), width: 96, height: 56),
          0,
          3.14159,
          false,
          p);
    }
    canvas.drawLine(
        Offset(cx - 56, s.height * 0.92), Offset(cx + 56, s.height * 0.92), p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
