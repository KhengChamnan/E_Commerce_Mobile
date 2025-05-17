import 'dart:convert';
import 'package:frontend/data/network/api_constant.dart';
import 'package:frontend/data/repository/cart_repository.dart';
import 'package:frontend/models/cart.dart';
import 'package:frontend/data/dto/cart_dto.dart';
import 'package:frontend/data/repository/laravel_api/auth_api_repository.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LaravelCartRepository implements CartRepository {
  final http.Client client;
  final LaravelAuthRepository _authRepository;

  LaravelCartRepository({
    http.Client? client,
    LaravelAuthRepository? authRepository,
  }) : client = client ?? http.Client(),
       _authRepository = authRepository ?? LaravelAuthRepository(
         secureStorage: const FlutterSecureStorage(),
       );

  @override
  Future<Cart> getCart() async {
    final response = await client.get(
      Uri.parse(ApiConstant.getCart),
      headers: await _getAuthHeaders(),
    );
    
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['status'] == true && jsonResponse.containsKey('cart')) {
        return CartDTO.fromJson(jsonResponse['cart']);
      } else {
        throw Exception('Failed to load cart: ${jsonResponse['message'] ?? 'Unknown error'}');
      }
    } else {
      throw Exception('Failed to load cart: ${response.reasonPhrase}');
    }
  }

  @override
  Future<bool> addToCart({required int productId, required int quantity}) async {
    final response = await client.post(
      Uri.parse(ApiConstant.addToCart),
      headers: await _getAuthHeaders(),
      body: {
        'product_id': productId.toString(),
        'quantity': quantity.toString(),
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return jsonResponse['status'] == true;
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to add item to cart');
    }
  }

  @override
  Future<bool> updateCartItem({required int cartItemId, required int quantity}) async {
    final endpoint = ApiConstant.updateCartItem.replaceAll('{id}', cartItemId.toString());
    
    final response = await client.put(
      Uri.parse(endpoint),
      headers: await _getAuthHeaders(),
      body: {
        'quantity': quantity.toString(),
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return jsonResponse['status'] == true;
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to update cart item');
    }
  }

  @override
  Future<bool> removeCartItem(int cartItemId) async {
    final endpoint = ApiConstant.removeCartItem.replaceAll('{id}', cartItemId.toString());
    
    final response = await client.delete(
      Uri.parse(endpoint),
      headers: await _getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return jsonResponse['status'] == true;
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to remove cart item');
    }
  }

  @override
  Future<bool> clearCart() async {
    final response = await client.delete(
      Uri.parse(ApiConstant.clearCart),
      headers: await _getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return jsonResponse['status'] == true;
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to clear cart');
    }
  }

  // Helper method to get authenticated headers with token from auth repository
  Future<Map<String, String>> _getAuthHeaders() async {
    // Get token from the auth repository
    final token = await _authRepository.getValidToken();
    
    if (token == null) {
      throw Exception('Authentication token not available. Please login first.');
    }
    
    return {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
}