import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/booking_model.dart';
import '../models/horse_model.dart';
import '../models/slot_model.dart';
import '../models/stable.dart';
import '../utils/app_routes.dart';
import '../utils/date_utils.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/booking_viewmodel.dart';
import '../widgets/primary_button.dart';
import 'booking_confirmation_view.dart';

class PaymentArguments {
  final Stable stable;
  final HorseModel horse;
  final SlotModel slot;

  const PaymentArguments({
    required this.stable,
    required this.horse,
    required this.slot,
  });
}

class PaymentView extends StatefulWidget {
  final PaymentArguments arguments;

  const PaymentView({super.key, required this.arguments});

  @override
  State<PaymentView> createState() => _PaymentViewState();
}

class _PaymentViewState extends State<PaymentView> {
  bool _isSubmitting = false;

  Future<BookingModel?> _createBooking() async {
    final bookingViewModel = context.read<BookingViewModel>();
    final currentUser = context.read<AuthViewModel>().currentUser;

    if (currentUser == null || currentUser.id.isEmpty) {
      if (!mounted) return null;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in first to book a slot.')),
      );
      return null;
    }

    final booking = await bookingViewModel.bookSlot(
      slotId: widget.arguments.slot.id,
      userId: currentUser.id,
    );

    if (booking == null) {
      if (!mounted) return null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(bookingViewModel.error ?? 'Booking failed.')),
      );
      return null;
    }

    return booking;
  }

  Future<void> _confirmAndPay() async {
    setState(() => _isSubmitting = true);
    final booking = await _createBooking();
    if (!mounted) return;

    if (booking == null) {
      setState(() => _isSubmitting = false);
      return;
    }

    final bookingViewModel = context.read<BookingViewModel>();
    final paymentUrl = await bookingViewModel.createPaymentUrl(booking.id);
    if (!mounted) return;

    if (paymentUrl != null && paymentUrl.isNotEmpty) {
      final uri = Uri.tryParse(paymentUrl);
      if (uri != null) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }

    setState(() => _isSubmitting = false);

    if (!mounted) return;

    Navigator.pushReplacementNamed(
      context,
      Routes.bookingConfirmation,
      arguments: BookingConfirmationArguments(
        booking: booking,
        stable: widget.arguments.stable,
        horse: widget.arguments.horse,
        slot: widget.arguments.slot,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final slot = widget.arguments.slot;
    final stable = widget.arguments.stable;
    final horse = widget.arguments.horse;
    final bookingDate = DateUtilsHelper.formatBookingDate(slot.date);
    final bookingViewModel = context.watch<BookingViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F3),
      appBar: AppBar(
        title: const Text('Booking Confirmation'),
        centerTitle: false,
        elevation: 0,
        backgroundColor: const Color(0xFFF4F7F3),
        foregroundColor: const Color(0xFF163020),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: const LinearGradient(
                  colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Review your booking',
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Confirm the booking and continue directly to payment.',
                    style: TextStyle(color: Colors.white, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _SummaryCard(
              stable: stable,
              horse: horse,
              slot: slot,
              bookingDate: bookingDate,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                children: [
                  PrimaryButton(
                    label: _isSubmitting || bookingViewModel.isLoading ? 'Processing...' : 'Confirm and pay',
                    onPressed: _isSubmitting || bookingViewModel.isLoading ? () {} : _confirmAndPay,
                    disabled: _isSubmitting || bookingViewModel.isLoading,
                    fullWidth: true,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF4FAF3),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Icon(Icons.lock_outline, color: Theme.of(context).colorScheme.primary, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Secure booking through the backend API.',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.stable,
    required this.horse,
    required this.slot,
    required this.bookingDate,
  });

  final Stable stable;
  final HorseModel horse;
  final SlotModel slot;
  final String bookingDate;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _RowItem(label: 'Stable', value: stable.name),
          const SizedBox(height: 10),
          _RowItem(label: 'Horse', value: horse.name),
          const SizedBox(height: 10),
          _RowItem(label: 'Date', value: bookingDate),
          const SizedBox(height: 10),
          _RowItem(label: 'Time', value: '${slot.startTime} - ${slot.endTime}'),
        ],
      ),
    );
  }
}

class _RowItem extends StatelessWidget {
  const _RowItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(fontWeight: FontWeight.w700),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
