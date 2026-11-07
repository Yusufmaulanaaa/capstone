import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/colors.dart';
import '../../../core/strings.dart';
import '../../../data/models/booking_model.dart';
import '../../../shared/widgets/widgets.dart';

class BookingConfirmedScreen extends StatelessWidget {
  final BookingModel booking;
  const BookingConfirmedScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, c) => SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: c.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    child: Column(children: [
                      const SizedBox(height: 16),
                      const Spacer(),
                      // Big check circle
                      Container(
                        width: 88,
                        height: 88,
                        decoration: const BoxDecoration(
                          color: C.ink,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check_rounded,
                            size: 44, color: C.white),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        AppStrings.consultationBooked,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: C.ink,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        AppStrings.bookedSubtitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: C.gray,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 28),
                      // Ticket card
                      _TicketCard(booking: booking),
                      const Spacer(),
                      const SizedBox(height: 16),
                      BlackButton(
                        label: AppStrings.addToCalendar,
                        icon: Icons.calendar_today_outlined,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Added to calendar'),
                              backgroundColor: C.ink,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      OutlinedPillButton(
                        label: AppStrings.backToHome,
                        onTap: () => context.goNamed('home'),
                      ),
                    ]),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}

class _TicketCard extends StatelessWidget {
  final BookingModel booking;
  const _TicketCard({required this.booking});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: C.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: C.line),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F0A0A0F),
              blurRadius: 24,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Row(children: [
              Avatar(
                  name: booking.lawyerName, url: booking.lawyerPhoto, size: 46),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.lawyerName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: C.ink,
                        ),
                      ),
                      Text(
                        booking.lawyerRole,
                        style: const TextStyle(fontSize: 12.5, color: C.gray),
                      ),
                    ]),
              ),
              Text(
                booking.price,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: C.ink,
                ),
              ),
            ]),
          ),
          // Dashed divider
          _DashedDivider(),
          // Details
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Column(children: [
              _Row(
                icon: Icons.calendar_today_outlined,
                label: DateFormat('EEEE, d MMMM yyyy').format(booking.date),
              ),
              const SizedBox(height: 10),
              _Row(
                icon: Icons.access_time_rounded,
                label: booking.time,
              ),
              const SizedBox(height: 10),
              _Row(
                icon: Icons.videocam_outlined,
                label: booking.typeLabel,
              ),
              if (booking.note != null) ...[
                const SizedBox(height: 10),
                _Row(
                  icon: Icons.notes_rounded,
                  label: booking.note!,
                ),
              ],
            ]),
          ),
        ]),
      );
}

class _DashedDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => CustomPaint(
        size: const Size(double.infinity, 1),
        painter: _DashedLinePainter(),
      );
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE8E9ED)
      ..strokeWidth = 1;
    const dashWidth = 8.0;
    const dashSpace = 5.0;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + dashWidth, 0), paint);
      x += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Row({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Row(children: [
        Icon(icon, size: 18, color: C.gray),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 14, color: C.ink),
          ),
        ),
      ]);
}
