import 'order_item.dart';
import 'user.dart';

class Order {
  final int id;
  final String orderNumber;
  final int userId;
  final double totalAmount;
  final double shippingCost;
  final String status;
  final String paymentStatus;
  final String shippingAddress;
  final String phone;
  final String? transactionId;
  final List<OrderItem> items;
  final DateTime createdAt;
  final DateTime updatedAt;
  final User? user;

  Order({
    required this.id,
    required this.orderNumber,
    required this.userId,
    required this.totalAmount,
    required this.shippingCost,
    required this.status,
    required this.paymentStatus,
    required this.shippingAddress,
    required this.phone,
    this.transactionId,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
    this.user,
  });

  Order copyWith({
    int? id,
    String? orderNumber,
    int? userId,
    double? totalAmount,
    double? shippingCost,
    String? status,
    String? paymentStatus,
    String? shippingAddress,
    String? phone,
    String? transactionId,
    List<OrderItem>? items,
    DateTime? createdAt,
    DateTime? updatedAt,
    User? user,
  }) {
    return Order(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      userId: userId ?? this.userId,
      totalAmount: totalAmount ?? this.totalAmount,
      shippingCost: shippingCost ?? this.shippingCost,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      phone: phone ?? this.phone,
      transactionId: transactionId ?? this.transactionId,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      user: user ?? this.user,
    );
  }

  @override
  String toString() {
    return 'Order(id: $id, orderNumber: $orderNumber, totalAmount: $totalAmount, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is Order &&
      other.id == id &&
      other.orderNumber == orderNumber;
  }

  @override
  int get hashCode => id.hashCode ^ orderNumber.hashCode;
} 