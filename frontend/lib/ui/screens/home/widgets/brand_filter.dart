import 'package:flutter/material.dart';
import 'package:frontend/data/network/api_constant.dart';
import 'package:frontend/ui/providers/product_provider.dart';
import 'package:frontend/ui/screens/product/product_list_screen.dart';
import 'package:provider/provider.dart';

class BrandFilter extends StatelessWidget {
  const BrandFilter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 90,
              child: (() {
                if (productProvider.brands.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (productProvider.brands.hasError) {
                  return Center(
                    child: Text(
                      'Failed to load brands: ${productProvider.brands.error.toString()}',
                    ),
                  );
                } else if (productProvider.brands.hasData) {
                  final brands = productProvider.brands.data!;

                  if (brands.isEmpty) {
                    return const Center(child: Text('No brands available'));
                  }

                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: brands.length + 1, // +1 for "See All" option
                    itemBuilder: (context, index) {
                      // Handle "See All" as the last item
                      if (index == brands.length) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: Column(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFD9D9D9),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.more_horiz,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(height: 4),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const ProductListScreen(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'See All',
                                  style: TextStyle(
                                    fontFamily: 'Quicksand',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      // Regular brand items
                      final brand = brands[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductListScreen(
                                brandId: brand.id,
                                brandName: brand.name,
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: Column(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFD9D9D9),
                                  shape: BoxShape.circle,
                                ),
                                child: brand.logo != null &&
                                        brand.logo!.isNotEmpty
                                    ? ClipOval(
                                        child: Image.network(
                                          ApiConstant.getBrandLogoUrl(
                                            brand.logo,
                                          ),
                                          fit: BoxFit.cover,
                                          width: 60,
                                          height: 60,
                                          errorBuilder: (
                                            context,
                                            error,
                                            stackTrace,
                                          ) {
                                            return const Icon(
                                              Icons.shopping_bag_outlined,
                                              color: Colors.grey,
                                            );
                                          },
                                        ),
                                      )
                                    : const Icon(
                                        Icons.shopping_bag_outlined,
                                        color: Colors.grey,
                                      ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                brand.name,
                                style: const TextStyle(
                                  fontFamily: 'Quicksand',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  return const Center(child: Text('No data available'));
                }
              })(),
            ),
          ],
        );
      },
    );
  }
} 