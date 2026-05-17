class Auth {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final String id;
  final String name;
  final String email;
  final String role;

  Auth({
    required this.accessToken,
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.refreshToken,
    required this.tokenType,
  });
}
