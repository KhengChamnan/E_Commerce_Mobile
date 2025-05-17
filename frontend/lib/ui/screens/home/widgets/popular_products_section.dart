import 'package:flutter/material.dart';
import 'package:frontend/ui/providers/product_provider.dart';
import 'package:frontend/ui/screens/home/widgets/product_card.dart';
import 'package:frontend/ui/screens/product/product_list_screen.dart';
import 'package:provider/provider.dart';

class PopularProductsSection extends StatelessWidget {
  const PopularProductsSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with "See All" button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Most Popular',
                  style: TextStyle(
                    fontFamily: 'Quicksand',
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProductListScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'SEE ALL',
                    style: TextStyle(
                      fontFamily: 'Quicksand',
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Show loading/error/empty state if needed
            if (productProvider.products.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (productProvider.products.hasError)
              Center(
                child: Text(
                  'Failed to load products: ${productProvider.products.error}',
                ),
              )
            else if (productProvider.products.hasData)
              Builder(
                builder: (context) {
                  final popularProducts =
                      productProvider.products.data!
                          .where((product) => product.price > 50)
                          .toList();

                  if (popularProducts.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: Text('No popular products available'),
                      ),
                    );
                  }

                  // ✅ FIXED HEIGHT to prevent overflow
                  final int rowCount = (popularProducts.length / 2).ceil();
                  final double cardHeight = 250; // Estimate per card
                  final double gridHeight =
                      (rowCount * cardHeight) + ((rowCount - 1) * 16);

                  return SizedBox(
                    height: gridHeight,
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 0.75,
                          ),
                      itemCount: popularProducts.length,
                      itemBuilder: (context, index) {
                        return ProductCard(product: popularProducts[index]);
                      },
                    ),
                  );
                },
              )
            else
              const Center(child: Text('No data available')),
          ],
        );
      },
    );
  }
} 