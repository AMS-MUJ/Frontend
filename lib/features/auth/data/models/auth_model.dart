import 'user_model.dart';
import '../../domain/entities/auth.dart';

class AuthModel extends Auth {
  AuthModel({
    required String accessToken,
    required UserModel user,
    required AuthStatus status,
  }) : super(accessToken: accessToken, user: user, status: status);

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    final token = json['token']?.toString() ?? '';

    final userJson = json['user'] as Map<String, dynamic>;

    // 🔹 Pick profile block dynamically
    Map<String, dynamic>? profileJson;

    for (final entry in json.entries) {
      if (entry.value is Map<String, dynamic> &&
          entry.key != 'user' &&
          entry.key != 'token') {
        profileJson = entry.value as Map<String, dynamic>;
        break;
      }
    }
    if (json.containsKey('teacher')) {
      profileJson = json['teacher'];
    } else if (json.containsKey('student')) {
      profileJson = json['student'];
    }

    // 2️⃣ FALLBACK: read from user itself (cache case) ✅
    profileJson ??= userJson;

    final userModel = UserModel.fromJson(userJson, profileJson: profileJson);

    return AuthModel(
      accessToken: token,
      user: userModel,
      status: AuthStatus.active,
    );
  }

  Map<String, dynamic> toJson() => {
    'token': accessToken,
    'status': status.name,
    'user': (user as UserModel).toJson(),
  };
}
