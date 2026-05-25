import '../../domain/entities/auth_user.dart';

class LoginResponseModel extends AuthUser {
  const LoginResponseModel({
    required super.id,
    required super.username,
    required super.email,
    required super.firstName,
    required super.lastName,
    required super.accessToken,
    super.refreshToken,
  });

  factory LoginResponseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final rawUser = json['user'];

    final user = rawUser is Map<String, dynamic>
        ? rawUser
        : <String, dynamic>{};

    return LoginResponseModel(
      id: (user['id'] as num? ?? 0).toInt(),

      username: (user['username'] ?? '').toString(),

      email: (user['email'] ?? '').toString(),

      firstName: (user['firstName'] ?? '').toString(),

      lastName: (user['lastName'] ?? '').toString(),

      accessToken: (json['accessToken'] ?? '').toString(),

      refreshToken: json['refreshToken']?.toString(),
    );
  }
}
