import 'package:flutter/material.dart';

import '../models/slot_model.dart';

class SlotCard extends StatelessWidget {
  final SlotModel slot;
  final bool selected;
  final VoidCallback onTap;

  const SlotCard({super.key, required this.slot, required this.onTap, this.selected = false});

  bool get _isAvailable => slot.status.toLowerCase() == 'available';

  Color get _statusColor {
    final s = slot.status.toLowerCase();
    if (s == 'available') return const Color(0xFF2E7D32);
    if (s == 'reserved' || s == 'booked') return const Color(0xFFB45309);
    return const Color(0xFF64748B);
  }

  String _formatTime(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return '--';

    final normalized = trimmed.toUpperCase().replaceAll(RegExp(r'\s+'), ' ');
    final amPmMatch = RegExp(r'^(\d{1,2})(?::(\d{2}))?(?::\d{2})?\s*([AP]M)$').firstMatch(normalized);
    if (amPmMatch != null) {
      final hour = int.tryParse(amPmMatch.group(1) ?? '');
      final minute = int.tryParse(amPmMatch.group(2) ?? '00') ?? 0;
      final period = amPmMatch.group(3)!;
      if (hour == null || minute < 0 || minute > 59) return trimmed;
      final hour12 = hour % 12 == 0 ? 12 : hour % 12;
      return '$hour12:${minute.toString().padLeft(2, '0')} $period';
    }

    final match = RegExp(r'^(\d{1,2})(?::(\d{2}))?(?::\d{2})?$').firstMatch(normalized);
    if (match == null) return trimmed;

    final hour = int.tryParse(match.group(1) ?? '');
    final minute = int.tryParse(match.group(2) ?? '00') ?? 0;
    if (hour == null || hour < 0 || hour > 23 || minute < 0 || minute > 59) {
      return trimmed;
    }

    final period = hour >= 12 ? 'PM' : 'AM';
    final hour12 = hour % 12 == 0 ? 12 : hour % 12;
    return '$hour12:${minute.toString().padLeft(2, '0')} $period';
  }

  String get _timeRange => '${_formatTime(slot.startTime)} - ${_formatTime(slot.endTime)}';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final isCompact = width < 380;
    final isSelected = selected && _isAvailable;
    final backgroundColor = !_isAvailable
        ? const Color(0xFFF8FAFC)
        : (isSelected ? theme.colorScheme.primary : Colors.white);
    final primaryTextColor = !_isAvailable
        ? const Color(0xFF94A3B8)
        : (isSelected ? Colors.white : const Color(0xFF0F172A));
    final secondaryTextColor = !_isAvailable
        ? const Color(0xFF94A3B8)
        : (isSelected ? Colors.white.withValues(alpha: 0.84) : const Color(0xFF475569));
    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      margin: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: !_isAvailable
              ? const Color(0xFFE6EEF6)
              : (isSelected ? theme.colorScheme.primary : const Color(0xFFE6E9EE)),
          width: isSelected ? 1.8 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: _isAvailable ? 0.06 : 0.02),
            offset: const Offset(0, 10),
            blurRadius: 20,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: _isAvailable ? onTap : null,
          child: Padding(
            padding: EdgeInsets.all(isCompact ? 12 : 14),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: isCompact ? 74 : 88,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.22)
                        : _isAvailable
                            ? _statusColor
                            : const Color(0xFFD1D5DB),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: isCompact ? 36 : 40,
                            height: isCompact ? 36 : 40,
                            decoration: BoxDecoration(
                              color: !_isAvailable ? const Color(0xFFF1F5F9) : (isSelected ? Colors.white.withValues(alpha: 0.12) : const Color(0xFFEAF8F0)),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              _isAvailable ? Icons.schedule_rounded : Icons.lock_outline_rounded,
                              size: 19,
                              color: !_isAvailable ? const Color(0xFF94A3B8) : (isSelected ? Colors.white : const Color(0xFF2F855A)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _timeRange,
                                  style: TextStyle(
                                    fontSize: isCompact ? 13 : 14,
                                    height: 1.05,
                                    fontWeight: FontWeight.w900,
                                    color: primaryTextColor,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  slot.date,
                                  style: TextStyle(
                                    fontSize: isCompact ? 11 : 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: secondaryTextColor,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            isSelected ? Icons.check_circle_rounded : Icons.chevron_right_rounded,
                            color: !_isAvailable ? const Color(0xFF94A3B8) : (isSelected ? Colors.white : const Color(0xFF475569)),
                            size: isCompact ? 18 : 20,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: isCompact ? 8 : 9, vertical: isCompact ? 4 : 5),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white.withValues(alpha: 0.12)
                                  : _isAvailable
                                      ? _statusColor.withValues(alpha: 0.08)
                                      : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              slot.status.toUpperCase(),
                              style: TextStyle(
                                color: _statusColor,
                                fontWeight: FontWeight.w800,
                                fontSize: isCompact ? 9 : 10,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isAvailable ? 'Tap to book' : 'Not available',
                            style: TextStyle(
                              color: secondaryTextColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
