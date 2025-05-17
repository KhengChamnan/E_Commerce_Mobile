/// Abstract interface for payment repository
abstract class PaymentRepositoryInterface {
  /// Creates a payment intent on the server and returns the client secret
  Future<Map<String, dynamic>> createPaymentIntent(int orderId);
}