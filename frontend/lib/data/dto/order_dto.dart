import '../../models/order.dart';
import '../../models/order_item.dart';
import '../../models/user.dart';
import 'order_item_dto.dart';
import 'user_dto.dart';

class OrderDTO {
  // Create Model from JSON
  static Order fromJson(Map<String, dynamic> json) {
    List<OrderItem> orderItems = [];
    
    if (json['items'] != null) {
      orderItems = OrderItemDTO.fromJsonList(json['items']);
    }
    
    User? userModel;
    if (json['user'] != null) {
      userModel = UserDto.fromJson(json['user']);
    }

    return Order(
      id: json['id'] ?? 0,
      orderNumber: json['order_number'] ?? '',
      userId: json['user_id'] ?? 0,
      totalAmount: json['total_amount'] != null ? double.parse(json['total_amount'].toString()) : 0.0,
      shippingCost: json['shipping_cost'] != null ? double.parse(json['shipping_cost'].toString()) : 0.0,
      status: json['status'] ?? 'pending',
      paymentStatus: json['payment_status'] ?? 'pending',
      shippingAddress: json['shipping_address'] ?? '',
      phone: json['phone'] ?? '',
      transactionId: json['transaction_id'],
      items: orderItems,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : DateTime.now(),
      user: userModel,
    );
  }

  // Convert Model to JSON
  static Map<String, dynamic> toJson(Order order) {
    return {
      'id': order.id,
      'order_number': order.orderNumber,
      'user_id': order.userId,
      'total_amount': order.totalAmount,
      'shipping_cost': order.shippingCost,
      'status': order.status,
      'payment_status': order.paymentStatus,
      'shipping_address': order.shippingAddress,
      'phone': order.phone,
      'transaction_id': order.transactionId,
    };
  }
  
  // Convert a list of JSON to a list of models
  static List<Order> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => fromJson(json)).toList();
  }
} 