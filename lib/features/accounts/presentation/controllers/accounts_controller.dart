import '../../../../core/config/api_config.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_result.dart';
import '../../data/datasources/accounts_api_service.dart';
import '../../data/repositories/accounts_repository_impl.dart';
import '../../domain/entities/account.dart';
import '../../domain/repositories/accounts_repository.dart';

class AccountsController {
  AccountsController() {
    _apiClient = ApiClient(
      baseUrl: ApiConfig.authBaseUrl,
      timeout: const Duration(milliseconds: ApiConfig.timeoutMs),
      enableLogging: true,
    );
    _repository = AccountsRepositoryImpl(AccountsApiService(_apiClient));
  }

  late final ApiClient _apiClient;
  late final AccountsRepository _repository;

  Future<ApiResult<List<Account>>> getAccounts() => _repository.getAccounts();

  Future<ApiResult<Account>> addAccount({
    required String firstName,
    required String lastName,
    required String email,
    required String username,
    required String password,
  }) {
    return _repository.addAccount(
      firstName: firstName,
      lastName: lastName,
      email: email,
      username: username,
      password: password,
    );
  }
}
