import 'dart:convert';
import '../model/mission.dart';


// pour exporter du JSON
class MissionExportService {
  static String exportToJson(Mission mission) {
    final map = mission.toJson();
    return const JsonEncoder.withIndent('  ').convert(map);
  }
}
