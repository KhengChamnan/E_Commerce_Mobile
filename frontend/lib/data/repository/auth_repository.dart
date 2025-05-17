import '../../models/user.dart';

abstract class AuthRepository {
  // Login user and return a JWT token
  Future<String> login(String email, String password);
  
  
  // Register with password confirmation
  Future<String> registerWithConfirmation(User user, String passwordConfirmation);
  
  // Logout the user
  Future<bool> logout();
  
  // Get current user profile
  Future<User> getCurrentUser();
  
  // Refresh the token
  Future<String> refreshToken();
  
  // Check if user is logged in
  bool isLoggedIn();
}