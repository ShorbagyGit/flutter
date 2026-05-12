import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../models/slot_model.dart';
import '../services/api_service.dart';

class HorseSlotsViewModel extends ChangeNotifier {
  HorseSlotsViewModel();

  List<SlotModel> slots = [];
  bool isLoading = false;
  String? error;

  Future<void> loadSlotsForHorse(String horseId) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final response = await ApiService.getSlotsByHorse(horseId);
      final data = response.data;
      if (data is List) {
        slots = data
            .whereType<Map>()
            .map((item) => SlotModel.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      } else {
        slots = [];
      }

      slots.sort((left, right) {
        final dateCompare = left.date.compareTo(right.date);
        if (dateCompare != 0) return dateCompare;
        return left.startTime.compareTo(right.startTime);
      });
    } on DioException catch (exception) {
      error = exception.message ?? 'Failed to load slots.';
      slots = [];
    } catch (exception) {
      error = exception.toString();
      slots = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
