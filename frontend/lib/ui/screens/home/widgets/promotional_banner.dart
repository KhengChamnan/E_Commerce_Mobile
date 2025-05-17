import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:frontend/data/network/api_constant.dart';
import 'package:frontend/ui/providers/product_provider.dart';
import 'package:provider/provider.dart';

class PromotionalBanner extends StatelessWidget {
  const PromotionalBanner({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        return SizedBox(
          height: 140,
          child: (() {
            if (productProvider.slideshows.isLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (productProvider.slideshows.hasError) {
              return Center(
                child: Text(
                  'Failed to load slideshows: ${productProvider.slideshows.error.toString()}',
                ),
              );
            } else if (productProvider.slideshows.hasData) {
              // Filter out inactive slideshows
              final activeSlides = productProvider.slideshows.data!
                  .where((slideshow) => slideshow.enable)
                  .toList();

              if (activeSlides.isEmpty) {
                // Fallback to static banner if no active slideshows available
                return _buildStaticBanner();
              }

              return CarouselSlider.builder(
                itemCount: activeSlides.length,
                options: CarouselOptions(
                  height: 130,
                  viewportFraction: 0.95,
                  autoPlay: true,
                  enlargeCenterPage: true,
                  autoPlayCurve: Curves.fastOutSlowIn,
                  enableInfiniteScroll: true,
                  autoPlayAnimationDuration: const Duration(
                    milliseconds: 800,
                  ),
                  autoPlayInterval: const Duration(seconds: 3),
                ),
                itemBuilder: (context, index, realIndex) {
                  final slideshow = activeSlides[index];
                  // Determine background color based on slideshow index (odd/even)
                  final backgroundColor = index % 2 == 0
                      ? const Color(0xFFCF0221) // Red for even indexes
                      : Colors.white; // White for odd indexes

                  // Text color should contrast with background
                  final textColor = index % 2 == 0 ? Colors.white : Colors.black87;

                  return Container(
                    height: 130,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 0,
                          blurRadius: 4,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${slideshow.price.toStringAsFixed(0)}\$',
                                  style: TextStyle(
                                    fontFamily: 'Quicksand',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 29,
                                    color: textColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  slideshow.name,
                                  style: TextStyle(
                                    fontFamily: 'Quicksand',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 19,
                                    color: textColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  slideshow.description,
                                  style: TextStyle(
                                    fontFamily: 'Quicksand',
                                    fontSize: 10,
                                    color: textColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(22),
                              bottomRight: Radius.circular(22),
                            ),
                            child: slideshow.image.isNotEmpty
                                ? Image.network(
                                    ApiConstant.getSlideshowUrl(
                                      slideshow.image,
                                    ),
                                    fit: BoxFit.cover,
                                    height: 100,
                                    width: double.infinity,
                                    errorBuilder: (
                                      context,
                                      error,
                                      stackTrace,
                                    ) {
                                      return Image.asset(
                                        'assets/shoeRack/promo_banner.png',
                                        fit: BoxFit.cover,
                                        height: 100,
                                        width: double.infinity,
                                      );
                                    },
                                  )
                                : Image.asset(
                                    'assets/shoeRack/promo_banner.png',
                                    fit: BoxFit.cover,
                                    height: 100,
                                    width: double.infinity,
                                  ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            } else {
              return _buildStaticBanner();
            }
          })(),
        );
      },
    );
  }

  Widget _buildStaticBanner() {
    return Container(
      height: 130,
      decoration: BoxDecoration(
        color: const Color(0xFFCF0221),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    '25%',
                    style: TextStyle(
                      fontFamily: 'Quicksand',
                      fontWeight: FontWeight.bold,
                      fontSize: 29,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Today Special',
                    style: TextStyle(
                      fontFamily: 'Quicksand',
                      fontWeight: FontWeight.bold,
                      fontSize: 19,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Get discount for every order\nOnly valid today',
                    style: TextStyle(
                      fontFamily: 'Quicksand',
                      fontSize: 10,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(22),
                bottomRight: Radius.circular(22),
              ),
              child: Image.asset(
                'assets/shoeRack/promo_banner.png',
                fit: BoxFit.cover,
                height: double.infinity,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 