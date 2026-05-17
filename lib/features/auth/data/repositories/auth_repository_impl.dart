import 'package:ams_try2/core/error/failure.dart';
import 'package:ams_try2/features/auth/data/datasource/auth_remote_data_source.dart';
import 'package:ams_try2/features/auth/data/models/auth_model.dart';
import 'package:ams_try2/features/auth/domain/entities/auth.dart';
import 'package:ams_try2/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ams_try2/features/auth/data/datasource/auth_local_data_source.dart';

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
      final AuthModel authModel = await remote.login(
        email: email,
        password: password,
      );

      /// Single source of truth (local handles token + user)
      debugPrint('CALLING cacheAuth');
      await local.cacheAuth(authModel);

      return Right(authModel.toEntity());
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } on CacheException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Auth?>> getSignedInAuth() async {
    try {
      final auth = await local.getCachedAuth();
      return Right(auth?.toEntity());
    } catch (_) {
      return Left(Failure('Cache read failed'));
    }
  }

  @override
  Future<void> logout() async {
    /// ✅ Local handles everything (token + user)
    await local.clear();
  }
}
