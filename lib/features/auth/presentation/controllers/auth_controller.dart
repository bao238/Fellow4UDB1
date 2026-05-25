import '../../../../core/config/api_config.dart';
import '../../../../core/auth/auth_session.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_result.dart';
import '../../data/datasources/auth_api_service.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/entities/registered_user.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthController {
  AuthController() {
    _apiClient = ApiClient(
      baseUrl: ApiConfig.authBaseUrl,
      timeout: const Duration(milliseconds: ApiConfig.timeoutMs),
      enableLogging: true,
    );
    _repository = AuthRepositoryImpl(AuthApiService(_apiClient));
  }

  late final ApiClient _apiClient;
  late final AuthRepository _repository;

  String? _accessToken;

  String? get accessToken => _accessToken;

  Future<ApiResult<AuthUser>> login({
    required String username,
    required String password,
  }) async {
    final result = await _repository.login(
      username: username,
      password: password,
    );
    _accessToken = result.data?.accessToken;
    if (result.data != null) {
      AuthSession.save(result.data!);
    }
    return result;
  }

  Future<ApiResult<RegisteredUser>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String username,
    required String password,
    required String country,
    required String role,
  }) {
    return _repository.register(
      firstName: firstName,
      lastName: lastName,
      email: email,
      username: username,
      password: password,
      country: country,
      role: role,
    );
  }

  void logout() {
    _accessToken = null;
    AuthSession.clear();
  }
}
