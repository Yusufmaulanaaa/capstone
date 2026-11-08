import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/colors.dart';
import '../../../core/providers.dart';
import '../../../core/strings.dart';
import '../../../data/models/booking_model.dart';
import '../../../data/models/lawyer_model.dart';
import '../../../data/services/api_client.dart';
import '../../../shared/widgets/widgets.dart';

class BookConsultationScreen extends ConsumerStatefulWidget {
  final LawyerModel lawyer;
  const BookConsultationScreen({super.key, required this.lawyer});
  @override
  ConsumerState<BookConsultationScreen> createState() => _BookConsultationScreenState();
}

class _BookConsultationScreenState extends ConsumerState<BookConsultationScreen> {
  final _noteCtrl = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedTime;
  ConsultationType _type = ConsultationType.video;
  bool _submitting = false;

  @override
  void dispose() { _noteCtrl.dispose(); super.dispose(); }
  List<DateTime> get _days => List.generate(7, (i) => DateTime.now().add(Duration(days: i)));
  bool get _canConfirm => _selectedDate != null && _selectedTime != null && !_submitting;
  String _dateStr(DateTime d) => DateFormat('yyyy-MM-dd').format(d);
  void _snack(String msg, {bool error = true}) { if (!mounted) return; ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: error ? C.red : C.ink, behavior: SnackBarBehavior.floating)); }

  Future<void> _confirm() async {
    if (ref.read(authProvider) == null) { _snack('Masuk terlebih dahulu untuk booking.'); if (mounted) context.pushNamed('login'); return; }
    if (!_canConfirm) return;
    setState(() => _submitting = true);
    try {
      final booking = await ref.read(bookingsApiProvider).create(lawyerId: widget.lawyer.id, date: _dateStr(_selectedDate!), time: _selectedTime!, type: consultationTypeToApi(_type), note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim());
      ref.invalidate(myBookingsProvider);
      await ref.read(notificationsProvider.notifier).refresh();
      if (mounted) context.goNamed('bookingConfirmed', extra: {'booking': booking});
    } on ApiException catch (e) {
      _snack(e.message);
    } catch (_) {
      _snack('Gagal membuat booking. Pastikan backend berjalan.');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final days = _days;
    final date = _selectedDate;
    final slotsAsync = date == null ? null : ref.watch(bookingSlotsProvider((lawyerId: widget.lawyer.id, date: _dateStr(date))));
    return Scaffold(
      body: SafeArea(bottom: false, child: Stack(children: [
        CustomScrollView(physics: const BouncingScrollPhysics(), slivers: [
          const SliverToBoxAdapter(child: HukumAppBar(title: AppStrings.bookConsultationTitle)),
          SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(20, 8, 20, 100), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: C.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: C.line)), child: Row(children: [Avatar(name: widget.lawyer.name, url: widget.lawyer.photo, size: 46), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(widget.lawyer.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: C.ink)), Text(widget.lawyer.role, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, color: C.gray))])), Text(widget.lawyer.price, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: C.ink))])),
            const SizedBox(height: 24),
            const Text('Pilih tanggal', style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w600, color: C.ink)),
            const SizedBox(height: 10),
            SizedBox(height: 68, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: days.length, separatorBuilder: (_, __) => const SizedBox(width: 8), itemBuilder: (_, i) { final d = days[i]; final selected = _selectedDate?.day == d.day && _selectedDate?.month == d.month; return GestureDetector(onTap: () => setState(() { _selectedDate = d; _selectedTime = null; }), child: AnimatedContainer(duration: const Duration(milliseconds: 200), width: 52, decoration: BoxDecoration(color: selected ? C.ink : C.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: selected ? C.ink : C.line)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text(DateFormat('EEE').format(d), style: TextStyle(fontSize: 11, color: selected ? C.white : C.gray)), const SizedBox(height: 4), Text('${d.day}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: selected ? C.white : C.ink))]))); })),
            const SizedBox(height: 24),
            const Text('Pilih jam (dari backend)', style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w600, color: C.ink)),
            const SizedBox(height: 10),
            if (date == null) const Text('Pilih tanggal untuk melihat slot tersedia.', style: TextStyle(color: C.gray))
            else slotsAsync!.when(
              loading: () => const Padding(padding: EdgeInsets.all(12), child: Center(child: CircularProgressIndicator(color: C.ink))),
              error: (e, _) => Text('Gagal memuat slot: $e', style: const TextStyle(color: C.red)),
              data: (slots) => GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 2.6, crossAxisSpacing: 8, mainAxisSpacing: 8), itemCount: slots.length, itemBuilder: (_, i) { final s = slots[i]; final slot = '${s['time']}'; final available = s['available'] == true; final selected = _selectedTime == slot; return GestureDetector(onTap: available ? () => setState(() => _selectedTime = slot) : null, child: AnimatedContainer(duration: const Duration(milliseconds: 200), alignment: Alignment.center, decoration: BoxDecoration(color: !available ? C.card : selected ? C.ink : C.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: !available ? C.line : selected ? C.ink : C.line)), child: Text(slot, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: !available ? C.gray.withAlpha(100) : selected ? C.white : C.ink, decoration: !available ? TextDecoration.lineThrough : null)))); }),
            ),
            const SizedBox(height: 24),
            const Text('Tipe konsultasi', style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w600, color: C.ink)),
            const SizedBox(height: 10),
            Container(height: 44, padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: C.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: C.line)), child: Row(children: List.generate(3, (i) { const labels = ['Video', 'Suara', 'Tatap muka']; final sel = i == _type.index; return Expanded(child: GestureDetector(onTap: () => setState(() => _type = ConsultationType.values[i]), child: AnimatedContainer(duration: const Duration(milliseconds: 200), alignment: Alignment.center, decoration: BoxDecoration(color: sel ? C.ink : Colors.transparent, borderRadius: BorderRadius.circular(10)), child: Text(labels[i], style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: sel ? C.white : C.gray))))); }))),
            const SizedBox(height: 24),
            const Text('Catatan (opsional)', style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w600, color: C.ink)),
            const SizedBox(height: 10),
            Container(padding: const EdgeInsets.fromLTRB(16, 12, 16, 12), decoration: BoxDecoration(color: C.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: C.line)), child: TextField(controller: _noteCtrl, minLines: 2, maxLines: 4, style: const TextStyle(fontSize: 14, color: C.ink), decoration: const InputDecoration(isDense: true, border: InputBorder.none, hintText: 'Catatan singkat untuk pengacara...', hintStyle: TextStyle(color: C.gray, fontSize: 14)))),
          ]))),
        ]),
        Positioned(bottom: 0, left: 0, right: 0, child: SafeArea(top: false, child: Container(padding: const EdgeInsets.fromLTRB(20, 12, 20, 16), decoration: const BoxDecoration(color: C.white, border: Border(top: BorderSide(color: C.line))), child: Column(mainAxisSize: MainAxisSize.min, children: [if (!_canConfirm && !_submitting) const Padding(padding: EdgeInsets.only(bottom: 8), child: Text('Pilih tanggal dan jam tersedia untuk melanjutkan.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: C.gray))), BlackButton(label: AppStrings.confirmBooking, onTap: _canConfirm ? _confirm : null, loading: _submitting)])))),
      ])),
    );
  }
}
