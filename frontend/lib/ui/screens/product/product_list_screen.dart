import 'package:flutter/material.dart';
import 'package:frontend/data/network/api_constant.dart';
import 'package:frontend/models/product.dart';
import 'package:frontend/ui/providers/product_provider.dart';
import 'package:frontend/ui/screens/product/product_detail_screen.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:frontend/utils/animation_utils.dart';
import 'package:frontend/ui/screens/search/search_screen.dart';

class ProductListScreen extends StatefulWidget {
  final bool isFromBottomNav;
  final int? brandId;
  final String? brandName;

  const ProductListScreen({
    Key? key, 
    this.isFromBottomNav = false,
    this.brandId,
    this.brandName,
  }) : super(key: key);

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  // Selected category filter
  String _selectedCategory = 'All';

  // Helper method to get the full image URL
  String getImageUrl(String? imagePath) {
    return ApiConstant.getProductImageUrl(imagePath);
  }

  @override
  void initState() {
    super.initState();
    // Fetch products when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchProducts();
      context.read<ProductProvider>().fetchBrands();
      context.read<ProductProvider>().fetchCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading:widget.isFromBottomNav ?null: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title:  Text(
          widget.brandName ?? (widget.isFromBottomNav ? 'All Products' : 'Most Popular'),
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {
              // TODO: Implement search functionality
              Navigator.push(
                  context,
                  AnimationUtils.createBottomToTopRoute(const SearchScreen()),
                );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Category filter tabs
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: SizedBox(
              height: 40,
              child: Consumer<ProductProvider>(
                builder: (context, provider, child) {
                  // Combined loading state check
                  if (provider.categories.isLoading ||
                      provider.brands.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // Error handling
                  if (provider.categories.hasError ||
                      provider.brands.hasError) {
                    return Center(
                      child: Text(
                        'Error loading filters',
                        style: TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  // Create a list with 'All' as first option
                  List<String> filterOptions = ['All'];

                  // Add categories if available
                  if (provider.categories.hasData) {
                    filterOptions.addAll(
                      provider.categories.data!
                          .map((category) => category.name)
                          .toList(),
                    );
                  }

                  // Add brands if available and we're not already filtering by brand
                  if (provider.brands.hasData && widget.brandId == null) {
                    filterOptions.addAll(
                      provider.brands.data!.map((brand) => brand.name).toList(),
                    );
                  }

                  // Remove duplicates if any
                  filterOptions = filterOptions.toSet().toList();

                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: filterOptions.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedCategory = filterOptions[index];
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              color:
                                  _selectedCategory == filterOptions[index]
                                      ? Colors.black
                                      : Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: Colors.black, width: 1),
                            ),
                            child: Center(
                              child: Text(
                                filterOptions[index],
                                style: TextStyle(
                                  color:
                                      _selectedCategory == filterOptions[index]
                                          ? Colors.white
                                          : Colors.black,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),

          // Product list
          Expanded(
            child: Consumer<ProductProvider>(
              builder: (context, provider, child) {
                final productsState = provider.products;

                // Show loading indicator while data is loading
                if (productsState.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Show error message if there was an error
                if (productsState.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Error: ${productsState.error}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            provider.fetchProducts(forceRefresh: true);
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                // Show products when data is available
                final allProducts = productsState.data!;
                
                // First filter by brandId if it exists
                var filteredProducts = widget.brandId != null 
                    ? allProducts.where((product) => product.brandId == widget.brandId).toList()
                    : allProducts;

                // Then filter by selected category if not 'All'
                final products = _selectedCategory == 'All'
                    ? filteredProducts
                    : filteredProducts.where((product) {
                        // Check if product matches selected category
                        final categoryName = product.category?['name'] as String?;
                        
                        
                        // Return true if category matches the selected filter
                        return categoryName == _selectedCategory;
                      }).toList();

                if (products.isEmpty) {
                  return const Center(child: Text('No products available for this selection'));
                }

                // Display products in a list
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return _buildProductCard(context, product);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F1F1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailScreen(productId: product.id!),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image with cart button
              Stack(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: Colors.white,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Hero(
                        tag: 'product-image-${product.id}',
                        child: CachedNetworkImage(
                          imageUrl: getImageUrl(product.image),
                          fit: BoxFit.cover,
                          placeholder:
                              (context, url) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                          errorWidget: (context, url, error) {
                            return Container(
                              color: Colors.grey.shade300,
                              child: const Center(
                                child: Icon(
                                  Icons.image_not_supported,
                                  color: Colors.grey,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  // Cart button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        color: Color(0xFF21D69F),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        iconSize: 14,
                        padding: EdgeInsets.zero,
                        icon: const Icon(
                          Icons.shopping_cart,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          // TODO: Add to favorites
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              // Product details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category
                    Text(
                      product.category?['name'] ?? 'Brand',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Product name
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Rating and sold info
                    const SizedBox(height: 8),
                    // Price
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: Color(0xFF2D264B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
