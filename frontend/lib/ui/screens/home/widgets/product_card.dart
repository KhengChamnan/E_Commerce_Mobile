import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:frontend/data/network/api_constant.dart';
import 'package:frontend/models/product.dart';
import 'package:frontend/ui/providers/cart_provider.dart';
import 'package:frontend/ui/screens/product/product_detail_screen.dart';
import 'package:provider/provider.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(
              productId: product.id!,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Calculate responsive dimensions
            final imageHeight = constraints.maxHeight * 0.55;
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image container with fixed aspect ratio
                SizedBox(
                  height: imageHeight,
                  width: double.infinity,
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                        ),
                        child: product.image != null && product.image!.isNotEmpty
                          ? Image.network(
                              ApiConstant.getProductImageUrl(product.image),
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[200],
                                  child: const Icon(
                                    Icons.image_not_supported,
                                  ),
                                );
                              },
                            )
                          : Container(
                              color: Colors.grey[200],
                              child: const Icon(Icons.image_not_supported),
                            ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: AddToCartButton(product: product),
                      ),
                    ],
                  ),
                ),
                
                // Product details section - FIXED OVERFLOW ISSUES
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        // Brand name with controlled height
                        SizedBox(
                          height: 16,
                          child: AutoSizeText(
                            product.brand != null && product.brand!['name'] != null
                                ? product.brand!['name'].toString()
                                : 'Nike',
                            style: const TextStyle(
                              fontFamily: 'Quicksand',
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            minFontSize: 10,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        
                        const SizedBox(height: 2),
                        
                        // Product name - IMPROVED TEXT WRAPPING
                        SizedBox(
                          height: 25, // Fixed height for product name
                          width: constraints.maxWidth - 16, // Account for padding
                          child: Text(
                            product.name,
                            style: const TextStyle(
                              fontFamily: 'Quicksand',
                              fontSize: 12,
                              height: 1.2, // Tighter line height
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        
                        const SizedBox(height: 2),
                        
                        // Category with fixed height
                        SizedBox(
                          child: AutoSizeText(
                            product.category != null && product.category!['name'] != null
                                ? product.category!['name'].toString()
                                : 'Category',
                            style: const TextStyle(
                              fontFamily: 'Quicksand',
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                            maxLines: 1,
                            minFontSize: 8,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        
                        // This spacer will take up all remaining space
                        const Spacer(),
                        
                        // Price at the bottom with fixed height
                        SizedBox(
                          child: Text(
                            'USD ${product.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontFamily: 'Quicksand',
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
        ),
      ),
    );
  }
}

class AddToCartButton extends StatefulWidget {
  final Product product;
  
  const AddToCartButton({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  State<AddToCartButton> createState() => _AddToCartButtonState();
}

class _AddToCartButtonState extends State<AddToCartButton> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isAdding = false;
  bool _showCheck = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _showCheck = false;
          _isAdding = false;
        });
        _animationController.reset();
      } else if (status == AnimationStatus.forward) {
        setState(() {
          _showCheck = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _addToCart() {
    if (_isAdding) return;

    setState(() {
      _isAdding = true;
    });

    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    
    if (widget.product.id != null) {
      // Add to cart with quantity 1
      cartProvider.addToCart(widget.product.id!, 1).then((_) {
        // Start animation
        _animationController.forward();
      }).catchError((error) {
        // Handle error
        setState(() {
          _isAdding = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _addToCart,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: _showCheck ? Colors.green : const Color(0xFF2FD180),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Center(
          child: _isAdding 
            ? _showCheck
              ? const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 16,
                )
              : const SizedBox(
                  width: 15,
                  height: 15,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
            : const Icon(
                Icons.shopping_cart,
                color: Colors.white,
                size: 16,
              ),
        ),
      ),
    );
  }
} 