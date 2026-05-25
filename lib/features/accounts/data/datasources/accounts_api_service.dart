import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';

class AccountsApiService {
  const AccountsApiService(this._apiClient);

  final ApiClient _apiClient;

  Future<Response<dynamic>> getAccounts() =>
      _apiClient.get<dynamic>(ApiEndpoints.users);

  Future<Response<dynamic>> addAccount(Map<String, dynamic> data) {
    return _apiClient.post<dynamic>(ApiEndpoints.usersAdd, data: data);
  }
}
