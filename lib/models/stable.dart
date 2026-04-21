class Stable {
  final String id;
  final String name;
  final String location;
  final String description;
  final String image;
  final String phone;
  final String capacity;

  Stable({
    required this.id,
    required this.name,
    required this.location,
    required this.description,
    required this.image,
    required this.phone,
    required this.capacity,
  });

  factory Stable.fromJson(Map<String, dynamic> json) {
    return Stable(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      location: json['location'] ?? '',
      description: json['description'] ?? '',
      image: json['image'] ?? '',
      phone: json['phone'] ?? '',
      capacity: json['capacity'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'description': description,
      'image': image,
      'phone': phone,
      'capacity': capacity,
    };
  }
}
