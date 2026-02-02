import '../../domain/entities/user.dart';

class UserModel extends User {
  UserModel({
    required super.id,
    required super.email,
    required super.role,
    super.name,
    super.designation,
  });

  factory UserModel.fromJson(
    Map<String, dynamic> json, {
    Map<String, dynamic>? profileJson,
  }) {
    return UserModel(
      id: json['id'].toString(),
      email: json['email'].toString(),
      role: json['role'].toString(),

      // Optional profile fields (if backend sends them)
      name: profileJson?['name']?.toString(),
      designation:
          profileJson?['designation']?.toString() ??
          profileJson?['Designation']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'role': role,
    'name': name,
    'designation': designation,
  };
}
