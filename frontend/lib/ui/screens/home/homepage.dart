import 'package:flutter/material.dart';
import 'package:frontend/ui/providers/auth/auth_provider.dart';
import 'package:frontend/ui/screens/orders/order_screen.dart';
import 'package:frontend/ui/screens/profile/profile_screen.dart';
import 'package:provider/provider.dart';
import 'package:frontend/models/user.dart';
import 'package:frontend/ui/screens/auth/login_screen.dart';
import 'package:frontend/ui/screens/product/product_list_screen.dart';
import 'package:frontend/ui/providers/product_provider.dart';
import 'package:frontend/ui/screens/home/widgets/brand_filter.dart';
import 'package:frontend/ui/screens/home/widgets/popular_products_section.dart';
import 'package:frontend/ui/screens/home/widgets/promotional_banner.dart';
import 'package:frontend/ui/screens/home/widgets/search_bar.dart';
import 'package:frontend/ui/providers/cart_provider.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Fetch product data when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productProvider = Provider.of<ProductProvider>(
        context,
        listen: false,
      );
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      Provider.of<ProductProvider>(context, listen: false).fetchSlideshows();
      productProvider.fetchProducts(forceRefresh: true);
      productProvider.fetchBrands(forceRefresh: true);
      cartProvider.getCart();
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void logout(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Show loading dialog immediately
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text("Logging out..."),
              ],
            ),
          ),
    );

    try {
      // Navigate to login screen immediately but maintain loading dialog
      if (context.mounted) {
        // Use a delayed navigation to make sure the loading dialog is shown first
        Future.delayed(Duration.zero, () {
          // ignore: use_build_context_synchronously
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        });
      }

      // Perform logout in the background after navigation has started
      await authProvider.logout();
    } catch (e) {
      // Handle any errors during logout
      if (context.mounted && Navigator.canPop(context)) {
        Navigator.pop(context); // Close the dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error during logout: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getScreenForIndex(_selectedIndex),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // Helper method to return the appropriate screen based on the selected index
  Widget _getScreenForIndex(int index) {
    switch (index) {
      case 0:
        return _buildHomeTab();
      case 1:
        return const ProductListScreen(
          isFromBottomNav: true,
        );
      case 2: 
        return const OrderScreen();
         // Shop tab shows the ProductListScreen
      case 3:
        // Get real-time user data from AuthProvider and pass to ProfileScreen
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final userData = authProvider.user.data;
        return ProfileScreen(
          user: userData,
          onLogout: () => logout(context),
        );
      default:
        return Center(child: Text('Coming Soon!'));
    }
  }

  // Bottom navigation bar design
  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(
              icon: Icon(
                Icons.home_outlined,
                color:
                    _selectedIndex == 0
                        ? Theme.of(context).primaryColor
                        : Colors.black54,
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.storefront_outlined,
                color:
                    _selectedIndex == 1
                        ? Theme.of(context).primaryColor
                        : Colors.black54,
              ),
              label: 'Shop',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.shopping_bag_outlined,
                color:
                    _selectedIndex == 2
                        ? Theme.of(context).primaryColor
                        : Colors.black54,
              ),
              label: 'Orders',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.person_outline,
                color:
                    _selectedIndex == 3
                        ? Theme.of(context).primaryColor
                        : Colors.black54,
              ),
              label: 'Profile',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.black54,
          selectedLabelStyle: const TextStyle(
            fontFamily: 'Quicksand',
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: 'Quicksand',
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          onTap: _onItemTapped,
        ),
      ),
    );
  }

  Widget _buildHomeTab() {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Search and favorites bar
              const HomeSearchBar(),

              const SizedBox(height: 24),

              // Promotional banner
              const PromotionalBanner(),

              const SizedBox(height: 24),

              // Brand filter section
              const BrandFilter(),

              const SizedBox(height: 24),

              // Popular products section
              const PopularProductsSection(),
            ],
          ),
        ),
      ),
    );
  }

  

  
}
