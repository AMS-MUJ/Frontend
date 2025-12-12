import 'user.dart';

enum AuthStatus { active, pendingVerification, suspended, unknown }

class Auth {
  final String accessToken;
  final User user;
  final AuthStatus status;

  Auth({
    required this.accessToken,
    required this.user,
    this.status = AuthStatus.active,
  });
}
