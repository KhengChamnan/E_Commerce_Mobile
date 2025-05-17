import 'package:flutter/foundation.dart';
import 'package:frontend/data/repository/cart_repository.dart';
import 'package:frontend/models/cart.dart';
import 'package:frontend/ui/providers/async_value.dart';

class CartProvider with ChangeNotifier {
  final CartRepository _repository;
  
  // State for cart
  AsyncValue<Cart?> _cart = AsyncValue.empty();
  AsyncValue<Cart?> get cart => _cart;
  
  // State for loading operations
  bool _isAddingToCart = false;
  bool get isAddingToCart => _isAddingToCart;
  
  // Last operation error message
  String? _lastErrorMessage;
  String? get lastErrorMessage => _lastErrorMessage;
  
  CartProvider({required CartRepository repository}) 
    : _repository = repository;
  
  // Fetch the user's cart
  Future<void> getCart() async {
    try {
      _cart = AsyncValue.loading();
      notifyListeners();
      
      final cart = await _repository.getCart();
      _cart = AsyncValue.success(cart);
      _lastErrorMessage = null;
    } catch (e) {
      _cart = AsyncValue.error(e);
      _lastErrorMessage = e.toString();
    } finally {
      notifyListeners();
    }
  }
  
  // Add an item to cart
  Future<void> addToCart(int productId, int quantity) async {
    try {
      _isAddingToCart = true;
      notifyListeners();
      
      await _repository.addToCart(productId: productId, quantity: quantity);
      _lastErrorMessage = null;
      
      // Refresh cart after adding item
      await getCart();
    } catch (e) {
      _lastErrorMessage = e.toString();
      notifyListeners();
    } finally {
      _isAddingToCart = false;
      notifyListeners();
    }
  }
  
  // Update a cart item quantity
  Future<void> updateCartItem(int cartItemId, int quantity) async {
    // Store the original cart and item data for recovery if needed
    final originalCart = _cart.data;
    final originalItem = originalCart?.items.firstWhere((item) => item.id == cartItemId);
    final originalQuantity = originalItem?.quantity;
    
    try {
      // Optimistic update - update cart data immediately
      if (_cart.hasData && _cart.data != null) {
        final updatedItems = _cart.data!.items.map((item) {
          if (item.id == cartItemId) {
            // Update item quantity locally
            return item.copyWith(quantity: quantity);
          }
          return item;
        }).toList();
        
        // Update cart with new items
        _cart = AsyncValue.success(_cart.data!.copyWith(items: updatedItems));
        notifyListeners();
      }
      
      // Make API call in the background
      _repository.updateCartItem(cartItemId: cartItemId, quantity: quantity).then((_) {
        // Success - no need to do anything as we already updated UI
        _lastErrorMessage = null;
      }).catchError((e) {
        // Error - revert to original state
        if (originalCart != null && originalQuantity != null) {
          _cart = AsyncValue.success(originalCart);
          _lastErrorMessage = "Failed to update item: ${e.toString()}";
          notifyListeners();
        }
      });
    } catch (e) {
      // Handle any synchronous errors
      _lastErrorMessage = e.toString();
      notifyListeners();
    }
  }
  
  // Remove an item from cart
  Future<void> removeCartItem(int cartItemId) async {
    // Store the original cart for recovery if needed
    final originalCart = _cart.data;
    
    try {
      // Optimistic update - remove item immediately from UI
      if (_cart.hasData && _cart.data != null) {
        final updatedItems = _cart.data!.items
            .where((item) => item.id != cartItemId)
            .toList();
        
        // Update cart with filtered items
        _cart = AsyncValue.success(_cart.data!.copyWith(items: updatedItems));
        notifyListeners();
      }
      
      // Make API call in the background
      _repository.removeCartItem(cartItemId).then((_) {
        // Success - no need to do anything as we already updated UI
        _lastErrorMessage = null;
      }).catchError((e) {
        // Error - revert to original state
        if (originalCart != null) {
          _cart = AsyncValue.success(originalCart);
          _lastErrorMessage = "Failed to remove item: ${e.toString()}";
          notifyListeners();
        }
      });
    } catch (e) {
      // Handle any synchronous errors
      _lastErrorMessage = e.toString();
      notifyListeners();
    }
  }
  
  // Clear the entire cart
  Future<void> clearCart() async {
    // Store the original cart for recovery if needed
    final originalCart = _cart.data;
    
    try {
      // Optimistic update - clear cart immediately in UI
      if (_cart.hasData && _cart.data != null) {
        // Create an empty cart but maintain the original cart ID and user ID
        _cart = AsyncValue.success(Cart(
          id: _cart.data!.id, 
          userId: _cart.data!.userId, 
          items: []
        ));
        notifyListeners();
      }
      
      // Make API call in the background
      _repository.clearCart().then((_) {
        // Success - no need to do anything as we already updated UI
        _lastErrorMessage = null;
      }).catchError((e) {
        // Error - revert to original state
        if (originalCart != null) {
          _cart = AsyncValue.success(originalCart);
          _lastErrorMessage = "Failed to clear cart: ${e.toString()}";
          notifyListeners();
        }
      });
    } catch (e) {
      // Handle any synchronous errors
      _lastErrorMessage = e.toString();
      notifyListeners();
    }
  }
  
  // Reset any error messages
  void clearErrors() {
    _lastErrorMessage = null;
    notifyListeners();
  }
}