import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/ui/providers/cart_provider.dart';

class CheckoutButton extends StatelessWidget {
  final double totalPrice;
  final VoidCallback onCheckout;

  const CheckoutButton({
    Key? key,
    required this.totalPrice,
    required this.onCheckout,
  }) : super(key: key);

  // Show confirmation dialog before clearing cart
  void _showClearCartConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Clear Cart',
          style: TextStyle(
            fontFamily: 'Quicksand',
            fontWeight: FontWeight.w700,
          ),
        ),
        content: const Text(
          'Are you sure you want to remove all items from your cart?',
          style: TextStyle(
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
              // Clear the cart and close the dialog
              Provider.of<CartProvider>(context, listen: false).clearCart();
              Navigator.of(context).pop();
            },
            child: const Text(
              'Clear Cart',
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Total price label
          const Text(
            'Total Price',
            style: TextStyle(
              fontFamily: 'Quicksand',
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
          
          const SizedBox(height: 4),
          
          // Total price amount
          Text(
            '\$${totalPrice.toStringAsFixed(2)}',
            style: const TextStyle(
              fontFamily: 'Quicksand',
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Row containing Clear Cart and Checkout buttons
          Row(
            children: [
              // Clear Cart button
              GestureDetector(
                onTap: () => _showClearCartConfirmation(context),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red[400],
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Checkout button
              Expanded(
                child: GestureDetector(
                  onTap: onCheckout,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF21D69F),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Shopping bag icon
                        Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.shopping_bag_outlined,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        
                        const SizedBox(width: 10),
                        
                        // Checkout text
                        const Text(
                          'Checkout',
                          style: TextStyle(
                            fontFamily: 'Quicksand',
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}