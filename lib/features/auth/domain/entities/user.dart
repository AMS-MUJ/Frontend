class User {
  final String id;
  final String email;
  final String role;

  // Optional profile fields (role-agnostic)
  final String? name;
  final String? designation;

  const User({
    required this.id,
    required this.email,
    required this.role,
    this.name,
    this.designation,
  });
}
