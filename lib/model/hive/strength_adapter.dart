/// Hive ne sait pas stocker les enum.
/// Il faut un typeAdapter qui va convertir l'enum, ici Strength
/// en un index, int, pour le stocker dans Hive, puis à la restauration
/// transformer l'int en une valeur de l'enum.
/// l'adapter pour l'enum Strength a l'ID 0, les autres adapter auront
/// un autre ID, 1, 2 ,...


import 'package:hive/hive.dart';
import '../../app/signal_strength.dart';

class StrengthAdapter extends TypeAdapter<Strength> {
  @override
  final int typeId = 0; // unique dans toute l'appli Hive

  @override
  Strength read(BinaryReader reader) {
    final index = reader.readInt();
    return Strength.values[index];
  }

  @override
  void write(BinaryWriter writer, Strength obj) {
    writer.writeInt(obj.index);
  }
}
