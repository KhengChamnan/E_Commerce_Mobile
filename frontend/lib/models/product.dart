class Product {
  final int? id;
  final String name;
  final String description;
  final double price;
  final String? image;
  final int categoryId;
  final int brandId;
  
  // Optional properties for related objects
  final Map<String, dynamic>? category;
  final Map<String, dynamic>? brand;

  Product({
    this.id,
    required this.name,
    required this.description,
    required this.price,
    this.image,
    required this.categoryId,
    required this.brandId,
    this.category,
    this.brand,
  });

  // Create a copy of Product with some changes
  Product copyWith({
    int? id,
    String? name,
    String? description,
    double? price,
    String? image,
    int? categoryId,
    int? brandId,
    Map<String, dynamic>? category,
    Map<String, dynamic>? brand,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      image: image ?? this.image,
      categoryId: categoryId ?? this.categoryId,
      brandId: brandId ?? this.brandId,
      category: category ?? this.category,
      brand: brand ?? this.brand,
    );
  }
}