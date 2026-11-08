import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/colors.dart';
import '../../../core/providers.dart';
import '../../../shared/widgets/lawyer_card.dart';
import '../../../shared/widgets/widgets.dart';

class FindLawyerScreen extends ConsumerStatefulWidget {
  const FindLawyerScreen({super.key});
  @override
  ConsumerState<FindLawyerScreen> createState() => _FindLawyerScreenState();
}

class _FindLawyerScreenState extends ConsumerState<FindLawyerScreen> {
  final _search = TextEditingController();
  String _q = '';
  @override
  void dispose() { _search.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(lawyersProvider);
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          HukumAppBar(title: 'Cari Pengacara', onBack: () => context.canPop() ? context.pop() : context.goNamed('home')),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
            child: TextField(
              controller: _search,
              onChanged: (v) => setState(() => _q = v.trim().toLowerCase()),
              style: const TextStyle(fontSize: 14.5, color: C.ink),
              decoration: InputDecoration(hintText: 'Cari nama, spesialisasi, kota...', hintStyle: const TextStyle(color: C.gray, fontSize: 14), prefixIcon: const Icon(Icons.search_rounded, color: C.gray, size: 20), filled: true, fillColor: C.card, contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: C.line)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: C.line)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: C.ink, width: 1.2))),
            ),
          ),
          Expanded(
            child: async.when(
              loading: () => const _ShimmerList(),
              error: (e, _) => _StateView(icon: Icons.cloud_off_outlined, title: 'Gagal memuat pengacara', subtitle: '$e', action: 'Coba lagi', onAction: () => ref.invalidate(lawyersProvider)),
              data: (all) {
                final items = _q.isEmpty ? all : all.where((l) => '${l.name} ${l.role} ${l.city} ${l.practiceAreas.join(' ')}'.toLowerCase().contains(_q)).toList();
                if (items.isEmpty) return _StateView(icon: Icons.person_search_outlined, title: 'Pengacara tidak ditemukan', subtitle: 'Coba ubah kata kunci pencarian.', action: 'Reset', onAction: () { _search.clear(); setState(() => _q = ''); });
                return RefreshIndicator(color: C.ink, onRefresh: () async => ref.invalidate(lawyersProvider), child: ListView.separated(physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()), padding: const EdgeInsets.fromLTRB(20, 4, 20, 24), itemCount: items.length, separatorBuilder: (_, __) => const SizedBox(height: 12), itemBuilder: (_, i) => LawyerCard(lawyer: items[i], width: double.infinity)));
              },
            ),
          ),
        ]),
      ),
    );
  }
}

class _ShimmerList extends StatelessWidget {
  const _ShimmerList();
  @override
  Widget build(BuildContext context) => ListView.separated(padding: const EdgeInsets.fromLTRB(20, 8, 20, 24), itemCount: 4, separatorBuilder: (_, __) => const SizedBox(height: 12), itemBuilder: (_, __) => Container(height: 170, decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), color: C.card, border: Border.all(color: C.line))));
}

class _StateView extends StatelessWidget {
  final IconData icon; final String title; final String subtitle; final String action; final VoidCallback onAction;
  const _StateView({required this.icon, required this.title, required this.subtitle, required this.action, required this.onAction});
  @override
  Widget build(BuildContext context) => Center(child: Padding(padding: const EdgeInsets.all(28), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: 52, color: C.line), const SizedBox(height: 14), Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: C.ink)), const SizedBox(height: 8), Text(subtitle, textAlign: TextAlign.center, maxLines: 4, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, color: C.gray, height: 1.45)), const SizedBox(height: 18), SizedBox(width: 190, child: BlackButton(label: action, onTap: onAction))])));
}
