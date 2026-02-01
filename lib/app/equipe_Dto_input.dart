import 'package:latlong2/latlong.dart';

/* Data Transfer Object : object servant à ramener les données
 * saisies pour une nouvelle équipe ?
 */

class EquipeDtoInput {
  final String equipeId; // peut être null en mode EM
  final LatLng? position; // peut être null pour une équipe mobile

  EquipeDtoInput({
    required this.equipeId, // pas obligatoire en mode EM
    this.position, // pas obligatoire
  });
}