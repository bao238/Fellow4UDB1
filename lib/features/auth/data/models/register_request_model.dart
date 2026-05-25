class RegisterRequestModel {
  const RegisterRequestModel({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.username,
    required this.password,
    required this.country,
    required this.role,
  });

  final String firstName;
  final String lastName;
  final String email;
  final String username;
  final String password;
  final String country;
  final String role;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'username': username,
      'password': password,
      'country': country,
      'role': role,
    };
  }
}
