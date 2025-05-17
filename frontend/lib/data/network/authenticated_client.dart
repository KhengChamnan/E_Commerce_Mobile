import 'package:http/http.dart' as http;
import 'package:frontend/data/repository/laravel_api/auth_api_repository.dart';

/// HTTP client that automatically adds authentication headers and handles token refreshing
class AuthenticatedClient extends http.BaseClient {
  final http.Client _inner;
  final LaravelAuthRepository _authRepository;
  
  // Authentication-exempt routes (don't need token)
  final List<String> _publicRoutes = [
    '/auth/login',
    '/auth/register',
    '/auth/password/reset',
  ];

  AuthenticatedClient(this._inner, this._authRepository);
  
  /// Check if a URL is for a public route that doesn't need authentication
  bool _isPublicRoute(Uri url) {
    return _publicRoutes.any((route) => url.path.contains(route));
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    // Skip authentication for public routes
    if (_isPublicRoute(request.url)) {
      return _inner.send(request);
    }
    
    // Get valid token (this will refresh if needed)
    final token = await _authRepository.getValidToken();
    
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    
    return _inner.send(request);
  }
  
  @override
  void close() {
    _inner.close();
    super.close();
  }
}