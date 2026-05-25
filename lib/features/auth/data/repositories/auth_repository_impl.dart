import '../../../../core/network/api_result.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/entities/registered_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_api_service.dart';
import '../models/login_request_model.dart';
import '../models/login_response_model.dart';
import '../models/register_request_model.dart';
import '../models/register_response_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._service);

  final AuthApiService _service;

  @override
  Future<ApiResult<AuthUser>> login({
    required String username,
    required String password,
  }) async {
    final response = await _service.login(
      LoginRequestModel(username: username, password: password),
    );

    final data = (response.data as Map<String, dynamic>?) ?? {};
    final user = LoginResponseModel.fromJson(data);

    return ApiResult<AuthUser>(
      statusCode: response.statusCode ?? 0,
      message: _messageOrFallback(data),
      data: user,
    );
  }

  @override
  Future<ApiResult<RegisteredUser>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String username,
    required String password,
    required String country,
    required String role,
  }) async {
    final response = await _service.register(
      RegisterRequestModel(
        firstName: firstName,
        lastName: lastName,
        email: email,
        username: username,
        password: password,
        country: country,
        role: role,
      ),
    );

    final data = (response.data as Map<String, dynamic>?) ?? {};
    final user = RegisterResponseModel.fromJson(data);

    return ApiResult<RegisteredUser>(
      statusCode: response.statusCode ?? 0,
      message: 'Registration successful.',
      data: user,
    );
  }

  String _messageOrFallback(Map<String, dynamic> data) {
    final dynamic message = data['message'] ?? data['error'] ?? data['title'];
    if (message is String && message.trim().isNotEmpty) {
      return message;
    }
    return 'Login successful.';
  }
}
