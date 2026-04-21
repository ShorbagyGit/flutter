class UserModel {
	final String id;
	final String name;
	final String email;
	final String phone;
	final String? image;
	final String role;
	final List<Map<String, dynamic>> products;

	const UserModel({
		required this.id,
		required this.name,
		required this.email,
		this.phone = '',
		this.image,
		this.role = '',
		this.products = const [],
	});

	factory UserModel.fromJson(Map<String, dynamic> json) {
		final nestedUser = json['user'];
		final nestedData = json['data'];

		if (nestedUser is Map<String, dynamic>) {
			return UserModel(
				id: _readId(nestedUser),
				name: _readName(nestedUser),
				email: _readEmail(nestedUser),
			);
		}

		if (nestedData is Map<String, dynamic>) {
			return UserModel(
				id: _readId(nestedData),
				name: _readName(nestedData),
				email: _readEmail(nestedData),
			);
		}

		return UserModel(
			id: _readId(json),
			name: _readName(json),
			email: _readEmail(json),
			phone: _readPhone(json),
			image: json['image']?.toString(),
			role: (json['role'] ?? '').toString(),
			products: _readProducts(json['products']),
		);
	}
}

String _readId(Map<String, dynamic> json) {
	return json['id']?.toString() ??
			json['userId']?.toString() ??
			json['user_id']?.toString() ??
			json['_id']?.toString() ??
			'';
}

String _readName(Map<String, dynamic> json) {
	return (json['name'] ?? json['fullName'] ?? json['username'] ?? json['userName'] ?? '').toString();
}

String _readEmail(Map<String, dynamic> json) {
	return (json['email'] ?? json['userEmail'] ?? '').toString();
}

String _readPhone(Map<String, dynamic> json) {
	return (json['phone'] ?? json['userPhone'] ?? '').toString();
}

List<Map<String, dynamic>> _readProducts(dynamic value) {
	if (value is List) {
		return value
				.whereType<Map>()
				.map((item) => Map<String, dynamic>.from(item))
				.toList();
	}

	return const [];
}
