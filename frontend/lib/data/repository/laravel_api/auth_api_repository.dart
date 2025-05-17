import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../models/user.dart';
import '../../dto/user_dto.dart';
import '../../network/api_constant.dart';
import '../../network/api_exception.dart';
import '../../network/network_error_handler.dart';
import '../auth_repository.dart';

class LaravelAuthRepository extends AuthRepository {
  // Token storage key
  static const String _tokenKey = 'auth_token';
  
  // Token expiration buffer (refresh token if less than 5 minutes left)
  static const int _expirationBufferMinutes = 5;

  // Secure storage instance
  final FlutterSecureStorage _secureStorage;

  // HTTP client for API requests
  final http.Client _client;

  // Cache login state
  bool _cachedLoginState = false;

  // Constructor with optional parameters for testing
  LaravelAuthRepository({
    http.Client? client,
    FlutterSecureStorage? secureStorage,
  }) : _client = client ?? http.Client(),
       _secureStorage = secureStorage ?? const FlutterSecureStorage() {
    // Initialize login state asynchronously
    updateLoginState();
  }

  @override
  Future<String> login(String email, String password) async {
    return NetworkErrorHandler.execute(() async {
      final response = await _client.post(
        Uri.parse(ApiConstant.login),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(UserDto.toLoginJson(email, password)),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        // Store the token securely
        final String token = data['access_token'];
        await _saveToken(token);
        
        // Update login state cache
        _cachedLoginState = true;

        return token;
      } else {
        final Map<String, dynamic> error = jsonDecode(response.body);
        throw ApiException(
          message: error['message'] ?? 'Login failed',
          statusCode: response.statusCode,
        );
      }
    }, operationName: 'Login');
  }

  @override
  Future<String> registerWithConfirmation(
    User user,
    String passwordConfirmation,
  ) async {
    return NetworkErrorHandler.execute(() async {
      final response = await _client.post(
        Uri.parse(ApiConstant.register),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(
          UserDto.toRegistrationWithConfirmationJson(
            user,
            passwordConfirmation,
          ),
        ),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        // Store the token securely
        final String token = data['access_token'];
        await _saveToken(token);

        return token;
      } else {
        final Map<String, dynamic> error = jsonDecode(response.body);
        // Better error handling for validation errors
        if (response.statusCode == 422 && error.containsKey('errors')) {
          // Format validation errors in a user-friendly way
          final Map<String, dynamic> errors = error['errors'];
          final List<String> errorMessages = [];

          errors.forEach((field, messages) {
            if (messages is List) {
              for (var message in messages) {
                errorMessages.add(message.toString());
              }
            }
          });

          if (errorMessages.isNotEmpty) {
            throw ApiException(
              message: errorMessages.join('\n'),
              statusCode: 422,
            );
          }
        }

        throw ApiException(
          message: error['message'] ?? 'Registration failed',
          statusCode: response.statusCode,
        );
      }
    }, operationName: 'Registration');
  }

  @override
  Future<bool> logout() async {
    return NetworkErrorHandler.execute(() async {
      final token = await getToken();

      if (token == null) {
        // Already logged out
        _cachedLoginState = false;
        return true;
      }

      final response = await _client.post(
        Uri.parse(ApiConstant.logout),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      // Clear token regardless of response
      await _clearToken();
      _cachedLoginState = false;

      return response.statusCode == 200 || response.statusCode == 204;
    }, operationName: 'Logout');
  }

  @override
  Future<User> getCurrentUser() async {
    return NetworkErrorHandler.execute(() async {
      final token = await getValidToken();

      if (token == null) {
        throw ApiException(message: 'Not authenticated', statusCode: 401);
      }

      try {
        final response = await _client.post(
          Uri.parse(ApiConstant.me),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ).timeout(const Duration(seconds: 10)); // Add timeout

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = jsonDecode(response.body);
          return UserDto.fromJson(data);
        } else {
          // Better error handling for unexpected responses
          String errorMessage;
          try {
            final Map<String, dynamic> error = jsonDecode(response.body);
            errorMessage = error['message'] ?? 'Failed to get user profile';
          } catch (e) {
            // Handle case where response body isn't valid JSON
            errorMessage = 'Invalid response from server: ${response.body}';
          }
          throw ApiException(
            message: errorMessage,
            statusCode: response.statusCode,
          );
        }
      } catch (e) {
        if (e is ApiException) {
          rethrow;
        }
        // More verbose error message for debugging
        print('Auth API error: ${e.toString()}');
        if (e is TimeoutException) {
          throw ApiException(
            message: 'Connection timed out. Server might be unreachable.',
            statusCode: 0,
            networkError: true,
          );
        }
        // Rethrow to be handled by NetworkErrorHandler
        rethrow;
      }
    }, operationName: 'Get User Profile');
  }

