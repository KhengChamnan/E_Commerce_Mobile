import 'dart:async';
import 'package:frontend/data/repository/auth_repository.dart';
import 'package:frontend/data/repository/laravel_api/auth_api_repository.dart';
import 'package:frontend/models/user.dart';

/// AuthService handles the business logic for authentication
/// separate from UI state management
class AuthService {
  // Repository instance
  final AuthRepository _repository;
  
  // Token expiration check interval
  
  // Constructor
  AuthService({AuthRepository? repository}) 
    : _repository = repository ?? LaravelAuthRepository();
    
  /// Authenticates a user and returns the user data
  Future<User> authenticateUser(String email, String password) async {
    // Perform login
    await _repository.login(email, password);
    
    // After successful login, get the user data
    return await _repository.getCurrentUser();
  }
  
  /// Registers a new user with password confirmation
  Future<User> registerUser(User user, String passwordConfirmation) async {
    // Register the user
    await _repository.registerWithConfirmation(user, passwordConfirmation);
    
    // After successful registration, get the user data
    return await _repository.getCurrentUser();
  }
  
  /// Logs out the current user
  Future<bool> logout() async {
    return await _repository.logout();
  }
  
  /// Gets the current authenticated user
  Future<User> getCurrentUser() async {
    return await _repository.getCurrentUser();
  }
  
  /// Checks if the user is currently logged in
  bool isLoggedIn() {
    return _repository.isLoggedIn();
  }
  
  /// Refreshes the auth token if needed and returns the user data
  Future<User?> refreshTokenIfNeeded() async {
    if (!isLoggedIn()) {
      return null;
    }
    
    if (_repository is LaravelAuthRepository) {
      final laravelRepo = _repository;
      
      // Only refresh if token is expired
      if (await laravelRepo.isTokenExpired()) {
        await laravelRepo.refreshToken();
      }
      
      // Get updated user info
      return await getCurrentUser();
    } else {
      // For other repository implementations
      await _repository.refreshToken();
      return await getCurrentUser();
    }
  }
  
  /// Checks if the current token is valid
  Future<bool> isTokenValid() async {
    if (!isLoggedIn()) {
      return false;
    }
    
    if (_repository is LaravelAuthRepository) {
      return !await (_repository).isTokenExpired();
    }
    
    return true; // Default for other repositories
  }
  
  /// Gets the current token
  Future<String?> getToken() async {
    if (_repository is LaravelAuthRepository) {
      return await (_repository).getToken();
    }
    
    return null;
  }
  
  /// Gets a valid token, refreshing if necessary
  Future<String?> getValidToken() async {
    if (_repository is LaravelAuthRepository) {
      return await (_repository).getValidToken();
    }
    
    return null;
  }
  
  /// Updates the login state in the repository
  Future<bool> updateLoginState() async {
    if (_repository is LaravelAuthRepository) {
      return await (_repository).updateLoginState();
    }
    
    return isLoggedIn();
  }
}