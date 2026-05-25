import 'dart:convert';

import '../../../../core/network/api_result.dart';
import '../../domain/entities/account.dart';
import '../../domain/repositories/accounts_repository.dart';
import '../datasources/accounts_api_service.dart';
import '../models/account_model.dart';

class AccountsRepositoryImpl implements AccountsRepository {
  const AccountsRepositoryImpl(this._service);

  final AccountsApiService _service;

  static Map<String, dynamic> _toMap(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is String && raw.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) return decoded;
      } catch (_) {}
    }
    return {};
  }

  @override
  Future<ApiResult<List<Account>>> getAccounts() async {
    final response = await _service.getAccounts();
    final data = _toMap(response.data);
    final users = (data['users'] as List<dynamic>? ?? <dynamic>[])
        .whereType<Map<String, dynamic>>()
        .map(AccountModel.fromJson)
        .toList();

    return ApiResult<List<Account>>(
      statusCode: response.statusCode ?? 0,
      message: 'Fetched ${users.length} accounts.',
      data: users,
    );
  }

  @override
  Future<ApiResult<Account>> addAccount({
    required String firstName,
    required String lastName,
    required String email,
    required String username,
    required String password,
  }) async {
    final payload = AccountModel(
      firstName: firstName,
      lastName: lastName,
      email: email,
      username: username,
    ).toJson(password: password);

    final response = await _service.addAccount(payload);
    final data = _toMap(response.data);
    final account = AccountModel.fromJson(data);

    return ApiResult<Account>(
      statusCode: response.statusCode ?? 0,
      message: 'Account created successfully.',
      data: account,
    );
  }
}
