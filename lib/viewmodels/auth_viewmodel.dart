import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/session_storage_service.dart';

class AuthViewModel extends ChangeNotifier {
  // Google sign-in still needs an OAuth client configured in Google Cloud.
  // Pass the server client ID at build time so native sign-in returns an ID token.
  static final String _googleServerClientId = const String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
    defaultValue: '',
  );

  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: const ['email', 'profile'],
    serverClientId:
        _googleServerClientId.isNotEmpty ? _googleServerClientId : null,
  );

  bool isLoading = false;
  String? error;
  UserModel? currentUser;
  String? firebaseToken;

  bool get isLoggedIn => currentUser != null;

  Future<bool> restoreSession() async {
    final session = await SessionStorageService.readSession();
    final token = SessionStorageService.tokenFromSession(session);
    final restoredUser = SessionStorageService.userFromSession(session);

    if (token == null || token.trim().isEmpty || restoredUser == null) {
      currentUser = null;
      firebaseToken = null;
      return false;
    }

    try {
      await ApiService.verifyFirebaseToken(token);
      currentUser = restoredUser;
      firebaseToken = token;
      return true;
    } catch (_) {
      await SessionStorageService.clearSession();
      currentUser = null;
      firebaseToken = null;
      return false;
    } finally {
      notifyListeners();
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final response = await ApiService.loginFirebaseUser({
        'email': email,
        'password': password,
      });

      return await _applySessionResponse(response.data, fallbackEmail: email);
    } on DioException catch (exception) {
      error = _resolveErrorMessage(exception);
      return false;
    } catch (_) {
      error = 'Something went wrong. Please try again.';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final response = await ApiService.registerFirebaseUser({
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
      });

      return await _applySessionResponse(
        response.data,
        fallbackEmail: email,
        fallbackName: name,
        fallbackPhone: phone,
      );
    } on DioException catch (exception) {
      error = _resolveErrorMessage(exception);
      return false;
    } catch (_) {
      error = 'Something went wrong. Please try again.';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> loginWithGoogle({
    required String idToken,
    String phone = '',
  }) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final response = await ApiService.googleSignInFirebase(
        idToken,
        phone.trim().isEmpty ? const {} : {'phone': phone.trim()},
      );
      return await _applySessionResponse(response.data);
    } on DioException catch (exception) {
      error = _resolveErrorMessage(exception);
      return false;
    } catch (_) {
      error = 'Something went wrong. Please try again.';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> loginWithGoogleNative({
    String phone = '',
  }) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        error = 'Google sign-in was cancelled.';
        return false;
      }

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      if (idToken == null || idToken.trim().isEmpty) {
        error = 'Google did not return a valid ID token. Set GOOGLE_SERVER_CLIENT_ID and make sure the OAuth client and SHA-1 are configured correctly.';
        return false;
      }

      final response = await ApiService.googleSignInFirebase(
        idToken,
        phone.trim().isEmpty ? const {} : {'phone': phone.trim()},
      );

      return await _applySessionResponse(response.data);
    } on DioException catch (exception) {
      error = _resolveErrorMessage(exception);
      return false;
    } on PlatformException catch (exception) {
      final details = exception.message?.trim();
      error = details == null || details.isEmpty
          ? 'Google sign-in failed on device. Please check Google Play Services and OAuth setup.'
          : 'Google sign-in failed: $details';
      debugPrint(
        '[AuthVM] Google native PlatformException: code=${exception.code}, message=${exception.message}, details=${exception.details}',
      );
      return false;
    } on Exception catch (exception, stackTrace) {
      error = 'Google sign-in failed before reaching backend: $exception';
      debugPrint('[AuthVM] Google native Exception: $exception');
      debugPrint('[AuthVM] Google native StackTrace: $stackTrace');
      return false;
    } catch (_) {
      error = 'Google sign-in failed before reaching backend.';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void logout() {
    currentUser = null;
    firebaseToken = null;
    error = null;
    unawaited(SessionStorageService.clearSession());
    unawaited(_googleSignIn.signOut());
    notifyListeners();
  }

  Future<bool> _applySessionResponse(
    dynamic responseData, {
    String fallbackEmail = '',
    String fallbackName = '',
    String fallbackPhone = '',
  }) async {
    final token = _readToken(responseData);
    final user = _readUser(responseData,
        fallbackEmail: fallbackEmail,
        fallbackName: fallbackName,
        fallbackPhone: fallbackPhone,
    );

    if (token == null || token.trim().isEmpty || user == null) {
      error = 'Invalid authentication response from server.';
      return false;
    }

    firebaseToken = token;
    currentUser = user;
    await SessionStorageService.saveSession(token: token, user: user);
    return true;
  }

  String? _readToken(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      for (final key in ['firebaseToken', 'token', 'accessToken', 'idToken']) {
        final value = responseData[key];
        if (value != null && value.toString().trim().isNotEmpty) {
          return value.toString();
        }
      }

      final nested = responseData['data'];
      if (nested is Map<String, dynamic>) {
        return _readToken(nested);
      }
    }

    if (responseData is String && responseData.trim().isNotEmpty) {
      return responseData.trim();
    }

    return null;
  }

  UserModel? _readUser(
    dynamic responseData, {
    required String fallbackEmail,
    required String fallbackName,
    required String fallbackPhone,
  }) {
    if (responseData is Map<String, dynamic>) {
      final userCandidate = responseData['user'];
      if (userCandidate is Map<String, dynamic>) {
        return UserModel.fromJson(userCandidate);
      }

      final nested = responseData['data'];
      if (nested is Map<String, dynamic>) {
        return _readUser(
          nested,
          fallbackEmail: fallbackEmail,
          fallbackName: fallbackName,
          fallbackPhone: fallbackPhone,
        );
      }

      if (responseData.containsKey('id') || responseData.containsKey('email')) {
        return UserModel.fromJson(responseData);
      }
    }

    if (fallbackEmail.isNotEmpty || fallbackName.isNotEmpty) {
      return UserModel(
        id: '',
        name: fallbackName,
        email: fallbackEmail,
        phone: fallbackPhone,
      );
    }

    return null;
  }

  String _resolveErrorMessage(DioException exception) {
    if (exception.type == DioExceptionType.connectionTimeout ||
        exception.type == DioExceptionType.receiveTimeout ||
        exception.type == DioExceptionType.sendTimeout ||
        exception.type == DioExceptionType.connectionError) {
      return 'Cannot reach backend at ${ApiService.baseUrl}. Please make sure the server is running and reachable from this device.';
    }

    final responseData = exception.response?.data;

    if (responseData is String && responseData.trim().isNotEmpty) {
      return responseData;
    }

    if (responseData is Map<String, dynamic>) {
      if (responseData['message'] != null) {
        return responseData['message'].toString();
      }
      if (responseData['error'] != null) {
        return responseData['error'].toString();
      }
    }

    return exception.message ?? 'Request failed. Please try again.';
  }
}
