import 'package:ams_try2/features/teacher/data/datasources/home_data_source.dart';
import 'package:ams_try2/features/teacher/domain/entities/schedule.dart';
import 'package:ams_try2/features/teacher/domain/repository/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeDatasource datasource;

  HomeRepositoryImpl(this.datasource);

  @override
  Future<List<Schedule>> getTodaySchedule() async {
    final models = await datasource.fetchSchedule();
    return models
        .map(
          (m) => Schedule(
            subject: m.subject,
            courseCode: m.courseCode,
            section: m.section,
            time: m.time,
            room: m.room,
            totalStudents: m.totalStudents,
          ),
        )
        .toList();
  }
}
