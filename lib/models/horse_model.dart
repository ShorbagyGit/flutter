class HorseModel {
  final String id;
  final String name;
  final String age;
  final String image;
  final double price;
  final String status;
  final String stableId;

  HorseModel({
    required this.id,
    required this.name,
    required this.age,
    required this.image,
    required this.price,
    required this.status,
    required this.stableId,
  });

  factory HorseModel.fromJson(Map<String, dynamic> json) {
    String readImage(Map<String, dynamic> source) {
      final candidates = [
        source['image'],
        source['imageUrl'],
        source['image_url'],
      ];

      for (final candidate in candidates) {
        final value = candidate?.toString().trim() ?? '';
        if (value.isNotEmpty) {
          return value;
        }
      }

      return '';
    }

    double readPrice(dynamic value) {
      if (value is num) {
        return value.toDouble();
      }
      if (value is String && value.trim().isNotEmpty) {
        return double.tryParse(value) ?? 0.0;
      }
      return 0.0;
    }

    return HorseModel(
      id: json['id']?.toString() ?? '',
      name: (json['name'] ?? '').toString(),
      age: (json['age'] ?? '').toString(),
      image: readImage(json),
      price: readPrice(json['price']),
      status: (json['status'] ?? '').toString(),
      stableId: json['stable'] is Map<String, dynamic>
          ? (json['stable']['id'] ?? '').toString()
          : (json['stableId'] ?? json['stable_id'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'image': image,
      'price': price,
      'status': status,
      'stable': {'id': stableId},
    };
  }
}
