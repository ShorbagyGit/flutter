class SlotModel {
  final String id;
  final String date;
  final String startTime;
  final String endTime;
  final String status;
  final double price;
  final String stableId;

  SlotModel({
    required this.id,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.price,
    required this.stableId,
  });

  factory SlotModel.fromJson(Map<String, dynamic> json) {
    return SlotModel(
      id: json['id']?.toString() ?? '',
      date: json['date']?.toString().trim() ?? '',
      startTime: json['startTime']?.toString().trim() ?? '',
      endTime: json['endTime']?.toString().trim() ?? '',
      status: json['status']?.toString().trim() ?? '',
      price: (json['price'] is int)
          ? (json['price'] as int).toDouble()
          : (json['price'] is String)
              ? double.tryParse(json['price']) ?? 0.0
              : (json['price'] as double?) ?? 0.0,
      stableId: json['stable']?['id']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'startTime': startTime,
      'endTime': endTime,
      'status': status,
      'price': price,
      'stable': {'id': stableId},
    };
  }
}
