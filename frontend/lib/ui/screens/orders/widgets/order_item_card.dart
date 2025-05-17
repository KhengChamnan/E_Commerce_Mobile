import 'package:flutter/material.dart';
import 'package:frontend/data/network/api_constant.dart';
import 'package:frontend/models/order.dart';
import 'package:frontend/models/order_item.dart';
import 'package:frontend/models/product.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:frontend/ui/providers/product_provider.dart';
import 'package:provider/provider.dart';

class OrderItemCard extends StatelessWidget {
  final Order order;
  final VoidCallback onTap;

  const OrderItemCard({
    Key? key,
    required this.order,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get the first item to display as a preview (if available)
    final OrderItem? firstItem = order.items.isNotEmpty ? order.items.first : null;
    final productProvider = Provider.of<ProductProvider>(context);

    // Try to get the product from the provider using productId if available
    Product? productFromProvider;
    if (firstItem?.productId != null && productProvider.products.hasData) {
      try {
        productFromProvider = productProvider.products.data?.firstWhere(
          (product) => product.id == firstItem!.productId,
        );
      } catch (_) {
        // Product not found in the provider's list
        productFromProvider = null;
      }
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F1F1),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product image
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: CachedNetworkImage(
                      // Use image from provider if available, otherwise fallback to the item's product image
                      imageUrl: ApiConstant.getProductImageUrl(
                        productFromProvider?.image ?? firstItem?.product?.image
                      ),
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.image_not_supported,
                        size: 40,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                // Order info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Brand or product name
                      Text(
                        productFromProvider?.name ?? firstItem?.productName ?? 'Order ${order.orderNumber}',
                        style: const TextStyle(
                          fontFamily: 'Quicksand',
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      
                      // Product description or order number
                      Text(
                        'Order #${order.orderNumber}',
                        style: const TextStyle(
                          fontFamily: 'Quicksand',
                          fontWeight: FontWeight.w400,
                          fontSize: 11,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      const SizedBox(height: 6),
                      
                      // Order details row - quantity
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Qty: ${firstItem?.quantity ?? 0}',
                          style: const TextStyle(
                            fontFamily: 'Quicksand',
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Order date
                      Text(
                        'Ordered on ${_formatDate(order.createdAt)}',
                        style: TextStyle(
                          fontFamily: 'Quicksand',
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Order summary info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Order status
                _buildStatusBadge(order.status),
                
                // Order items count
                Text(
                  '${order.items.length} ${order.items.length == 1 ? 'item' : 'items'} • \$${order.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontFamily: 'Quicksand',
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Track order button
            InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(5),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF21D69F),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Center(
                  child: Text(
                    'Track Order',
                    style: TextStyle(
                      fontFamily: 'Quicksand',
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Simple date formatter
  String _formatDate(DateTime date) {
    final List<String> months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Widget _buildStatusBadge(String status) {
    Color badgeColor;
    IconData icon;
    String statusText = status.substring(0, 1).toUpperCase() + status.substring(1);
    
    switch (status.toLowerCase()) {
      case 'processing':
        badgeColor = Colors.orange;
        icon = Icons.sync;
        break;
      case 'shipped':
        badgeColor = Colors.blue;
        icon = Icons.local_shipping;
        break;
      case 'delivered':
        badgeColor = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'cancelled':
        badgeColor = Colors.red;
        icon = Icons.cancel;
        break;
      default:
        badgeColor = Colors.grey;
        icon = Icons.pending;
        statusText = 'Pending';
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: badgeColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: badgeColor),
          const SizedBox(width: 4),
          Text(
            statusText,
            style: TextStyle(
              fontFamily: 'Quicksand',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: badgeColor,
            ),
          ),
        ],
      ),
    );
  }
} 