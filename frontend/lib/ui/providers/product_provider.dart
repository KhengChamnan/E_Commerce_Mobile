import 'package:flutter/foundation.dart';
import 'package:frontend/data/repository/product_repository.dart';
import 'package:frontend/models/brands.dart';
import 'package:frontend/models/category.dart';
import 'package:frontend/models/product.dart';
import 'package:frontend/models/slideshow.dart';
import 'package:frontend/ui/providers/async_value.dart';

class ProductProvider with ChangeNotifier {
  final ProductRepository _repository;

  // State for products
  AsyncValue<List<Product>> _products = AsyncValue.loading();
  AsyncValue<List<Product>> get products => _products;

  // State for brands
  AsyncValue<List<Brand>> _brands = AsyncValue.loading();
  AsyncValue<List<Brand>> get brands => _brands;

  // State for categories
  AsyncValue<List<CategoryProduct>> _categories = AsyncValue.loading();
  AsyncValue<List<CategoryProduct>> get categories => _categories;

  // State for slideshows
  AsyncValue<List<Slideshow>> _slideshows = AsyncValue.loading();
  AsyncValue<List<Slideshow>> get slideshows => _slideshows;

  // Keep track of data freshness to optimize refreshing
  DateTime? _lastProductsFetch;
  DateTime? _lastBrandsFetch;
  DateTime? _lastCategoriesFetch;
  DateTime? _lastSlideshowsFetch;
  
  // Cache duration - default 5 minutes
  final Duration _cacheDuration = const Duration(minutes: 5);

  ProductProvider({required ProductRepository repository}) : _repository = repository;

  // Generic fetch method to reduce code duplication
  Future<AsyncValue<T>> _fetchData<T>({
    required AsyncValue<T> currentState,
    required Future<T> Function() fetchFunction,
    required Function(AsyncValue<T>) updateState,
    DateTime? lastFetchTime,
    Function(DateTime)? updateLastFetchTime,
    bool forceRefresh = false,
  }) async {
    // Return cached data if it's still fresh
    if (!forceRefresh && 
        lastFetchTime != null && 
        DateTime.now().difference(lastFetchTime) < _cacheDuration && 
        !currentState.isLoading && 
        !currentState.hasError) {
      return currentState;
    }

    try {
      // Set to loading state only if we don't have data already
      if (currentState.data == null) {
        updateState(AsyncValue<T>.loading());
        notifyListeners();
      }
      
      final data = await fetchFunction();
      final newState = AsyncValue<T>.success(data);
      updateState(newState);
      
      // Update the last fetch time
      if (updateLastFetchTime != null) {
        updateLastFetchTime(DateTime.now());
      }
      
      return newState;
    } catch (error, stackTrace) {
      // Create error state with both error and stack trace for better debugging
      final errorState = AsyncValue<T>.error(error, stackTrace);
      updateState(errorState);
      return errorState;
    } finally {
      notifyListeners();
    }
  }

  // Fetch products from repository
  Future<void> fetchProducts({bool forceRefresh = false}) async {
    await _fetchData<List<Product>>(
      currentState: _products,
      fetchFunction: _repository.fetchProducts,
      updateState: (state) => _products = state,
      lastFetchTime: _lastProductsFetch,
      updateLastFetchTime: (time) => _lastProductsFetch = time,
      forceRefresh: forceRefresh,
    );
  }

  // Fetch brands from repository
  Future<void> fetchBrands({bool forceRefresh = false}) async {
    await _fetchData<List<Brand>>(
      currentState: _brands,
      fetchFunction: _repository.fetchBrands,
      updateState: (state) => _brands = state,
      lastFetchTime: _lastBrandsFetch,
      updateLastFetchTime: (time) => _lastBrandsFetch = time,
      forceRefresh: forceRefresh,
    );
  }

  // Fetch categories from repository
  Future<void> fetchCategories({bool forceRefresh = false}) async {
    await _fetchData<List<CategoryProduct>>(
      currentState: _categories,
      fetchFunction: _repository.fetchCategories,
      updateState: (state) => _categories = state,
      lastFetchTime: _lastCategoriesFetch,
      updateLastFetchTime: (time) => _lastCategoriesFetch = time,
      forceRefresh: forceRefresh,
    );
  }

  // Fetch slideshows from repository
  Future<void> fetchSlideshows({bool forceRefresh = false}) async {
    await _fetchData<List<Slideshow>>(
      currentState: _slideshows,
      fetchFunction: _repository.fetchSlideshows,
      updateState: (state) => _slideshows = state,
      lastFetchTime: _lastSlideshowsFetch,
      updateLastFetchTime: (time) => _lastSlideshowsFetch = time,
      forceRefresh: forceRefresh,
    );
  }

  // Convenience method to load all data at once with parallel fetching
  Future<void> fetchAllData({bool forceRefresh = false}) async {
    await Future.wait([
      fetchProducts(forceRefresh: forceRefresh),
      fetchBrands(forceRefresh: forceRefresh),
      fetchCategories(forceRefresh: forceRefresh),
      fetchSlideshows(forceRefresh: forceRefresh),
    ]);
  }
  
  // Convenience method to check if any data is currently loading
  bool get isLoading => 
    _products.isLoading || 
    _brands.isLoading || 
    _categories.isLoading || 
    _slideshows.isLoading;
    
  // Convenience method to check if all data is loaded successfully
  bool get isAllDataLoaded =>
    _products.hasData &&
    _brands.hasData &&
    _categories.hasData &&
    _slideshows.hasData;
}