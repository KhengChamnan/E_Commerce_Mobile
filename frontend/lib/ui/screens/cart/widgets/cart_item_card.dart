import 'package:flutter/material.dart';
import 'package:frontend/data/network/api_constant.dart';
import 'package:frontend/models/cart_item.dart';
import 'package:frontend/ui/providers/product_provider.dart';
import 'package:provider/provider.dart';

class CartItemCard extends StatelessWidget {
  final CartItem item;
  final VoidCallback onQuantityIncreased;
  final VoidCallback onQuantityDecreased;
  final VoidCallback onRemove;

  const CartItemCard({
    Key? key,
    required this.item,
    required this.onQuantityIncreased,
    required this.onQuantityDecreased,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Access the ProductProvider to get brand information
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    
    // Find the brand name if available
    String brandName = 'Brand';
    if (item.product?.brandId != null && productProvider.brands.hasData) {
      final brandId = item.product!.brandId;
      try {
        final brand = productProvider.brands.data!.firstWhere(
          (brand) => brand.id == brandId,
        );
        brandName = brand.name;
      } catch (e) {
        // Brand not found, use default name with ID
        brandName = 'Brand #${brandId}';
      }
    } else if (item.product?.brand?['name'] != null) {
      // Fallback to the brand name from the product if available
      brandName = item.product!.brand!['name'];
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF1F1F1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Container(
                width: 100,
                height: 100,
                color: Colors.grey.shade200,
                child: item.product?.image != null
                    ? Image.network(
                        ApiConstant.getProductImageUrl(item.product!.image!),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.image_not_supported,
                          size: 40,
                          color: Colors.grey,
                        ),
                      )
                    : const Icon(
                        Icons.image_not_supported,
                        size: 40,
                        color: Colors.grey,
                      ),
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Product details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Brand name
                  Text(
                    brandName,
                    style: const TextStyle(
                      fontFamily: 'Quicksand',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Product name
                  Text(
                    item.product?.name ?? 'Product #${item.productId}',
                    style: const TextStyle(
                      fontFamily: 'Quicksand',
                      fontSize: 11,
                      color: Colors.black,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  
                  
                  const SizedBox(height: 12),
                  
                  // Price and quantity controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Price
                      Text(
                        '\$${item.totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontFamily: 'Quicksand',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF21D69F),
                        ),
                      ),
                      
                      // Quantity controls
                      Row(
                        children: [
                          // Decrease button
                          _buildQuantityButton(
                            icon: Icons.remove,
                            onTap: item.quantity > 1 ? onQuantityDecreased : null,
                          ),
                          
                          // Quantity display
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF21D69F),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Text(
                              '${item.quantity}',
                              style: const TextStyle(
                                fontFamily: 'Quicksand',
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          
                          // Increase button
                          _buildQuantityButton(
                            icon: Icons.add,
                            onTap: onQuantityIncreased,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Delete button
            GestureDetector(
              onTap: onRemove,
              child: const Padding(
                padding: EdgeInsets.all(4.0),
                child: Icon(
                  Icons.delete_outline,
                  color: Color(0xFF2D264B),
                  size: 22,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback? onTap,
  }) {
    final bool isDisabled = onTap == null;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: isDisabled ? Colors.grey.shade200 : Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            if (!isDisabled)
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                spreadRadius: 1,
              ),
          ],
        ),
        child: Center(
          child: Icon(
            icon,
            size: 16,
            color: isDisabled ? Colors.grey.shade400 : const Color(0xFF2D264B),
          ),
        ),
      ),
    );
  }
} 