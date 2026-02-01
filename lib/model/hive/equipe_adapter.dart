/// Hive ne sait pas stocker une Equipe.
/// Il faut un typeAdapter qui va convertir l'Equipe en données gérables
/// l'adapter pour les Equipes a l'ID 3, les autres adapter auront
/// un autre ID, 4,5, ..

import 'package:hive/hive.dart';
import '../equipe.dart';
import '../tir.dart';

class EquipeAdapter extends TypeAdapter<Equipe> {
  @override
  final int typeId = 3; // ⚠️ unique et définitif

  @override
  Equipe read(BinaryReader reader) {
    final equipeId = reader.readString();
    final membres = reader.read().cast<String>();
    final tirs = reader.read().cast<Tir>();

    return Equipe(
      equipeId: equipeId,
      equipeMembres: membres,
      equipeTirs: tirs,
    );
  }

  @override
  void write(BinaryWriter writer, Equipe obj) {
    writer.writeString(obj.equipeId);
    writer.write(obj.equipeMembres);
    writer.write(obj.equipeTirs);
  }
}