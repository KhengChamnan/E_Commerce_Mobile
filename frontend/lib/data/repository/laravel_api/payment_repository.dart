import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/data/network/api_constant.dart';
import 'package:frontend/data/repository/laravel_api/auth_api_repository.dart';
import 'package:frontend/data/repository/payment_repository_interface.dart';

class PaymentRepository implements PaymentRepositoryInterface {
  final http.Client client;
  final LaravelAuthRepository _authRepository;

  PaymentRepository({
    http.Client? client,
    LaravelAuthRepository? authRepository,
  }) : client = client ?? http.Client(),
       _authRepository = authRepository ?? LaravelAuthRepository(
         secureStorage: const FlutterSecureStorage(),
       );

  /// Creates a payment intent on the server and returns the client secret
  @override
  Future<Map<String, dynamic>> createPaymentIntent(int orderId) async {
    try {
      // Use GET request with orderId in the URL
      final response = await client.get(
        Uri.parse('${ApiConstant.createPaymentIntent}/$orderId'),
        headers: await _getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          return {
            'success': true,
            'clientSecret': jsonResponse['client_secret'],
            'paymentIntentId': jsonResponse['payment_intent_id'],
            'publishableKey': jsonResponse['publishable_key'],
          };
        } else {
          return {
            'success': false,
            'message': jsonResponse['message'] ?? 'Failed to create payment intent',
          };
        }
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error connecting to payment service: $e',
      };
    }
  }

  /// Get auth headers for API requests
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _authRepository.getValidToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// Confirms a payment intent on the server and returns the payment intent
  Future<Map<String, dynamic>> confirmPayment(String paymentIntentId) async {
    try {
      final response = await client.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents/$paymentIntentId/confirm'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Basic ' + base64Encode(utf8.encode('${ApiConstant.stripeSecretKey}:')),
        },
        // If you need to send any additional parameters with the confirmation
        // body: 'return_url=https://yourdomain.com/success',
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return {
          'success': true,
          'paymentIntent': jsonResponse,
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['error']?['message'] ?? 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error confirming payment: $e',
      };
    }
  }
}