import '../../../../core/network/api_result.dart';
import '../entities/auth_user.dart';
import '../entities/registered_user.dart';

abstract class AuthRepository {
  Future<ApiResult<AuthUser>> login({
    required String username,
    required String password,
  });

  Future<ApiResult<RegisteredUser>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String username,
    required String password,
    required String country,
    required String role,
  });
}
