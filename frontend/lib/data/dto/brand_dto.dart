import '../../models/brands.dart';

class BrandDTO {
  // Convert Brand instance to JSON map for API requests
  static Map<String, dynamic> toJson(Brand brand) {
    return {
      'id': brand.id,
      'name': brand.name,
      'description': brand.description,
      'logo': brand.logo,
    };
  }

  // Create Brand instance from JSON map received from API
  static Brand fromJson(Map<String, dynamic> json) {
    return Brand(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      logo: json['logo'],
    );
  }

  // Convert a list of JSON maps to a list of Brand objects
  static List<Brand> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => fromJson(json)).toList();
  }
}