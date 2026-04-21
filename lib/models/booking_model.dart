class BookingModel {
  final String id;
  final String bookingDate;
  final String status;
  final String date;
  final String startTime;
  final String endTime;
  final double price;
  final int paymobOrderId;
  final String userId;
  final String stableId;
  final String slotId;

  BookingModel({
    required this.id,
    required this.bookingDate,
    required this.status,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.price,
    required this.paymobOrderId,
    required this.userId,
    required this.stableId,
    required this.slotId,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    String readString(List<String> keys, {String fallback = ''}) {
      for (final key in keys) {
        final value = json[key];
        if (value != null && value.toString().trim().isNotEmpty) {
          return value.toString();
        }
      }
      return fallback;
    }

    double readDouble(List<String> keys, {double fallback = 0.0}) {
      for (final key in keys) {
        final value = json[key];
        if (value is num) {
          return value.toDouble();
        }
        if (value is String && value.trim().isNotEmpty) {
          final parsed = double.tryParse(value);
          if (parsed != null) return parsed;
        }
      }
      return fallback;
    }

    String readNestedId(List<String> keys) {
      for (final key in keys) {
        final value = json[key];
        if (value is Map<String, dynamic>) {
          final nestedId = value['id'] ?? value['userId'] ?? value['stableId'] ?? value['slotId'];
          if (nestedId != null && nestedId.toString().trim().isNotEmpty) {
            return nestedId.toString();
          }
        }
        if (value != null && value.toString().trim().isNotEmpty) {
          return value.toString();
        }
      }
      return '';
    }

    return BookingModel(
      id: readString(['id', 'bookingId']),
      bookingDate: readString(['bookingDate', 'booking_date']),
      status: readString(['status']),
      date: readString(['date', 'booking_date']),
      startTime: readString(['startTime', 'start_time']),
      endTime: readString(['endTime', 'end_time']),
      price: readDouble(['price']),
      paymobOrderId: (json['paymobOrderId'] ?? json['paymob_order_id'] ?? 0) is int
          ? (json['paymobOrderId'] ?? json['paymob_order_id'] ?? 0) as int
          : int.tryParse((json['paymobOrderId'] ?? json['paymob_order_id'] ?? 0).toString()) ?? 0,
      userId: readNestedId(['user', 'userId', 'user_id']),
      stableId: readNestedId(['stable', 'stableId', 'stable_id']),
      slotId: readNestedId(['slot', 'slotId', 'slot_id']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookingDate': bookingDate,
      'status': status,
      'date': date,
      'startTime': startTime,
      'endTime': endTime,
      'price': price,
      'paymobOrderId': paymobOrderId,
      'user': {'id': userId},
      'stable': {'id': stableId},
      'slot': {'id': slotId},
    };
  }
}
