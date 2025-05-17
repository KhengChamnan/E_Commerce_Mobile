import 'package:frontend/models/cart.dart';
import 'package:frontend/data/dto/cart_item_dto.dart';

class CartDTO {
  static Cart fromJson(Map<String, dynamic> json) {
    return Cart(
      id: json['id'],
      userId: json['user_id'],
      items: json['items'] != null 
          ? (json['items'] as List).map((item) => CartItemDTO.fromJson(item)).toList() 
          : [],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
    );
  }

  static Map<String, dynamic> toJson(Cart cart) {
    return {
      'id': cart.id,
      'user_id': cart.userId,
      'items': cart.items.map((item) => CartItemDTO.toJson(item)).toList(),
      'created_at': cart.createdAt?.toIso8601String(),
      'updated_at': cart.updatedAt?.toIso8601String(),
    };
  }
  
  static List<Cart> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => fromJson(json)).toList();
  }
}