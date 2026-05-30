import 'package:ams_try2/core/network/api_routes.dart';
import 'package:ams_try2/features/create_class/data/models/section_model.dart';
import 'package:ams_try2/features/create_class/data/models/subject_model.dart';
import 'package:dio/dio.dart';

abstract class CreateClassRemoteDataSource {
  Future<List<SubjectModel>> getSubjects(int year);

  Future<List<SectionModel>> getSections(String subjectId);

  Future<void> createPermanentClass(Map<String, dynamic> payload);

  Future<void> createTemporaryClass(Map<String, dynamic> payload);
}

class CreateClassRemoteDSImpl implements CreateClassRemoteDataSource {
  final Dio dio;

  CreateClassRemoteDSImpl(this.dio);

  @override
  Future<List<SubjectModel>> getSubjects(int year) async {
    final response = await dio.get(
      ApiRoutes.getSubjects,
      queryParameters: {'year': year},
    );
    final list = response.data['subjects'] as List;
    return list.map((e) => SubjectModel.fromJson(e)).toList();
  }

  @override
  Future<List<SectionModel>> getSections(String subjectId) async {
    final response = await dio.get(
      ApiRoutes.getSections,
      queryParameters: {'subject_id': subjectId},
    );
    return (response.data['sections'] as List)
        .map((e) => SectionModel.fromJson(e))
        .toList();
  }

  @override
  Future<void> createPermanentClass(Map<String, dynamic> payload) async {
    await dio.post(ApiRoutes.createPermanentClass, data: payload);
  }

  @override
  Future<void> createTemporaryClass(Map<String, dynamic> payload) async {
    await dio.post(ApiRoutes.createTemporaryClass, data: payload);
  }
}
