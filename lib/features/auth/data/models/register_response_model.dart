import '../../domain/entities/registered_user.dart';

class RegisterResponseModel extends RegisteredUser {
  const RegisterResponseModel({
    required super.id,
    required super.username,
    required super.email,
    required super.firstName,
    required super.lastName,
    required super.country,
    required super.role,
  });

  factory RegisterResponseModel.fromJson(Map<String, dynamic> json) {
    return RegisterResponseModel(
      id: (json['id'] as num? ?? 0).toInt(),
      username: (json['username'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      firstName: (json['firstName'] ?? '').toString(),
      lastName: (json['lastName'] ?? '').toString(),
      country: (json['country'] ?? '').toString(),
      role: (json['role'] ?? '').toString(),
    );
  }
}
