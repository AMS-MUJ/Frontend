import '../../domain/entities/auth.dart';

class AuthModel {
  final String accessToken;
  final String refreshToken;
  final String tokenType;

  final String id;
  final String name;
  final String email;
  final String role;

  AuthModel({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>;

    return AuthModel(
      accessToken: json['access_token'] ?? '',
      refreshToken: json['refresh_token'] ?? '',
      tokenType: json['token_type'] ?? 'bearer',

      id: user['id'] ?? '',
      name: user['name'] ?? '',
      email: user['email'] ?? '',
      role: user['role'] ?? '',
    );
  }

  /// Model → Entity
  Auth toEntity() {
    return Auth(
      accessToken: accessToken,
      refreshToken: refreshToken,
      tokenType: tokenType,

      id: id,
      name: name,
      email: email,
      role: role,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'token_type': tokenType,

      'user': {'id': id, 'name': name, 'email': email, 'role': role},
    };
  }
}
