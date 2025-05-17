class CategoryProduct {
  final int? id;
  final String name;
  final String? description;
  
  // Constructor
  CategoryProduct({
    this.id,
    required this.name,
    this.description,
  });
  
  // Copy method for creating a new instance with updated values
  CategoryProduct copyWith({
    int? id,
    String? name,
    String? description,
  }) {
    return CategoryProduct(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
    );
  }
  
  @override
  String toString() {
    return 'Category(id: $id, name: $name, description: $description)';
  }
}