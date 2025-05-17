// frontend/lib/data/repository/laravel_api/product_api_repository.dart
import 'package:frontend/data/network/api_constant.dart';
import 'package:frontend/data/dto/product_dto.dart';
import 'package:frontend/data/dto/brand_dto.dart';
import 'package:frontend/data/dto/category_dto.dart';
import 'package:frontend/data/dto/slideshow_dto.dart';
import 'package:frontend/models/brands.dart';
import 'package:frontend/models/category.dart';
import 'package:frontend/models/product.dart';
import 'package:frontend/models/slideshow.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../product_repository.dart';

class LaravelProductRepository implements ProductRepository {
  final http.Client client;

  LaravelProductRepository({http.Client? client}) : client = client ?? http.Client();

  @override
  Future<List<Product>> fetchProducts() async {
    final response = await client.get(Uri.parse(ApiConstant.products));

    if (response.statusCode == 200) {
      final dynamic decodedData = json.decode(response.body);
      
      // Check if the response matches the expected structure from the API
      if (decodedData is Map<String, dynamic> && decodedData.containsKey('products')) {
        // Access the 'products' array from the response
        final productsData = decodedData['products'];
        
        if (productsData is List) {
          return ProductDTO.fromJsonList(productsData);
        } else if (productsData is Map<String, dynamic>) {
          return [ProductDTO.fromJson(productsData)];
        }
      }
      // Fallback handling for other response formats
      else if (decodedData is List) {
        return ProductDTO.fromJsonList(decodedData);
      } 
      else if (decodedData is Map<String, dynamic>) {
        // If we get here, the response is a map but doesn't have 'products' key
        // This is a fallback to try to handle unexpected response formats
        return [ProductDTO.fromJson(decodedData)];
      } 
      
      throw Exception('Unexpected response format for products');
    } else {
      throw Exception('Failed to load products');
    }
  }

  @override
  Future<Product> fetchProductById(int id) async {
    final String url = ApiConstant.productDetail.replaceAll('{id}', id.toString());
    final response = await client.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final dynamic jsonData = json.decode(response.body);
      // Check if response has a 'product' key (matching the backend structure)
      if (jsonData is Map<String, dynamic> && jsonData.containsKey('product')) {
        return ProductDTO.fromJson(jsonData['product']);
      } else {
        // Fallback if the response format is different
        return ProductDTO.fromJson(jsonData);
      }
    } else {
      throw Exception('Failed to load product with id: $id');
    }
  }

  @override
  Future<List<Brand>> fetchBrands() async {
    final response = await client.get(Uri.parse(ApiConstant.brands));

    if (response.statusCode == 200) {
      final dynamic decodedData = json.decode(response.body);
      
      // Check if the response matches the expected structure from the API
      if (decodedData is Map<String, dynamic> && decodedData.containsKey('brands')) {
        // Access the 'brands' array from the response
        final brandsData = decodedData['brands'];
        
        if (brandsData is List) {
          return BrandDTO.fromJsonList(brandsData);
        } else if (brandsData is Map<String, dynamic>) {
          return [BrandDTO.fromJson(brandsData)];
        }
      }
      // Fallback handling for other response formats
      else if (decodedData is List) {
        return BrandDTO.fromJsonList(decodedData);
      } 
      else if (decodedData is Map<String, dynamic>) {
        // If we get here, the response is a map but doesn't have 'brands' key
        // This is a fallback to try to handle unexpected response formats
        return [BrandDTO.fromJson(decodedData)];
      } 
      
      throw Exception('Unexpected response format for brands');
    } else {
      throw Exception('Failed to load brands');
    }
  }

  @override
  Future<List<CategoryProduct>> fetchCategories() async {
    final response = await client.get(Uri.parse(ApiConstant.categories));

    if (response.statusCode == 200) {
      final dynamic decodedData = json.decode(response.body);
      
      // Check if the response matches the expected structure from the API
      if (decodedData is Map<String, dynamic> && decodedData.containsKey('categories')) {
        // Access the 'categories' array from the response
        final categoriesData = decodedData['categories'];
        
        if (categoriesData is List) {
          return CategoryDTO.fromJsonList(categoriesData);
        } else if (categoriesData is Map<String, dynamic>) {
          return [CategoryDTO.fromJson(categoriesData)];
        }
      }
      // Fallback handling for other response formats
      else if (decodedData is List) {
        return CategoryDTO.fromJsonList(decodedData);
      } 
      else if (decodedData is Map<String, dynamic>) {
        // If we get here, the response is a map but doesn't have 'categories' key
        // This is a fallback to try to handle unexpected response formats
        return [CategoryDTO.fromJson(decodedData)];
      } 
      
      throw Exception('Unexpected response format for categories');
    } else {
      throw Exception('Failed to load categories');
    }
  }

  @override
  Future<List<Slideshow>> fetchSlideshows() async {
    final response = await client.get(Uri.parse(ApiConstant.slideshows));

    if (response.statusCode == 200) {
      final dynamic decodedData = json.decode(response.body);
      
      // Check if the response matches the expected structure from the API
      if (decodedData is Map<String, dynamic> && decodedData.containsKey('slideshows')) {
        // Access the 'slideshows' array from the response
        final slideshowsData = decodedData['slideshows'];
        
        if (slideshowsData is List) {
          return SlideShowDTO.fromJsonList(slideshowsData);
        } else if (slideshowsData is Map<String, dynamic>) {
          return [SlideShowDTO.fromJson(slideshowsData)];
        }
      }
      // Fallback handling for other response formats
      else if (decodedData is List) {
        return SlideShowDTO.fromJsonList(decodedData);
      } 
      else if (decodedData is Map<String, dynamic>) {
        // If we get here, the response is a map but doesn't have 'slideshows' key
        // This is a fallback to try to handle unexpected response formats
        return [SlideShowDTO.fromJson(decodedData)];
      } 
      
      throw Exception('Unexpected response format for slideshows');
    } else {
      throw Exception('Failed to load slideshows');
    }
  }
}