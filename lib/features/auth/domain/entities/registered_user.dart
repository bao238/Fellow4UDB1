class RegisteredUser {
  const RegisteredUser({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.country,
    required this.role,
  });

  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String country;
  final String role;
}
