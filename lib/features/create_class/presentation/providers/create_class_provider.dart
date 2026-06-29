import 'package:ams_try2/features/create_class/data/datasources/create_class_remote_ds.dart';
import 'package:ams_try2/features/create_class/data/repositories/create_class_repo_impl.dart';
import 'package:ams_try2/features/create_class/domain/repository/create_class_repository.dart';
import 'package:ams_try2/features/create_class/domain/usecase/create_class_usecase.dart';
import 'package:ams_try2/features/create_class/domain/usecase/get_sections_usecase.dart';
import 'package:ams_try2/features/create_class/domain/usecase/get_subjects_usecase.dart';
import 'package:ams_try2/features/create_class/presentation/providers/create_class_notifier.dart';
import 'package:ams_try2/features/create_class/presentation/providers/create_class_state.dart';
import 'package:ams_try2/core/network/dio_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final createClassRepoProvider = Provider<CreateClassRepository>((ref) {
  final dio = ref.read(dioProvider);
  return CreateClassRepositoryImpl(CreateClassRemoteDSImpl(dio));
});

final createClassNotifierProvider =
    StateNotifierProvider<CreateClassNotifier, CreateClassState>((ref) {
      final repo = ref.read(createClassRepoProvider);
      return CreateClassNotifier(
        GetSubjects(repo),
        GetSections(repo),
        CreatePermanentClass(repo),
        CreateTemporaryClass(repo),
      );
    });
