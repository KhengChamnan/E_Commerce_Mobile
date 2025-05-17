import 'dart:async';
import 'dart:io';

import 'api_exception.dart';

/// Enhanced error handling for network requests
class NetworkErrorHandler {
  /// Handle different types of exceptions that can occur during network calls
  static ApiException handleError(Object e, {String customMessage = ''}) {
    final prefix = customMessage.isNotEmpty ? '$customMessage: ' : '';
    
    if (e is SocketException) {
      return ApiException(
        message: '${prefix}No internet connection. Please check your network.',
        statusCode: 0,
        networkError: true
      );
    } else if (e is TimeoutException) {
      return ApiException(
        message: '${prefix}Connection timed out. Please try again.',
        statusCode: 0,
        networkError: true
      );
    } else if (e is FormatException) {
      return ApiException(
        message: '${prefix}Invalid response format.',
        statusCode: 0,
        networkError: false
      );
    } else if (e is ApiException) {
      // Pass through ApiExceptions without modification
      return e;
    } else {
      return ApiException(
        message: '${prefix}Unexpected error: ${e.toString()}',
        statusCode: 0,
        networkError: false
      );
    }
  }
  
  /// Executes a network request with proper error handling
  static Future<T> execute<T>(
    Future<T> Function() networkCall, 
    {String operationName = 'Operation'}
  ) async {
    try {
      return await networkCall();
    } catch (e) {
      throw handleError(e, customMessage: operationName);
    }
  }
}