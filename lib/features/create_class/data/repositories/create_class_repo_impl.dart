import 'package:ams_try2/features/create_class/data/datasources/create_class_remote_ds.dart';
import 'package:ams_try2/features/create_class/domain/entities/section_entity.dart';
import 'package:ams_try2/features/create_class/domain/entities/subject_entity.dart';
import 'package:ams_try2/features/create_class/domain/repository/create_class_repository.dart';

class CreateClassRepositoryImpl implements CreateClassRepository {
  final CreateClassRemoteDataSource remote;

  CreateClassRepositoryImpl(this.remote);

  @override
  Future<List<Subject>> getSubjects(int year, String branch) async {
    final models = await remote.getSubjects(year, branch);
    return models.map((m) => Subject(name: m.name)).toList();
  }

  @override
  Future<List<Section>> getSections(String courseName, String branch) async {
    final models = await remote.getSections(courseName, branch);
    return models.map((m) => Section(name: m.name)).toList();
  }

  @override
  Future<void> createPermanentClass(Map<String, dynamic> payload) {
    return remote.createPermanentClass(payload);
  }

  @override
  Future<void> createTemporaryClass(Map<String, dynamic> payload) {
    return remote.createTemporaryClass(payload);
  }
}
