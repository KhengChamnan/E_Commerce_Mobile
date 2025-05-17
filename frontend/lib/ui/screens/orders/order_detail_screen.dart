import 'package:flutter/material.dart';
import 'package:frontend/data/network/api_constant.dart';
import 'package:frontend/models/order.dart';
import 'package:frontend/models/order_item.dart';
import 'package:frontend/models/product.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:frontend/ui/providers/product_provider.dart';
import 'package:provider/provider.dart';

class OrderDetailScreen extends StatelessWidget {
  final Order order;

  const OrderDetailScreen({
    Key? key,
    required this.order,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "Order Details",
          style: TextStyle(
            fontFamily: 'Quicksand',
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order number and date
              _buildOrderHeader(),
              
              const SizedBox(height: 24),
              
              // Order status with timeline
              _buildOrderStatus(),
              
              const SizedBox(height: 24),
              
              // Order items list
              _buildOrderItems(context),
              
              const SizedBox(height: 24),
              
              // Price summary
              _buildPriceSummary(),
              
              const SizedBox(height: 24),
              
              // Shipping information
              _buildShippingInfo(),
              
              const SizedBox(height: 32),
              
              // Action buttons
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Order #${order.orderNumber}',
          style: const TextStyle(
            fontFamily: 'Quicksand',
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Placed on ${_formatDate(order.createdAt)}',
          style: TextStyle(
            fontFamily: 'Quicksand',
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildOrderStatus() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Status',
            style: TextStyle(
              fontFamily: 'Quicksand',
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildStatusBadge(order.status),
          
          const SizedBox(height: 16),
          
          // Simple timeline
          Row(
            children: [
              _buildTimelineStep(
                label: 'Processing', 
                isActive: true, 
                isCompleted: true
              ),
              _buildTimelineLine(isActive: true),
              _buildTimelineStep(
                label: 'Shipped', 
                isActive: order.status == 'shipped' || order.status == 'delivered', 
                isCompleted: order.status == 'delivered'
              ),
              _buildTimelineLine(isActive: order.status == 'delivered'),
              _buildTimelineStep(
                label: 'Delivered', 
                isActive: order.status == 'delivered', 
                isCompleted: order.status == 'delivered'
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStep({
    required String label, 
    required bool isActive, 
    required bool isCompleted
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? const Color(0xFF21D69F) : Colors.grey.shade300,
              border: Border.all(
                color: isActive ? const Color(0xFF21D69F) : Colors.grey.shade300,
                width: 2,
              ),
            ),
            child: isCompleted 
              ? const Icon(Icons.check, color: Colors.white, size: 16)
              : null,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Quicksand',
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              color: isActive ? Colors.black : Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineLine({required bool isActive}) {
    return Expanded(
      child: Container(
        height: 2,
        color: isActive ? const Color(0xFF21D69F) : Colors.grey.shade300,
      ),
    );
  }

  Widget _buildOrderItems(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Items',
          style: TextStyle(
            fontFamily: 'Quicksand',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        
        // List of items
        ...order.items.map((item) => _buildOrderItemRow(item, context)).toList(),
      ],
    );
  }

  Widget _buildOrderItemRow(OrderItem item, BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    
    // Try to get the product from the provider using productId
    Product? productFromProvider;
    if (productProvider.products.hasData) {
      try {
        productFromProvider = productProvider.products.data?.firstWhere(
          (product) => product.id == item.productId,
        );
      } catch (_) {
        // Product not found in the provider's list
        productFromProvider = null;
      }
    }
    
    final bool hasValidImage = (productFromProvider?.image != null && productFromProvider!.image!.isNotEmpty) || 
                              (item.product?.image != null && item.product!.image!.isNotEmpty);
    
    final String? imageUrl = productFromProvider?.image ?? item.product?.image;
                               
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image or placeholder
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(10),
            ),
            child: hasValidImage
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl: ApiConstant.getProductImageUrl(imageUrl),
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Center(
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
                      color: Colors.grey,
                    ),
                  ),
                )
              : const Icon(Icons.image_not_supported, color: Colors.grey),
          ),
          const SizedBox(width: 12),
          
          // Product info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  productFromProvider?.name ?? item.productName,
                  style: const TextStyle(
                    fontFamily: 'Quicksand',
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Qty: ${item.quantity}',
                  style: TextStyle(
                    fontFamily: 'Quicksand',
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          
          // Price
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${item.price.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontFamily: 'Quicksand',
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              if (item.quantity > 1)
                Text(
                  '${item.quantity} × \$${(item.price / item.quantity).toStringAsFixed(2)}',
                  style: TextStyle(
                    fontFamily: 'Quicksand',
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Price Details',
          style: TextStyle(
            fontFamily: 'Quicksand',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              _buildPriceRow('Subtotal', '\$${(order.totalAmount - order.shippingCost).toStringAsFixed(2)}'),
              const SizedBox(height: 8),
              _buildPriceRow('Shipping Fee', '\$${order.shippingCost.toStringAsFixed(2)}'),
              const Divider(height: 24),
              _buildPriceRow(
                'Total Amount', 
                '\$${order.totalAmount.toStringAsFixed(2)}',
                isBold: true
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Quicksand',
            fontSize: 14,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
            color: isBold ? Colors.black : Colors.grey.shade700,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Quicksand',
            fontSize: 14,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildShippingInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Shipping Information',
          style: TextStyle(
            fontFamily: 'Quicksand',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.location_on_outlined, size: 20, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      order.shippingAddress,
                      style: const TextStyle(
                        fontFamily: 'Quicksand',
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.phone_outlined, size: 20, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    order.phone,
                    style: const TextStyle(
                      fontFamily: 'Quicksand',
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              // TODO: Implement track order functionality
            },
            icon: const Icon(Icons.local_shipping_outlined),
            label: const Text('Track Order'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: const Color(0xFF21D69F),
              padding: const EdgeInsets.symmetric(vertical: 12),
              textStyle: const TextStyle(
                fontFamily: 'Quicksand',
                fontWeight: FontWeight.w600,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              // TODO: Implement contact support functionality
            },
            icon: const Icon(Icons.support_agent_outlined),
            label: const Text('Contact Support'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.black,
              side: const BorderSide(color: Colors.black),
              padding: const EdgeInsets.symmetric(vertical: 12),
              textStyle: const TextStyle(
                fontFamily: 'Quicksand',
                fontWeight: FontWeight.w600,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: badgeColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: badgeColor),
          const SizedBox(width: 6),
          Text(
            statusText,
            style: TextStyle(
              fontFamily: 'Quicksand',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: badgeColor,
            ),
          ),
        ],
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
} 