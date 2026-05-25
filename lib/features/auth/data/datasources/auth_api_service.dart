import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/login_request_model.dart';
import '../models/register_request_model.dart';

class AuthApiService {
  const AuthApiService(this._apiClient);

  final ApiClient _apiClient;

  Future<Response<dynamic>> login(LoginRequestModel request) {
    return _apiClient.post<dynamic>(ApiEndpoints.login, data: request.toJson());
  }

  Future<Response<dynamic>> register(RegisterRequestModel request) {
    return _apiClient.post<dynamic>(
      ApiEndpoints.register,
      data: request.toJson(),
    );
  }
}
