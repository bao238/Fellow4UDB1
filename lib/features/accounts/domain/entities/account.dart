class Account {
  const Account({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.username,
  });

  final int? id;
  final String firstName;
  final String lastName;
  final String email;
  final String username;
}
