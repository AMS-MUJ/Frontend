import 'package:ams_try2/features/create_class/domain/entities/section_entity.dart';
import 'package:ams_try2/features/create_class/domain/repository/create_class_repository.dart';

class GetSections {
  final CreateClassRepository repo;

  GetSections(this.repo);

  Future<List<Section>> call(String subjectId) {
    return repo.getSections(subjectId);
  }
}
