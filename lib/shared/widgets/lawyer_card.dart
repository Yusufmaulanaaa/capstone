import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/colors.dart';
import '../../data/models/lawyer_model.dart';
import 'widgets.dart';

class LawyerCard extends ConsumerWidget {
  final LawyerModel lawyer;
  final double? width;

  const LawyerCard({super.key, required this.lawyer, this.width});

  Widget _chip(String text, {Color? bg, Color? fg, Color? border}) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: bg ?? C.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: border ?? C.line),
        ),
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: fg ?? C.gray,
          ),
        ),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final areas = lawyer.practiceAreas.take(2).toList();
    return GestureDetector(
      onTap: () => context.pushNamed(
        'lawyer',
        pathParameters: {'id': lawyer.id},
        extra: {'lawyer': lawyer},
      ),
      child: Container(
        width: width ?? 310,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: C.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: C.line),
          boxShadow: const [
            BoxShadow(
              color: Color(0x140A0A0F),
              blurRadius: 18,
              offset: Offset(0, 8),
            )
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [C.gold, Color(0xFFFDE68A)],
                ),
              ),
              child: Avatar(name: lawyer.name, url: lawyer.photo, size: 50),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          lawyer.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                            color: C.ink,
                          ),
                        ),
                      ),
                      if (lawyer.verified)
                        const Icon(Icons.verified_rounded,
                            size: 17, color: C.gold),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    lawyer.role,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: C.gray,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(children: [
                    const Icon(Icons.location_on_outlined,
                        size: 13, color: C.gray),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        lawyer.city,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, color: C.gray),
                      ),
                    ),
                  ]),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final a in areas)
                _chip(a,
                    bg: C.ink.withAlpha(10),
                    fg: C.ink,
                    border: C.ink.withAlpha(20)),
              if (lawyer.practiceAreas.length > 2)
                _chip('+${lawyer.practiceAreas.length - 2}'),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: C.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: C.line),
            ),
            child: Row(
              children: [
                _stat(Icons.star_rounded, lawyer.rating, C.gold),
                _dot(),
                _stat(Icons.work_outline_rounded, lawyer.exp, C.ink),
                _dot(),
                _stat(Icons.folder_open_rounded, lawyer.cases, C.ink),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Mulai dari',
                        style: TextStyle(fontSize: 11, color: C.gray)),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        lawyer.price,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: C.ink,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: BlackButton(
                  label: 'Konsultasi',
                  onTap: () => context.pushNamed(
                    'book',
                    extra: {'lawyer': lawyer},
                  ),
                ),
              ),
            ],
          ),
        ]),
      ),
    );
  }

  Widget _stat(IconData icon, String text, Color color) => Expanded(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 3),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  text,
                  maxLines: 1,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: C.ink,
                  ),
                ),
              ),
            ),
          ],
        ),
      );

  Widget _dot() => Container(
      width: 4,
      height: 4,
      decoration: const BoxDecoration(color: C.line, shape: BoxShape.circle));
}
