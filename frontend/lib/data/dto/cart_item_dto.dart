import 'package:frontend/models/cart_item.dart';
import 'package:frontend/data/dto/product_dto.dart';

class CartItemDTO {
  static CartItem fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      cartId: json['cart_id'] ?? 0,
      productId: json['product_id'],
      quantity: json['quantity'],
      product: json['product'] != null 
          ? ProductDTO.fromJson(json['product'])
          : null,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
    );
  }

  static Map<String, dynamic> toJson(CartItem cartItem) {
    return {
      'id': cartItem.id,
      'cart_id': cartItem.cartId,
      'product_id': cartItem.productId,
      'quantity': cartItem.quantity,
      'created_at': cartItem.createdAt?.toIso8601String(),
      'updated_at': cartItem.updatedAt?.toIso8601String(),
    };
  }
  
  static List<CartItem> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => fromJson(json)).toList();
  }
}