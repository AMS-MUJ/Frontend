import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../entities/auth.dart';

abstract interface class AuthRepository {
  Future<Either<Failure, Auth>> login({
    required String email,
    required String password,
  });

  Future<Option<Auth>> getSignedInAuth();

  Future<void> logout();
}
