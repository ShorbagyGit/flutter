class ProductModel {
  final String id;
  final String title;
  final String description;
  final double price;
  final String phone;
  final String imageUrl;
  final String category;
  final String location;
  final String? userId;
  final String? userName;

  const ProductModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.phone,
    required this.imageUrl,
    required this.category,
    required this.location,
    this.userId,
    this.userName,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'];

    return ProductModel(
      id: json['id']?.toString() ?? '',
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      price: (json['price'] is num)
          ? (json['price'] as num).toDouble()
          : double.tryParse(json['price']?.toString() ?? '') ?? 0,
      phone: (json['phone'] ?? '').toString(),
      imageUrl: (json['imageUrl'] ?? '').toString(),
      category: (json['category'] ?? '').toString(),
      location: (json['location'] ?? '').toString(),
      userId: user is Map<String, dynamic> ? user['id']?.toString() : null,
      userName: user is Map<String, dynamic>
          ? (user['name'] ?? user['fullName'] ?? '').toString()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'title': title,
      'description': description,
      'price': price,
      'phone': phone,
      'imageUrl': imageUrl,
      'category': category,
      'location': location,
    };

    final parsedUserId = int.tryParse(userId ?? '');
    if (parsedUserId != null) {
      map['user'] = {'id': parsedUserId};
    }

    return map;
  }
}
