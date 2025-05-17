import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend/data/services/auth_service.dart';
import 'package:frontend/data/network/api_exception.dart';
import 'package:frontend/models/user.dart';
import 'package:frontend/ui/providers/async_value.dart';

class AuthProvider extends ChangeNotifier {
  // Service for authentication business logic
  final AuthService _authService;
  
  // Timer for background token refresh
  Timer? _tokenRefreshTimer;
  
  // Token refresh interval (5 minutes)
  static const Duration _tokenRefreshInterval = Duration(minutes: 5);
  
  // Authentication state
  AsyncValue<User?> _user = AsyncValue.loading();
  AsyncValue<String?> _token = AsyncValue.loading();
  
  // Network error status
  bool _hasNetworkError = false;
  
  // Constructor
  AuthProvider({AuthService? authService}) 
    : _authService = authService ?? AuthService() {
    // Start token refresh timer when provider is created
    _startTokenRefreshTimer();
  }
  
  @override
  void dispose() {
    _stopTokenRefreshTimer();
    super.dispose();
  }
  
  // Getters
  AsyncValue<User?> get user => _user;
  AsyncValue<String?> get token => _token;
  bool get hasNetworkError => _hasNetworkError;
  
  // Check if user is logged in
  bool get isLoggedIn => _authService.isLoggedIn() && 
      _user.data != null && 
      !_user.isLoading && 
      !_user.hasError;
  
  // Start background token refresh timer
  void _startTokenRefreshTimer() {
    _stopTokenRefreshTimer(); // Ensure no duplicate timers
    
    // Set up periodic token refresh if user is logged in
    _tokenRefreshTimer = Timer.periodic(_tokenRefreshInterval, (_) {
      if (isLoggedIn) {
        // Silently refresh token in background
        _silentTokenRefresh();
      }
    });
  }
  
  // Stop background token refresh timer
  void _stopTokenRefreshTimer() {
    _tokenRefreshTimer?.cancel();
    _tokenRefreshTimer = null;
  }
  
  // Silent token refresh that doesn't update UI unless there's an error
  Future<void> _silentTokenRefresh() async {
    if (!isLoggedIn) return;
    
    try {
      // Use service to refresh token if needed
      await _authService.refreshTokenIfNeeded();
      
      // Reset network error flag on successful refresh
      _hasNetworkError = false;
    } catch (e) {
      // Only handle network errors silently
      if (e is ApiException && e.networkError) {
        _hasNetworkError = true;
        // Don't logout on network errors, try again later
      } else if (e is ApiException && e.isAuthError) {
        // Auth errors require logout
        await logout();
      }
      // Other errors are ignored in silent refresh
    }
  }
  
  // Initialize auth state - call this when app starts
  Future<void> initAuth() async {
    try {
      _user = AsyncValue.loading();
      _token = AsyncValue.loading();
      notifyListeners();
      
      // Update login state to ensure we have the latest status
      await _authService.updateLoginState();
      
      // Check if token is valid and refresh if needed
      if (!await _authService.isTokenValid()) {
        try {
          // Try to refresh token if expired
          await refreshToken();
        } catch (e) {
          // If refresh fails due to network error, still try to use cached user info
          if (e is ApiException && e.networkError) {
            _hasNetworkError = true;
            // Continue initialization with potentially stale token
          } else {
            // For auth or other errors, logout
            await logout();
            return;
          }
        }
      }
      
      if (_authService.isLoggedIn()) {
        try {
          // Get the current user
          final user = await _authService.getCurrentUser();
          _user = AsyncValue.success(user);
          
          // Get current token for UI purposes
          final token = await _authService.getToken();
          _token = AsyncValue.success(token);
          
          // Reset network error flag on success
          _hasNetworkError = false;
        } catch (e) {
          // If user fetch fails but it's a network error, keep the logged in state
          // but mark as having network issue
          if (e is ApiException && e.networkError) {
            _hasNetworkError = true;
            // Don't clear user state, try to use cached data if available
            if (_user.data == null) {
              _user = AsyncValue.success(User(
                id: 0, 
                name: 'Offline User', 
                email: 'offline@example.com', 
                password: ''
              ));
            }
          } else {
            // For auth or other errors, logout
            debugPrint('Auth initialization failed: $e');
            await _authService.logout();
            _user = AsyncValue.success(null);
            _token = AsyncValue.success(null);
          }
        }
      } else {
        // Not logged in
        _user = AsyncValue.success(null);
        _token = AsyncValue.success(null);
      }
    } catch (e) {
      debugPrint('Auth initialization error: $e');
      _user = AsyncValue.error(e);
      _token = AsyncValue.error(e);
    } finally {
      notifyListeners();
    }
  }
  
