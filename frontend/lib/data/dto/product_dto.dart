import 'package:frontend/models/product.dart';

class ProductDTO {
  static Product fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: double.parse(json['price'].toString()),
      image: json['image'],
      categoryId: json['category_id'],
      brandId: json['brand_id'],
      category: json['category'],
      brand: json['brand'],
    );
  }

  static Map<String, dynamic> toJson(Product product) {
    return {
      'id': product.id,
      'name': product.name,
      'description': product.description,
      'price': product.price,
      'image': product.image,
      'category_id': product.categoryId,
      'brand_id': product.brandId,
    };
  }
  
  static List<Product> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => fromJson(json)).toList();
  }
}