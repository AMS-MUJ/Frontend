import 'package:ams_try2/features/create_class/domain/entities/subject_entity.dart';
import 'package:ams_try2/features/create_class/domain/repository/create_class_repository.dart';

class GetSubjects {
  final CreateClassRepository repo;

  GetSubjects(this.repo);

  Future<List<Subject>> call(int year) {
    return repo.getSubjects(year);
  }
}
