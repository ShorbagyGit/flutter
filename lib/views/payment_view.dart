import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/slot_model.dart';
import '../models/stable.dart';
import '../utils/app_routes.dart';
import '../utils/date_utils.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/booking_viewmodel.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/primary_button.dart';
import 'booking_confirmation_view.dart';

class PaymentArguments {
  final Stable stable;
  final SlotModel slot;
  final String selectedDate;

  const PaymentArguments({
    required this.stable,
    required this.slot,
    required this.selectedDate,
  });
}

class PaymentView extends StatefulWidget {
  final PaymentArguments arguments;

  const PaymentView({super.key, required this.arguments});

  @override
  State<PaymentView> createState() => _PaymentViewState();
}

class _PaymentViewState extends State<PaymentView> {
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  String? _cardNumberError;
  String? _expiryError;
  String? _cvvError;

  String get _rawCardNumber => _cardNumberController.text.replaceAll('-', '');
  String get _expiryValue => _expiryController.text.trim();
  String get _cvvValue => _cvvController.text.trim();

  bool _isValidMonth(String expiry) {
    if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(expiry)) return false;
    final month = int.tryParse(expiry.substring(0, 2));
    return month != null && month >= 1 && month <= 12;
  }

  bool _isExpiryNotPast(String expiry) {
    if (!_isValidMonth(expiry)) return false;
    final month = int.parse(expiry.substring(0, 2));
    final year = 2000 + int.parse(expiry.substring(3, 5));
    final now = DateTime.now();
    return year > now.year || (year == now.year && month >= now.month);
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  Future<void> _submitPayment() async {
    final rawCardNumber = _rawCardNumber.trim();
    final expiry = _expiryValue;
    final cvv = _cvvValue;
    final isCardNumberValid = RegExp(r'^\d{16}$').hasMatch(rawCardNumber);
    final isExpiryValid = RegExp(r'^\d{2}/\d{2}$').hasMatch(expiry);
    final isMonthValid = _isValidMonth(expiry);
    final isExpiryNotPast = _isExpiryNotPast(expiry);
    final isCvvValid = RegExp(r'^\d{3}$').hasMatch(cvv);

    setState(() {
      _cardNumberError = isCardNumberValid ? null : 'Card number must be exactly 16 digits';
      if (!isExpiryValid) {
        _expiryError = 'Expiry must be in MM/YY format';
      } else if (!isMonthValid) {
        _expiryError = 'Month must be between 01 and 12';
      } else if (!isExpiryNotPast) {
        _expiryError = 'Card is expired';
      } else {
        _expiryError = null;
      }
      _cvvError = isCvvValid ? null : 'CVV must be exactly 3 digits';
    });

    if (!isCardNumberValid || !isExpiryValid || !isMonthValid || !isExpiryNotPast || !isCvvValid) {
      return;
    }

    final bookingViewModel = context.read<BookingViewModel>();
    final currentUser = context.read<AuthViewModel>().currentUser;

    if (currentUser == null || currentUser.id.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in first to book a slot.')),
      );
      return;
    }

    await bookingViewModel.bookSlot(
      slotId: widget.arguments.slot.id,
      userId: currentUser.id,
      date: widget.arguments.selectedDate,
    );

    if (!mounted) return;

    if (bookingViewModel.currentBooking != null) {
      final bookingId = bookingViewModel.currentBooking!.id;
      final paymentUrl = await bookingViewModel.createPaymentUrl(bookingId);
      if (paymentUrl == null || paymentUrl.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment link could not be created. Please try again.')),
        );
        return;
      }

      final uri = Uri.tryParse(paymentUrl);
      if (uri == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid payment URL returned from server.')),
        );
        return;
      }

      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open payment page.')),
        );
        return;
      }

      await bookingViewModel.fetchBookingsForUser(currentUser.id, showLoading: false);
      Navigator.pushNamed(
        context,
        Routes.bookingConfirmation,
        arguments: BookingConfirmationArguments(
          booking: bookingViewModel.currentBooking!,
          stable: widget.arguments.stable,
          slot: widget.arguments.slot,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment failed. Please try again.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingViewModel = context.watch<BookingViewModel>();
    final slot = widget.arguments.slot;
    final stable = widget.arguments.stable;
    final formattedDate = DateUtilsHelper.formatBookingDate(widget.arguments.selectedDate);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F3),
      appBar: AppBar(
        title: const Text('Payment'),
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
                    'Complete your booking',
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Review the details below and finish payment securely.',
                    style: TextStyle(color: Colors.white, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
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
                  Row(
                    children: [
                      Container(
                        height: 46,
                        width: 46,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF4EB),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.storefront, color: Color(0xFF2E7D32)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              stable.name,
                              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              formattedDate,
                              style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F9F4),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE6EBDD)),
                    ),
                    child: Column(
                      children: [
                        _buildDetailLine('Time', '${slot.startTime} - ${slot.endTime}'),
                        const SizedBox(height: 10),
                        _buildDetailLine('Date', formattedDate),
                        const SizedBox(height: 10),
                        _buildDetailLine('Total', 'EGP ${slot.price.toStringAsFixed(0)}'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 24),
            const Text(
              'Payment method',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
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
                  _PaymentMethodChip(
                    icon: Icons.credit_card,
                    title: 'Credit / Debit Card',
                    subtitle: 'Secure card payment',
                    selected: true,
                  ),
                  const SizedBox(height: 12),
                  _PaymentMethodChip(
                    icon: Icons.wallet_outlined,
                    title: 'Cash on arrival',
                    subtitle: 'Pay at the stable',
                    selected: false,
                  ),
                  const SizedBox(height: 20),
                  _SectionLabel(title: 'Card details'),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _cardNumberController,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() => _cardNumberError = null),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      _CardNumberInputFormatter(),
                    ],
                    maxLength: 19,
                    decoration: InputDecoration(
                      labelText: 'Card number',
                      prefixIcon: const Icon(Icons.credit_card_outlined),
                      filled: true,
                      fillColor: const Color(0xFFF7F9F4),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(color: Color(0xFFE4E8DF)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 1.5),
                      ),
                      counterText: '',
                      errorText: _cardNumberError,
                    ),
                  ),
                  const SizedBox(height: 12),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final useColumn = constraints.maxWidth < 320;
                      final expiryField = TextField(
                        controller: _expiryController,
                        keyboardType: TextInputType.datetime,
                        onChanged: (_) => setState(() => _expiryError = null),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          _ExpiryDateInputFormatter(),
                        ],
                        maxLength: 5,
                        decoration: InputDecoration(
                          labelText: 'MM/YY',
                          filled: true,
                          fillColor: const Color(0xFFF7F9F4),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: const BorderSide(color: Color(0xFFE4E8DF)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 1.5),
                          ),
                          counterText: '',
                          errorText: _expiryError,
                        ),
                      );

                      final cvvField = TextField(
                        controller: _cvvController,
                        keyboardType: TextInputType.number,
                        obscureText: true,
                        onChanged: (_) => setState(() => _cvvError = null),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(3),
                        ],
                        maxLength: 3,
                        decoration: InputDecoration(
                          labelText: 'CVV',
                          filled: true,
                          fillColor: const Color(0xFFF7F9F4),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: const BorderSide(color: Color(0xFFE4E8DF)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 1.5),
                          ),
                          counterText: '',
                          errorText: _cvvError,
                        ),
                      );

                      if (useColumn) {
                        return Column(
                          children: [
                            expiryField,
                            const SizedBox(height: 12),
                            cvvField,
                          ],
                        );
                      }

                      return Row(
                        children: [
                          Expanded(child: expiryField),
                          const SizedBox(width: 12),
                          Expanded(child: cvvField),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 20),
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
                            'Secure encrypted payment',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  bookingViewModel.isLoading
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 6),
                          child: Center(child: LoadingIndicator(message: 'Processing payment...')),
                        )
                      : PrimaryButton(
                          label: 'Pay EGP ${slot.price.toStringAsFixed(0)}',
                          onPressed: _submitPayment,
                          fullWidth: true,
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailLine(String label, String value) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stack = constraints.maxWidth < 280;
        if (stack) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Color(0xFF64748B))),
              const SizedBox(height: 6),
              Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.w700),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(child: Text(label, style: const TextStyle(color: Color(0xFF64748B)))),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.w700),
                textAlign: TextAlign.end,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: Color(0xFF2E7D32),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}

class _PaymentMethodChip extends StatelessWidget {
  const _PaymentMethodChip({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFEAF4EB) : const Color(0xFFF7F9F4),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: selected ? const Color(0xFF2E7D32) : const Color(0xFFE4E8DF),
          width: selected ? 1.3 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: selected ? const Color(0xFF2E7D32) : Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: selected ? Colors.white : theme.colorScheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (selected)
            Container(
              height: 20,
              width: 20,
              decoration: const BoxDecoration(
                color: Color(0xFF2E7D32),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, size: 14, color: Colors.white),
            ),
        ],
      ),
    );
  }
}

class _CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    final trimmed = digitsOnly.length > 16 ? digitsOnly.substring(0, 16) : digitsOnly;

    final buffer = StringBuffer();
    for (var i = 0; i < trimmed.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write('-');
      }
      buffer.write(trimmed[i]);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _ExpiryDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    final trimmed = digitsOnly.length > 4 ? digitsOnly.substring(0, 4) : digitsOnly;

    final buffer = StringBuffer();
    for (var i = 0; i < trimmed.length; i++) {
      if (i == 2) {
        buffer.write('/');
      }
      buffer.write(trimmed[i]);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
