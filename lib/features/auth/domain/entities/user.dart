class User {
  final String id;
  final String email;
  final String role;
  final String? name;

  const User({
    required this.id,
    required this.email,
    required this.role,
    this.name,
  });
}
