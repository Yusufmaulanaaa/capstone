import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/colors.dart';
import '../../../core/providers.dart';
import '../../../shared/widgets/widgets.dart';
import '../../../shared/widgets/lawyer_card.dart';

class ConsultationScreen extends ConsumerStatefulWidget {
  const ConsultationScreen({super.key});
  @override
  ConsumerState<ConsultationScreen> createState() => _ConsultationScreenState();
}

class _ConsultationScreenState extends ConsumerState<ConsultationScreen> {
  String _filter = 'Semua';
  final _filters = const ['Semua', 'Penipuan', 'Penggelapan', 'Pencurian', 'Penganiayaan', 'Pencemaran'];
  bool _match(String spec) => _filter == 'Semua' || spec.toLowerCase().contains(_filter.toLowerCase());

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(lawyersProvider);
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(20, 14, 20, 8), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [Container(width: 46, height: 46, decoration: BoxDecoration(gradient: const LinearGradient(colors: [C.ink, Color(0xFF2A2A35)]), borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.gavel_rounded, color: C.white, size: 22)), const SizedBox(width: 12), const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Konsultasi', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: C.ink)), Text('Data pengacara dari backend HukumIn', style: TextStyle(fontSize: 12.5, color: C.gray))])), CircleBtn(icon: Icons.refresh_rounded, onTap: () => ref.invalidate(lawyersProvider), semanticsLabel: 'Muat ulang')]),
              const SizedBox(height: 14),
              SingleChildScrollView(scrollDirection: Axis.horizontal, physics: const BouncingScrollPhysics(), child: Row(children: [for (final f in _filters) ...[GestureDetector(onTap: () => setState(() => _filter = f), child: AnimatedContainer(duration: const Duration(milliseconds: 160), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9), decoration: BoxDecoration(color: _filter == f ? C.ink : C.card, borderRadius: BorderRadius.circular(20), border: Border.all(color: _filter == f ? C.ink : C.line)), child: Text(f, style: TextStyle(fontSize: 13, fontWeight: _filter == f ? FontWeight.w700 : FontWeight.w500, color: _filter == f ? C.white : C.ink)))), const SizedBox(width: 8)]])),
            ]))),
            async.when(
              loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: C.ink))),
              error: (e, _) => SliverFillRemaining(child: Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.cloud_off_outlined, size: 48, color: C.line), const SizedBox(height: 12), const Text('Gagal memuat pengacara', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: C.ink)), const SizedBox(height: 8), Text('$e', textAlign: TextAlign.center, maxLines: 4, overflow: TextOverflow.ellipsis, style: const TextStyle(color: C.gray)), const SizedBox(height: 16), SizedBox(width: 180, child: BlackButton(label: 'Coba lagi', onTap: () => ref.invalidate(lawyersProvider)))])))),
              data: (all) {
                final lawyers = all.where((l) => '${l.role} ${l.practiceAreas.join(' ')}'.split(RegExp(r'[\s,/]+')).any(_match) || l.practiceAreas.any(_match) || _match(l.role)).toList();
                if (lawyers.isEmpty) return const SliverFillRemaining(child: Center(child: Text('Tidak ada pengacara untuk filter ini.', style: TextStyle(color: C.gray))));
                return SliverPadding(padding: const EdgeInsets.fromLTRB(20, 8, 20, 24), sliver: SliverList(delegate: SliverChildBuilderDelegate((context, i) => Padding(padding: const EdgeInsets.only(bottom: 12), child: LawyerCard(lawyer: lawyers[i], width: double.infinity)), childCount: lawyers.length)));
              },
            ),
          ],
        ),
      ),
    );
  }
}
