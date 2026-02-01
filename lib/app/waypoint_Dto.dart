import 'package:latlong2/latlong.dart';

/* Data Transfer Object : object servant à ramener les données
 * saisies pour un waypoint
 */

class WaypointDTO {
  final String? equipeId;  // pas obligatoire en mode EM : une seule équipe
  final LatLng position;

  WaypointDTO({
    this.equipeId,
    required this.position,
  });
}