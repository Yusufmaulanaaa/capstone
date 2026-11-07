import 'package:flutter/material.dart';
import '../../../core/colors.dart';
import '../../../data/repositories/mock_repository.dart';
import '../../../shared/widgets/widgets.dart';
import '../../../shared/widgets/lawyer_card.dart';

class ConsultationScreen extends StatefulWidget {
  const ConsultationScreen({super.key});

  @override
  State<ConsultationScreen> createState() => _ConsultationScreenState();
}

class _ConsultationScreenState extends State<ConsultationScreen> {
  String _filter = 'Semua';
  final _filters = const [
    'Semua',
    'Penipuan',
    'Penggelapan',
    'Pencurian',
    'Penganiayaan',
    'Pencemaran',
  ];

  bool _match(String spec) {
    if (_filter == 'Semua') return true;
    final s = spec.toLowerCase();
    return s.contains(_filter.toLowerCase());
  }

  @override
  Widget build(BuildContext context) {
    final lawyers = kLawyers.where((l) => l.practiceAreas.any(_match)).toList();

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [C.ink, Color(0xFF2A2A35)],
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.gavel_rounded,
                              color: C.white, size: 22),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Konsultasi',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: C.ink,
                                ),
                              ),
                              Text(
                                'Pilih pengacara terbaik untuk kasus Anda',
                                style: TextStyle(fontSize: 12.5, color: C.gray),
                              ),
                            ],
                          ),
                        ),
                        CircleBtn(
                          icon: Icons.search_rounded,
                          onTap: () {},
                          semanticsLabel: 'Cari',
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          for (final f in _filters) ...[
                            _FilterChip(
                              label: f,
                              active: _filter == f,
                              onTap: () => setState(() => _filter = f),
                            ),
                            const SizedBox(width: 8),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final l = lawyers[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: LawyerCard(lawyer: l, width: double.infinity),
                    );
                  },
                  childCount: lawyers.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _FilterChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: active ? C.ink : C.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: active ? C.ink : C.line),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              color: active ? C.white : C.ink,
            ),
          ),
        ),
      );
}