  @override
  Future<String> refreshToken() async {
    return NetworkErrorHandler.execute(() async {
      final token = await getToken();

      if (token == null) {
        throw ApiException(message: 'Not authenticated', statusCode: 401);
      }

      try {
        final response = await _client.post(
          Uri.parse(ApiConstant.refresh),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ).timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = jsonDecode(response.body);

          // Store the new token securely
          final String newToken = data['access_token'];
          await _saveToken(newToken);

          return newToken;
        } else {
          String errorMessage;
          try {
            final Map<String, dynamic> error = jsonDecode(response.body);
            errorMessage = error['message'] ?? 'Failed to refresh token';
          } catch (e) {
            errorMessage = 'Invalid response from server during token refresh';
          }
          throw ApiException(
            message: errorMessage,
            statusCode: response.statusCode,
          );
        }
      } catch (e) {
        if (e is ApiException) {
          rethrow;
        }
        // More verbose error message for debugging
        print('Token refresh error: ${e.toString()}');
        if (e is TimeoutException) {
          throw ApiException(
            message: 'Connection timed out during token refresh.',
            statusCode: 0,
            networkError: true,
          );
        }
        rethrow;
      }
    }, operationName: 'Token Refresh');
  }

  @override
  bool isLoggedIn() {
    // Return the cached login state - which is updated during login/logout operations
    return _cachedLoginState;
  }

  // Make this method public so it can be called from outside
  Future<bool> updateLoginState() async {
    final token = await getToken();
    _cachedLoginState = token != null && token.isNotEmpty;
    return _cachedLoginState;
  }

  // Helper methods for secure token management

  Future<void> _saveToken(String token) async {
    await _secureStorage.write(key: _tokenKey, value: token);
    _cachedLoginState = true;
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  Future<void> _clearToken() async {
    await _secureStorage.delete(key: _tokenKey);
    _cachedLoginState = false;
  }
  
  /// Check if the current token is expired or about to expire
  Future<bool> isTokenExpired() async {
    final token = await getToken();
    if (token == null) return true;
    
    // JWT tokens are Base64Url encoded with three parts separated by dots
    final parts = token.split('.');
    if (parts.length != 3) return true;

    try {
      // The payload is in the second part - decode and normalize Base64Url
      final normalized = base64Url.normalize(parts[1]);
      final payloadJson = utf8.decode(base64Url.decode(normalized));
      final payload = json.decode(payloadJson);
      
      // Check the expiration time
      final exp = payload['exp'] as int?;
      if (exp == null) return true;
      
      // Get current time in seconds since epoch
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      
      // Return true if token is expired or will expire within buffer time
      final bufferSeconds = _expirationBufferMinutes * 60;
      return now + bufferSeconds >= exp;
    } catch (e) {
      print('Error checking token expiration: $e');
      return true; // If there's any error parsing, consider token expired
    }
  }

  /// Get a valid token, refreshing if necessary
  Future<String?> getValidToken() async {
    final token = await getToken();
    if (token == null) {
      _cachedLoginState = false;
      return null;
    }
    
    // Check if token is expired or about to expire
    if (await isTokenExpired()) {
      try {
        // Try to refresh the token
        return await refreshToken();
      } catch (e) {
        // If refreshing fails, clear token and return null
        print('Token refresh failed: $e');
        await _clearToken();
        _cachedLoginState = false;
        return null;
      }
    }
    
    return token;
  }
}