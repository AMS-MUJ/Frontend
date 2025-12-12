import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/auth.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_usercase.dart';

/// Simple immutable state for authentication
class AuthState {
  final bool loading;
  final Auth? auth;
  final Failure? failure;

  const AuthState({this.loading = false, this.auth, this.failure});

  AuthState copyWith({bool? loading, Auth? auth, Failure? failure}) {
    return AuthState(
      loading: loading ?? this.loading,
      auth: auth ?? this.auth,
      failure: failure,
    );
  }
}

/// StateNotifier that performs login and holds auth state.
///
/// It depends on:
///  - [LoginUseCase] for performing login
///  - [AuthRepository] for checking cached auth & logout
class AuthNotifier extends StateNotifier<AuthState> {
  final LoginUseCase loginUseCase;
  final AuthRepository repository;

  AuthNotifier({required this.loginUseCase, required this.repository})
    : super(const AuthState());

  /// Perform login with email & password.
  /// On success the state.auth will be set to the returned Auth.
  Future<void> login(String email, String password) async {
    state = state.copyWith(loading: true, failure: null);

    final result = await loginUseCase(
      LoginParams(email: email.trim(), password: password.trim()),
    );

    result.match(
      (Failure f) {
        state = state.copyWith(loading: false, failure: f);
      },
      (Auth a) {
        state = state.copyWith(loading: false, auth: a, failure: null);
      },
    );
  }

  /// Try to load cached (signed-in) auth from local storage.
  /// Use this at app startup to restore session.
  Future<void> loadCachedAuth() async {
    state = state.copyWith(loading: true, failure: null);
    try {
      final opt = await repository.getSignedInAuth();
      opt.match(
        () {
          // None -> not signed in
          state = state.copyWith(loading: false, auth: null);
        },
        (Auth a) {
          state = state.copyWith(loading: false, auth: a, failure: null);
        },
      );
    } catch (e) {
      // treat as no cached auth (do not crash the app)
      state = state.copyWith(loading: false, auth: null);
    }
  }

  /// Logout: clear remote/local (repo.logout) and reset in-memory state.
  Future<void> logout() async {
    await repository.logout();
    state = const AuthState();
  }
}

/// Provider placeholder — override this in main.dart with a real instance.
/// Example override in main:
/// authNotifierProvider.overrideWithValue(AuthNotifier(loginUseCase: loginUseCase, repository: repo))
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((
  ref,
) {
  throw UnimplementedError(
    'Provide AuthNotifier with LoginUseCase and AuthRepository in ProviderScope overrides.',
  );
});
