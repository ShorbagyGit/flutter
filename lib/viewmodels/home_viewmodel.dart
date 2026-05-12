import 'package:flutter/material.dart';

import '../models/stable.dart';
import '../services/api_service.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel();

  bool isLoading = false;
  String? error;
  List<Stable> stables = [];
  List<Stable> _allStables = [];
  bool searchByLocation = false;
  String searchQuery = '';

  Future<void> loadStables() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final response = await ApiService.getAllStables();
      final loaded = (response.data as List).map((item) => Stable.fromJson(item)).toList();
      _allStables = loaded;
      stables = loaded;
    } catch (exception) {
      error = exception.toString();
      _allStables = [];
      stables = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> search(String query) async {
    searchQuery = query.trim();
    if (searchQuery.isEmpty) {
      stables = List<Stable>.from(_allStables);
      error = null;
      notifyListeners();
      return;
    }

    final lower = searchQuery.toLowerCase();
    stables = _allStables
        .where((stable) => stable.name.toLowerCase().contains(lower))
        .toList();
    error = null;
    notifyListeners();
  }

  List<Stable> suggestionsByName(String query, {int limit = 6}) {
    final text = query.trim().toLowerCase();
    if (text.isEmpty) return [];
    return _allStables
        .where((stable) => stable.name.toLowerCase().contains(text))
        .take(limit)
        .toList();
  }

  void selectStableFromSuggestion(Stable stable) {
    searchQuery = stable.name;
    stables = _allStables.where((item) => item.id == stable.id).toList();
    error = null;
    notifyListeners();
  }

  List<String> get availableCities {
    final cities = _allStables
        .map((stable) => stable.location.trim())
        .where((location) => location.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    return cities;
  }

  void filterByCity(String city) {
    final selected = city.trim().toLowerCase();
    if (selected.isEmpty) {
      stables = List<Stable>.from(_allStables);
    } else {
      stables = _allStables
          .where((stable) => stable.location.trim().toLowerCase() == selected)
          .toList();
    }
    error = null;
    notifyListeners();
  }

  void toggleSearchMode() {
    searchByLocation = !searchByLocation;
    notifyListeners();
  }
}
