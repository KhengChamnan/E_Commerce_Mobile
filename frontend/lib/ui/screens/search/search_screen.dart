import 'package:flutter/material.dart';
import 'package:frontend/data/network/api_constant.dart';
import 'package:frontend/models/product.dart';
import 'package:frontend/ui/providers/product_provider.dart';
import 'package:frontend/ui/screens/product/product_detail_screen.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<Product> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    // Initialize with empty search
    _performSearch('');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      _isSearching = true;
    });

    // Use the ProductProvider to get products and filter them
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    final productsState = productProvider.products;

    if (productsState.hasData) {
      final allProducts = productsState.data!;
      
      if (_searchQuery.isEmpty || _searchQuery.length < 2) {
        // If search is empty or less than 2 characters, don't show any products
        _searchResults = [];
      } else {
        // Filter products based on search criteria
        _searchResults = allProducts.where((product) {
          final name = product.name.toLowerCase();
          final description = product.description.toLowerCase();
          final brandName = product.brand?['name']?.toString().toLowerCase() ?? '';
          final categoryName = product.category?['name']?.toString().toLowerCase() ?? '';
          
          // Match by name, description, brand or category
          return name.contains(_searchQuery) || 
                 description.contains(_searchQuery) ||
                 brandName.contains(_searchQuery) ||
                 categoryName.contains(_searchQuery);
        }).toList();
      }
    } else {
      _searchResults = [];
    }

    setState(() {
      _isSearching = false;
    });
  }

  // Helper method to get the full image URL
  String getImageUrl(String? imagePath) {
    return ApiConstant.getProductImageUrl(imagePath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top search bar with back button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  // Back button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE5E5E5)),
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.black),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Search input
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _searchController,
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: 'Search products...',
                          hintStyle: const TextStyle(
                            color: Color(0xFF9E9E9E),
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                          prefixIcon: const Icon(Icons.search, color: Color(0xFF9E9E9E)),
                          suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close, color: Color(0xFF9E9E9E), size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  _performSearch('');
                                },
                              )
                            : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        onChanged: (value) {
                          // Debounce the search to avoid too many searches while typing
                          Future.delayed(const Duration(milliseconds: 300), () {
                            if (value == _searchController.text) {
                              _performSearch(value);
                            }
                          });
                        },
                        textInputAction: TextInputAction.search,
                        onSubmitted: _performSearch,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Popular chips - optional based on your requirements
            if (_searchQuery.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Popular searches',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildSearchChip('Shoes'),
                        _buildSearchChip('Running shoes'),
                        _buildSearchChip('Sneakers'),
                        _buildSearchChip('Popular'),
                        _buildSearchChip('New arrivals'),
                      ],
                    ),
                  ],
                ),
              ),
            
            Expanded(
              child: Consumer<ProductProvider>(
                builder: (context, provider, child) {
                  final productsState = provider.products;
          
                  // Display loading indicator when searching or loading initial data
                  if (_isSearching || productsState.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
          
                  // Display error
                  if (productsState.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red, size: 48),
                          const SizedBox(height: 16),
                          Text(
                            'Error loading products',
                            style: const TextStyle(color: Colors.red, fontSize: 16),
                          ),
                        ],
                      ),
                    );
                  }
          
                  if (_searchQuery.isEmpty || _searchQuery.length < 2) {
                    // If search is empty, show placeholder
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/search_placeholder.png',
                            width: 120,
                            height: 120,
                            errorBuilder: (ctx, _, __) => const Icon(
                              Icons.search,
                              size: 80,
                              color: Color(0xFFDDDDDD),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isEmpty
                                ? 'Search for products'
                                : 'Type at least 2 characters',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
          
                  // No results
                  if (_searchResults.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/no_results.png',
                            width: 120,
                            height: 120,
                            errorBuilder: (ctx, _, __) => const Icon(
                              Icons.search_off,
                              size: 80,
                              color: Color(0xFFDDDDDD),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No results found for "$_searchQuery"',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try a different search term',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
          
                  // Display search results in a grid
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Results for "${_searchQuery}"',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_searchResults.length} products found',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: GridView.builder(
                            padding: EdgeInsets.zero,
                            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 200, // Maximum width for each grid item
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 10,
                              childAspectRatio: 0.75, // More vertical space for content
                            ),
                            itemCount: _searchResults.length,
                            itemBuilder: (context, index) {
                              final product = _searchResults[index];
                              return _buildProductCard(context, product);
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchChip(String label) {
    return GestureDetector(
      onTap: () {
        _searchController.text = label;
        _performSearch(label);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    // Calculate screen width to ensure proper sizing
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth - 16 * 2 - 6)/2 ; // Account for padding and spacing
    final imageHeight = cardWidth * 0.8; // Set image height proportional to width
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(productId: product.id!),
          ),
        );
      },
      child: Container(
        // Set explicit constraints to prevent overflow
        constraints: BoxConstraints(
          maxWidth: cardWidth,
          minHeight: 0, // Allow minimum height
        ),
        child: Card(
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          clipBehavior: Clip.hardEdge, // Ensure nothing exceeds the card boundaries
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Product image with fixed height
              SizedBox(
                height: imageHeight,
                width: double.infinity,
                child: product.image != null
                    ? CachedNetworkImage(
                        imageUrl: getImageUrl(product.image),
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.grey.shade300,
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey.shade200,
                          child: const Icon(
                            Icons.image_not_supported,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : Container(
                        color: Colors.grey.shade200,
                        child: const Icon(
                          Icons.image_not_supported,
                          color: Colors.grey,
                        ),
                      ),
              ),
              // Product info
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (product.brand != null)
                        Text(
                          product.brand!['name'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 4),
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF21D69F),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 