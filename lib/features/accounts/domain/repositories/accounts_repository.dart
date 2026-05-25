import '../../../../core/network/api_result.dart';
import '../entities/account.dart';

abstract class AccountsRepository {
  Future<ApiResult<List<Account>>> getAccounts();

  Future<ApiResult<Account>> addAccount({
    required String firstName,
    required String lastName,
    required String email,
    required String username,
    required String password,
  });
}
