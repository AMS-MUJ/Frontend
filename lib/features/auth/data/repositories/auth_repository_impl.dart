// lib/features/auth/data/repositories/auth_repository_impl.dart

import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/auth.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasource/auth_local_data_source.dart';
import '../datasource/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remote;
  final AuthLocalDataSource local;

  AuthRepositoryImpl({required this.remote, required this.local});

  @override
  Future<Either<Failure, Auth>> login({
    required String email,
    required String password,
  }) async {
    try {
      final Auth authModel = await remote.login(
        email: email,
        password: password,
      );
      // Cache the successful auth (token + user + status)
      await local.cacheAuth(
        authModel as dynamic,
      ); // safe: remote returns AuthModel
      return Right(authModel);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } on CacheException catch (e) {
      // Cache failure: still a failure — report it upstream
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Option<Auth>> getSignedInAuth() async {
    try {
      final cached = await local.getCachedAuth();
      if (cached == null) return const None();
      return Some(cached);
    } on CacheException {
      // If cache is corrupted/unreadable, consider the user not signed-in
      return const None();
    } catch (_) {
      return const None();
    }
  }

  @override
  Future<void> logout() async {
    // Clear local cache. If you have a remote logout endpoint, call it here too.
    await local.clear();
  }
}
