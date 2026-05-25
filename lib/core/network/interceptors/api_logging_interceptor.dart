import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiLoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint(
        '--> ${options.method} ${options.baseUrl}${options.path}\n'
        'Headers: ${options.headers}\n'
        'Query: ${options.queryParameters}\n'
        'Body: ${_prettyJson(options.data)}',
      );
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint(
        '<-- ${response.statusCode} ${response.requestOptions.method} '
        '${response.requestOptions.baseUrl}${response.requestOptions.path}\n'
        'Data: ${_prettyJson(response.data)}',
      );
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint(
        '<-- ERROR ${err.response?.statusCode ?? 'N/A'} '
        '${err.requestOptions.method} '
        '${err.requestOptions.baseUrl}${err.requestOptions.path}\n'
        'Message: ${err.message}\n'
        'Data: ${_prettyJson(err.response?.data)}',
      );
    }
    handler.next(err);
  }

  String _prettyJson(dynamic data) {
    if (data == null) return 'null';
    if (data is String) return data;
    try {
      return const JsonEncoder.withIndent('  ').convert(data);
    } catch (_) {
      return data.toString();
    }
  }
}
