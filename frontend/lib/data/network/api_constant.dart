// frontend/lib/data/network/api_constant.dart
class ApiConstant {
  //

  //static const String baseUrl = 'http://192.168.1.51:8000/api';

  // Use this for local testing when running on a physical device
  // Make sure this matches your computer's IP address on your local network
  //static const String baseUrl = 'http://192.168.18.133:8000/api';

  // Using ngrok can sometimes cause connectivity issues due to its temporary nature
  // If you're experiencing issues, try using a local IP address instead
  static const String baseUrl = 'https://elegant-many-oyster.ngrok-free.app/api';

  //static const String baseUrl='http://10.100.100.143:8000/api';

  //static const String baseUrl='http://172.20.10.2:8000/api';

  // Use this for Android emulator
  //static const String baseUrl = 'http://10.0.2.2:8000/api';

  // Stripe Configuration
  static const String stripePublishableKey = 'API KEY';
  static const String stripeSecretKey= 'API KEY';

  // Storage URL (used for images)
  static String getStorageUrl() {
    // Remove the /api part from the baseUrl for storage paths
    final baseUrlWithoutApi = baseUrl.replaceAll('/api', '');
    return '$baseUrlWithoutApi/storage';
  }

  // Helper method to get product image URL
  static String getProductImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return 'https://via.placeholder.com/400';
    }
    
    // Clean up the path if it has any unexpected formatting
    String cleanPath = imagePath.trim();
    
    // Check if the image path is already a full URL
    if (cleanPath.startsWith('http')) {
      return cleanPath;
    }
    
    // Remove any leading slashes that might cause path issues
    if (cleanPath.startsWith('/')) {
      cleanPath = cleanPath.substring(1);
    }
    
    return '${getStorageUrl()}/products/$cleanPath';
  }

    // Helper method to get brand logo URL
static String getBrandLogoUrl(String? logoPath) {
  if (logoPath == null || logoPath.isEmpty) {
    return 'https://via.placeholder.com/400';
  }
  
  // Check if the logo path is already a full URL
  if (logoPath.startsWith('http')) {
    return logoPath;
  }
  
  return '${getStorageUrl()}/brands/$logoPath';
}

// Helper method to get slideshow image URL
static String getSlideshowUrl(String? imagePath) {
  if (imagePath == null || imagePath.isEmpty) {
    return 'https://via.placeholder.com/400';
  }
  
  // Check if the image path is already a full URL
  if (imagePath.startsWith('http')) {
    return imagePath;
  }
  
  return '${getStorageUrl()}/slideshows/$imagePath';
}

  // Auth Endpoints 
  static const String login = '$baseUrl/auth/login/';
  static const String register = '$baseUrl/auth/register/';
  static const String logout = '$baseUrl/auth/logout/';
  static const String me = '$baseUrl/auth/me';
  static const String refresh = '$baseUrl/auth/refresh';

  // Product Endpoints
  static const String products = '$baseUrl/products';
  static const String productDetail = '$baseUrl/products/{id}'; // Replace {id} with actual product ID

  // Brand Endpoints
  static const String brands = '$baseUrl/brands';

  // Category Endpoints
  static const String categories = '$baseUrl/categories';
  
  // Slideshow Endpoints
  static const String slideshows = '$baseUrl/slideshows';
  
  // Cart Endpoints
  static const String getCart = '$baseUrl/cart';
  static const String addToCart = '$baseUrl/cart/add';
  static const String updateCartItem = '$baseUrl/cart/items/{id}'; // Replace {id} with actual cart item ID
  static const String removeCartItem = '$baseUrl/cart/items/{id}'; // Replace {id} with actual cart item ID
  static const String clearCart = '$baseUrl/cart/clear';

  // Order Endpoints
  static const String orders = '$baseUrl/orders';
  static const String createOrder = '$baseUrl/orders/create';
  static const String orderDetail = '$baseUrl/orders/{id}'; // Replace {id} with actual order ID
  static const String updateOrderStatus = '$baseUrl/orders/{id}/status'; // Replace {id} with actual order ID


  // Payment Endpoints
  static const String createPaymentIntent = '$baseUrl/payments/intent';
}