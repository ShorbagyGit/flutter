import 'package:flutter/material.dart';

import '../models/booking_model.dart';
import '../models/slot_model.dart';
import '../models/stable.dart';
import '../utils/app_routes.dart';
import '../utils/date_utils.dart';
import '../widgets/primary_button.dart';

class BookingConfirmationArguments {
  final BookingModel booking;
  final Stable stable;
  final SlotModel slot;

  BookingConfirmationArguments({
    required this.booking,
    required this.stable,
    required this.slot,
  });
}

class BookingConfirmationView extends StatelessWidget {
  final BookingConfirmationArguments arguments;

  const BookingConfirmationView({super.key, required this.arguments});

  @override
  Widget build(BuildContext context) {
    final date = DateUtilsHelper.formatBookingDate(arguments.booking.date);
    final timeRange = '${arguments.slot.startTime} - ${arguments.slot.endTime}';
    final theme = Theme.of(context);
    final ticketColor = Colors.white;
    final pageColor = const Color(0xFFF3F5F2);

    return Scaffold(
      backgroundColor: pageColor,
      appBar: AppBar(
        title: const Text('Booking Ticket'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Admit One',
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                  letterSpacing: 1.8,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: ticketColor,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 32,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF2E7D32), Color(0xFF1F5F24)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(28),
                          topRight: Radius.circular(28),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'RIDING TICKET',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    letterSpacing: 1.4,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 11,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  arguments.stable.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 24,
                                    height: 1.05,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Text(
                              'CONFIRMED',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _TicketInfoCell(
                                  icon: Icons.calendar_month_outlined,
                                  label: 'Date',
                                  value: date,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _TicketInfoCell(
                                  icon: Icons.schedule_outlined,
                                  label: 'Time',
                                  value: timeRange,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: _TicketInfoCell(
                                  icon: Icons.tag_outlined,
                                  label: 'Slot',
                                  value: arguments.slot.id,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _TicketInfoCell(
                                  icon: Icons.person_outline,
                                  label: 'Status',
                                  value: arguments.booking.status,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    _PerforatedDivider(backgroundColor: pageColor),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Booking Code',
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurfaceVariant,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                SelectableText(
                                  arguments.booking.id,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    letterSpacing: 0.8,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Please arrive 15 min early.',
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurfaceVariant,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            width: 84,
                            height: 84,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F8F4),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const FittedBox(
                              child: Text(
                                '||||| || ||||| ||| || |||||',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF5EE),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Color(0xFF2E7D32), size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Please arrive 15 minutes before your slot starts.',
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              PrimaryButton(
                label: 'Return to Home',
                onPressed: () {
                  Navigator.popUntil(context, ModalRoute.withName(Routes.mainShell));
                },
              ),
              const SizedBox(height: 10),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.popUntil(context, ModalRoute.withName(Routes.mainShell));
                  },
                  child: const Text('Back to Home'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PerforatedDivider extends StatelessWidget {
  final Color backgroundColor;

  const _PerforatedDivider({required this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 26,
      child: Stack(
        children: [
          Positioned.fill(
            child: Align(
              alignment: Alignment.center,
              child: Row(
                children: List.generate(
                  28,
                  (_) => Expanded(
                    child: Container(
                      height: 1,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      color: const Color(0xFFD7DDD3),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: -12,
            top: 1,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: backgroundColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: -12,
            top: 1,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: backgroundColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TicketInfoCell extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _TicketInfoCell({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9F4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: const Color(0xFF647567)),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF647567),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
