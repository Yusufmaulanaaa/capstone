import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/colors.dart';
import '../../../data/models/lawyer_model.dart';
import '../../../data/repositories/mock_repository.dart';
import '../../../shared/widgets/lawyer_card.dart';
import '../../../shared/widgets/widgets.dart';

enum LawyerSort { rating, price, experience }

class LawyerSearchFilter {
  final String query;
  final Set<String> specialties;
  final String? city;
  final double minRating;
  final RangeValues priceRange;
  final bool availableOnly;
  final LawyerSort sort;
  const LawyerSearchFilter({
    this.query = '',
    this.specialties = const {},
    this.city,
    this.minRating = 0,
    this.priceRange = const RangeValues(0, 600),
    this.availableOnly = false,
    this.sort = LawyerSort.rating,
  });

  LawyerSearchFilter copyWith({
    String? query,
    Set<String>? specialties,
    Object? city = _sentinel,
    double? minRating,
    RangeValues? priceRange,
    bool? availableOnly,
    LawyerSort? sort,
  }) =>
      LawyerSearchFilter(
        query: query ?? this.query,
        specialties: specialties ?? this.specialties,
        city: identical(city, _sentinel) ? this.city : city as String?,
        minRating: minRating ?? this.minRating,
        priceRange: priceRange ?? this.priceRange,
        availableOnly: availableOnly ?? this.availableOnly,
        sort: sort ?? this.sort,
      );

  static const _sentinel = Object();
  bool get hasActiveFilters =>
      specialties.isNotEmpty ||
      city != null ||
      minRating > 0 ||
      priceRange.start > 0 ||
      priceRange.end < 600 ||
      availableOnly;
}

int _parseExp(String s) =>
    int.tryParse(RegExp(r'\d+').firstMatch(s)?.group(0) ?? '0') ?? 0;

List<LawyerModel> applyLawyerFilter(
    List<LawyerModel> all, LawyerSearchFilter f) {
  final q = f.query.trim().toLowerCase();
  final list = all.where((l) {
    if (q.isNotEmpty) {
      final hay = '${l.name} ${l.role} ${l.city} ${l.practiceAreas.join(' ')}'
          .toLowerCase();
      if (!hay.contains(q)) {
        return false;
      }
    }
    if (f.specialties.isNotEmpty &&
        !l.practiceAreas.any(f.specialties.contains)) return false;
    if (f.city != null && f.city!.isNotEmpty && l.city != f.city) return false;
    if (l.ratingNum < f.minRating) return false;
    if (l.priceNum < f.priceRange.start || l.priceNum > f.priceRange.end)
      return false;
    if (f.availableOnly && !l.verified) return false;
    return true;
  }).toList();
  switch (f.sort) {
    case LawyerSort.rating:
      list.sort((a, b) => b.ratingNum.compareTo(a.ratingNum));
    case LawyerSort.price:
      list.sort((a, b) => a.priceNum.compareTo(b.priceNum));
    case LawyerSort.experience:
      list.sort((a, b) => _parseExp(b.exp).compareTo(_parseExp(a.exp)));
  }
  return list;
}

class FindLawyerScreen extends ConsumerStatefulWidget {
  const FindLawyerScreen({super.key});
  @override
  ConsumerState<FindLawyerScreen> createState() => _FindLawyerScreenState();
}

