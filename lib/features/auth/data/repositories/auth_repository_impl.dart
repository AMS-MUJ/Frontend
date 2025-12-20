import 'package:ams_try2/core/storage/secure_storage.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/auth.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasource/auth_local_data_source.dart';
import '../datasource/auth_remote_data_source.dart';
import '../models/auth_model.dart';

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
      await secureStorage.write(key: 'token', value: authModel.accessToken);
      await local.cacheAuth(authModel);
      return Right(authModel); // AuthModel extends Auth
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
  Future<Either<Failure, Auth?>> getSignedInAuth() async {
    try {
      final auth = await local.getCachedAuth(); // may be null
      return Right(auth);
    } catch (_) {
      return Left(Failure('Cache read failed'));
    }
  }

  @override
  Future<void> logout() async {
    await local.clear();
    await secureStorage.delete(key: 'token');
  }
}
