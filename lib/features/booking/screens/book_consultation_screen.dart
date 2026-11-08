import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/colors.dart';
import '../../../core/strings.dart';
import '../../../data/models/lawyer_model.dart';
import '../../../data/models/booking_model.dart';
import '../../../shared/widgets/widgets.dart';

class BookConsultationScreen extends ConsumerStatefulWidget {
  final LawyerModel lawyer;
  const BookConsultationScreen({super.key, required this.lawyer});

  @override
  ConsumerState<BookConsultationScreen> createState() =>
      _BookConsultationScreenState();
}

class _BookConsultationScreenState
    extends ConsumerState<BookConsultationScreen> {
  final TextEditingController _noteCtrl = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedTime;
  ConsultationType _type = ConsultationType.video;

  final List<String> _timeSlots = [
    '09:00',
    '10:00',
    '11:00',
    '13:00',
    '14:00',
    '15:00',
    '16:00',
    '17:00',
  ];
  final Set<String> _disabledSlots = {'11:00', '14:00'};

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  List<DateTime> _get7Days() {
    final now = DateTime.now();
    return List.generate(7, (i) => now.add(Duration(days: i)));
  }

  bool get _canConfirm => _selectedDate != null && _selectedTime != null;

  int get _total => widget.lawyer.priceNum;

  @override
  Widget build(BuildContext context) {
    final days = _get7Days();

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Stack(children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              const SliverToBoxAdapter(
                child: HukumAppBar(title: AppStrings.bookConsultationTitle),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Lawyer mini header
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: C.card,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: C.line),
                        ),
                        child: Row(children: [
                          Avatar(
                              name: widget.lawyer.name,
                              url: widget.lawyer.photo,
                              size: 46),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.lawyer.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: C.ink,
                                  ),
                                ),
                                Text(
                                  widget.lawyer.role,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 13, color: C.gray),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 92),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                widget.lawyer.price,
                                style: const TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w700,
                                  color: C.ink,
                                ),
                              ),
                            ),
                          ),
                        ]),
                      ),
                      const SizedBox(height: 24),
                      // Date selection
                      const _Label(AppStrings.selectDate),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 68,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: days.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (_, i) {
                            final d = days[i];
                            final selected = _selectedDate?.day == d.day;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedDate = d),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 52,
                                decoration: BoxDecoration(
                                  color: selected ? C.ink : C.card,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                      color: selected ? C.ink : C.line),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      DateFormat('EEE').format(d),
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: selected ? C.white : C.gray,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${d.day}',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: selected ? C.white : C.ink,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Time slots
                      const _Label(AppStrings.selectTime),
                      const SizedBox(height: 10),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 2.6,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: _timeSlots.length,
                        itemBuilder: (_, i) {
                          final slot = _timeSlots[i];
                          final disabled = _disabledSlots.contains(slot);
                          final selected = _selectedTime == slot;
                          return GestureDetector(
                            onTap: disabled
                                ? null
                                : () => setState(() => _selectedTime = slot),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: disabled
                                    ? C.card
                                    : selected
                                        ? C.ink
                                        : C.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: disabled
                                        ? C.line
                                        : selected
                                            ? C.ink
                                            : C.line),
                              ),
                              child: Text(
                                slot,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: disabled
                                      ? C.gray.withAlpha(100)
                                      : selected
                                          ? C.white
                                          : C.ink,
                                  decoration: disabled
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      // Consultation type
                      const _Label(AppStrings.consultationType),
                      const SizedBox(height: 10),
                      _SegmentedControl(
                        options: const [
                          AppStrings.video,
                          AppStrings.voice,
                          AppStrings.inPerson,
                        ],
                        selected: _type.index,
                        onSelect: (i) =>
                            setState(() => _type = ConsultationType.values[i]),
                      ),
                      const SizedBox(height: 24),
                      // Note
                      const _Label(AppStrings.addNote),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                        decoration: BoxDecoration(
                          color: C.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: C.line),
                        ),
                        child: TextField(
                          controller: _noteCtrl,
                          minLines: 2,
                          maxLines: 4,
                          style: const TextStyle(fontSize: 14, color: C.ink),
                          decoration: const InputDecoration(
                            isDense: true,
                            border: InputBorder.none,
                            hintText: 'Any specific concerns or notes…',
                            hintStyle: TextStyle(color: C.gray, fontSize: 14),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Summary card
                      const _Label(AppStrings.summary),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: C.card,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: C.line),
                        ),
                        child: Column(children: [
                          _SummaryRow(
                            label: 'Pengacara',
                            value: widget.lawyer.name,
                          ),
                          const SizedBox(height: 8),
                          _SummaryRow(
                            label: 'Tanggal',
                            value: _selectedDate != null
                                ? DateFormat('EEEE, d MMMM')
                                    .format(_selectedDate!)
                                : '—',
                          ),
                          const SizedBox(height: 8),
                          _SummaryRow(
                            label: 'Waktu',
                            value: _selectedTime ?? '—',
                          ),
                          const SizedBox(height: 8),
                          _SummaryRow(
                            label: 'Tipe',
                            value: [
                              'Panggilan video',
                              'Panggilan suara',
                              'Tatap muka',
                            ][_type.index],
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Divider(height: 1, color: C.line),
                          ),
                          _SummaryRow(
                            label: AppStrings.total,
                            value: 'Rp${_total}rb',
                            bold: true,
                          ),
                        ]),
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Sticky bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                decoration: const BoxDecoration(
                  color: C.white,
                  border: Border(top: BorderSide(color: C.line)),
                ),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  if (!_canConfirm)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Text(
                        AppStrings.selectDateAndTime,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: C.gray),
                      ),
                    ),
                  BlackButton(
                    label: AppStrings.confirmBooking,
                    onTap: _canConfirm ? _confirm : null,
                  ),
                ]),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  void _confirm() {
    final booking = BookingModel(
      lawyerName: widget.lawyer.name,
      lawyerRole: widget.lawyer.role,
      lawyerPhoto: widget.lawyer.photo,
      price: widget.lawyer.price,
      priceNum: widget.lawyer.priceNum,
      date: _selectedDate!,
      time: _selectedTime!,
      type: _type,
      note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
    );
    context.pushNamed('bookingConfirmed', extra: {'booking': booking});
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          fontSize: 15.5,
          fontWeight: FontWeight.w600,
          color: C.ink,
        ),
      );
}

class _SegmentedControl extends StatelessWidget {
  final List<String> options;
  final int selected;
  final ValueChanged<int> onSelect;

  const _SegmentedControl({
    required this.options,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) => Container(
        height: 44,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: C.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: C.line),
        ),
        child: Row(
            children: List.generate(options.length, (i) {
          final sel = i == selected;
          return Expanded(
            child: GestureDetector(
              onTap: () => onSelect(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: sel ? C.ink : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    options[i],
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: sel ? C.white : C.gray,
                    ),
                  ),
                ),
              ),
            ),
          );
        })),
      );
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) => Row(children: [
        Text(label, style: const TextStyle(fontSize: 13.5, color: C.gray)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
              color: C.ink,
            ),
          ),
        ),
      ]);
}
