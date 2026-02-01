import '../model/mission.dart';
import 'mission_exporter.dart';

class _StubExporter implements MissionExporter {
  @override
  Future<void> export(Mission mission) async {
    throw UnsupportedError('No exporter for this platform');
  }
}

final MissionExporter exporter = _StubExporter();