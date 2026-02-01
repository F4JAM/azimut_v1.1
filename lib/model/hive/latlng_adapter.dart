/// Hive ne sait pas stocker les LatLng
/// Il faut un typeAdapter qui va convertir le LatLng en deux doubles pour le
/// stocker dans Hive, puis à la restauration reconstruire un LatLng.
/// L'adapter pour LatLng a l'ID 1, les autres adapter auront
/// un autre ID : 2 ,...

import 'package:hive/hive.dart';
import 'package:latlong2/latlong.dart';

class LatLngAdapter extends TypeAdapter<LatLng> {
  @override
  final int typeId = 1; // ⚠️ unique et définitif

  @override
  LatLng read(BinaryReader reader) {
    final latitude = reader.readDouble();
    final longitude = reader.readDouble();
    return LatLng(latitude, longitude);
  }

  @override
  void write(BinaryWriter writer, LatLng obj) {
    writer.writeDouble(obj.latitude);
    writer.writeDouble(obj.longitude);
  }
}
