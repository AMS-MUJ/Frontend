import 'package:ams_try2/features/create_class/domain/entities/section_entity.dart';
import 'package:ams_try2/features/create_class/domain/entities/subject_entity.dart';

abstract class CreateClassRepository {
  Future<List<Subject>> getSubjects(int year, String branch);

  Future<List<Section>> getSections(String courseName, String branch);

  Future<void> createPermanentClass(Map<String, dynamic> payload);
  Future<void> createTemporaryClass(Map<String, dynamic> payload);
}
