import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

enum ApiErrorType {
  unauthorized,
  forbidden,
  notFound,
  validation,
  server,
  network,
  timeout,
  cancelled,
  unknown,
}

class ApiException implements Exception {
  const ApiException({
    required this.type,
    required this.message,
    this.statusCode,
  });

  final ApiErrorType type;
  final String message;
  final int? statusCode;

  factory ApiException.fromDioException(DioException error) {
    if (error.type == DioExceptionType.cancel) {
      return const ApiException(
        type: ApiErrorType.cancelled,
        message: 'Request was cancelled.',
      );
    }

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return const ApiException(
        type: ApiErrorType.timeout,
        message: 'Request timeout. Please try again.',
      );
    }

    if (error.type == DioExceptionType.badResponse) {
      final statusCode = error.response?.statusCode;
      final message =
          _extractMessage(error.response?.data) ??
          'Request failed with status code $statusCode';
      return ApiException(
        type: _mapStatusCode(statusCode),
        statusCode: statusCode,
        message: message,
      );
    }

    if (error.type == DioExceptionType.connectionError) {
      final host = error.requestOptions.uri.host.toLowerCase();
      final isLocalHost =
          host == 'localhost' || host == '127.0.0.1' || host.endsWith('.local');
      return ApiException(
        type: ApiErrorType.network,
        message: isLocalHost
            ? 'Cannot connect to local API server. Make sure the backend is running.'
            : 'Cannot connect to the API server. Please check the deployment URL.',
      );
    }

    // Trên mobile/desktop: kiểm tra SocketException qua error.error
    if (!kIsWeb) {
      final sourceError = error.error;
      if (sourceError != null && sourceError.toString().contains('SocketException')) {
        final host = error.requestOptions.uri.host.toLowerCase();
        final isLocalHost =
            host == 'localhost' || host == '127.0.0.1' || host.endsWith('.local');
        return ApiException(
          type: ApiErrorType.network,
          message: isLocalHost
              ? 'Cannot connect to local API server. Make sure the backend is running.'
              : 'Cannot connect to the API server. Please check the deployment URL.',
        );
      }
    }

    return ApiException(
      type: ApiErrorType.unknown,
      message: error.message ?? 'Unexpected error occurred.',
    );
  }

  static String? _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      final dynamic rawMessage =
          data['message'] ?? data['error'] ?? data['title'] ?? data['detail'];
      if (rawMessage is String && rawMessage.trim().isNotEmpty) {
        return rawMessage;
      }
    }
    // data là String (HTML hoặc plain text từ server lỗi)
    if (data is String && data.trim().isNotEmpty) {
      if (data.trimLeft().startsWith('<')) {
        return 'Server returned an unexpected response.';
      }
      final trimmed = data.trim();
      return trimmed.length > 200 ? '${trimmed.substring(0, 200)}...' : trimmed;
    }
    return null;
  }

  static ApiErrorType _mapStatusCode(int? statusCode) {
    switch (statusCode) {
      case 401:
        return ApiErrorType.unauthorized;
      case 403:
        return ApiErrorType.forbidden;
      case 404:
        return ApiErrorType.notFound;
      case 422:
        return ApiErrorType.validation;
      default:
        if (statusCode != null && statusCode >= 500) {
          return ApiErrorType.server;
        }
        return ApiErrorType.unknown;
    }
  }

  @override
  String toString() =>
      'ApiException(type: $type, statusCode: $statusCode, message: $message)';
}
