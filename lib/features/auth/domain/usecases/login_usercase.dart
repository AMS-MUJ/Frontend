import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../entities/auth.dart';
import '../repositories/auth_repository.dart';

class LoginParams {
  final String email;
  final String password;
  const LoginParams({required this.email, required this.password});
}

class LoginUseCase {
  final AuthRepository repository;
  LoginUseCase(this.repository);
  Future<Either<Failure, Auth>> call(LoginParams params) {
    return repository.login(email: params.email, password: params.password);
  }
}
