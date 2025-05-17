import 'package:flutter/material.dart';
import 'package:frontend/data/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'ui/screens/auth/auth_wrapper.dart';
import 'ui/providers/auth/auth_provider.dart';
import 'data/repository/laravel_api/product_api_repository.dart';
import 'data/repository/laravel_api/cart_api_repository.dart';
import 'ui/providers/product_provider.dart';
import 'ui/providers/product_details_provider.dart';
import 'ui/providers/cart_provider.dart';
import 'ui/providers/order_provider.dart';
import 'data/repository/laravel_api/order_api_repository.dart';
import 'ui/providers/payment_provider.dart';
import 'data/services/payment_service.dart';
import 'data/repository/laravel_api/payment_repository.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'data/network/api_constant.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  bool stripeInitialized = false;
  
  try {
    // Initialize Stripe with the publishable key from ApiConstant
    print('Initializing Stripe with key: ${ApiConstant.stripePublishableKey}');
    Stripe.publishableKey = ApiConstant.stripePublishableKey;
    await Stripe.instance.applySettings();
    print('Stripe initialized successfully');
    stripeInitialized = true;
  } catch (e) {
    print('Error initializing Stripe: $e');
    // Continue even if Stripe fails to initialize
  }
  
  runApp(
    MultiProvider(
      providers: [
        Provider<AuthService>(
          create: (_) => AuthService(),
        ),
        ChangeNotifierProxyProvider<AuthService, AuthProvider>(
          create: (context) => AuthProvider(
            authService: context.read<AuthService>(),
          ),
          update: (context, authService, previous) => 
            previous ?? AuthProvider(authService: authService),
        ),
        ChangeNotifierProvider(
          create: (context) => ProductProvider(repository: LaravelProductRepository()),
        ),
        ChangeNotifierProvider(
          create: (context) => ProductDetailsProvider(repository: LaravelProductRepository()),
        ),
        ChangeNotifierProvider(
          create: (context) => CartProvider(repository: LaravelCartRepository()),
        ),
        ChangeNotifierProvider(
          create: (context) => OrderProvider(repository: LaravelOrderRepository()),
        ),
        ChangeNotifierProvider(
          create: (context) => PaymentProvider(
            paymentService: PaymentService(
              repository: PaymentRepository(),
              stripeInitialized: stripeInitialized,
            ),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
        ),
      ),
      home: const AuthWrapper(), // Use AuthWrapper instead of LoginScreen
    );
  }
}

