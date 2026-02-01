import '../model/mission.dart';
import 'mission_exporter.dart';
import 'mission_web_export_service.dart';

class _WebExporter implements MissionExporter {
  @override
  Future<void> export(Mission mission) async {
    MissionWebExportService.downloadJson(mission);
  }
}

final MissionExporter exporter = _WebExporter();