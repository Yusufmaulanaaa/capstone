import 'package:flutter/material.dart';
import '../../../core/colors.dart';

class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            margin: const EdgeInsets.only(left: 10, right: 20, top: 14),
            padding: const EdgeInsets.fromLTRB(26, 14, 16, 14),
            decoration: BoxDecoration(
              color: C.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: C.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Asisten hukum sedang mengetik...',
                  style: TextStyle(fontSize: 12, color: C.gray),
                ),
                const SizedBox(height: 8),
                AnimatedBuilder(
                  animation: _ctrl,
                  builder: (_, __) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(3, (i) {
                      final delay = i / 3;
                      final v = ((_ctrl.value + delay) % 1.0);
                      final offset = v < 0.5 ? v * 2 : 2 - v * 2;
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        child: Transform.translate(
                          offset: Offset(0, -6 * offset),
                          child: Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: C.gray,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: C.white,
                shape: BoxShape.circle,
                border: Border.all(color: C.line),
              ),
              child: const Icon(Icons.auto_awesome_rounded,
                  size: 16, color: C.ink),
            ),
          ),
        ],
      );
}
