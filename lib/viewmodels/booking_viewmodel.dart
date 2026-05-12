import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../models/booking_model.dart';
import '../services/api_service.dart';

class BookingViewModel extends ChangeNotifier {
  BookingViewModel();

  bool isLoading = false;
  String? error;
  List<BookingModel> bookings = [];
  BookingModel? currentBooking;

  void clearBookings() {
    bookings = [];
    error = null;
    isLoading = false;
    notifyListeners();
  }

  Future<void> fetchBookingsForUser(
    String userId, {
    bool showLoading = true,
  }) async {
    if (showLoading) {
      isLoading = true;
      error = null;
      notifyListeners();
    }

    try {
      final response = await ApiService.getBookingsByUser(userId);
      _log('Bookings response type: ${response.data.runtimeType}');
      bookings = _parseBookingsPayload(response.data);
      if (!showLoading) {
        error = null;
      }
    } on DioException catch (exception) {
      _log('Bookings request failed: ${exception.message}');
      final statusCode = exception.response?.statusCode;
      final responseText = exception.response?.data?.toString().toLowerCase() ?? '';

      if (statusCode == 404 || statusCode == 204 || responseText.contains('no booking')) {
        bookings = [];
        error = null;
      } else {
        error = 'Unable to load bookings right now. Please try again.';
        bookings = [];
      }
    } catch (exception) {
      _log('Bookings request failed: $exception');
      error = 'Unable to load bookings right now. Please try again.';
      bookings = [];
    } finally {
      if (showLoading) {
        isLoading = false;
      }
      notifyListeners();
    }
  }

  Future<void> fetchAllBookings({bool showLoading = true}) async {
    if (showLoading) {
      isLoading = true;
      error = null;
      notifyListeners();
    }

    try {
      final response = await ApiService.getAllBookings();
      _log('All bookings response type: ${response.data.runtimeType}');
      bookings = _parseBookingsPayload(response.data);
      if (!showLoading) {
        error = null;
      }
    } on DioException catch (exception) {
      _log('All bookings request failed: ${exception.message}');
      error = 'Unable to load bookings right now. Please try again.';
      bookings = [];
    } catch (exception) {
      _log('All bookings request failed: $exception');
      error = 'Unable to load bookings right now. Please try again.';
      bookings = [];
    } finally {
      if (showLoading) {
        isLoading = false;
      }
      notifyListeners();
    }
  }

