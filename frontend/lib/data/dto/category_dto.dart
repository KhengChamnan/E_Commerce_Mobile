import '../../models/category.dart';

class CategoryDTO {
  // Convert Category model to JSON
  static Map<String, dynamic> toJson(CategoryProduct category) {
    return {
      'id': category.id,
      'name': category.name,
      'description': category.description,
    };
  }
  
  // Create Category model from JSON
  static CategoryProduct fromJson(Map<String, dynamic> json) {
    return CategoryProduct(
      id: json['id'],
      name: json['name'],
      description: json['description'],
    );
  }

  // Convert a list of JSON maps to a list of Category objects
  static List<CategoryProduct> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => fromJson(json)).toList();
  }
}