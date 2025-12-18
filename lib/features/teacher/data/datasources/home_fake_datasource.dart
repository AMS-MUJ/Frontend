// home_fake_datasource.dart
import '../models/schedule_model.dart';
import './home_data_source.dart';

class HomeFakeDatasource implements HomeDatasource {
  @override
  Future<List<ScheduleModel>> fetchSchedule() async {
    await Future.delayed(const Duration(seconds: 2));

    return [
      ScheduleModel(
        id: '1',
        subject: 'Data Structure and Algorithms',
        courseCode: 'CSE2101',
        section: 'B',
        time: '10:00 - 11:00',
        room: 'B203',
        status: 'Scheduled',
        totalStudents: 60,
      ),
      ScheduleModel(
        id: '2',
        subject: 'Data Structure and Algorithms',
        courseCode: 'CSE2101',
        section: 'C',
        time: '11:00 - 12:00',
        room: 'B205',
        status: 'Scheduled',
        totalStudents: 60,
      ),
      ScheduleModel(
        id: '3',
        subject: 'Advance Java',
        courseCode: 'CSE2101',
        section: 'C',
        time: '13:00 - 14:00',
        room: 'B005',
        status: 'Scheduled',
        totalStudents: 180,
      ),
      ScheduleModel(
        id: '4',
        subject: 'Blockchain Basics',
        courseCode: 'CSE4202',
        section: 'E',
        time: '16:00 - 16:45',
        room: 'B205',
        status: 'Scheduled',
        totalStudents: 180,
      ),
    ];
  }
}
