/// Hive ne sait pas stocker une Mission.
/// Il faut un typeAdapter qui va convertir la Mission en données gérables
/// l'adapter pour les Equipes a l'ID 4, les autres adapter auront
/// un autre ID, 5, 6 ..

import 'package:hive/hive.dart';
import '../mission.dart';
import '../equipe.dart';
import '../../app/app_role.dart';
class MissionAdapter extends TypeAdapter<Mission> {
  @override
  final int typeId = 4; // ⚠️ unique et définitif

  @override
  Mission read(BinaryReader reader) {
    final role = AppRole.values[reader.readInt()];
    final equipes = reader.read().cast<Equipe>();
    return Mission. fromHive(
        role: role,
        equipes: equipes,);
  }

  @override
  void write(BinaryWriter writer, Mission obj) {
    writer.writeInt(obj.role.index);
    writer.write(obj.equipes);
  }
}
