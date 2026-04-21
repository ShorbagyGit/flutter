import 'package:flutter/material.dart';

import '../models/stable.dart';
import '../services/api_service.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel();

  bool isLoading = false;
  String? error;
  List<Stable> stables = [];
  bool searchByLocation = false;
  String searchQuery = '';

  Future<void> loadStables() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final response = await ApiService.getAllStables();
      stables = (response.data as List).map((item) => Stable.fromJson(item)).toList();
    } catch (exception) {
      error = exception.toString();
      stables = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> search(String query) async {
    searchQuery = query.trim();
    if (searchQuery.isEmpty) {
      await loadStables();
      return;
    }

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final response = searchByLocation ? await ApiService.searchStablesByLocation(searchQuery) : await ApiService.searchStablesByName(searchQuery);
      stables = (response.data as List).map((item) => Stable.fromJson(item)).toList();
    } catch (exception) {
      error = exception.toString();
      stables = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void toggleSearchMode() {
    searchByLocation = !searchByLocation;
    notifyListeners();
  }
}
