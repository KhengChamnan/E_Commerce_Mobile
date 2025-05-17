class Brand {
  final int? id;
  final String name;
  final String? description;
  final String? logo;

  Brand({
    this.id,
    required this.name,
    this.description,
    this.logo,
  });

  @override
  String toString() {
    return 'Brand(id: $id, name: $name, description: $description, logo: $logo)';
  }

  Brand copyWith({
    int? id,
    String? name,
    String? description,
    String? logo,
  }) {
    return Brand(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      logo: logo ?? this.logo,
    );
  }
}