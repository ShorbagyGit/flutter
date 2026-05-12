import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/user_model.dart';

class SessionStorageService {
  SessionStorageService._();

  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const String _tokenKey = 'firebaseToken';
  static const String _userIdKey = 'userId';
  static const String _userEmailKey = 'userEmail';
  static const String _userNameKey = 'userName';
  static const String _userPhoneKey = 'userPhone';
  static const String _userImageKey = 'userImage';
  static const String _userRoleKey = 'userRole';

  static Future<void> saveSession({
    required String token,
    required UserModel user,
  }) async {
    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(key: _userIdKey, value: user.id);
    await _storage.write(key: _userEmailKey, value: user.email);
    await _storage.write(key: _userNameKey, value: user.name);
    await _storage.write(key: _userPhoneKey, value: user.phone);
    await _storage.write(key: _userImageKey, value: user.image ?? '');
    await _storage.write(key: _userRoleKey, value: user.role);
  }

  static Future<Map<String, String?>> readSession() async {
    return {
      _tokenKey: await _storage.read(key: _tokenKey),
      _userIdKey: await _storage.read(key: _userIdKey),
      _userEmailKey: await _storage.read(key: _userEmailKey),
      _userNameKey: await _storage.read(key: _userNameKey),
      _userPhoneKey: await _storage.read(key: _userPhoneKey),
      _userImageKey: await _storage.read(key: _userImageKey),
      _userRoleKey: await _storage.read(key: _userRoleKey),
    };
  }

  static Future<void> clearSession() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userIdKey);
    await _storage.delete(key: _userEmailKey);
    await _storage.delete(key: _userNameKey);
    await _storage.delete(key: _userPhoneKey);
    await _storage.delete(key: _userImageKey);
    await _storage.delete(key: _userRoleKey);
  }

  static UserModel? userFromSession(Map<String, String?> session) {
    final userId = session[_userIdKey] ?? '';
    final userEmail = session[_userEmailKey] ?? '';
    final userName = session[_userNameKey] ?? '';
    if (userId.isEmpty && userEmail.isEmpty && userName.isEmpty) {
      return null;
    }

    return UserModel(
      id: userId,
      name: userName,
      email: userEmail,
      phone: session[_userPhoneKey] ?? '',
      image: _emptyToNull(session[_userImageKey]),
      role: session[_userRoleKey] ?? '',
    );
  }

  static String? tokenFromSession(Map<String, String?> session) {
    return session[_tokenKey];
  }

  static String? _emptyToNull(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    return value;
  }
}
