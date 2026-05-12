import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../models/horse_model.dart';
import '../models/stable.dart';
import '../services/api_service.dart';

class StableViewModel extends ChangeNotifier {
  StableViewModel();

  Stable? stable;
  List<HorseModel> horses = [];
  bool isLoading = false;
  String? error;

  Future<void> init(Stable stable) async {
    this.stable = stable;
    await loadHorsesForStable();
  }

  Future<void> loadHorsesForStable() async {
    final stableId = _normalizeId(stable?.id);
    if (stableId.isEmpty) {
      debugPrint('[StableVM] loadHorsesForStable aborted: empty stableId');
      return;
    }

    debugPrint('[StableVM] loadHorsesForStable start | stableId=$stableId');

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final response = await ApiService.getHorsesByStable(stableId);
      debugPrint(
        '[StableVM] /Horse/stable/$stableId raw response type=${response.data.runtimeType}',
      );
      debugPrint('[StableVM] /Horse/stable/$stableId raw response=${response.data}');
      var parsedHorses = _extractHorseList(response.data);
      debugPrint(
        '[StableVM] parsed horses count from stable endpoint=${parsedHorses.length}',
      );

      // Fallback: if endpoint returns incomplete data, filter from all horses.
      if (parsedHorses.length <= 1) {
        debugPrint(
          '[StableVM] triggering fallback /Horse/getall because parsed count=${parsedHorses.length}',
        );
        final allResponse = await ApiService.getAllHorses();
        debugPrint(
          '[StableVM] /Horse/getall raw response type=${allResponse.data.runtimeType}',
        );
        final allHorses = _extractHorseList(allResponse.data);
        debugPrint('[StableVM] /Horse/getall parsed horses count=${allHorses.length}');
        final matched = allHorses
            .where((horse) => _normalizeId(horse.stableId) == stableId)
            .toList();
        debugPrint('[StableVM] fallback matched horses for stableId=$stableId count=${matched.length}');
        if (matched.length > parsedHorses.length) {
          debugPrint('[StableVM] fallback replaced parsed list (${parsedHorses.length} -> ${matched.length})');
          parsedHorses = matched;
        }
      }

      horses = _dedupeById(parsedHorses);
      debugPrint('[StableVM] horses count after dedupe=${horses.length}');

      horses.sort((left, right) => left.name.compareTo(right.name));
      debugPrint('[StableVM] final horses count before notifyListeners=${horses.length}');
    } on DioException catch (exception) {
      error = exception.message ?? 'Failed to load horses.';
      horses = [];
      debugPrint('[StableVM] DioException while loading horses: $error');
    } catch (exception) {
      error = exception.toString();
      horses = [];
      debugPrint('[StableVM] Exception while loading horses: $error');
    } finally {
      isLoading = false;
      notifyListeners();
      debugPrint('[StableVM] notifyListeners called | isLoading=$isLoading | horses=${horses.length}');
    }
  }

  List<HorseModel> _extractHorseList(dynamic data) {
    if (data == null) return [];

    if (data is List) {
      return data
          .whereType<Map>()
          .map((item) => HorseModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }

    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      final nestedCandidates = [
        map['data'],
        map['horses'],
        map['items'],
        map['result'],
      ];

      for (final candidate in nestedCandidates) {
        final parsed = _extractHorseList(candidate);
        if (parsed.isNotEmpty) {
          return parsed;
        }
      }

      // Some APIs can return a single horse object.
      if (map.containsKey('id') || map.containsKey('name')) {
        return [HorseModel.fromJson(map)];
      }
    }

    return [];
  }

  List<HorseModel> _dedupeById(List<HorseModel> source) {
    final uniqueById = <String, HorseModel>{};
    for (final horse in source) {
      final key = _normalizeId(horse.id);
      if (key.isEmpty) {
        continue;
      }
      uniqueById[key] = horse;
    }

    // Keep horses without ids too, but avoid duplicates by name+stable fallback key.
    final withoutId = source.where((horse) => _normalizeId(horse.id).isEmpty);
    final seenFallback = <String>{};
    final extras = <HorseModel>[];
    for (final horse in withoutId) {
      final fallbackKey =
          '${_normalizeId(horse.stableId)}-${horse.name.trim().toLowerCase()}-${horse.age.trim()}';
      if (seenFallback.add(fallbackKey)) {
        extras.add(horse);
      }
    }

    return [...uniqueById.values, ...extras];
  }

  String _normalizeId(String? raw) => raw?.trim() ?? '';
}
