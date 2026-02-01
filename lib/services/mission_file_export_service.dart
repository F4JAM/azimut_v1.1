// pour création du fichier contenant le JSON pour export
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../model/mission.dart';
import 'mission_export_service.dart';

class MissionFileExportService {
  static Future<File> exportMissionToFile(Mission mission) async {
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');

    final file = File(
      '${directory.path}/mission_$timestamp.json',
    );

    final jsonString =
    MissionExportService.exportToJson(mission);

    return file.writeAsString(jsonString);
  }
}