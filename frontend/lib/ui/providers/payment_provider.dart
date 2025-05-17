import 'package:flutter/material.dart';
import 'package:frontend/data/services/payment_service.dart';
import 'package:frontend/ui/providers/async_value.dart';

/// Provider to manage payment state
class PaymentProvider with ChangeNotifier {
  final PaymentService _paymentService;
  
  // Payment processing state
  AsyncValue<Map<String, dynamic>> _paymentState = const AsyncValue.initial();
  AsyncValue<Map<String, dynamic>> get paymentState => _paymentState;
  
  // Constructor with optional service injection for testing
  PaymentProvider({PaymentService? paymentService}) 
    : _paymentService = paymentService ?? PaymentService();
  
  /// Process a payment with Stripe
  Future<void> makePayment({required int orderId}) async {
    try {
      // Set state to loading
      _paymentState = const AsyncValue.loading();
      notifyListeners();
      
      // Process the payment
      final result = await _paymentService.createPaymentIntent(orderId: orderId);
      
      // Update state based on result
      if (result['success'] == true) {
        _paymentState = AsyncValue.success(result);
      } else {
        _paymentState = AsyncValue.error(result['message'] ?? 'Payment failed');
      }
    } catch (e) {
      // Handle any unexpected errors
      _paymentState = AsyncValue.error('Payment error: ${e.toString()}');
    } finally {
      notifyListeners();
    }
  }
  
  /// Reset payment state
  void resetPaymentState() {
    _paymentState = const AsyncValue.initial();
    notifyListeners();
  }
}