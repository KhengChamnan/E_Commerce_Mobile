import '../../models/order_item.dart';
import '../../models/product.dart';
import 'product_dto.dart';

class OrderItemDTO {
  static OrderItem fromJson(Map<String, dynamic> json) {
    Product? productModel;
    if (json['product'] != null) {
      productModel = ProductDTO.fromJson(json['product']);
    }
    
    // Ensure product image is properly mapped
    if (productModel != null && json['product'] != null && json['product']['image'] != null) {
      productModel = productModel.copyWith(
        image: json['product']['image'].toString(),
      );
    }
    
    return OrderItem(
      id: json['id'] ?? 0,
      orderId: json['order_id'] ?? 0,
      productId: json['product_id'] ?? 0,
      productName: json['product_name'] ?? '',
      price: json['price'] != null ? double.parse(json['price'].toString()) : 0.0,
      quantity: json['quantity'] ?? 0,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : DateTime.now(),
      product: productModel,
    );
  }

  static Map<String, dynamic> toJson(OrderItem orderItem) {
    return {
      'id': orderItem.id,
      'order_id': orderItem.orderId,
      'product_id': orderItem.productId,
      'product_name': orderItem.productName,
      'price': orderItem.price,
      'quantity': orderItem.quantity,
    };
  }
  
  static List<OrderItem> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => fromJson(json)).toList();
  }
} 