import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../services/api_service.dart';

class AuthViewModel extends ChangeNotifier {
  bool isLoading = false;
  String? error;
  UserModel? currentUser;

  bool get isLoggedIn => currentUser != null;

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final response = await ApiService.loginUser({
        'email': email,
        'password': password,
      });

      final data = response.data;
      if (data is Map<String, dynamic>) {
        currentUser = UserModel.fromJson(data);
      } else {
        currentUser = UserModel(id: '', name: '', email: email);
      }

      return true;
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
      await ApiService.registerUser({
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
      });
      return true;
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

  void logout() {
    currentUser = null;
    error = null;
    notifyListeners();
  }

  String _resolveErrorMessage(DioException exception) {
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
