import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/data/network/api_constant.dart';
import 'package:frontend/ui/providers/product_details_provider.dart';
import 'package:frontend/ui/providers/product_provider.dart';
import 'package:frontend/ui/providers/cart_provider.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_add_to_cart_button/flutter_add_to_cart_button.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;

  const ProductDetailScreen({Key? key, required this.productId})
    : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  // Helper method to get the full image URL
  String getImageUrl(String? imagePath) {
    return ApiConstant.getProductImageUrl(imagePath);
  }

  @override
  void initState() {
    super.initState();
    // Fetch product details when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductDetailsProvider>().fetchProduct(widget.productId);
    });
  }

  // State variable to control the add to cart button animation
  AddToCartButtonStateId stateId = AddToCartButtonStateId.idle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<ProductDetailsProvider>(
        builder: (context, provider, child) {
          final productState = provider.product;

          // Show loading indicator while data is loading
          if (productState.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Show error message if there was an error
          if (productState.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${productState.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      provider.fetchProduct(widget.productId);
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Make sure we have data before using it
          if (productState.data == null) {
            return const Center(child: Text('No product data available'));
          }

          // Show product details when data is available
          final product = productState.data!;

          return Stack(
            children: [
              // Main content
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Image with back button
                    Stack(
                      children: [
                        // Product Image
                        Container(
                          width: double.infinity,
                          height: 350,
                          color: const Color(0xFFF1F1F1),
                          child: Hero(
                            tag: 'product-image-${product.id}',
                            child: CachedNetworkImage(
                              imageUrl: getImageUrl(product.image),
                              fit: BoxFit.contain,
                              placeholder:
                                  (context, url) => const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                              errorWidget: (context, url, error) {
                                return Container(
                                  color: Colors.grey.shade300,
                                  child: const Center(
                                    child: Icon(
                                      Icons.error_outline,
                                      size: 50,
                                      color: Colors.red,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                        // Back button
                        Positioned(
                          top: 50,
                          left: 20,
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: SvgPicture.asset(
                                'assets/shoeRack/icons/back_arrow.svg',
                                width: 20,
                                height: 20,
                                color: const Color(0xFF2D264B),
                              ),
                            ),
                          ),
                        ),

                        // Status bar spacer
                        Container(
                          height: MediaQuery.of(context).padding.top,
                          color: Colors.white,
                        ),
                      ],
                    ),

                    // Product Details Section
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Brand name
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                product.brand?['name'] ?? 'Brand',
                                style: const TextStyle(
                                  fontFamily: 'Quicksand',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 25,
                                ),
                              ),
                              
                            ],
                          ),

                          const SizedBox(height: 8),

                          // Product name
                          Text(
                            product.name,
                            style: const TextStyle(
                              fontFamily: 'Quicksand',
                              fontWeight: FontWeight.w400,
                              fontSize: 15,
                              color: Colors.black54,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Price
                          Text(
                            '\$${product.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontFamily: 'Quicksand',
                              fontWeight: FontWeight.w700,
                              fontSize: 30,
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Description
                          Text(
                            product.description,
                            style: const TextStyle(
                              fontFamily: 'Quicksand',
                              fontWeight: FontWeight.w300,
                              fontSize: 14,
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Categories title
                          Text(
                            product.category!['name'] ?? 'Categories',
                            style: TextStyle(
                              fontFamily: 'Quicksand',
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Build category products list
                          Consumer<ProductProvider>(
                            builder: (context, productProvider, child) {
                              // Start loading products if not already loaded
                              if (!productProvider.products.hasData &&
                                  !productProvider.products.isLoading) {
                                WidgetsBinding.instance.addPostFrameCallback((
                                  _,
                                ) {
                                  productProvider.fetchProducts();
                                });
                              }

                              // Show loading indicator if products are loading
                              if (productProvider.products.isLoading) {
                                return const SizedBox(
                                  height: 150,
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }

                              // Show error if products failed to load
                              if (productProvider.products.hasError) {
                                return SizedBox(
                                  height: 150,
                                  child: Center(
                                    child: Text(
                                      'Error loading products',
                                      style: TextStyle(color: Colors.red[400]),
                                    ),
                                  ),
                                );
                              }

                              // Get all products in this category
                              final allProducts =
                                  productProvider.products.data ?? [];
                              final categoryProducts =
                                  allProducts
                                      .where(
                                        (p) =>
                                            p.id != product.id &&
                                            p.categoryId == product.categoryId,
                                      )
                                      .toList();

                              if (categoryProducts.isEmpty) {
                                return const SizedBox(
                                  height: 150,
                                  child: Center(
                                    child: Text('No products in this category'),
                                  ),
                                );
                              }

                              return SizedBox(
                                height: 150,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: categoryProducts.length.clamp(
                                    0,
                                    5,
                                  ),
                                  itemBuilder: (context, index) {
                                    final categoryProduct =
                                        categoryProducts[index];

                                    return GestureDetector(
                                      onTap: () {
                                        // Navigate to the product details
                                        if (categoryProduct.id != product.id) {
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) =>
                                                      ProductDetailScreen(
                                                        productId:
                                                            categoryProduct.id!,
                                                      ),
                                            ),
                                          );
                                        }
                                      },
                                      child: Container(
                                        width: 120,
                                        margin: const EdgeInsets.only(
                                          right: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.05,
                                              ),
                                              blurRadius: 5,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Product image
                                            Expanded(
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.shade100,
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                        topLeft:
                                                            Radius.circular(8),
                                                        topRight:
                                                            Radius.circular(8),
                                                      ),
                                                ),
                                                child: Center(
                                                  child: CachedNetworkImage(
                                                    imageUrl: getImageUrl(
                                                      categoryProduct.image,
                                                    ),
                                                    fit: BoxFit.cover,
                                                    width: double.infinity,
                                                    height: double.infinity,
                                                    placeholder:
                                                        (
                                                          context,
                                                          url,
                                                        ) => const Center(
                                                          child: SizedBox(
                                                            width: 20,
                                                            height: 20,
                                                            child:
                                                                CircularProgressIndicator(
                                                                  strokeWidth:
                                                                      2,
                                                                ),
                                                          ),
                                                        ),
                                                    errorWidget:
                                                        (
                                                          context,
                                                          url,
                                                          error,
                                                        ) => const Icon(
                                                          Icons.error_outline,
                                                          color: Colors.grey,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                            ),

                                            // Product name and price
                                            Padding(
                                              padding: const EdgeInsets.all(
                                                8.0,
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    categoryProduct.name,
                                                    style: const TextStyle(
                                                      fontFamily: 'Quicksand',
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 12,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    '\$${categoryProduct.price.toStringAsFixed(2)}',
                                                    style: const TextStyle(
                                                      fontFamily: 'Quicksand',
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      fontSize: 12,
                                                      color: Color(0xFF21D69F),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 24),

                          const SizedBox(height: 24),

                          // Related products title
                          const Text(
                            "Similar Products",
                            style: TextStyle(
                              fontFamily: 'Quicksand',
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Build category products
                          Consumer<ProductProvider>(
                            builder: (context, productProvider, child) {
                              // Start loading products if not already loaded
                              if (!productProvider.products.hasData &&
                                  !productProvider.products.isLoading) {
                                WidgetsBinding.instance.addPostFrameCallback((
                                  _,
                                ) {
                                  productProvider.fetchProducts();
                                });
                              }

                              // Show loading indicator if products are loading
                              if (productProvider.products.isLoading) {
                                return const SizedBox(
                                  height: 150,
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }

                              // Show error if products failed to load
                              if (productProvider.products.hasError) {
                                return SizedBox(
                                  height: 150,
                                  child: Center(
                                    child: Text(
                                      'Error loading category products',
                                      style: TextStyle(color: Colors.red[400]),
                                    ),
                                  ),
                                );
                              }

                              // Get all products in this category except current one
                              final allProducts =
                                  productProvider.products.data ?? [];
                              final categoryProducts =
                                  allProducts
                                      .where(
                                        (p) =>
                                            p.id != product.id &&
                                            p.categoryId == product.categoryId,
                                      )
                                      .toList();

                              if (categoryProducts.isEmpty) {
                                return const SizedBox(
                                  height: 150,
                                  child: Center(
                                    child: Text(
                                      'No other products in this category',
                                    ),
                                  ),
                                );
                              }

                              return SizedBox(
                                height: 150,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: categoryProducts.length.clamp(
                                    0,
                                    5,
                                  ),
                                  itemBuilder: (context, index) {
                                    final categoryProduct =
                                        categoryProducts[index];

                                    return GestureDetector(
                                      onTap: () {
                                        // Navigate to the product details
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) =>
                                                    ProductDetailScreen(
                                                      productId:
                                                          categoryProduct.id!,
                                                    ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        width: 120,
                                        margin: const EdgeInsets.only(
                                          right: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.05,
                                              ),
                                              blurRadius: 5,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Product image
                                            Expanded(
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.shade100,
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                        topLeft:
                                                            Radius.circular(8),
                                                        topRight:
                                                            Radius.circular(8),
                                                      ),
                                                ),
                                                child: Center(
                                                  child: CachedNetworkImage(
                                                    imageUrl: getImageUrl(
                                                      categoryProduct.image,
                                                    ),
                                                    fit: BoxFit.cover,
                                                    width: double.infinity,
                                                    height: double.infinity,
                                                    placeholder:
                                                        (
                                                          context,
                                                          url,
                                                        ) => const Center(
                                                          child: SizedBox(
                                                            width: 20,
                                                            height: 20,
                                                            child:
                                                                CircularProgressIndicator(
                                                                  strokeWidth:
                                                                      2,
                                                                ),
                                                          ),
                                                        ),
                                                    errorWidget:
                                                        (
                                                          context,
                                                          url,
                                                          error,
                                                        ) => const Icon(
                                                          Icons.error_outline,
                                                          color: Colors.grey,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                            ),

                                            // Product name and price
                                            Padding(
                                              padding: const EdgeInsets.all(
                                                8.0,
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    categoryProduct.name,
                                                    style: const TextStyle(
                                                      fontFamily: 'Quicksand',
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 12,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    '\$${categoryProduct.price.toStringAsFixed(2)}',
                                                    style: const TextStyle(
                                                      fontFamily: 'Quicksand',
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      fontSize: 12,
                                                      color: Color(0xFF21D69F),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),

                          const SizedBox(
                            height: 80,
                          ), // Space for the bottom button
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Add to Cart button
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    height: 50,
                    child: AddToCartButton(
                      trolley: SvgPicture.asset(
                        'assets/shoeRack/icons/cart_icon.svg',
                        width: 20,
                        height: 20,
                        color: Colors.white,
                      ),
                      text: const Text(
                        "Add to Cart",
                        style: TextStyle(
                          fontFamily: 'Quicksand',
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                      check: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 30,
                      ),
                      borderRadius: BorderRadius.circular(15),
                      backgroundColor: const Color(0xFF21D69F),
                      onPressed: (id) {
                        if (id == AddToCartButtonStateId.idle) {
                          // Handle logic when pressed on idle state
                          setState(() {
                            stateId = AddToCartButtonStateId.loading;
                          });
                          
                          // Get the product details from the provider
                          final product = context.read<ProductDetailsProvider>().product.data;
                          
                          // Add the product to the cart
                          if (product != null) {
                            context.read<CartProvider>().addToCart(product.id!, 1).then((_) {
                              // Change to done state after successful addition
                              setState(() {
                                stateId = AddToCartButtonStateId.done;
                              });
                              
                              // Auto reset to idle state after 2 seconds
                              Future.delayed(const Duration(seconds: 2), () {
                                if (mounted) {
                                  setState(() {
                                    stateId = AddToCartButtonStateId.idle;
                                  });
                                }
                              });
                              
                            }).catchError((error) {
                              // Change back to idle state if there's an error
                              setState(() {
                                stateId = AddToCartButtonStateId.idle;
                              });
                              
                              
                            });
                          }
                        } else if (id == AddToCartButtonStateId.done) {
                          // Reset to idle state when clicked on done state
                          setState(() {
                            stateId = AddToCartButtonStateId.idle;
                          });
                        }
                      },
                      stateId: stateId,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
