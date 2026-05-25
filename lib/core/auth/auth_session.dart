import '../../features/auth/domain/entities/auth_user.dart';

class AuthSession {
  AuthSession._();

  static String? accessToken;
  static String? username;
  static String? email;
  static String? fullName;

  static bool get isLoggedIn =>
      accessToken != null && accessToken!.trim().isNotEmpty;

  static void save(AuthUser user) {
    accessToken = user.accessToken;
    username = user.username;
    email = user.email;
    fullName = '${user.firstName} ${user.lastName}'.trim();
  }

  static void clear() {
    accessToken = null;
    username = null;
    email = null;
    fullName = null;
  }
}
