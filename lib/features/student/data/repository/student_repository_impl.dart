import 'package:ams_try2/features/student/data/model/student_schedule_model.dart';
import 'package:ams_try2/features/student/domain/entities/student_schedule.dart';

import '../../domain/repository/student_repository.dart';
import '../datasource/student_remote_datasource.dart';

class StudentRepositoryImpl implements StudentRepository {
  final StudentRemoteDatasource datasource;

  StudentRepositoryImpl(this.datasource);

  @override
  Future<List<StudentSchedule>> getTodaySchedule() async {
    final response = await datasource.getStudentHome();

    final List<dynamic> schedule = response['schedule'] as List<dynamic>;

    return schedule
        .map((e) => StudentScheduleModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
