import 'package:flutter/foundation.dart';
import 'package:frontend/data/repository/product_repository.dart';
import 'package:frontend/models/product.dart';
import 'package:frontend/ui/providers/async_value.dart';

class ProductDetailsProvider with ChangeNotifier {
  final ProductRepository _repository;
  
  // State for single product
  AsyncValue<Product?> _product = AsyncValue.empty();
  AsyncValue<Product?> get product => _product;
  
  // Last fetched product ID
  int? _lastProductId;
  int? get lastProductId => _lastProductId;
  
  // Cache duration - default 5 minutes
  final Duration _cacheDuration = const Duration(minutes: 5);
  
  // Keep track of last fetch time for caching
  DateTime? _lastProductFetch;

  ProductDetailsProvider({required ProductRepository repository}) 
    : _repository = repository;

  // Fetch a single product from repository
  Future<void> fetchProduct(int productId, {bool forceRefresh = false}) async {
    // Skip if we're already fetching the same product and it's not a force refresh
    if (!forceRefresh && _lastProductId == productId && _product.isLoading) {
      return;
    }
    
    // Return cached data if it's still fresh and it's the same product
    if (!forceRefresh && 
        _lastProductFetch != null && 
        DateTime.now().difference(_lastProductFetch!) < _cacheDuration && 
        !_product.isLoading && 
        !_product.hasError &&
        _lastProductId == productId) {
      return;
    }

    try {
      // Set to loading state if different product or no data yet
      if (_lastProductId != productId || _product.data == null) {
        _product = AsyncValue<Product?>.loading();
        notifyListeners();
      }
      
      // Update last product ID
      _lastProductId = productId;
      
      // Fetch product
      final data = await _repository.fetchProductById(productId);
      _product = AsyncValue<Product?>.success(data);
      _lastProductFetch = DateTime.now();
    } catch (error, stackTrace) {
      // Create error state with both error and stack trace for better debugging
      _product = AsyncValue<Product?>.error(error, stackTrace);
    } finally {
      notifyListeners();
    }
  }

  // Clear product data when no longer needed
  void clearProduct() {
    _product = AsyncValue.empty();
    _lastProductId = null;
    _lastProductFetch = null;
    notifyListeners();
  }
}