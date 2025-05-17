import 'dart:convert';
import 'package:frontend/data/network/api_constant.dart';
import 'package:frontend/data/repository/order_repository.dart';
import 'package:frontend/models/order.dart';
import 'package:frontend/data/dto/order_dto.dart';
import 'package:frontend/data/repository/laravel_api/auth_api_repository.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LaravelOrderRepository implements OrderRepository {
  final http.Client client;
  final LaravelAuthRepository _authRepository;

  LaravelOrderRepository({
    http.Client? client,
    LaravelAuthRepository? authRepository,
  }) : client = client ?? http.Client(),
       _authRepository = authRepository ?? LaravelAuthRepository(
         secureStorage: const FlutterSecureStorage(),
       );

  @override
  Future<List<Order>> getOrders() async {
    final response = await client.get(
      Uri.parse(ApiConstant.orders),
      headers: await _getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['status'] == true && jsonResponse.containsKey('orders')) {
        return OrderDTO.fromJsonList(jsonResponse['orders']);
      } else {
        throw Exception('Failed to load orders: ${jsonResponse['message'] ?? 'Unknown error'}');
      }
    } else {
      throw Exception('Failed to load orders: ${response.reasonPhrase}');
    }
  }

  @override
  Future<Order> getOrderById(int orderId) async {
    final endpoint = ApiConstant.orderDetail.replaceAll('{id}', orderId.toString());
    
    final response = await client.get(
      Uri.parse(endpoint),
      headers: await _getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['status'] == true && jsonResponse.containsKey('order')) {
        return OrderDTO.fromJson(jsonResponse['order']);
      } else {
        throw Exception('Failed to load order: ${jsonResponse['message'] ?? 'Unknown error'}');
      }
    } else {
      throw Exception('Failed to load order: ${response.reasonPhrase}');
    }
  }

  @override
  Future<Order> createOrder({
    required String shippingAddress,
    required String phone,
  }) async {
    final response = await client.post(
      Uri.parse(ApiConstant.createOrder),
      headers: await _getAuthHeaders(),
      body: json.encode({
        'shipping_address': shippingAddress,
        'phone': phone,
      }),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['status'] == true && jsonResponse.containsKey('order')) {
        return OrderDTO.fromJson(jsonResponse['order']);
      } else {
        throw Exception('Failed to create order: ${jsonResponse['message'] ?? 'Unknown error'}');
      }
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to create order');
    }
  }
  
  @override
  Future<Order> updateOrderStatus({
    required int orderId,
    required String status,
    required String paymentStatus,
    String? transactionId,
  }) async {
    final endpoint = ApiConstant.updateOrderStatus.replaceAll('{id}', orderId.toString());
    
    final body = {
      'status': status,
      'payment_status': paymentStatus,
    };
    
    if (transactionId != null) {
      body['transaction_id'] = transactionId;
    }
    
    final response = await client.patch(
      Uri.parse(endpoint),
      headers: await _getAuthHeaders(),
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['success'] == true && jsonResponse.containsKey('order')) {
        return OrderDTO.fromJson(jsonResponse['order']);
      } else {
        throw Exception('Failed to update order status: ${jsonResponse['message'] ?? 'Unknown error'}');
      }
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to update order status');
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
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
}
