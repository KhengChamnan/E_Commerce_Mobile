class ApiException implements Exception {
  final String message;
  final int statusCode;
  final bool networkError;
  
  ApiException({
    required this.message,
    required this.statusCode,
    this.networkError = false,
  });

  @override
  String toString() {
    return 'ApiException: $message (Status code: $statusCode)';
  }

  /// Check if this is an authentication error (unauthorized)
  bool get isAuthError => statusCode == 401;
  
  /// Check if this is a validation error
  bool get isValidationError => statusCode == 422;
  
  /// Check if this is a server error
  bool get isServerError => statusCode >= 500 && statusCode < 600;
}