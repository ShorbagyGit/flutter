import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../models/product_model.dart';
import '../services/api_service.dart';

class MarketplaceViewModel extends ChangeNotifier {
  bool isLoading = false;
  bool isSubmitting = false;
  String? error;
  List<ProductModel> products = [];
  List<ProductModel> userProducts = [];

  Future<void> loadProducts() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final response = await ApiService.getMarketplaceProducts();
      products = (response.data as List)
          .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (exception) {
      error = _resolveErrorMessage(exception);
      products = [];
    } catch (_) {
      error = 'Failed to load marketplace products.';
      products = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addProduct({
    required String title,
    required String description,
    required double price,
    required String phone,
    required String imageUrl,
    required String category,
    required String location,
    String? userId,
  }) async {
    isSubmitting = true;
    error = null;
    notifyListeners();

    try {
      final product = ProductModel(
        id: '',
        title: title,
        description: description,
        price: price,
        phone: phone,
        imageUrl: imageUrl,
        category: category,
        location: location,
        userId: userId,
      );

      await ApiService.saveMarketplaceProduct(product.toJson());
      await loadProducts();
      return true;
    } on DioException catch (exception) {
      error = _resolveErrorMessage(exception);
      return false;
    } catch (_) {
      error = 'Failed to add product. Please try again.';
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> loadUserProducts(String userId) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final response = await ApiService.getProductsByUserId(userId);
      userProducts = (response.data as List)
          .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (exception) {
      error = _resolveErrorMessage(exception);
      userProducts = [];
    } catch (_) {
      error = 'Failed to load your products.';
      userProducts = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteUserProduct(String productId) async {
    try {
      await ApiService.deleteMarketplaceProduct(productId);
      userProducts.removeWhere((product) => product.id == productId);
      notifyListeners();
      return true;
    } on DioException catch (exception) {
      error = _resolveErrorMessage(exception);
      return false;
    } catch (_) {
      error = 'Failed to delete product. Please try again.';
      return false;
    }
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
