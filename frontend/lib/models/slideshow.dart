class Slideshow {
  final int id;
  final String name;
  final String description;
  final double price;
  final String image;
  final int productId;
  final bool enable;
  final String? link;
  final int? ssorder;


  Slideshow({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    required this.productId,
    this.enable = true,
    this.link,
    this.ssorder,
  });
}