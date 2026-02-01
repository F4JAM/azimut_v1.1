import 'package:latlong2/latlong.dart';

/* class représentant un relevé d'azimut à partir de la position courante */
class Waypoint {

  final LatLng position;
  final String equipeId;
  final DateTime timestamp;
  String source = ""; // PC ou EM

  // Constructeur standard
  Waypoint({
    required this.position,
    required this.equipeId,
    DateTime? timestamp,
    String? source,
  }) : timestamp = timestamp ?? DateTime.now();
}