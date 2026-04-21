import 'package:flutter/material.dart';

import '../models/slot_model.dart';

class SlotCard extends StatelessWidget {
  final SlotModel slot;
  final bool selected;
  final VoidCallback onTap;

  const SlotCard({super.key, required this.slot, required this.onTap, this.selected = false});

  bool get _isAvailable => slot.status.toLowerCase() == 'available';

  Color get _statusColor {
    if (slot.status.toLowerCase() == 'available') {
      return const Color(0xFF2E7D32);
    }
    if (slot.status.toLowerCase() == 'reserved' || slot.status.toLowerCase() == 'booked') {
      return const Color(0xFFB45309);
    }
    return const Color(0xFF94A3B8);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardBackground = !_isAvailable
        ? const Color(0xFFF8FAFC)
        : (selected ? theme.colorScheme.primary : Colors.white);
    final primaryTextColor = !_isAvailable
        ? const Color(0xFF94A3B8)
        : (selected ? Colors.white : const Color(0xFF111827));
    return GestureDetector(
      onTap: _isAvailable ? onTap : null,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: cardBackground,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: !_isAvailable
                ? const Color(0xFFE2E8F0)
                : (selected ? theme.colorScheme.primary : const Color(0xFFE5E7EB)),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: _isAvailable ? 0.04 : 0.01),
              offset: const Offset(0, 8),
              blurRadius: 18,
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${slot.startTime} - ${slot.endTime}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: primaryTextColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: _statusColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            slot.status.toUpperCase(),
                            style: TextStyle(
                              color: _statusColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'EGP ${slot.price.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: primaryTextColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                _isAvailable
                    ? Icon(
                        Icons.chevron_right,
                        color: selected ? Colors.white : const Color(0xFF4B5563),
                        size: 22,
                      )
                    : const Icon(
                        Icons.lock_outline,
                        color: Color(0xFF94A3B8),
                        size: 18,
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
