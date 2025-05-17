// frontend/lib/data/repository/i_product_repository.dart
import 'package:frontend/models/category.dart';
import 'package:frontend/models/brands.dart';
import 'package:frontend/models/product.dart';
import 'package:frontend/models/slideshow.dart';

abstract class ProductRepository {
  Future<List<Product>> fetchProducts();
  Future<Product> fetchProductById(int id); // New method
  Future<List<Brand>> fetchBrands();
  Future<List<CategoryProduct>> fetchCategories();
  Future<List<Slideshow>> fetchSlideshows();
}