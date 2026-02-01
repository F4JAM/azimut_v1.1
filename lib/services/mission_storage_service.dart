import 'package:hive_flutter/hive_flutter.dart';
import '../model/mission.dart';

// stockage des données de la mission dans des box Hive
// pour pouvoir si besoin les rétablir plus tard

class MissionStorageService {
  static const String _boxName = 'missionBox';
  static const String _missionKey = 'currentMission';

  static Future<Mission?> restore() async {
    final box = await Hive.openBox<Mission>(_boxName);
    return box.get(_missionKey);
  }

  /// Sauvegarde la mission
  static Future<void> save(Mission mission) async {
    final box = await Hive.openBox<Mission>(_boxName);
    await box.put(_missionKey, mission);
    await box.close();
  }

  /// Supprime la mission sauvegardée
  static Future<void> clear() async {
    final box = await Hive.openBox<Mission>(_boxName);
    await box.delete(_missionKey);
    await box.close();
  }

  /* pour plus tard

  /// Restaure la mission
  static Future<Mission?> restore() async {
    final box = await Hive.openBox<Mission>(_boxName);
    final mission = box.get(_missionKey);
    await box.close();
    return mission;
  }
   */ // fin de pour plus tard
}