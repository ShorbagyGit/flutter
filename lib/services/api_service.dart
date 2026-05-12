import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'session_storage_service.dart';

class ApiService {
// -------------------- BASE API --------------------
  static const String _configuredBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
  );

  static final Dio api = _createApi();

  static Dio _createApi() {
    final dio = Dio(
      BaseOptions(
        baseUrl: _resolveBaseUrl(_configuredBaseUrl),
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final session = await SessionStorageService.readSession();
          final token = SessionStorageService.tokenFromSession(session);

          if (token != null && token.trim().isNotEmpty) {
            options.headers.putIfAbsent(
              'Authorization',
              () => 'Bearer ${token.trim()}',
            );
          }

          handler.next(options);
        },
      ),
    );

    if (!kReleaseMode) {
      dio.interceptors.add(
        LogInterceptor(
          request: true,
          requestHeader: true,
          requestBody: true,
          responseHeader: false,
          responseBody: true,
          error: true,
          logPrint: (object) => debugPrint(object.toString()),
        ),
      );
    }

    return dio;
  }

  static String get baseUrl => api.options.baseUrl;

  static String _resolveBaseUrl(String configuredBaseUrl) {
    final value = configuredBaseUrl.trim().isNotEmpty
      ? configuredBaseUrl.trim()
        : (kReleaseMode ? 'https://api.example.com' : 'http://localhost:8080');

    final normalized = _normalizeLocalHost(value);

    if (kReleaseMode && normalized.startsWith('http://')) {
      throw StateError('API_BASE_URL must use HTTPS in release builds.');
    }

    return normalized;
  }

  static String resolveMediaUrl(String? url) {
    final value = url?.trim() ?? '';
    if (value.isEmpty) return '';

    final resolved = value.startsWith('http://') || value.startsWith('https://')
        ? value
        : Uri.parse(api.options.baseUrl).resolve(
            value.startsWith('/') ? value.substring(1) : value,
          ).toString();

    return _normalizeLocalHost(resolved);
  }

  static String _normalizeLocalHost(String url) {
    if (kIsWeb) return url;

    return url;
  }

// -------------------- STABLE APIs --------------------
  static Future getAllStables() => api.get("/Stable/getall");

  static Future getStableById(String id) => api.get("/Stable/$id");

  static Future saveStable(Map<String, dynamic> stable) =>
      api.post("/Stable/save", data: stable);

  static Future deleteStable(String id) =>
      api.delete("/Stable/delete/$id");

// -------------------- HORSE APIs --------------------
  static Future getAllHorses() => api.get("/Horse/getall");

  static Future getHorseById(String id) => api.get("/Horse/$id");

  static Future getHorsesByStable(String stableId) =>
      api.get("/Horse/stable/$stableId");

  static Future searchHorsesByName(String name) =>
      api.get("/Horse/search/$name");

// -------------------- SLOT APIs --------------------
  static Future getAllSlots() => api.get("/Slot/getall");

  static Future getSlotById(String id) => api.get("/Slot/$id");

  static Future getSlotsByHorse(String horseId) =>
      api.get("/Slot/horse/$horseId");

  static Future getAvailableSlotsByHorse(String horseId) =>
      api.get("/Slot/horse/$horseId/available");

  static Future getSlotsByDate(String date) => api.get("/Slot/date/$date");

  static Future getAvailableSlotsByDate(String date) =>
      api.get("/Slot/available/date/$date");

  static Future saveSlot(Map<String, dynamic> slot) =>
      api.post("/Slot/save", data: slot);

  static Future updateSlot(String id, Map<String, dynamic> slot) =>
      api.put("/Slot/update/$id", data: slot);

  static Future deleteSlot(String id) =>
      api.delete("/Slot/delete/$id");

// -------------------- BOOKING APIs --------------------
  static Future getAllBookings() => api.get(
        "/Booking/getall",
        options: Options(responseType: ResponseType.plain),
      );

  static Future getBookingById(String id) => api.get("/Booking/$id");

  static Future getBookingsByUser(String userId) =>
      api.get(
        "/Booking/user/$userId",
        options: Options(responseType: ResponseType.plain),
      );

  static Future getBookingsByDate(String date) => api.get("/Booking/date/$date");

  static Future getBookingsByStatus(String status) =>
      api.get("/Booking/status/$status");

  static Future saveBooking(Map<String, dynamic> booking) =>
      api.post("/Booking/save", data: booking);

  static Future bookSlot({
    required String slotId,
    required String userId,
    String? date,
  }) =>
      api.post(
        "/Booking/bookSlot",
        queryParameters: {
          "slotId": slotId,
          "userId": userId,
          if (date != null && date.trim().isNotEmpty) "date": date.trim(),
        },
      );

  static Future cancelBooking(String bookingId) =>
      api.post("/Booking/cancel/$bookingId");

  static Future createPayment(String bookingId) =>
      api.post("/payments/create/$bookingId");

  static Future deleteBooking(String id) =>
      api.delete("/Booking/delete/$id");

// -------------------- USER APIs --------------------
  static Future getAllUsers() => api.get("/User/getall");

  static Future getUserById(String id) => api.get("/User/$id");

  static Future saveUser(Map<String, dynamic> user) =>
      api.post("/User/save", data: user);

  static Future deleteUser(String id) =>
      api.delete("/User/delete/$id");

  // -------------------- AUTH APIs --------------------
  static Future registerFirebaseUser(Map<String, dynamic> user) {
    return api.post(
      "/User/firebase/register",
      data: user,
    );
  }

  static Future loginFirebaseUser(Map<String, dynamic> user) {
    return api.post(
      "/User/firebase/login",
      data: user,
    );
  }

  static Future googleSignInFirebase(String idToken, Map<String, dynamic> body) {
    return api.post(
      "/User/firebase/google-signin",
      queryParameters: {'idToken': idToken},
      data: body,
    );
  }

  static Future verifyFirebaseToken(String token) {
    return api.post(
      "/User/firebase/verify-token",
      queryParameters: {'token': token},
    );
  }

// -------------------- SEARCH APIs --------------------
  static Future searchStablesByLocation(String location) =>
      api.get(
        "/Search/location",
        queryParameters: {'location': location},
      );

  static Future searchStablesByName(String name) =>
      api.get(
        "/Search/name",
        queryParameters: {'name': name},
      );

  // -------------------- AUTH APIs --------------------
static Future registerUser(Map<String, dynamic> user) {
  return api.post(
    "/User/register",
    data: user,
  );
}

static Future loginUser(Map<String, dynamic> user) {
  return api.post(
    "/User/login",
    data: user,
  );
}

// -------------------- MARKETPLACE APIs --------------------
static Future getMarketplaceProducts() => api.get("/Marketplace/getall");

static Future getMarketplaceProductById(String id) =>
    api.get("/Marketplace/$id");

static Future getProductsByUserId(String userId) =>
    api.get("/Marketplace/user/$userId");

static Future saveMarketplaceProduct(Map<String, dynamic> product) =>
    api.post("/Marketplace/save", data: product);

static Future deleteMarketplaceProduct(String id) =>
    api.delete("/Marketplace/delete/$id");
}