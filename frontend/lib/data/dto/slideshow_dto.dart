import 'package:frontend/models/slideshow.dart';

class SlideShowDTO {
  static Slideshow fromJson(Map<String, dynamic> json) {
    return Slideshow(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: double.parse((json['price'] ?? 0).toString()),
      image: json['image'] ?? '',
      productId: json['product_id'] ?? 0,
      enable: json['enable'] == 1 || json['enable'] == true,
      link: json['link'],
      ssorder: json['ssorder'],
    );
  }

  static Map<String, dynamic> toJson(Slideshow slideshow) {
    return {
      'id': slideshow.id,
      'name': slideshow.name,
      'description': slideshow.description,
      'price': slideshow.price,
      'image': slideshow.image,
      'product_id': slideshow.productId,
      'enable': slideshow.enable,
      'link': slideshow.link,
      'ssorder': slideshow.ssorder,
      
    };
  }
  
  static List<Slideshow> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => fromJson(json)).toList();
  }
}