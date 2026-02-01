import '../model/mission.dart';

abstract class MissionExporter {
  Future<void> export(Mission mission);
}
