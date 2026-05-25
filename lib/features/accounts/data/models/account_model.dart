import '../../domain/entities/account.dart';

class AccountModel extends Account {
  const AccountModel({
    super.id,
    required super.firstName,
    required super.lastName,
    required super.email,
    required super.username,
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      id: (json['id'] as num?)?.toInt(),
      firstName: (json['firstName'] ?? '').toString(),
      lastName: (json['lastName'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      username: (json['username'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson({String? password}) {
    return <String, dynamic>{
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'username': username,
      if (password != null && password.isNotEmpty) 'password': password,
    };
  }
}
