import 'package:flutter/material.dart';
import 'package:frontend/ui/providers/cart_provider.dart';
import 'package:frontend/ui/screens/cart/widgets/cart_app_bar.dart';
import 'package:frontend/ui/screens/cart/widgets/cart_item_card.dart';
import 'package:frontend/ui/screens/cart/widgets/checkout_button.dart';
import 'package:frontend/ui/screens/cart/checkout/checkout_screen.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch cart when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartProvider>().getCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Custom app bar with back button and title
            const CartAppBar(title: 'My Cart'),
            
            // Cart content (list of items)
            Expanded(
              child: Consumer<CartProvider>(
                builder: (context, provider, child) {
                  final cartState = provider.cart;
                  
                  // Show loading indicator while data is loading
                  if (cartState.isLoading) {
                    return const Center(child: CircularProgressIndicator(
                      color: Color(0xFF21D69F),
                    ));
                  }
                  
                  // Show error message if there was an error
                  if (cartState.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Error: ${cartState.error}',
                            style: const TextStyle(
                              fontFamily: 'Quicksand',
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => provider.getCart(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF21D69F),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  final cart = cartState.data;
                  
                  // Show empty cart message if cart is empty
                  if (cart == null || cart.items.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shopping_cart_outlined,
                            size: 80,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Your cart is empty',
                            style: TextStyle(
                              fontFamily: 'Quicksand',
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Add some products to your cart',
                            style: TextStyle(
                              fontFamily: 'Quicksand',
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  // Show the list of cart items
                  return Column(
                    children: [
                      // Cart items list
                      Expanded(
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16.0),
                          itemCount: cart.items.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final item = cart.items[index];
                            return CartItemCard(
                              item: item,
                              onQuantityDecreased: () {
                                if (item.quantity > 1) {
                                  provider.updateCartItem(item.id!, item.quantity - 1);
                                } else {
                                  _showRemoveConfirmDialog(context, item, provider);
                                }
                              },
                              onQuantityIncreased: () {
                                provider.updateCartItem(item.id!, item.quantity + 1);
                              },
                              onRemove: () => _showRemoveConfirmDialog(context, item, provider),
                            );
                          },
                        ),
                      ),
                      
                      // Checkout section
                      CheckoutButton(
                        totalPrice: cart.totalPrice,
                        onCheckout: () {
                          // Navigate to checkout screen
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const CheckoutScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showRemoveConfirmDialog(BuildContext context, item, CartProvider provider) {
    final productName = item.product?.name ?? 'This item';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Remove Item',
          style: TextStyle(
            fontFamily: 'Quicksand',
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Remove $productName from your cart?',
          style: const TextStyle(
            fontFamily: 'Quicksand',
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontFamily: 'Quicksand',
                color: Colors.black54,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              provider.removeCartItem(item.id!);
            },
            child: const Text(
              'Remove',
              style: TextStyle(
                fontFamily: 'Quicksand',
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 