  // Login user
  Future<void> login(String email, String password) async {
    try {
      _user = AsyncValue.loading();
      _token = AsyncValue.loading();
      notifyListeners();
      
      // Use auth service to handle the authentication process
      final user = await _authService.authenticateUser(email, password);
      _user = AsyncValue.success(user);
      
      // Get the token after login
      final token = await _authService.getToken();
      _token = AsyncValue.success(token);
      
      // Reset network error flag on successful login
      _hasNetworkError = false;
      
      // Restart token refresh timer after successful login
      _startTokenRefreshTimer();
    } catch (e) {
      _token = AsyncValue.error(e);
      _user = AsyncValue.error(e);
      
      // Set network error flag if appropriate
      if (e is ApiException && e.networkError) {
        _hasNetworkError = true;
      }
    } finally {
      // Add a small delay to ensure state is properly updated
      await Future.delayed(const Duration(milliseconds: 100));
      notifyListeners();
    }
  }
  
  // Register user with password confirmation
  Future<void> registerWithConfirmation(User user, String passwordConfirmation) async {
    try {
      _user = AsyncValue.loading();
      _token = AsyncValue.loading();
      notifyListeners();
      
      // Use auth service to register the user
      final registeredUser = await _authService.registerUser(user, passwordConfirmation);
      _user = AsyncValue.success(registeredUser);
      
      // Get token after registration
      final token = await _authService.getToken();
      _token = AsyncValue.success(token);
      
      // Reset network error flag on successful registration
      _hasNetworkError = false;
      
      // Restart token refresh timer after successful registration
      _startTokenRefreshTimer();
    } catch (e) {
      _token = AsyncValue.error(e);
      _user = AsyncValue.error(e);
      
      // Set network error flag if appropriate
      if (e is ApiException && e.networkError) {
        _hasNetworkError = true;
      }
    } finally {
      notifyListeners();
    }
  }
  
  // Logout user
  Future<void> logout() async {
    try {
      // Skip the loading state when logging out to prevent UI flicker
      // Don't notify listeners yet to avoid showing "no user" message
      
      // Stop the token refresh timer
      _stopTokenRefreshTimer();
      
      await _authService.logout();
      
      // Set user and token to null after logout
      _user = AsyncValue.success(null);
      _token = AsyncValue.success(null);
      _hasNetworkError = false;
      
      // Only notify at the end after navigation should have started
      // This will be called after the navigation in the UI has already begun
    } catch (e) {
      // Even if logout fails on server, still clear local state
      _user = AsyncValue.success(null);
      _token = AsyncValue.success(null);
      _hasNetworkError = false;
    } finally {
      // Delay the notification slightly to ensure navigation has time to start
      await Future.delayed(const Duration(milliseconds: 50));
      notifyListeners();
    }
  }
  
  // Refresh token
  Future<void> refreshToken() async {
    try {
      if (!_authService.isLoggedIn()) {
        // If not logged in, skip refresh
        _token = AsyncValue.success(null);
        _user = AsyncValue.success(null);
        notifyListeners();
        return;
      }
      
      _token = AsyncValue.loading();
      notifyListeners();
      
      // Use service to refresh token
      final newToken = await _authService.getValidToken();
      _token = AsyncValue.success(newToken);
      _hasNetworkError = false;
    } catch (e) {
      debugPrint('Token refresh failed: $e');
      _token = AsyncValue.error(e);
      
      // Handle network errors specially
      if (e is ApiException && e.networkError) {
        _hasNetworkError = true;
        // For network errors, don't logout - try again later
      } else {
        // For auth or other errors, logout
        await logout();
      }
    } finally {
      notifyListeners();
    }
  }
  
  // Method to check and handle network reconnection
  Future<void> checkNetworkAndRefreshState() async {
    if (_hasNetworkError && isLoggedIn) {
      try {
        // Try to refresh token and user data
        await refreshToken();
        if (isLoggedIn) {
          final user = await _authService.getCurrentUser();
          _user = AsyncValue.success(user);
        }
        _hasNetworkError = false;
      } catch (e) {
        // Still having network issues, keep flag true
        if (e is ApiException && e.networkError) {
          _hasNetworkError = true;
        } else {
          // Other errors should logout
          await logout();
        }
      } finally {
        notifyListeners();
      }
    }
  }
}