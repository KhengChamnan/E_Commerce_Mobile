import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:frontend/data/repository/payment_repository_interface.dart';
import 'package:frontend/data/repository/laravel_api/payment_repository.dart';

/// Service to handle payment operations
class PaymentService {
  final PaymentRepositoryInterface _repository;
  final bool stripeInitialized;

  /// Creates a PaymentService with the given repository
  /// If no repository is provided, a default PaymentRepository is used
  PaymentService({
    PaymentRepositoryInterface? repository,
    this.stripeInitialized = false,
  }) : _repository = repository ?? PaymentRepository();

  /// Initialize the Stripe SDK (call this in main.dart)
  static Future<void> initialize(String publishableKey) async {
    WidgetsFlutterBinding.ensureInitialized();
    Stripe.publishableKey = publishableKey;
    await Stripe.instance.applySettings();
  }

  /// Process a payment with the given order ID
  Future<Map<String, dynamic>> createPaymentIntent({required int orderId}) async {
    try {
      // Check if Stripe is initialized
      if (!stripeInitialized) {
        return {
          'success': false,
          'message': 'Stripe is not initialized properly. Please try again later.',
        };
      }
      
      // Create a payment intent via the repository
      final result = await _repository.createPaymentIntent(orderId);
      
      // Validate the result
      if (result['success'] == true && result['clientSecret'] != null) {
        return result;
      } else {
        return {
          'success': false,
          'message': result['message'] ?? 'Failed to create payment intent',
        };
      }
    } catch (e) {
      // Return an error response
      return {
        'success': false,
        'message': 'Payment processing error: $e',
      };
    }
  }
}