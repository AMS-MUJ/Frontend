import 'user_model.dart';
import '../../domain/entities/auth.dart';

class AuthModel extends Auth {
  AuthModel({
    required String accessToken,
    required UserModel user,
    required AuthStatus status,
  }) : super(accessToken: accessToken, user: user, status: status);

  /// Convert backend JSON → AuthModel
  factory AuthModel.fromJson(Map<String, dynamic> json) {
    // Token field (support common alternatives)
    final token =
        (json['token'] ?? json['access_token'] ?? json['jwt'])?.toString() ??
        '';

    // Role may be inside "user" or top-level
    final role = (json['role'] ?? json['user']?['role'] ?? 'student')
        .toString();

    // Build UserModel (use nested json if available)
    final userJson =
        (json['user'] as Map<String, dynamic>?) ??
        {
          'id': json['user_id'],
          'email': json['email'],
          'name': json['name'],
          'role': role,
        };

    final userModel = UserModel.fromJson(userJson);

    // Map backend status string → enum
    final statusStr = (json['status'] ?? '').toString().toLowerCase();
    final status = statusStr == 'approved' || statusStr == 'active'
        ? AuthStatus.active
        : statusStr == 'pending'
        ? AuthStatus.pendingVerification
        : statusStr == 'suspended'
        ? AuthStatus.suspended
        : AuthStatus.unknown;

    return AuthModel(accessToken: token, user: userModel, status: status);
  }

  /// Convert back to JSON for secure storage
  Map<String, dynamic> toJson() => {
    'token': accessToken,
    'status': status.toString(),
    'user': (user as UserModel).toJson(),
  };
}
