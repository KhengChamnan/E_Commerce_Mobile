import 'package:frontend/models/cart_item.dart';

class Cart {
  final int? id;
  final int? userId;
  final List<CartItem> items;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Cart({
    this.id,
    this.userId,
    this.items = const [],
    this.createdAt,
    this.updatedAt,
  });

  // Add a copy with method for immutability
  Cart copyWith({
    int? id,
    int? userId,
    List<CartItem>? items,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Cart(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Total price calculation
double get totalPrice {
  return items.fold(0, (total, item) => total + item.totalPrice);
}

  // Item count
  int get itemCount {
    return items.fold(0, (total, item) => total + item.quantity);
  }

  @override
  String toString() {
    return 'Cart(id: $id, userId: $userId, items: $items, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}