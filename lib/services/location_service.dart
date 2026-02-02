/* localisation service : sortie de la logique d'initialisation et
 * utilisation du GPS de la logique de gestion de la carte OSM. Voir en bas
 * comment utiliser le service dans mission_map.dart
 * oloobo  2025_12_11
 */

import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class LocationService {
  LocationService._privateConstructor();
  static final LocationService instance = LocationService._privateConstructor();

  final LocationSettings _locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 50,
  );

  /// Vérifie GPS + permission, puis retourne la position initiale.
  Future<LatLng> determinePosition() async {
    // 1. GPS activé ?
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      throw Exception('Le GPS n’est pas activé');
    }

    // 2. Permission ?
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Permission GPS refusée');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
      throw Exception("Permission GPS refusée définitivement");
    }

    // 3. Obtenir la position
    final pos = await Geolocator.getCurrentPosition(
      locationSettings: _locationSettings,
    );

    return LatLng(pos.latitude, pos.longitude);
  }

  /// Stream de positions en temps réel
  Stream<LatLng> getPositionStream() {
    return Geolocator.getPositionStream(locationSettings: _locationSettings)
        .map((pos) => LatLng(pos.latitude, pos.longitude));
  }
}
