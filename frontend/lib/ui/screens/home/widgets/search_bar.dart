import 'package:flutter/material.dart';
import 'package:frontend/ui/providers/cart_provider.dart';
import 'package:frontend/ui/screens/cart/cart_screen.dart';
import 'package:frontend/ui/screens/search/search_screen.dart';
import 'package:provider/provider.dart';
import 'package:frontend/utils/animation_utils.dart';

class HomeSearchBar extends StatelessWidget {
  final VoidCallback? onSearchTap;

  const HomeSearchBar({Key? key, this.onSearchTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Search input field
        Expanded(
          child: GestureDetector(
            onTap: () {
              // If onSearchTap is provided, use it
              if (onSearchTap != null) {
                onSearchTap!();
              } else {
                // Otherwise, navigate to the search screen
                // Otherwise, navigate to the search screen with animation
                Navigator.push(
                  context,
                  AnimationUtils.createBottomToTopRoute(const SearchScreen()),
                );
              }
            },
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F1F1),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Icon(Icons.search, color: Colors.black.withOpacity(0.5)),
                  const SizedBox(width: 8),
                  Text(
                    'Search',
                    style: TextStyle(
                      fontFamily: 'Quicksand',
                      fontSize: 16,
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),

        // Cart button with badge counter
        Consumer<CartProvider>(
          builder: (context, cartProvider, child) {
            // Get the number of items in cart
            final cartState = cartProvider.cart;
            final itemCount =
                cartState.hasData && cartState.data != null
                    ? cartState.data!.itemCount
                    : 0;

            return Stack(
              children: [
                // Cart button
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFF21D69F),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CartScreen(),
                        ),
                      ).then((_) {
                        // Refresh cart after returning from cart screen
                        cartProvider.getCart();
                      });
                    },
                    borderRadius: BorderRadius.circular(30),
                    child: const Icon(Icons.shopping_cart, color: Colors.white),
                  ),
                ),

                // Badge counter
                if (itemCount > 0)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 20,
                        minHeight: 20,
                      ),
                      child: Center(
                        child: Text(
                          itemCount > 99 ? '99+' : '$itemCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
