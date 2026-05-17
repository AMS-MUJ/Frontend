import '../../domain/entities/user.dart';

class UserModel {
  final String id;
  final String email;
  final String role;
  final String? name;

  UserModel({
    required this.id,
    required this.email,
    required this.role,
    this.name,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }

  /// 🔥 Model → Entity conversion
  User toEntity() {
    return User(id: id, email: email, role: role, name: name);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'email': email, 'role': role, 'name': name};
  }
}
