import 'package:frontend/models/product.dart';

class CartItem {
  final int? id;
  final int cartId;
  final int productId;
  final int quantity;
  final Product? product; // For relationship loading
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CartItem({
    this.id,
    required this.cartId,
    required this.productId,
    required this.quantity,
    this.product,
    this.createdAt,
    this.updatedAt,
  });

  // Add a copy with method for immutability
  CartItem copyWith({
    int? id,
    int? cartId,
    int? productId,
    int? quantity,
    Product? product,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CartItem(
      id: id ?? this.id,
      cartId: cartId ?? this.cartId,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      product: product ?? this.product,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Calculate total price for this item
  double get totalPrice => product != null ? product!.price * quantity : 0;

  @override
  String toString() {
    return 'CartItem(id: $id, cartId: $cartId, productId: $productId, quantity: $quantity, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}