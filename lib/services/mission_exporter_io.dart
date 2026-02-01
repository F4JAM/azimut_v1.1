import 'package:share_plus/share_plus.dart';

import '../model/mission.dart';
import 'mission_exporter.dart';
import 'mission_file_export_service.dart';

class _IoExporter implements MissionExporter {
  @override
  Future<void> export(Mission mission) async {
    final file = await MissionFileExportService.exportMissionToFile(mission);
    await Share.shareXFiles([XFile(file.path)], text: 'Export mission JSON');
  }
}

final MissionExporter exporter = _IoExporter();