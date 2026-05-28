import 'package:ams_try2/core/network/api_routes.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

import './home_data_source.dart';
import '../models/schedule_model.dart';

class HomeRemoteDatasource implements HomeDatasource {
  final Dio dio;

  HomeRemoteDatasource(this.dio);

  @override
  Future<List<ScheduleModel>> fetchSchedule() async {
    final response = await dio.get(ApiRoutes.teacherDashboard);

    debugPrint("Calling api");

    final data = response.data;

    final list = data['classes'];

    if (list == null || list is! List) {
      return [];
    }

    return list.map<ScheduleModel>((e) => ScheduleModel.fromJson(e)).toList();
  }
}
