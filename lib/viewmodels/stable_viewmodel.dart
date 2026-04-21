import 'package:flutter/material.dart';

import '../models/slot_model.dart';
import '../models/stable.dart';
import '../services/api_service.dart';

class StableViewModel extends ChangeNotifier {
  StableViewModel();

  Stable? stable;
  List<DateTime> availableDates = [];
  List<SlotModel> slots = [];
  List<SlotModel> allSlots = []; // Store all slots for filtering
  String selectedDate = '';
  bool isLoading = false;
  String? error;

  Future<void> init(Stable stable) async {
    this.stable = stable;
    await loadAllSlotsAndExtractDates();
  }

  Future<void> loadAllSlotsAndExtractDates() async {
    if (stable == null) return;
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final response = await ApiService.getSlotsByStable(stable!.id.toString());
      if (response.data != null && response.data is List) {
        allSlots = (response.data as List)
            .map((item) {
              try {
                return SlotModel.fromJson(item as Map<String, dynamic>);
              } catch (e) {
                error = 'Error parsing slot: $e';
                return null;
              }
            })
            .whereType<SlotModel>()
            .toList();
        
        // Extract unique dates from slots
        final dateStrings = allSlots.map((slot) => slot.date.trim()).toSet().toList();
        availableDates = dateStrings.map((dateStr) {
          try {
            return DateTime.parse(dateStr);
          } catch (e) {
            return null;
          }
        }).whereType<DateTime>().toList();
        
        availableDates.sort(); // Sort dates in ascending order
        
        if (availableDates.isNotEmpty) {
          selectedDate = availableDates.first.toIso8601String().split('T').first;
          await loadSlotsForDate(selectedDate);
        } else {
          error = 'No available dates found';
        }
      } else {
        error = 'Invalid response format';
        availableDates = [];
        allSlots = [];
      }
    } catch (exception) {
      error = 'Failed to load slots: ${exception.toString()}';
      availableDates = [];
      allSlots = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadSlotsForDate(String date) async {
    selectedDate = date;
    isLoading = true;
    error = null;
    slots = []; // Clear slots before loading new ones
    notifyListeners();

    try {
      // Filter slots for the selected date and available status
      slots = allSlots
          .where((slot) => slot.date.trim() == date.trim())
          .toList();
      
      // Sort slots by start time
      slots.sort((a, b) => a.startTime.compareTo(b.startTime));
    } catch (exception) {
      error = 'Failed to load slots: ${exception.toString()}';
      slots = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