  Future<BookingModel?> bookSlot({
    required String slotId,
    required String userId,
    String? date,
  }) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final response = await ApiService.bookSlot(slotId: slotId, userId: userId, date: date);
      final parsed = _decodeSingleBooking(response.data);
      currentBooking = parsed;
      return parsed;
    } catch (exception) {
      error = exception.toString();
      currentBooking = null;
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> cancelBooking(String bookingId) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      await ApiService.cancelBooking(bookingId);
      bookings = bookings.map((booking) {
        if (booking.id == bookingId) {
          return BookingModel(
            id: booking.id,
            bookingDate: booking.bookingDate,
            status: 'CANCELLED',
            date: booking.date,
            startTime: booking.startTime,
            endTime: booking.endTime,
            price: booking.price,
            paymobOrderId: booking.paymobOrderId,
            userId: booking.userId,
            stableId: booking.stableId,
            stableName: booking.stableName,
            horseId: booking.horseId,
            horseName: booking.horseName,
            slotId: booking.slotId,
          );
        }
        return booking;
      }).toList();
    } catch (exception) {
      error = exception.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> createPaymentUrl(String bookingId) async {
    try {
      final response = await ApiService.createPayment(bookingId);
      final data = response.data;
      if (data is String && data.isNotEmpty) {
        return data;
      }
      if (data is Map && data['url'] is String) {
        return data['url'] as String;
      }
      return null;
    } catch (exception) {
      error = exception.toString();
      notifyListeners();
      return null;
    }
  }

  List<BookingModel> upcomingBookings() {
    return bookings.where((booking) {
      final bookingDate = DateTime.tryParse(booking.date);
      return bookingDate != null && bookingDate.isAfter(DateTime.now());
    }).toList();
  }

  List<BookingModel> pastBookings() {
    return bookings.where((booking) {
      final bookingDate = DateTime.tryParse(booking.date);
      return bookingDate == null || bookingDate.isBefore(DateTime.now());
    }).toList();
  }

  int get rideCount => bookings.length;

  int get hoursBooked => bookings.length * 2;

  void _log(String message) {
    if (kDebugMode) {
      debugPrint(message);
    }
  }

  List<BookingModel> _parseBookingsPayload(dynamic payload) {
    if (payload is List) {
      return _mapBookingList(payload);
    }

    if (payload is Map) {
      final map = Map<String, dynamic>.from(payload);
      final listFromEnvelope = _extractListFromEnvelope(map);
      if (listFromEnvelope != null) {
        return listFromEnvelope;
      }

      if (map.containsKey('id')) {
        return [BookingModel.fromJson(map)];
      }
    }

    if (payload is String) {
      final raw = payload.trim();
      _log('Bookings raw response: ${raw.length > 1000 ? '${raw.substring(0, 1000)}...' : raw}');

      if (raw.isEmpty || raw == '[]' || raw.toLowerCase().contains('no booking')) {
        return [];
      }

      for (final candidate in _bookingJsonCandidates(raw)) {
        try {
          final decoded = jsonDecode(candidate);
          final parsed = _decodeDecodedBookings(decoded);
          if (parsed != null) {
            return parsed;
          }
        } on FormatException {
          continue;
        }
      }
    }

    error = 'Invalid bookings data received from server.';
    return [];
  }

  BookingModel? _decodeSingleBooking(dynamic payload) {
    if (payload is Map) {
      return BookingModel.fromJson(Map<String, dynamic>.from(payload));
    }

    if (payload is String) {
      final raw = payload.trim();
      for (final candidate in _bookingJsonCandidates(raw)) {
        try {
          final decoded = jsonDecode(candidate);
          if (decoded is Map) {
            return BookingModel.fromJson(Map<String, dynamic>.from(decoded));
          }
          if (decoded is List && decoded.isNotEmpty && decoded.first is Map) {
            return BookingModel.fromJson(Map<String, dynamic>.from(decoded.first as Map));
          }
        } on FormatException {
          continue;
        }
      }
    }

    return null;
  }

  List<BookingModel>? _decodeDecodedBookings(dynamic decoded) {
    if (decoded is List) {
      return _mapBookingList(decoded);
    }

    if (decoded is Map) {
      final map = Map<String, dynamic>.from(decoded);
      final envelopeList = _extractListFromEnvelope(map);
      if (envelopeList != null) {
        return envelopeList;
      }

      if (map.containsKey('id')) {
        return [BookingModel.fromJson(map)];
      }
    }

    return null;
  }

  List<BookingModel>? _extractListFromEnvelope(Map<String, dynamic> map) {
    for (final key in ['data', 'bookings', 'result', 'items']) {
      final value = map[key];
      if (value is List) {
        return _mapBookingList(value);
      }
    }
    return null;
  }

  List<BookingModel> _mapBookingList(List values) {
    final parsedBookings = <BookingModel>[];

    for (final item in values) {
      if (item is Map) {
        parsedBookings.add(BookingModel.fromJson(Map<String, dynamic>.from(item)));
      }
    }

    return parsedBookings;
  }

  List<String> _bookingJsonCandidates(String responseText) {
    final candidates = <String>{};

    String stripOuterQuotes(String value) {
      final trimmed = value.trim();
      if (trimmed.length >= 2 && trimmed.startsWith('"') && trimmed.endsWith('"')) {
        return trimmed.substring(1, trimmed.length - 1).replaceAll(r'\"', '"');
      }
      return trimmed;
    }

    String replaceSingleQuotes(String value) => value.replaceAll("'", '"');

    String removeTrailingCommas(String value) {
      return value.replaceAll(RegExp(r",\s*([}\]])"), r'$1');
    }

    final base = stripOuterQuotes(responseText);
    final extracted = _extractJsonSegment(base);

    for (final value in [responseText, base, extracted, replaceSingleQuotes(base), replaceSingleQuotes(extracted)]) {
      candidates.add(removeTrailingCommas(value.trim()));
    }

    return candidates.toList();
  }

  String _extractJsonSegment(String responseText) {
    final firstBracket = responseText.indexOf('[');
    final lastBracket = responseText.lastIndexOf(']');
    if (firstBracket >= 0 && lastBracket > firstBracket) {
      return responseText.substring(firstBracket, lastBracket + 1);
    }

    final firstBrace = responseText.indexOf('{');
    final lastBrace = responseText.lastIndexOf('}');
    if (firstBrace >= 0 && lastBrace > firstBrace) {
      return responseText.substring(firstBrace, lastBrace + 1);
    }

    return responseText;
  }
}