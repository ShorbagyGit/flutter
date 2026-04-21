import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/slot_model.dart';
import '../models/stable.dart';
import '../viewmodels/stable_viewmodel.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/primary_button.dart';
import '../widgets/slot_card.dart';
import '../utils/app_routes.dart';
import 'payment_view.dart';

class StableDetailsView extends StatefulWidget {
  final Stable stable;

  const StableDetailsView({super.key, required this.stable});

  @override
  State<StableDetailsView> createState() => _StableDetailsViewState();
}

class _StableDetailsViewState extends State<StableDetailsView> {
  SlotModel? _selectedSlot;

  bool _isAvailableSlot(SlotModel slot) => slot.status.toLowerCase() == 'available';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ChangeNotifierProvider<StableViewModel>(
      create: (_) => StableViewModel()..init(widget.stable),
      builder: (context, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF4F7F3),
          body: Consumer<StableViewModel>(builder: (context, viewModel, child) {
            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  automaticallyImplyLeading: false,
                  pinned: true,
                  expandedHeight: 240,
                  backgroundColor: const Color(0xFFF4F7F3),
                  elevation: 0,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          widget.stable.image,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(color: theme.colorScheme.surfaceContainerHighest),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.black.withValues(alpha: 0.35), Colors.black.withValues(alpha: 0.05)],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 32,
                          left: 16,
                          right: 16,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _RoundIconButton(
                                icon: Icons.arrow_back,
                                onTap: () => Navigator.of(context).pop(),
                              ),
                              _RoundIconButton(
                                icon: Icons.favorite_border,
                                onTap: () {},
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          left: 16,
                          right: 16,
                          bottom: 18,
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.92),
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.stable.name,
                                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on_outlined, size: 16, color: Color(0xFF2E7D32)),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        widget.stable.location,
                                        style: const TextStyle(color: Color(0xFF4B5563), fontSize: 13),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SectionCard(
                          child: Row(
                            children: [
                              _MiniStat(label: 'Slots', value: viewModel.slots.length.toString()),
                              const SizedBox(width: 10),
                              _MiniStat(
                                label: 'Lowest Price',
                                value: viewModel.slots.isNotEmpty
                                    ? 'EGP ${viewModel.slots.map((s) => s.price).reduce(min).toStringAsFixed(0)}'
                                    : 'EGP -',
                              ),
                              const SizedBox(width: 10),
                              _MiniStat(
                                label: 'Location',
                                value: 'Open',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        _SectionCard(
                          title: 'About',
                          child: Text(
                            widget.stable.description,
                            style: const TextStyle(color: Color(0xFF4B5563), height: 1.5),
                          ),
                        ),
                        const SizedBox(height: 14),
                        _SectionCard(
                          title: 'Select date',
                          child: _buildDatesSection(viewModel, theme),
                        ),
                        const SizedBox(height: 14),
                        _SectionCard(
                          title: 'Available slots',
                          child: _buildSlotsSection(viewModel, theme),
                        ),
                        const SizedBox(height: 14),
                        if (_selectedSlot != null &&
                            viewModel.slots.any((slot) => slot.id == _selectedSlot!.id) &&
                            _isAvailableSlot(_selectedSlot!))
                          _SectionCard(
                            title: 'Selected slot',
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${_selectedSlot!.startTime} - ${_selectedSlot!.endTime}',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 16),
                                PrimaryButton(
                                  fullWidth: true,
                                  label: 'Book Now',
                                  onPressed: () {
                                    if (_selectedSlot == null || !_isAvailableSlot(_selectedSlot!)) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('This slot is not available for booking.')),
                                      );
                                      return;
                                    }
                                    Navigator.pushNamed(
                                      context,
                                      Routes.payment,
                                      arguments: PaymentArguments(
                                        stable: widget.stable,
                                        slot: _selectedSlot!,
                                        selectedDate: viewModel.selectedDate,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        );
      },
    );
  }

  Widget _buildDatesSection(StableViewModel viewModel, ThemeData theme) {
    if (viewModel.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: LoadingIndicator(message: 'Loading dates...'),
      );
    }

    if (viewModel.error != null && viewModel.availableDates.isEmpty) {
      return Text(viewModel.error!, style: TextStyle(color: theme.colorScheme.error));
    }

    if (viewModel.availableDates.isEmpty) {
      return const Text('No dates available', style: TextStyle(color: Color(0xFF4B5563)));
    }

    return SizedBox(
      height: 104,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: viewModel.availableDates.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final date = viewModel.availableDates[index];
          final dateStr = date.toIso8601String().split('T').first;
          final isSelected = viewModel.selectedDate == dateStr;
          final day = date.day.toString();
          final month = _monthName(date.month);

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedSlot = null;
              });
              viewModel.loadSlotsForDate(dateStr);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
              width: 82,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      )
                    : null,
                color: isSelected ? null : const Color(0xFFF8FAF7),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isSelected ? const Color(0xFF2E7D32) : const Color(0xFFE4E8DF)),
                boxShadow: [
                  BoxShadow(
                    color: isSelected ? const Color(0xFF2E7D32).withValues(alpha: 0.24) : Colors.black.withValues(alpha: 0.04),
                    blurRadius: isSelected ? 14 : 8,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    day,
                    style: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF111827),
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    month,
                    style: TextStyle(
                      color: isSelected ? Colors.white.withValues(alpha: 0.85) : const Color(0xFF64748B),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    if (month < 1 || month > 12) {
      return '';
    }

    return months[month - 1];
  }

  Widget _buildSlotsSection(StableViewModel viewModel, ThemeData theme) {
    if (viewModel.availableDates.isEmpty && !viewModel.isLoading) {
      return const Text('Select a date first', style: TextStyle(color: Color(0xFF4B5563)));
    }

    if (viewModel.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: LoadingIndicator(message: 'Loading slots...'),
      );
    }

    if (viewModel.error != null) {
      return Text(viewModel.error!, style: TextStyle(color: theme.colorScheme.error));
    }

    if (viewModel.slots.isEmpty) {
      return const Text('No time slots available for this date.', style: TextStyle(color: Color(0xFF4B5563)));
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: viewModel.slots.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final slot = viewModel.slots[index];
        return SlotCard(
          slot: slot,
          selected: _selectedSlot?.id == slot.id,
          onTap: () {
            setState(() {
              _selectedSlot = slot;
            });
          },
        );
      },
    );
  }

}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(icon, color: const Color(0xFF2E7D32)),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({this.title, required this.child});

  final String? title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
          ],
          child,
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F9F4),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF163020)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
