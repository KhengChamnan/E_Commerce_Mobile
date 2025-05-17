import 'package:flutter/material.dart';
import 'package:frontend/models/cart_item.dart';
import 'package:frontend/data/network/api_constant.dart';
import 'package:frontend/ui/providers/product_provider.dart';
import 'package:provider/provider.dart';

class CheckoutItemCard extends StatelessWidget {
  final CartItem item;
  final VoidCallback onRemove;
  final VoidCallback? onQuantityIncreased;
  final VoidCallback? onQuantityDecreased;

  const CheckoutItemCard({
    Key? key, 
    required this.item, 
    required this.onRemove,
    this.onQuantityIncreased,
    this.onQuantityDecreased,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Access the ProductProvider to get brand information
    final productProvider = Provider.of<ProductProvider>(
      context,
      listen: false,
    );

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
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product image
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.network(
                    ApiConstant.getProductImageUrl(item.product?.image),
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, error, stackTrace) => Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.image_not_supported,
                            color: Colors.white,
                          ),
                        ),
                  ),
                ),
                const SizedBox(width: 12),
                // Product details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            brandName,
                            style: const TextStyle(
                              fontFamily: 'Quicksand',
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Color(0xFF2D264B),
                              size: 22,
                            ),
                            onPressed: onRemove,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.product?.name ?? 'Product Name',
                        style: const TextStyle(
                          fontFamily: 'Quicksand',
                          fontWeight: FontWeight.w400,
                          fontSize: 11,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Quantity controls
                Row(
                  children: [
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
                // Price
                Text(
                  '\$${item.totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontFamily: 'Quicksand',
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
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
