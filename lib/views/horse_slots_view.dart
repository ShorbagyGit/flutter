import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/slot_model.dart';
import '../utils/app_routes.dart';
import '../viewmodels/horse_slots_viewmodel.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/primary_button.dart';
import '../widgets/slot_card.dart';
import 'horse_details_view.dart';
import 'booking_payment_view.dart';
import '../services/api_service.dart';

class HorseSlotsView extends StatefulWidget {
  final HorseSlotsArguments arguments;

  const HorseSlotsView({super.key, required this.arguments});

  @override
  State<HorseSlotsView> createState() => _HorseSlotsViewState();
}

class _HorseSlotsViewState extends State<HorseSlotsView> {
  SlotModel? _selectedSlot;

  bool _isAvailableSlot(SlotModel slot) {
    return slot.status.toLowerCase() == 'available';
  }

  void _continueToBooking(HorseSlotsViewModel viewModel) {
    if (_selectedSlot == null || !_isAvailableSlot(_selectedSlot!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select an available slot first.')),
      );
      return;
    }

    Navigator.pushNamed(
      context,
      Routes.payment,
      arguments: PaymentArguments(
        stable: widget.arguments.stable,
        horse: widget.arguments.horse,
        slot: _selectedSlot!,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ChangeNotifierProvider<HorseSlotsViewModel>(
      create: (_) => HorseSlotsViewModel()..loadSlotsForHorse(widget.arguments.horse.id),
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F7F3),
        bottomNavigationBar: Consumer<HorseSlotsViewModel>(
          builder: (context, viewModel, _) {
            final hasValidSelection =
                _selectedSlot != null &&
                viewModel.slots.any((slot) => slot.id == _selectedSlot!.id) &&
                _isAvailableSlot(_selectedSlot!);

            return SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Colors.black.withValues(alpha: 0.05))),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 24,
                      offset: const Offset(0, -8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEAF8F0),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(Icons.schedule_rounded, color: Color(0xFF2E7D32)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            hasValidSelection
                                ? '${_selectedSlot!.date} • ${_selectedSlot!.startTime} - ${_selectedSlot!.endTime}'
                                : 'Choose a slot to unlock booking.',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF4B5563),
                              fontWeight: FontWeight.w600,
                              height: 1.25,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    PrimaryButton(
                      fullWidth: true,
                      label: hasValidSelection ? 'Book selected slot' : 'Select a slot first',
                      disabled: !hasValidSelection,
                      onPressed: () => _continueToBooking(viewModel),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        body: Consumer<HorseSlotsViewModel>(
          builder: (context, viewModel, child) {
            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  automaticallyImplyLeading: false,
                  pinned: true,
                  expandedHeight: 352,
                  backgroundColor: const Color(0xFFF4F7F3),
                  elevation: 0,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          ApiService.resolveMediaUrl(widget.arguments.horse.image),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: theme.colorScheme.surfaceContainerHighest,
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.black.withValues(alpha: 0.62),
                                Colors.black.withValues(alpha: 0.16),
                              ],
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
                            ],
                          ),
                        ),
                        Positioned(
                          left: 16,
                          right: 16,
                          bottom: 16,
                          child: Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.95),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.34)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.12),
                                  blurRadius: 28,
                                  offset: const Offset(0, 14),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 42,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFD6E7DB),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  widget.arguments.horse.name,
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF102015),
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  widget.arguments.stable.name,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF4B5563),
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _HeaderChip(
                                        icon: Icons.payments_outlined,
                                        label: 'EGP ${widget.arguments.horse.price.toStringAsFixed(0)}',
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: _HeaderChip(
                                        icon: Icons.calendar_month_outlined,
                                        label: _selectedSlot == null
                                            ? 'Pick a slot'
                                            : '${_selectedSlot!.startTime} - ${_selectedSlot!.endTime}',
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
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SectionCard(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final itemWidth = constraints.maxWidth >= 420
                                  ? (constraints.maxWidth - 20) / 3
                                  : (constraints.maxWidth - 10) / 2;

                              return Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: [
                                  SizedBox(
                                    width: itemWidth,
                                    child: _MiniStat(label: 'Price', value: 'EGP ${widget.arguments.horse.price.toStringAsFixed(0)}'),
                                  ),
                                  SizedBox(
                                    width: itemWidth,
                                    child: _MiniStat(label: 'Age', value: widget.arguments.horse.age),
                                  ),
                                  SizedBox(
                                    width: constraints.maxWidth >= 420 ? itemWidth : constraints.maxWidth,
                                    child: _MiniStat(label: 'Status', value: widget.arguments.horse.status),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 14),
                        _SectionCard(
                          title: 'Available slots',
                          child: _buildSlotsSection(viewModel, theme),
                        ),
                        const SizedBox(height: 110),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSlotsSection(HorseSlotsViewModel viewModel, ThemeData theme) {
    if (viewModel.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: LoadingIndicator(message: 'Loading slots...'),
      );
    }

    if (viewModel.error != null) {
      return Text(
        viewModel.error!,
        style: TextStyle(color: theme.colorScheme.error),
      );
    }

    if (viewModel.slots.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Text(
          'No time slots available for this horse.',
          style: TextStyle(color: Color(0xFF4B5563)),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: viewModel.slots.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final slot = viewModel.slots[index];
        return SlotCard(
          slot: slot,
          selected: _selectedSlot?.id == slot.id,
          onTap: () {
            setState(() {
              _selectedSlot = _selectedSlot?.id == slot.id ? null : slot;
            });
          },
        );
      },
    );
  }
}

class _HeaderChip extends StatelessWidget {
  const _HeaderChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9F4),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF2E7D32)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF163020),
            ),
          ),
        ],
      ),
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
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF163020),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF4B5563),
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
