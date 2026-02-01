import 'package:latlong2/latlong.dart';
import 'package:azimut/model/geo_utils.dart';
import '../app/signal_strength.dart';

/* class représentant un relevé d'azimut à partir de la position courante */
class Tir {

  final LatLng position;
  final double heading;
  final DateTime timestamp;
  final Strength strength;   // enum défini dans signal_strength.dart

  // distance du point projeté pour un tir : 10km
  final double projectedPointDistance = 10000.0;

  // Constructeur standard
  Tir({
    required this.position,
    required this.heading,
    DateTime? timestamp,
    this.strength = Strength.Moyen, // valeur par défaut
  }) : timestamp = timestamp ?? DateTime.now();
       //strength = Strength.Moyen;


  // Constructeur nommé : coordonnées fournie sous forme de deux doubles
  // convertis en LatLng
  Tir.withCoords({
    required double latitude,
    required double longitude,
    required this.heading,
    DateTime? timestamp,
    String? strength
  }): this.position = LatLng(latitude, longitude),
      timestamp = timestamp ?? DateTime.now(),
      strength = Strength.Moyen;


  // construction du point projeté par le tir
  //  utilise computeDestinationPoint de geo_utils.dart
  LatLng get projectedPoint {
    return computeDestinationPoint(position, projectedPointDistance, heading);
  }

  // construction du couple de point [base du tir, point projeté]
  List<LatLng> get line {
    return [position, projectedPoint];
  }

  // pour export JSON
  Map<String, dynamic> toJson() {
    return {
      'latitude': position.latitude,
      'longitude': position.longitude,
      'mgrs': position.toMGRSString(), // sauve aussi la MGRS
      'heading': heading,
      'timestamp': timestamp.toIso8601String(),
      'strength': strength.name,
    };
  }



} // class Tir




