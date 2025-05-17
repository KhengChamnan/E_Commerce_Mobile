import 'package:frontend/models/order.dart';

abstract class OrderRepository {
  /// Get all orders for the authenticated user
  Future<List<Order>> getOrders();
  
  /// Get a specific order by ID
  Future<Order> getOrderById(int orderId);
  
  /// Create a new order with shipping address and phone
  Future<Order> createOrder({
    required String shippingAddress,
    required String phone,
  });
  
  /// Update order status and payment status
  Future<Order> updateOrderStatus({
    required int orderId,
    required String status,
    required String paymentStatus,
    String? transactionId,
  });
}
