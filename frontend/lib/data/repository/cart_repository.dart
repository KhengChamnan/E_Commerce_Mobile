import 'package:frontend/models/cart.dart';

abstract class CartRepository {
  Future<Cart> getCart();
  Future<bool> addToCart({required int productId, required int quantity});
  Future<bool> updateCartItem({required int cartItemId, required int quantity});
  Future<bool> removeCartItem(int cartItemId);
  Future<bool> clearCart();
}