class _FindLawyerScreenState extends ConsumerState<FindLawyerScreen> {
  final _search = TextEditingController();
  final _repo = LawyerRepository();
  LawyerSearchFilter _filter = const LawyerSearchFilter();
  late Future<List<LawyerModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = _repo.fetchLawyers();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    setState(() => _future = _repo.fetchLawyers());
    await _future;
  }

  void _openFilter(List<LawyerModel> all) async {
    final specialties = {for (final l in all) ...l.practiceAreas}.toList()
      ..sort();
    final cities = {for (final l in all) l.city}.toList()..sort();
    final res = await showModalBottomSheet<LawyerSearchFilter>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FilterSheet(
          filter: _filter, specialties: specialties, cities: cities),
    );
    if (res != null) setState(() => _filter = res);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          HukumAppBar(
              title: 'Cari Pengacara',
              onBack: () =>
                  context.canPop() ? context.pop() : context.goNamed('home')),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
            child: Row(children: [
              Expanded(
                child: TextField(
                  controller: _search,
                  onChanged: (v) =>
                      setState(() => _filter = _filter.copyWith(query: v)),
                  style: const TextStyle(fontSize: 14.5, color: C.ink),
                  decoration: InputDecoration(
                    hintText: 'Cari nama, spesialisasi, kota...',
                    hintStyle: const TextStyle(color: C.gray, fontSize: 14),
                    prefixIcon: const Icon(Icons.search_rounded,
                        color: C.gray, size: 20),
                    filled: true,
                    fillColor: C.card,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: C.line)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: C.line)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: C.ink, width: 1.2)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              FutureBuilder<List<LawyerModel>>(
                future: _future,
                builder: (context, snap) => CircleBtn(
                  icon: Icons.tune_rounded,
                  semanticsLabel: 'Filter',
                  dot: _filter.hasActiveFilters,
                  onTap: snap.hasData ? () => _openFilter(snap.data!) : null,
                ),
              ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: _SortControl(
              selected: _filter.sort,
              onSelect: (s) =>
                  setState(() => _filter = _filter.copyWith(sort: s)),
            ),
          ),
          if (_filter.hasActiveFilters)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    for (final s in _filter.specialties)
                      _ActiveChip(
                          label: s,
                          onRemove: () => setState(() => _filter =
                              _filter.copyWith(
                                  specialties: {..._filter.specialties}
                                    ..remove(s)))),
                    if (_filter.city != null)
                      _ActiveChip(
                          label: _filter.city!,
                          onRemove: () => setState(
                              () => _filter = _filter.copyWith(city: null))),
                    if (_filter.minRating > 0)
                      _ActiveChip(
                          label:
                              'Rating ≥ ${_filter.minRating.toStringAsFixed(1)}',
                          onRemove: () => setState(
                              () => _filter = _filter.copyWith(minRating: 0))),
                    if (_filter.availableOnly)
                      _ActiveChip(
                          label: 'Tersedia',
                          onRemove: () => setState(() => _filter =
                              _filter.copyWith(availableOnly: false))),
                    GestureDetector(
                        onTap: () => setState(() => _filter =
                            LawyerSearchFilter(
                                query: _filter.query, sort: _filter.sort)),
                        child: const Text('Hapus semua',
                            style: TextStyle(
                                fontSize: 12.5,
                                color: C.gray,
                                fontWeight: FontWeight.w600))),
                  ]),
            ),
          Expanded(
            child: FutureBuilder<List<LawyerModel>>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting)
                  return const _ShimmerList();
                if (snap.hasError) return _ErrorState(onRetry: _refresh);
                final items = applyLawyerFilter(snap.data ?? const [], _filter);
                if (items.isEmpty) {
                  return _EmptyState(
                    icon: Icons.person_search_outlined,
                    title: 'Pengacara tidak ditemukan',
                    subtitle: 'Coba ubah kata kunci atau filter pencarian.',
                    action: 'Reset filter',
                    onAction: () => setState(() {
                      _search.clear();
                      _filter = const LawyerSearchFilter();
                    }),
                  );
                }
                return RefreshIndicator(
                  color: C.ink,
                  onRefresh: _refresh,
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics()),
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) =>
                        LawyerCard(lawyer: items[i], width: double.infinity),
                  ),
                );
              },
            ),
          ),
        ]),
      ),
    );
  }
}

class _SortControl extends StatelessWidget {
  final LawyerSort selected;
  final ValueChanged<LawyerSort> onSelect;
  const _SortControl({required this.selected, required this.onSelect});
  @override
  Widget build(BuildContext context) {
    const opts = [
      (LawyerSort.rating, 'Rating'),
      (LawyerSort.price, 'Harga'),
      (LawyerSort.experience, 'Pengalaman')
    ];
    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
          color: C.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: C.line)),
      child: Row(children: [
        for (final o in opts)
          Expanded(
              child: GestureDetector(
            onTap: () => onSelect(o.$1),
            child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: selected == o.$1 ? C.ink : Colors.transparent,
                    borderRadius: BorderRadius.circular(10)),
                child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(o.$2,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: selected == o.$1 ? C.white : C.gray)))),
          ))
      ]),
    );
  }
}

class _ActiveChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;
  const _ActiveChip({required this.label, required this.onRemove});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(10, 6, 6, 6),
        decoration: BoxDecoration(
            color: C.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: C.line)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 12, color: C.ink, fontWeight: FontWeight.w500)),
          const SizedBox(width: 4),
          GestureDetector(
              onTap: onRemove,
              child: const Icon(Icons.close_rounded, size: 16, color: C.gray)),
        ]),
      );
}

class _FilterSheet extends StatefulWidget {
  final LawyerSearchFilter filter;
  final List<String> specialties;
  final List<String> cities;
  const _FilterSheet(
      {required this.filter, required this.specialties, required this.cities});
  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late LawyerSearchFilter f;
  @override
  void initState() {
    super.initState();
    f = widget.filter;
  }

