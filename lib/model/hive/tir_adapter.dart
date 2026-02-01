/// Hive ne sait pas stocker des Tirs.
/// Il faut un typeAdapter qui va convertir le Tir en données gérables
/// l'adapter pour le Tir a l'ID 2, les autres adapter auront
/// un autre ID, 3, 4,...

import 'package:hive/hive.dart';
import '../tir.dart';

class TirAdapter extends TypeAdapter<Tir> {
  @override
  final int typeId = 2; // ⚠️ unique et définitif

  @override
  Tir read(BinaryReader reader) {
    final position = reader.read();   // LatLng
    final heading = reader.readDouble();
    final timestamp = reader.read();  // DateTime
    final strength = reader.read();   // Strength

    return Tir(
      position: position,
      heading: heading,
      timestamp: timestamp,
      strength: strength,
    );
  }

  @override
  void write(BinaryWriter writer, Tir obj) {
    writer.write(obj.position);
    writer.writeDouble(obj.heading);
    writer.write(obj.timestamp);   // DateTime
    writer.write(obj.strength);
  }
}