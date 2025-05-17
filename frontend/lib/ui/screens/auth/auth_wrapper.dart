import 'package:flutter/material.dart';
import 'package:frontend/ui/providers/auth/auth_provider.dart';
import 'package:frontend/ui/screens/auth/login_screen.dart';
import 'package:frontend/ui/screens/home/homepage.dart';
import 'package:provider/provider.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _initializing = true;

  @override
  void initState() {
    super.initState();
    // Initialize authentication state when the widget is created
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    // Using Future.microtask ensures this runs after the widget is built
    Future.microtask(() async {
      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await authProvider.initAuth();
        if (mounted) {
          setState(() {
            _initializing = false;
          });
        }
      } catch (e) {
        debugPrint('Error initializing auth: $e');
        // Set initializing to false even if there's an error to show login screen
        if (mounted) {
          setState(() {
            _initializing = false;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator while initializing
    if (_initializing) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    // Now that initialization is complete, we can safely use the provider
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // Show loading indicator while checking authentication
        if (authProvider.user.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        // If there's an error in auth state, show login screen
        if (authProvider.user.hasError) {
          debugPrint("Auth error: ${authProvider.user.error}");
          return const LoginScreen();
        }
        
        // Get the user data and token state
        final userData = authProvider.user.data;
        final isLoggedIn = authProvider.isLoggedIn;
        
        debugPrint("AuthWrapper: isLoggedIn=$isLoggedIn, userData=${userData != null}");
        
        // If user is authenticated, show home screen, otherwise show login
        if (isLoggedIn && userData != null) {
          return const Homepage();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
