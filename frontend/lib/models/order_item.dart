import 'product.dart';

class OrderItem {
  final int id;
  final int orderId;
  final int productId;
  final String productName;
  final double price;
  final int quantity;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Product? product;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.createdAt,
    required this.updatedAt,
    this.product,
  });

  // Calculate subtotal for this item
  double get subtotal => price * quantity;

  OrderItem copyWith({
    int? id,
    int? orderId,
    int? productId,
    String? productName,
    double? price,
    int? quantity,
    DateTime? createdAt,
    DateTime? updatedAt,
    Product? product,
  }) {
    return OrderItem(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      product: product ?? this.product,
    );
  }

  @override
  String toString() {
    return 'OrderItem(id: $id, productName: $productName, price: $price, quantity: $quantity)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is OrderItem &&
      other.id == id &&
      other.productId == productId;
  }

  @override
  int get hashCode => id.hashCode ^ productId.hashCode;
} 