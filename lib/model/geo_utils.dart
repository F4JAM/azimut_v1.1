import 'dart:math';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' as latlong2;
import 'package:geoengine/geoengine.dart' as geoengine;

/*
latlong2 utilise un LatLng(latitude, longitude) avec ses properties .latitude and .longitude.
geoengine utilise aussi un LatLng(latitude, longitude) avec les même noms de propriétés !
Mais ça n'est pas les mêmes objets -> il faut donner des alias pour faire la différence.

L'extension de la class LatLong2 ci-dessous permet d'utiliser la méthode toMGRS() de geoengine
avec un objet de la class Latlong2.
Usage : unPointLatLong2.toMGRSString()
Il faut lire "final geoLatLng = geoengine.LatLng(latitude, longitude);" comme 
"final geoLatLng = geoengine.LatLng(this.latitude, this.longitude);". On est dans la class LatLong2.
*/

extension LatLong2Mgrsextension on latlong2.LatLng {
  /// Convert latlong2.LatLng to MGRS string
  String toMGRSString() {
    final geoLatLng = geoengine.LatLng(latitude, longitude);
    return geoLatLng.toMGRS().toString();
  }
}


/* Calcule la position d'un point situé à distanceMeters du point start à l'angle bearingDegrees
*/
latlong2.LatLng computeDestinationPoint(latlong2.LatLng start, double distanceMeters, double bearingDegrees) {
  const earthRadius = 6371000.0; // m

  ///déclinaison Allériot 12/2025 : 2.67° E +/- 0.36°
  ///NON ACTIVEE : EST ou OUEST, + ou -  ? !!!
  final declinaisonDeg = 2.67;
  //double bearingTrue = (bearingDegrees + declinaisonDeg)%360;
  //if (bearingTrue  < 0) bearing += 360.0;

  //final bearingRad = (bearingDegrees + declinaisonDeg)%360 * pi / 180.0;
  final bearingRad = bearingDegrees * pi /180.0;
  final lat1 = start.latitude * pi / 180.0;
  final lon1 = start.longitude * pi / 180.0;

  final lat2 = asin(sin(lat1) * cos(distanceMeters / earthRadius) +
      cos(lat1) * sin(distanceMeters / earthRadius) * cos(bearingRad));

  final lon2 = lon1 +
      atan2(
        sin(bearingRad) * sin(distanceMeters / earthRadius) * cos(lat1),
        cos(distanceMeters / earthRadius) - sin(lat1) * sin(lat2),
      );

  return latlong2.LatLng(lat2 * 180.0 / pi, lon2 * 180.0 / pi);
}

/* Renvoie la coordonnées MGRS du point latlong2
 * Utilise l'extension de class
 */

String MGRS (latlong2.LatLng point) {
  return point.toMGRSString();
}

/* Génération d'une MGRS avec une précision de 100m : 2x3 digits pour le easting et northing
 * à partir de la MGRS complète sous forme de String
 */
String MGRS_100m(String mgrsString) {

  final parts = mgrsString.split(' '); // ['31U', 'DQ', '48251', '11932']
  
  final zone         =  parts[0];
  final square_100km =  parts[1];
  final eastingStr   =  parts[2];  // '48251'
  final northingStr  =  parts[3]; // '11932'

  // réduction à 3 digits
  final easting = (int.parse(eastingStr) / 100).round();
  final northing = (int.parse(northingStr) / 100).round();

  final eastingStrPadded = easting.toString().padLeft(3, '0');
  final northingStrPadded = northing.toString().padLeft(3, '0');

  
  return '${zone} ${square_100km} ${eastingStrPadded} ${northingStrPadded}';
} // MGRS_100m

/* Conversion d'une MGRS saisie avec 2x3 digit (100m) en un LatLong
 * Modèle à transmettre : [32T, FJ, 525 335]
 * ajoute deux '00' pour passer en métrique
 */
latlong2.LatLng Mgrs_100mToLatLng (mgrsString) {
  final parts = mgrsString.split(' ');

  final zone         =  parts[0];
  final square_100km =  parts[1];
  //final eastingStr   =  (double.parse(parts[2])*100); // '483OO'
  //final northingStr  =  (double.parse(parts[3])*100); // '11900'
  final eastingStr = parts[2]+'00';
  final northingStr  = parts[3]+'00';

  final mgrsFull = '${zone} ${square_100km} ${eastingStr} ${northingStr}';

  var mgrsRef = geoengine.MGRS.parse(mgrsFull);
  var utm = mgrsRef.toUTM();
  debugPrint('🧭 conversion dans geo_utils ${utm}');
  final ltln = utm.toLatLng();

 //final position = latlong2.LatLng (ltln.lat, ltln.lng);
  return( latlong2.LatLng (ltln.lat, ltln.lng));
} // Mgrs_100mToLatLng