  @override
  Widget build(BuildContext context) => Container(
        decoration: const BoxDecoration(
            color: C.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
        padding: EdgeInsets.fromLTRB(
            20, 12, 20, 20 + MediaQuery.of(context).padding.bottom),
        child: SingleChildScrollView(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
              Center(
                  child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                          color: C.line,
                          borderRadius: BorderRadius.circular(2)))),
              const Text('Filter Pencarian',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w800, color: C.ink)),
              const SizedBox(height: 14),
              const Text('Spesialisasi',
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700, color: C.ink)),
              const SizedBox(height: 8),
              Wrap(spacing: 8, runSpacing: 8, children: [
                for (final s in widget.specialties.take(10))
                  GestureDetector(
                    onTap: () => setState(() {
                      final n = {...f.specialties};
                      if (n.contains(s)) {
                        n.remove(s);
                      } else {
                        n.add(s);
                      }
                      f = f.copyWith(specialties: n);
                    }),
                    child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                            color: f.specialties.contains(s) ? C.ink : C.card,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: f.specialties.contains(s)
                                    ? C.ink
                                    : C.line)),
                        child: Text(s,
                            style: TextStyle(
                                fontSize: 12.5,
                                color:
                                    f.specialties.contains(s) ? C.white : C.ink,
                                fontWeight: FontWeight.w600))),
                  )
              ]),
              const SizedBox(height: 16),
              const Text('Kota',
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700, color: C.ink)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                    color: C.card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: C.line)),
                child: DropdownButtonHideUnderline(
                    child: DropdownButton<String?>(
                  value: f.city,
                  isExpanded: true,
                  hint: const Text('Semua kota',
                      style: TextStyle(color: C.gray, fontSize: 14)),
                  items: [
                    const DropdownMenuItem<String?>(
                        value: null, child: Text('Semua kota')),
                    for (final c in widget.cities)
                      DropdownMenuItem<String?>(value: c, child: Text(c))
                  ],
                  onChanged: (v) => setState(() => f = f.copyWith(city: v)),
                )),
              ),
              const SizedBox(height: 10),
              Text('Rating minimal: ${f.minRating.toStringAsFixed(1)}',
                  style: const TextStyle(
                      fontSize: 13.5,
                      color: C.ink,
                      fontWeight: FontWeight.w600)),
              Slider(
                  value: f.minRating,
                  min: 0,
                  max: 5,
                  divisions: 10,
                  activeColor: C.ink,
                  inactiveColor: C.line,
                  onChanged: (v) =>
                      setState(() => f = f.copyWith(minRating: v))),
              Text(
                  'Rentang harga: Rp${f.priceRange.start.round()}rb - Rp${f.priceRange.end.round()}rb',
                  style: const TextStyle(
                      fontSize: 13.5,
                      color: C.ink,
                      fontWeight: FontWeight.w600)),
              RangeSlider(
                  values: f.priceRange,
                  min: 0,
                  max: 600,
                  divisions: 12,
                  activeColor: C.ink,
                  inactiveColor: C.line,
                  onChanged: (v) =>
                      setState(() => f = f.copyWith(priceRange: v))),
              SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  activeColor: C.ink,
                  title: const Text('Hanya tersedia (terverifikasi)',
                      style: TextStyle(fontSize: 14, color: C.ink)),
                  value: f.availableOnly,
                  onChanged: (v) =>
                      setState(() => f = f.copyWith(availableOnly: v))),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(
                    child: OutlinedPillButton(
                        label: 'Reset',
                        onTap: () => setState(() => f =
                            LawyerSearchFilter(query: f.query, sort: f.sort)))),
                const SizedBox(width: 10),
                Expanded(
                    child: BlackButton(
                        label: 'Terapkan',
                        onTap: () => Navigator.of(context).pop(f))),
              ]),
            ])),
      );
}

class _ShimmerList extends StatelessWidget {
  const _ShimmerList();
  @override
  Widget build(BuildContext context) => ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, __) => _ShimmerBox(height: 170, radius: 24),
      );
}

class _ShimmerBox extends StatefulWidget {
  final double height;
  final double radius;
  const _ShimmerBox({required this.height, required this.radius});
  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1200))
    ..repeat(reverse: true);
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
      animation: _c,
      builder: (_, __) => Container(
            height: widget.height,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.radius),
                color: Color.lerp(C.card, C.line, _c.value) ?? C.card,
                border: Border.all(color: C.line)),
          ));
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String action;
  final VoidCallback onAction;
  const _EmptyState(
      {required this.icon,
      required this.title,
      required this.subtitle,
      required this.action,
      required this.onAction});
  @override
  Widget build(BuildContext context) => Center(
      child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, size: 52, color: C.line),
            const SizedBox(height: 14),
            Text(title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700, color: C.ink)),
            const SizedBox(height: 8),
            Text(subtitle,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 14, color: C.gray, height: 1.45)),
            const SizedBox(height: 18),
            SizedBox(
                width: 190, child: BlackButton(label: action, onTap: onAction)),
          ])));
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorState({required this.onRetry});
  @override
  Widget build(BuildContext context) => _EmptyState(
      icon: Icons.cloud_off_outlined,
      title: 'Gagal memuat data',
      subtitle: 'Periksa koneksi atau coba lagi.',
      action: 'Coba lagi',
      onAction: onRetry);
}
