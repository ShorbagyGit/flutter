import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiService {
// -------------------- BASE API --------------------
  static final Dio api = Dio(
    BaseOptions(
      baseUrl: "http://localhost:8080",
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  );

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

    if (defaultTargetPlatform == TargetPlatform.android) {
      return url.replaceFirst('://localhost', '://10.0.2.2');
    }

    return url;
  }

// -------------------- STABLE APIs --------------------
  static Future getAllStables() => api.get("/Stable/getall");

  static Future getStableById(String id) => api.get("/Stable/$id");

  static Future saveStable(Map<String, dynamic> stable) =>
      api.post("/Stable/save", data: stable);

  static Future deleteStable(String id) =>
      api.delete("/Stable/delete/$id");

// -------------------- SLOT APIs --------------------
  static Future getAllSlots() => api.get("/Slot/getall");

  static Future getSlotById(String id) => api.get("/Slot/$id");

  static Future saveSlot(Map<String, dynamic> slot) =>
      api.post("/Slot/save", data: slot);

  static Future deleteSlot(String id) =>
      api.delete("/Slot/delete/$id");

  static Future getSlotsByStable(String stableId) =>
      api.get("/Slot/stable/$stableId");

  static Future getSlotsByStatus(String status) =>
      api.get("/Slot/status/$status");

// -------------------- BOOKING APIs --------------------
  static Future getAllBookings() => api.get(
        "/Booking/getall",
        options: Options(responseType: ResponseType.plain),
      );

  static Future getBookingsByUser(String userId) =>
      api.get(
        "/Booking/user/$userId",
        options: Options(responseType: ResponseType.plain),
      );

  static Future getBookingById(String id) => api.get("/Booking/$id");

  static Future bookSlot({
    required String slotId,
    required String userId,
    required String date,
  }) =>
      api.post(
        "/Booking/bookSlot",
        queryParameters: {
          "slotId": slotId,
          "userId": userId,
          "date": date,
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

// -------------------- SEARCH APIs --------------------
  static Future searchStablesByLocation(String location) =>
      api.get("/Search/location?location=$location");

  static Future searchStablesByName(String name) =>
      api.get("/Search/name?name=$name");

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