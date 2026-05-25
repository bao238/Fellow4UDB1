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

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    // Server trả về flat object:
    // { message, accessToken, refreshToken, id, username, email, firstName, lastName, fullName }
    return LoginResponseModel(
      id: (json['id'] as num? ?? 0).toInt(),
      username: (json['username'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      firstName: (json['firstName'] ?? '').toString(),
      lastName: (json['lastName'] ?? '').toString(),
      accessToken: (json['accessToken'] ?? json['token'] ?? '').toString(),
      refreshToken: json['refreshToken']?.toString(),
    );
  }
}
