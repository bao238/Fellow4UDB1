import 'package:flutter/foundation.dart';

class ApiConfig {
  ApiConfig._();

  static const String _defaultLocalApiUrl = 'http://localhost:3000';
  static const String _envBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );
  static const String _envAuthBaseUrl = String.fromEnvironment(
    'AUTH_BASE_URL',
    defaultValue: '',
  );

  static String get baseUrl {
    if (_envBaseUrl.isNotEmpty) return _envBaseUrl;
    // Khi deploy web production cùng origin với API thì dùng Uri.base.origin.
    // Khi chạy local (flutter run -d chrome), web app chạy ở port khác với
    // API server (localhost:3000), nên luôn dùng _defaultLocalApiUrl.
    if (kIsWeb && !_isLocalOrigin) return Uri.base.origin;
    return _defaultLocalApiUrl;
  }

  static String get authBaseUrl {
    if (_envAuthBaseUrl.isNotEmpty) return _envAuthBaseUrl;
    if (kIsWeb && !_isLocalOrigin) return Uri.base.origin;
    return _defaultLocalApiUrl;
  }

  /// Trả về true nếu web app đang chạy trên localhost / 127.0.0.1
  /// (tức là môi trường dev, không phải production).
  static bool get _isLocalOrigin {
    if (!kIsWeb) return false;
    final host = Uri.base.host;
    return host == 'localhost' || host == '127.0.0.1';
  }

  static const int timeoutMs = int.fromEnvironment(
    'API_TIMEOUT_MS',
    defaultValue: 15000,
  );

  static bool get isLocalApi =>
      baseUrl == _defaultLocalApiUrl || authBaseUrl == _defaultLocalApiUrl;

  static bool get hasCustomApiUrl =>
      baseUrl != _defaultLocalApiUrl || authBaseUrl != _defaultLocalApiUrl;
}
